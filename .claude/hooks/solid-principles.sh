#!/bin/bash
#
# SOLID Principles Enforcement Hook
# Enforces Single Responsibility, Open/Closed, Liskov Substitution,
# Interface Segregation, and Dependency Inversion principles.
#
# Compatible with macOS (BSD grep) — uses grep -E, not grep -P.
#

# Read hook input from stdin to a temp file for reliable parsing
tmp_input=$(mktemp 2>/dev/null || echo "/tmp/solid_input_$$.tmp")
input=$(cat)
echo "$input" > "$tmp_input"
trap 'rm -f "$tmp_input" "$tmp_content" "$tmp_full" 2>/dev/null' EXIT

# Extract tool info using file
tool_name=$(jq -r '.tool_name' "$tmp_input" 2>/dev/null || echo "")
file_path=$(jq -r '.tool_input.file_path' "$tmp_input" 2>/dev/null || echo "")

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
  content=$(jq -r '.tool_input.content' "$tmp_input" 2>/dev/null || echo "")
  full_file_content="$content"
elif [ "$tool_name" = "Edit" ]; then
  content=$(jq -r '.tool_input.new_string' "$tmp_input" 2>/dev/null || echo "")
  if [ -f "$file_path" ]; then
    full_file_content=$(cat "$file_path" 2>/dev/null || echo "$content")
  else
    full_file_content="$content"
  fi
else
  exit 0
fi

# Skip if no content
if [ -z "$content" ]; then
  exit 0
fi

# Write to temp files for efficient processing
tmp_content=$(mktemp 2>/dev/null || echo "/tmp/solid_content_$$.tmp")
tmp_full=$(mktemp 2>/dev/null || echo "/tmp/solid_full_$$.tmp")
echo "$content" > "$tmp_content"
echo "$full_file_content" > "$tmp_full"

# Helpers
filename=$(basename "$file_path")

is_test_file=false
if [[ "$file_path" == *_test.dart || "$file_path" == */test/**/test_*.dart ]]; then
  is_test_file=true
fi

is_generated_file=false
if [[ "$filename" == *.g.dart || "$filename" == *.gr.dart || "$filename" == *.freezed.dart || "$filename" == *.config.dart ]]; then
  is_generated_file=true
fi

# Skip test files and generated files
if [ "$is_test_file" = true ] || [ "$is_generated_file" = true ]; then
  exit 0
fi

# Determine file type for targeted checks
is_bloc_file=false
if [[ "$filename" == *bloc*.dart || "$filename" == *cubit*.dart ]]; then
  is_bloc_file=true
fi

is_repository_file=false
if [[ "$filename" == *_repository.dart ]]; then
  is_repository_file=true
fi

is_service_file=false
if [[ "$filename" == *_service.dart ]]; then
  is_service_file=true
fi

