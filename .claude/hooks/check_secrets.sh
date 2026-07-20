#!/bin/bash

###############################################################################
# Secret Scanner - Detects hardcoded API keys and secrets in Flutter projects
# Runs as a PreToolUse hook to block Edit/Write operations that contain secrets.
###############################################################################

set -euo pipefail

# Read hook input from stdin
input=$(cat)

# Extract tool info
tool_name=$(echo "$input" | jq -r '.tool_name')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only check .dart files
if [[ -z "$file_path" || "$file_path" != *.dart ]]; then
  exit 0
fi

# Extract the content being written
if [ "$tool_name" = "Write" ]; then
  content=$(echo "$input" | jq -r '.tool_input.content // empty')
elif [ "$tool_name" = "Edit" ]; then
  content=$(echo "$input" | jq -r '.tool_input.new_string // empty')
else
  exit 0
fi

# Skip if no content
if [ -z "$content" ]; then
  exit 0
fi

# Write content to temp file
tmp_content=$(mktemp)
trap 'rm -f "$tmp_content"' EXIT
echo "$content" > "$tmp_content"

violations=()

# Pattern 1: AWS Access Key
# Exclude templates (X's, 0's) and placeholders
if grep -qE "AKIA[0-9A-Z]{16}" "$tmp_content" 2>/dev/null; then
  if ! grep -qE "AKIAX{16}" "$tmp_content"; then
    violations+=("HARDCODED AWS ACCESS KEY: Detected AWS access key pattern (AKIA*) in the code. This should be in environment variables.")
  fi
fi

# Pattern 2: GitHub Token
if grep -qE "(ghp_|gho_|ghu_|ghs_|ghr_)[A-Za-z0-9_]{36,}" "$tmp_content" 2>/dev/null; then
  violations+=("HARDCODED GITHUB TOKEN: Detected GitHub token pattern in the code. This should be in environment variables.")
fi

# Pattern 3: Stripe Keys
# Exclude templates (X's) and placeholders
if grep -qE "(pk_|sk_)live_[0-9a-zA-Z]{24,}" "$tmp_content" 2>/dev/null; then
  if ! grep -qE "(pk_|sk_)live_X+" "$tmp_content"; then
    violations+=("HARDCODED STRIPE API KEY: Detected Stripe live API key in the code. This should be in environment variables.")
  fi
fi

# Pattern 4: API Key assignments
if grep -qiE "apikey|api_key" "$tmp_content" 2>/dev/null; then
  if grep -qiE "['\"].*?(api_key|apikey).*?['\"].*=.*['\"][^'\"]{15,}['\"]" "$tmp_content" 2>/dev/null; then
    if ! grep -qiE "placeholder|example|XXX|\.\.\.|YOUR_" "$tmp_content"; then
      violations+=("HARDCODED API KEY: Detected hardcoded API key assignment. Use environment variables instead.")
    fi
  fi
fi

# Pattern 5: Secret/Password assignments
# Check for lines containing password/secret keywords with long string values
# Exclude: templates, field names, UI labels, demo data
if grep -qiE "(password|secret|credential|private_key|client_secret).*=\s*['\"][A-Za-z0-9_]{8,}['\"]" "$tmp_content" 2>/dev/null; then
  # Exclude templates, field names, demo data, UI strings
  if ! grep -qiE "placeholder|example|XXX|\.\.\.|YOUR_|test|demo|sample|fake|template|field|label|text|enter|input|form|passwordField|secretField" "$tmp_content"; then
    violations+=("HARDCODED SECRET/PASSWORD: Detected hardcoded secret or password. Use environment variables instead.")
  fi
fi

# Pattern 6: Token assignments (JWT, bearer, etc.)
if grep -qiE "token|access_token|auth_token|jwt_token|bearer_token" "$tmp_content" 2>/dev/null; then
  if grep -qiE "['\"].*?(token).*?['\"].*=.*['\"][^'\"]{20,}['\"]" "$tmp_content" 2>/dev/null; then
    if ! grep -qiE "placeholder|example|XXX|\.\.\.|YOUR_" "$tmp_content"; then
      violations+=("HARDCODED AUTH TOKEN: Detected hardcoded authentication token. Use environment variables instead.")
    fi
  fi
fi

# Pattern 7: Long base64-like strings (likely keys)
if grep -qE "['\"][A-Za-z0-9+/]{40,}={0,2}['\"]" "$tmp_content" 2>/dev/null; then
  if ! grep -qiE "placeholder|example|XXX|\.\.\.|YOUR_|certificate|public" "$tmp_content"; then
    violations+=("SUSPICIOUS BASE64 STRING: Detected long base64-encoded string that may be a hardcoded key. Use environment variables instead.")
  fi
fi

# --- Report results ---
if [ ${#violations[@]} -gt 0 ]; then
  reason="SECURITY VIOLATION: Hardcoded secrets detected in $file_path"$'\n\n'
  for v in "${violations[@]}"; do
    reason+="- $v"$'\n\n'
  done
  reason+=$'\n'
  reason+="📖 How to Fix:"$'\n\n'
  reason+="1. Move secrets to .env file:"$'\n'
  reason+="   echo 'YOUR_API_KEY=actual_key_here' >> .env"$'\n\n'
  reason+="2. Add to lib/core/constants/env.dart:"$'\n'
  reason+="   static String? yourApiKey = dotenv.env['YOUR_API_KEY'];"$'\n\n'
  reason+="3. Use in code:"$'\n'
  reason+="   final apiKey = Env.yourApiKey ?? '';"$'\n\n'
  reason+="4. Remove the hardcoded value from your Dart file"$'\n'
  reason+="Fix ALL violations above and retry."

  jq -n --arg reason "$reason" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": $reason
    }
  }'
  exit 0
fi

# No violations — allow the tool call
exit 0
