#!/bin/bash
#
# Widget Abstraction Enforcement Hook
# Enforces use of app-wide widget abstractions in features/presentation layers
# Check lib/core/widgets/ for existing abstractions before creating new ones
#

set -euo pipefail

# Read hook input from stdin
input=$(cat)

# Extract tool info
tool_name=$(echo "$input" | jq -r '.tool_name')
file_path=$(echo "$input" | jq -r '.tool_input.file_path // empty')

# Only check .dart files in features/widgets or presentation folders
if [[ -z "$file_path" || "$file_path" != *.dart ]]; then
  exit 0
fi

# Only check features/widgets, feature screens, and presentation folders
if [[ ! "$file_path" =~ features/.*widgets/ ]] && [[ ! "$file_path" =~ features/.*_screen\.dart$ ]] && [[ ! "$file_path" =~ presentation/ ]]; then
  exit 0
fi

# Exclude core abstraction files
if [[ "$file_path" =~ core/(theme|widgets)/ ]] && [[ "$file_path" =~ (app_colors|app_spacing|app_text|app_button|app_card|app_input|app_radius|app_font_size)\.dart$ ]]; then
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

violations=()

# Generic message for all violations
generic_msg="Check lib/core/widgets/ for existing abstractions. If no suitable abstraction exists, create one in the core/widgets folder following the existing patterns."