is_widget_file=false
if [[ "$file_path" == */widgets/* || "$file_path" == */screens/* || "$file_path" == */pages/* ]]; then
  is_widget_file=true
fi

is_domain_file=false
if [[ "$file_path" == */domain/* ]]; then
  is_domain_file=true
fi

violations=()

# ============================================================
# SOLID - S: Single Responsibility Principle (SRP)
# A class should have one reason to change
# ============================================================

# SRP-1: BLoC files shouldn't contain UI logic or navigation
if [ "$is_bloc_file" = true ]; then
  matches=$(grep -E 'Navigator\.|showDialog|showModalBottomSheet|Theme\.of\(context\)|MediaQuery\.of\(context\)|Scaffold\.of\(context\)|ScaffoldMessenger\.of\(context\)|BuildContext\s+context' "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$matches" ]; then
    violations+=("SOLID-S-1: BLoC has UI/navigation code. BLoC should only handle business logic. Move UI/navigation to presentation layer with BlocListener.")
  fi
fi

# SRP-2: Widgets shouldn't directly call APIs/Firebase
if [ "$is_widget_file" = true ]; then
  matches=$(grep -E '\b(FirebaseFirestore\.instance|FirebaseAuth\.instance|FirebaseStorage\.instance|http\.(get|post|put|delete)|dio\.(get|post|put|delete|request))' "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$matches" ]; then
    violations+=("SOLID-S-2: Widget directly calls data layer. Widgets should only handle UI. Move data calls to repository → use case → BLoC.")
  fi
fi

# SRP-3: No god classes (excessive responsibilities)
# A class with >15 methods indicates multiple responsibilities
check_god_class() {
  local class_name="$1"
  local class_content="$2"

  # Count actual method declarations (not fields, constructors, or getters)
  # Pattern: methodName(params) { or Future<...> methodName(params) {
  # Exclude: fields (final/const/late/static), constructor params, getters
  local method_count=$(echo "$class_content" | grep -c -E '^\s+(Future\s+<.*?>\s+|void\s+)?[a-z_][a-zA-Z0-9_]*\s*\([^)]*\)\s*{' 2>/dev/null || echo "0")

  # Exclude common boilerplate methods
  local content_excluded=$(echo "$class_content" | grep -vE 'toString|hashCode|operator\s+' || echo "")
  method_count=$(echo "$content_excluded" | grep -c -E '^\s+(Future\s+<.*?>\s+|void\s+)?[a-z_][a-zA-Z0-9_]*\s*\([^)]*\)\s*{' 2>/dev/null || echo "0")

  # Only flag if significantly high (>20 methods to avoid false positives)
  if [ "$method_count" -gt 20 ]; then
    violations+=("SOLID-S-3: Class '$class_name' has $method_count methods. This indicates multiple responsibilities. Split into smaller, focused classes following SRP.")
    return 0
  fi
  return 1
}

# Check each class for god class pattern
while IFS= read -r class_line; do
  class_name=$(echo "$class_line" | grep -oE 'class\s+[A-Z][a-zA-Z0-9_]*' | awk '{print $2}' 2>/dev/null || echo "")
  if [ -n "$class_name" ]; then
    check_god_class "$class_name" "$content" && break
  fi
done < <(grep -E '^\s*class\s+[A-Z][a-zA-Z0-9_]*\s+(extends|implements|with|{)' "$tmp_content" 2>/dev/null)

# SRP-4: Repositories shouldn't contain business logic formatting
if [ "$is_repository_file" = true ]; then
  matches=$(grep -E 'TextEditingController|FocusNode|BuildContext|Widget\(\)|EdgeInsets\(|Color\(' "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$matches" ]; then
    violations+=("SOLID-S-4: Repository contains UI-related code. Repositories should only handle data access. Move UI concerns to presentation layer.")
  fi
fi

# ============================================================
# SOLID - O: Open/Closed Principle (OCP)
# Open for extension, closed for modification
# ============================================================

# OCP-1: Avoid long switch/if-else chains on types (should use polymorphism)
# Check for 5+ consecutive type checks in all files (not just services)
case_count=$(grep -E -c 'case\s+[A-Z]' "$tmp_content" 2>/dev/null || echo "0")
case_count=${case_count:-0}
if [ "$case_count" -ge 5 ] 2>/dev/null; then
  violations+=("SOLID-O-1: Long switch/case chain detected (5+ cases). Use polymorphism/strategy pattern instead. Create abstract base class with type-specific implementations.")
fi

# OCP-2: Watch for "if type is X do A, if type is Y do B" pattern
type_check_count=$(grep -E -c 'if\s*\([^)]*\s+is\s+[A-Z]' "$tmp_content" 2>/dev/null || echo "0")
type_check_count=${type_check_count:-0}
if [ "$type_check_count" -ge 4 ] 2>/dev/null; then
  violations+=("SOLID-O-2: Multiple type checks (4+ 'is' checks). Use polymorphism instead. Move behavior into type-specific implementations.")
fi

# ============================================================
# SOLID - L: Liskov Substitution Principle (LSP)
# Subtypes must be substitutable for their base types
# ============================================================

# LSP-1: Methods that override but throw errors
# Look for @override followed by throw in the next few lines
has_override=$(grep -E '@override' "$tmp_content" 2>/dev/null || echo "")
if [ -n "$has_override" ]; then
  error_throw=$(grep -A3 '@override' "$tmp_content" 2>/dev/null | grep -E 'throw\s+(UnsupportedError|UnimplementedError|NotImplementedError)' || echo "")
  if [ -n "$error_throw" ]; then
    violations+=("SOLID-L-1: Override method throws error. This violates LSP - the subtype cannot be substituted. Use interface segregation or refactor the hierarchy.")
  fi
fi

# LSP-2: Child class tightening preconditions
if grep -q '@override' "$tmp_content" 2>/dev/null; then
  override_with_exception=$(grep -A5 '@override' "$tmp_content" 2>/dev/null | grep -E 'throw\s+(ArgumentError|StateError|RangeError)' || echo "")
  if [ -n "$override_with_exception" ]; then
    violations+=("SOLID-L-2: Override tightens preconditions (adds new exceptions). This violates LSP - parent behavior should be honored, not restricted.")
  fi
fi

# ============================================================
# SOLID - I: Interface Segregation Principle (ISP)
# Clients shouldn't depend on interfaces they don't use
# ============================================================

# ISP-1: Watch for fat interfaces (>10 methods)
if [ "$is_domain_file" = true ]; then
  abstract_interfaces=$(grep -E '^\s*abstract\s+class\s+[A-Z][a-zA-Z0-9_]*' "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$abstract_interfaces" ]; then
    while IFS= read -r interface_line; do
      interface_name=$(echo "$interface_line" | grep -oE 'abstract\s+class\s+[A-Z][a-zA-Z0-9_]*' | awk '{print $3}' 2>/dev/null || echo "")
      if [ -n "$interface_name" ]; then
        # Count method declarations in the interface
        method_count=$(awk "/abstract class $interface_name/,/^}/" "$tmp_content" 2>/dev/null | grep -c -E '(void|Future|dynamic|String|int|double|bool)\s+[a-z]' || echo "0")
        if [ "$method_count" -gt 10 ]; then
          violations+=("SOLID-I-1: Interface '$interface_name' has $method_count methods. This violates ISP - split into smaller, focused interfaces.")
          break
        fi
      fi
    done <<< "$abstract_interfaces"
  fi
fi

# ISP-2: Empty or stub implementations
# Check for multiple empty method bodies: void method() {}
empty_count=$(grep -E '^\s+void\s+[a-z_][a-zA-Z0-9_]*\s*\(\s*\)\s*\{\}' "$tmp_content" 2>/dev/null | wc -l | tr -d ' ')
empty_count=${empty_count:-0}
unimplemented_count=$(grep -E -c 'throw\s+UnimplementedError\(\)' "$tmp_content" 2>/dev/null || echo "0")
unimplemented_count=${unimplemented_count:-0}

if [ "$((empty_count + unimplemented_count))" -gt 3 ] 2>/dev/null; then
  violations+=("SOLID-I-2: Multiple empty/unimplemented method implementations ($empty_count empty, $unimplemented_count unimplemented). This indicates the interface is too fat (ISP violation). Split into smaller interfaces.")
fi

# ============================================================
# SOLID - D: Dependency Inversion Principle (DIP)
# Depend on abstractions, not concretions
# ============================================================

# DIP-1: Direct instantiation of concrete services/repositories
if [ "$is_bloc_file" = true ] || [ "$is_widget_file" = true ]; then
  # Look for concrete service/repository instantiation
  # Pattern: Service(), Repository(), Provider(), Manager(), etc.
  concrete_inst=$(grep -E '(Service|Repository|Provider|Manager|Controller)\(' "$tmp_content" 2>/dev/null | \
    grep -v -E '(TextEditingController|ScrollController|TabController|PageController|AnimationController|FocusNode|AspectRatio|EdgeInsets)' || echo "")
  if [ -n "$concrete_inst" ]; then
    violations+=("SOLID-D-1: Direct concrete instantiation. Depend on abstractions (interfaces/abstract classes) instead of concrete implementations. Use dependency injection.")
  fi
fi

# DIP-2: Direct Firebase/HTTP instantiation
if [ "$is_bloc_file" = true ] || [ "$is_widget_file" = true ]; then
  matches=$(grep -E 'FirebaseFirestore\.instance|FirebaseAuth\.instance|FirebaseStorage\.instance|Dio\(\)|HttpClient\(\)' "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$matches" ]; then
    violations+=("SOLID-D-2: Direct data source instantiation. High-level modules should depend on repository interfaces, not concrete Firebase/HTTP instances. Create abstract repository and inject it.")
  fi
fi

# DIP-3: Constructor should accept abstractions
if [ "$is_bloc_file" = true ] || [ "$is_service_file" = true ]; then
  constructors=$(grep -E -A10 '^\s+[A-Z][a-zA-Z0-9_]*\s*\(' "$tmp_content" 2>/dev/null | grep -E '(this\.\s*[A-Z][a-zA-Z0-9_]*Repository|this\.\s*[A-Z][a-zA-Z0-9_]*Service)' 2>/dev/null | grep -v -E '(Abstract|Interface|Base)' || echo "")
  if [ -n "$constructors" ]; then
    violations+=("SOLID-D-3: Constructor depends on concrete types. Use abstract classes/interfaces for dependencies (e.g., 'AuthRepository' not 'FirebaseAuthRepository').")
  fi
fi

# ============================================================
# ADDITIONAL ARCHITECTURAL INTEGRITY CHECKS
# ============================================================

# ARCH-1: Domain layer must not depend on outer layers
if [ "$is_domain_file" = true ]; then
  matches=$(grep -E "import\s+'\.\./\.\./(data|presentation|infrastructure)/" "$tmp_content" 2>/dev/null || echo "")
  if [ -n "$matches" ]; then
    violations+=("ARCH-1: Domain layer imports outer layers. Domain must be innermost layer with no outward dependencies (Clean Architecture).")
  fi
fi

# ============================================================
# REPORT RESULTS
# ============================================================

if [ ${#violations[@]} -gt 0 ]; then
  reason="SOLID PRINCIPLE VIOLATION(S) in $file_path:"$'\n\n'
  for v in "${violations[@]}"; do
    reason+="- $v"$'\n\n'
  done
  reason+="Fix ALL violations above and retry."

  jq -n --arg reason "$reason" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "permissionDecision": "deny",
      "permissionDecisionReason": $reason
    }
  }' 2>/dev/null || echo '{"hookSpecificOutput": {"permissionDecision": "deny"}}'
  exit 0
fi

# No violations — allow the tool call
exit 0
