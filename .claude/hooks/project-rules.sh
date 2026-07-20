#!/bin/bash
#
# Project-Specific Rules Hook (Ajovia)
# Rules specific to this project's clean architecture, BLoC patterns,
# design system, and coding conventions from AI_DEVELOPMENT_GUIDE.md.
#
# Compatible with macOS (BSD grep) — uses grep -E, not grep -P.
#

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

# Exclude test/solid/features directory (contains intentional violation test files)
if [[ "$file_path" =~ test/solid/features/ ]]; then
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

# Helpers
filename=$(basename "$file_path")

is_bloc_file=false
if [[ "$filename" == *_bloc.dart || "$filename" == *_cubit.dart ]]; then
  is_bloc_file=true
fi

is_domain_file=false
if [[ "$file_path" == */domain/* ]]; then
  is_domain_file=true
fi

is_theme_file=false
if [[ "$file_path" == */core/theme/* || "$file_path" == */core/widgets/app_colors.dart || "$file_path" == */core/widgets/app_spacing.dart || "$file_path" == */core/widgets/app_text.dart ]]; then
  is_theme_file=true
fi

is_presentation_file=false
if [[ "$file_path" == */features/*/widgets/* || "$file_path" == */features/*/*_screen.dart || "$file_path" == */presentation/* ]]; then
  is_presentation_file=true
fi

is_feature_screen_file=false
if [[ "$file_path" == */features/*/*.dart && ! "$file_path" == */widgets/* ]]; then
  is_feature_screen_file=true
fi

is_generated_file=false
if [[ "$filename" == *.g.dart || "$filename" == *.gr.dart || "$filename" == *.freezed.dart || "$filename" == *.config.dart ]]; then
  is_generated_file=true
fi

# Skip generated files entirely
if [ "$is_generated_file" = true ]; then
  exit 0
fi

violations=()

# ============================================================
# RULE P1: No Navigator/showDialog in BLoC
# Use state-based navigation; emit navigation state, handle
# in the page's BlocListener.
# ============================================================
if [ "$is_bloc_file" = true ]; then
  matches=$(echo "$content" | grep -E 'Navigator\.(push|pop|pushReplacement|pushNamed|pushAndRemoveUntil)|showDialog|showModalBottomSheet|showBottomSheet|showSnackBar|context\.router\.' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P1 - No Navigator/showDialog in BLoC: Use state-based navigation. Emit a navigation action in state, handle it in the page's BlocListener. Detected: $matches")
  fi
fi

# ============================================================
# RULE P2: No BuildContext in BLoC
# Pass data via events/state, not context.
# ============================================================
if [ "$is_bloc_file" = true ]; then
  matches=$(echo "$content" | grep -E 'BuildContext\s+\w+' | grep -v 'Emitter<' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P2 - No BuildContext in BLoC: BLoC must not depend on BuildContext. Pass data via events and expose it through state. Detected: $matches")
  fi
fi

# ============================================================
# RULE P3: No hardcoded colors — use AppColors
# File: lib/core/theme/app_colors.dart
# e.g., AppColors.primary, AppColors.textPrimary, AppColors.error
# ============================================================
if [ "$is_theme_file" = false ]; then
  matches=$(echo "$content" | grep -E 'Color\(0x[0-9a-fA-F]+\)|Colors\.[a-zA-Z]+' | grep -v '// ignore-rule' | grep -v 'AppColor' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P3 - No hardcoded colors: Use AppColors constants from lib/core/theme/app_colors.dart (e.g., AppColors.primary, AppColors.textPrimary, AppColors.error). If a color variation doesn't exist, add it to AppColors. Detected: $matches")
  fi
fi

# ============================================================
# RULE P4: Domain layer must not import from data or presentation
# Domain is the innermost layer — no outward dependencies.
# ============================================================
if [ "$is_domain_file" = true ]; then
  matches=$(echo "$content" | grep -E "import\s+'.*/(data|presentation)/" || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P4 - Domain layer isolation: Domain must NEVER import from data/ or presentation/ layers. Domain is the innermost layer with no outward dependencies. Detected: $matches")
  fi
fi

# ============================================================
# RULE P5: No direct API/Dio calls in BLoC
# Use repositories and use cases instead.
# ============================================================
if [ "$is_bloc_file" = true ]; then
  matches=$(echo "$content" | grep -E '\bdio\.(get|post|put|patch|delete|request)\b|http\.(get|post|put|patch|delete)\b|Dio\(\)|FirebaseFirestore\.instance|FirebaseAuth\.instance|FirebaseStorage\.instance' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P5 - No direct API/Firebase calls in BLoC: Use repositories and use cases for data fetching, not direct Dio/HTTP/Firebase calls. Detected: $matches")
  fi
fi

# ============================================================
# RULE P6: No setState in BLoC
# BLoC files must use emit() to update state, never setState.
# ============================================================
if [ "$is_bloc_file" = true ]; then
  matches=$(echo "$content" | grep -E '\bsetState\s*\(' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P6 - No setState in BLoC: BLoC must use emit() to update state, not setState(). setState is for StatefulWidget only. Detected: $matches")
  fi
fi

# ============================================================
# RULE P7: No commonly used hardcoded spacing — use AppSpacing
# File: lib/core/widgets/app_spacing.dart
# Only block common sizes (4, 8, 12, 16, 20, 24, 32) to avoid false positives
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  # Only block commonly used spacing sizes: 4, 8, 12, 16, 20, 24, 32
  matches=$(echo "$content" | grep -E 'SizedBox\s*\(\s*(height|width)\s*:\s*(4|8|12|16|20|24|32)\b' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P7 - No commonly used hardcoded spacing: Use AppSpacing from lib/core/widgets/app_spacing.dart (e.g., AppSpacing.vGap16, AppSpacing.hGap8). Common sizes: 4, 8, 12, 16, 20, 24, 32. Detected: $matches")
  fi
fi

# ============================================================
# RULE P8: Presentation layer must not import from data layer
# Presentation can import from domain, not data directly.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  matches=$(echo "$content" | grep -E "import\s+'.*/(data)/(datasources|repositories|models)/" || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P8 - Presentation must not import from data layer: Presentation can import from domain layer only, not directly from data/datasources, data/repositories, or data/models. Use domain entities and repository interfaces. Detected: $matches")
  fi
fi

# ============================================================
# RULE P9: No hardcoded border radius — use AppRadius
# File: lib/core/theme/app_radius.dart
# e.g., AppRadius.md, AppRadius.lg, AppRadius.pill
# ============================================================
if [ "$is_theme_file" = false ]; then
  matches=$(echo "$content" | grep -E 'BorderRadius\.circular\s*\(\s*[0-9]' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P9 - No hardcoded border radius: Use AppRadius constants from lib/core/theme/app_radius.dart (e.g., AppRadius.md, AppRadius.lg, AppRadius.pill). If a radius doesn't exist, add it to AppRadius. Detected: $matches")
  fi
fi

# ============================================================
# RULE P10: No raw Text widget — use AppText
# File: lib/core/widgets/app_text.dart
# e.g., AppText('Hello', variant: TextVariant.bodyMedium)
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  # Check for Text( but not AppText(, RichText(, Text.rich(, DefaultTextStyle(
  matches=$(echo "$content" | grep -E '^\s*Text\(' | grep -v 'AppText\|RichText\|Text\.rich\|DefaultTextStyle\|// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P10 - No raw Text widget: Use AppText with TextVariant from lib/core/widgets/app_text.dart (e.g., AppText('Hello', variant: TextVariant.bodyMedium)). Detected: $matches")
  fi
fi

# ============================================================
# RULE P11: No raw ElevatedButton/TextButton — use AppButton
# File: lib/core/widgets/app_button.dart
# e.g., AppButton.primary(...), AppButton.secondary(...)
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  matches=$(echo "$content" | grep -E '\b(ElevatedButton|TextButton|OutlinedButton)\s*\(' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P11 - No raw button widgets: Use AppButton variants from lib/core/widgets/app_button.dart (e.g., AppButton.primary(...), AppButton.secondary(...), AppButton.outline(...)). Detected: $matches")
  fi
fi

# ============================================================
# RULE P12: No raw TextField — use AppInput
# File: lib/core/widgets/app_input.dart
# e.g., AppInput(label: 'Email', hintText: 'Enter email')
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  matches=$(echo "$content" | grep -E '\b(TextField|TextFormField)\s*\(' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P12 - No raw TextField: Use AppInput from lib/core/widgets/app_input.dart (e.g., AppInput(label: 'Email', hintText: 'Enter email')). Detected: $matches")
  fi
fi

# ============================================================
# RULE P13: No commonly used hardcoded EdgeInsets — use AppSpacing
# Only block common sizes (4, 8, 12, 16, 24) to avoid false positives
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  # Only block commonly used padding sizes: 4, 8, 12, 16, 24
  matches=$(echo "$content" | grep -E 'EdgeInsets\.(all|symmetric|only|fromLTRB)\s*\([^)]*\b(4|8|12|16|24)\b' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P13 - No commonly used hardcoded EdgeInsets: Use AppSpacing from lib/core/widgets/app_spacing.dart (e.g., AppSpacing.pad16, AppSpacing.hPad8). Common sizes: 4, 8, 12, 16, 24. Detected: $matches")
  fi
fi

# ============================================================
# RULE P14: No hardcoded font sizes — use TextVariant or AppFontSize
# File: lib/core/theme/app_font_size.dart
# Prefer TextVariant via AppText; use AppFontSize only for edge cases.
# ============================================================
if [ "$is_presentation_file" = true ] && [ "$is_theme_file" = false ]; then
  matches=$(echo "$content" | grep -E 'fontSize:\s*[0-9]+(\.[0-9]+)?\s*[,)]' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P14 - No hardcoded font sizes: Use AppText with TextVariant (e.g., TextVariant.bodyMedium). For edge cases, use AppFontSize constants from lib/core/theme/app_font_size.dart. Detected: $matches")
  fi
fi

# ============================================================
# RULE P15: Use Either<Failure, T> for error handling
# Repositories/use cases should return Either from dartz,
# not throw exceptions.
# ============================================================
if [ "$is_domain_file" = true ]; then
  # Check for throw in repository interfaces or use cases
  matches=$(echo "$content" | grep -E '^\s*throw\s+' | grep -v '// ignore-rule' || true)
  if [ -n "$matches" ]; then
    violations+=("RULE P15 - Use Either<Failure, T> for error handling: Domain layer should return Either<Failure, T> from dartz, not throw exceptions. Detected: $matches")
  fi
fi

# ============================================================
# ADD MORE PROJECT-SPECIFIC RULES BELOW
# ============================================================


# --- Report results ---
if [ ${#violations[@]} -gt 0 ]; then
  reason="PROJECT RULE VIOLATION(S) in $file_path:"$'\n\n'
  for v in "${violations[@]}"; do
    reason+="- $v"$'\n\n'
  done
  reason+="Fix ALL violations above and retry. Refer to AI_DEVELOPMENT_GUIDE.md for correct patterns."

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