# ============================================================
# RULE W1: No raw Container widget — use AppCard/AppContainer
# ============================================================
matches=$(echo "$content" | grep -oE '\bContainer\s*\(' | grep -vE 'AppCard|AppContainer|// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W1 - No raw Container widget. Use AppCard or AppContainer from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W2: No raw Text/Text.rich/RichText/DefaultTextStyle — use AppText
# ============================================================
matches=$(echo "$content" | grep -oE '\b(Text\.rich|RichText|DefaultTextStyle|Text\s*\()' | grep -vE 'AppText|TextSpan|// ignore-rule' | head -5 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W2 - No raw Text widgets (Text, Text.rich, RichText, DefaultTextStyle). Use AppText from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W3: No raw buttons — use AppButton
# ============================================================
matches=$(echo "$content" | grep -oE '\b(ElevatedButton|TextButton|OutlinedButton|IconButton|FloatingActionButton|GestureDetector\.*)\s*\(' | grep -v '// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W3 - No raw button widgets. Use AppButton from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W4: No raw input fields — use AppInput
# ============================================================
matches=$(echo "$content" | grep -oE '\b(TextField|TextFormField|CupertinoTextField|Form)\s*\(' | grep -v '// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W4 - No raw input widgets. Use AppInput from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W5: No raw Card widget — use AppCard
# ============================================================
matches=$(echo "$content" | grep -oE '\bCard\s*\(' | grep -v 'AppCard\|// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W5 - No raw Card widget. Use AppCard from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W6: Limit raw DecoratedBox usage
# ============================================================
decorated_box_count=$(echo "$content" | grep -oE '\bDecoratedBox\s*\(' | grep -v '// ignore-rule' | wc -l | tr -d ' ')
if [ "$decorated_box_count" -gt 2 ]; then
  violations+=("RULE W6 - Too many DecoratedBox widgets ($decorated_box_count found). Use abstractions from lib/core/widgets/ or create one. Limit: 2 per file.")
fi

# ============================================================
# RULE W7: No raw EdgeInsets — use AppSpacing
# ============================================================
matches=$(echo "$content" | grep -oE 'EdgeInsets\.(all|symmetric|only|fromLTRB)\s*\(' | grep -v '// ignore-rule' | head -5 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W7 - No raw EdgeInsets. Use AppSpacing from lib/core/widgets/ (e.g., AppSpacing.pad16, .padSymmetric()). $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W8: No raw SizedBox for spacing — use AppSpacing
# ============================================================
matches=$(echo "$content" | grep -oE 'SizedBox\s*\(\s*(height|width)\s*:' | grep -v '// ignore-rule' | head -5 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W8 - No raw SizedBox for spacing. Use AppSpacing from lib/core/widgets/ (e.g., 16.vGap, 16.hGap extensions or AppSpacing.vGap16). $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W9: No hardcoded font sizes — use AppText
# ============================================================
matches=$(echo "$content" | grep -oE 'fontSize:\s*[0-9]+(\.[0-9]+)?' | grep -v '// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W9 - No hardcoded font sizes. Use AppText from lib/core/widgets/ with appropriate TextVariant. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W10: No raw ListView/GridView for common patterns — use abstractions
# ============================================================
list_count=$(echo "$content" | grep -oE '\b(ListView|GridView)\s*\(' | grep -v '// ignore-rule' | wc -l | tr -d ' ')
if [ "$list_count" -gt 3 ]; then
  violations+=("RULE W10 - Too many ListView/GridView widgets ($list_count found). Consider creating abstraction in lib/core/widgets/. Limit: 3 per file.")
fi

# ============================================================
# RULE W11: No raw Stack/Positioned — use abstractions
# ============================================================
stack_count=$(echo "$content" | grep -oE '\bStack\s*\(' | grep -v '// ignore-rule' | wc -l | tr -d ' ')
if [ "$stack_count" -gt 2 ]; then
  violations+=("RULE W11 - Too many Stack widgets ($stack_count found). Use abstractions from lib/core/widgets/ or create one. Limit: 2 per file.")
fi

# ============================================================
# RULE W12: No raw Padding widget — use AppSpacing
# ============================================================
matches=$(echo "$content" | grep -oE '\bPadding\s*\(' | grep -v '// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W12 - No raw Padding widget. Use AppSpacing from lib/core/widgets/ (e.g., AppSpacing.pad16 or wrap with AppContainer). $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W13: No raw Center/Align widgets — use abstractions
# ============================================================
align_count=$(echo "$content" | grep -oE '\b(Center|Align)\s*\(' | grep -v '// ignore-rule' | wc -l | tr -d ' ')
if [ "$align_count" -gt 3 ]; then
  violations+=("RULE W13 - Too many Center/Align widgets ($align_count found). Consider creating abstraction in lib/core/widgets/. Limit: 3 per file.")
fi

# ============================================================
# RULE W14: No raw Column/Row for common patterns — use abstractions
# ============================================================
layout_count=$(echo "$content" | grep -oE '\b(Column|Row)\s*\(' | grep -v '// ignore-rule' | wc -l | tr -d ' ')
if [ "$layout_count" -gt 5 ]; then
  violations+=("RULE W14 - Too many Column/Row widgets ($layout_count found). Consider creating abstraction in lib/core/widgets/ for repeated patterns. Limit: 5 per file.")
fi

# ============================================================
# RULE W15: No raw Image/NetworkImage — use abstraction
# ============================================================
matches=$(echo "$content" | grep -oE '\b(Image\.network|Image\.asset|Image\.file|Image\.memory)\s*\(' | grep -vE 'AppImage|// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W15 - No raw Image widgets. Check lib/core/widgets/ for image abstraction (e.g., AppImage). $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W16: No raw Icon widget — use abstraction
# ============================================================
matches=$(echo "$content" | grep -oE '\bIcon\s*\(' | grep -vE 'AppIcon|// ignore-rule' | head -5 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W16 - No raw Icon widget. Check lib/core/widgets/ for icon abstraction (e.g., AppIcon). $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W17: No raw Switch/Checkbox/Radio — use abstractions
# ============================================================
matches=$(echo "$content" | grep -oE '\b(Switch|Checkbox|Radio)\s*\(' | grep -vE 'AppSwitch|AppCheckbox|AppRadio|// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W17 - No raw selection widgets. Use abstractions from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W18: No raw Slider/ProgressIndicator — use abstractions
# ============================================================
matches=$(echo "$content" | grep -oE '\b(Slider|LinearProgressIndicator|CircularProgressIndicator)\s*\(' | grep -vE 'AppSlider|AppProgress|// ignore-rule' | head -3 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W18 - No raw slider/progress widgets. Use abstractions from lib/core/widgets/. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W19: No raw AppBar — use abstraction
# ============================================================
matches=$(echo "$content" | grep -oE '\bAppBar\s*\(' | grep -vE 'AppAppBar|CustomAppBar|// ignore-rule' | head -2 || true)
if [ -n "$matches" ]; then
  violations+=("RULE W19 - No raw AppBar widget. Check lib/core/widgets/ for app bar abstraction. $generic_msg. Detected: $matches")
fi

# ============================================================
# RULE W20: No raw Scaffold — use abstraction
# ============================================================
scaffold_count=$(echo "$content" | grep -oE '\bScaffold\s*\(' | grep -vE 'AppScaffold|// ignore-rule' | wc -l | tr -d ' ')
if [ "$scaffold_count" -gt 1 ]; then
  violations+=("RULE W20 - Too many Scaffold widgets ($scaffold_count found). Use AppScaffold from lib/core/widgets/. $generic_msg. Limit: 1 per screen.")
fi

# --- Report results ---
if [ ${#violations[@]} -gt 0 ]; then
  reason="🚫 WIDGET ABSTRACTION VIOLATIONS in $file_path:"$'\n\n'
  for v in "${violations[@]}"; do
    reason+="$v"$'\n\n'
  done
  reason+="━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"$'\n'
  reason+="MANDATORY: Fix ALL violations above before proceeding."$'\n'
  reason+="1. Check lib/core/widgets/ for existing abstractions"$'\n'
  reason+="2. If no suitable abstraction exists, create one following existing patterns"$'\n'
  reason+="3. Use // ignore-rule ONLY for truly exceptional cases"$'\n'

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
