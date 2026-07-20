#!/bin/bash
#
# Flutter Best Practices Hook
# Universal Flutter rules applicable to any Flutter project.
# Runs as a PreToolUse hook to block Edit/Write calls that violate best practices.
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

# Extract the content being written AND full file context
# For Edit operations, we need the full file for rules that check
# the complete widget (e.g., dispose, stateful checks, line count).
if [ "$tool_name" = "Write" ]; then
  content=$(echo "$input" | jq -r '.tool_input.content // empty')
  full_file_content="$content"
elif [ "$tool_name" = "Edit" ]; then
  content=$(echo "$input" | jq -r '.tool_input.new_string // empty')
  # Read the full file for rules that need complete file context
  if [ -f "$file_path" ]; then
    full_file_content=$(cat "$file_path")
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

# Write content to temp files to avoid repeated echo|grep pipelines
tmp_content=$(mktemp)
tmp_full=$(mktemp)
trap 'rm -f "$tmp_content" "$tmp_full"' EXIT
echo "$content" > "$tmp_content"
echo "$full_file_content" > "$tmp_full"

# Helpers
filename=$(basename "$file_path")

is_test_file=false
if [[ "$file_path" == *_test.dart || "$file_path" == */test/* ]]; then
  is_test_file=true
fi

is_presentation_file=false
# Check if file is in presentation layer, but exclude bloc/cubit files (business logic, not UI)
if [[ "$file_path" == */presentation/* || "$file_path" == */pages/* || "$file_path" == */widgets/* || "$file_path" == */ui/* || "$file_path" == */screens/* || "$file_path" == */views/* || "$file_path" == */features/*/*_screen.dart ]]; then
  # Exclude bloc and cubit files - they're business logic, not UI
  if [[ "$file_path" != */bloc/* && "$file_path" != */cubit/* ]]; then
    is_presentation_file=true
  fi
fi

violations=()

# ============================================================
# RULE F1: No widget-returning functions
# Use StatelessWidget or StatefulWidget classes instead.
# ============================================================
matches=$(grep -E '^\s*(static\s+)?Widget[? ]\s*[a-zA-Z_][a-zA-Z0-9_]*\s*\(' "$tmp_content" | grep -v 'Widget build\s*(' || true)
if [ -n "$matches" ]; then
  violations+=("RULE F1 - No widget-returning functions: Use StatelessWidget or StatefulWidget classes instead of functions that return Widget. Detected: $matches")
fi

# ============================================================
# RULE F2: No helper methods returning List<Widget>
# Use dedicated widget classes instead.
# ============================================================
matches2=$(grep -E '^\s*(static\s+)?List<Widget>\s+[a-zA-Z_][a-zA-Z0-9_]*\s*\(' "$tmp_content" || true)
if [ -n "$matches2" ]; then
  violations+=("RULE F2 - No List<Widget> functions: Extract these into dedicated widget classes. Detected: $matches2")
fi

# ============================================================
# RULE F3: No print() statements
# Use debugPrint() or a logger instead. print() can cause
# performance issues and is not stripped in release builds.
# ============================================================
if [ "$is_test_file" = false ]; then
  matches3=$(grep -E '^\s*print\(' "$tmp_content" || true)
  if [ -n "$matches3" ]; then
    violations+=("RULE F3 - No print() statements: Use the projects Logger class, if not available then use debugPrint() or a proper logger instead. print() is not stripped in release builds and can cause jank. Detected: $matches3")
  fi
fi

# ============================================================
# RULE F4: Check mounted before using context after await
# Using BuildContext after an async gap without checking
# mounted can cause crashes if the widget is disposed.
# Uses awk to track sequential await -> context usage within
# the same code flow, resetting on mounted checks or returns.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  has_violation=$(awk '
    /await\s+/ { has_await = 1 }
    /if\s*\(\s*!?(mounted|context\.mounted)/ { has_await = 0 }
    /return;/ || /return\s/ { has_await = 0 }
    has_await && /context\.(read|watch|pop|push)|Navigator\.of\(context|ScaffoldMessenger\.of\(context|Theme\.of\(context|MediaQuery\.of\(context|showDialog|setState/ { found = 1 }
    END { if (found) print "violation" }
  ' "$tmp_content")
  if [ -n "$has_violation" ]; then
    violations+=("RULE F4 - Check mounted after await: You must check 'if (!mounted) return;' or 'if (!context.mounted) return;' before using BuildContext after an async gap. This prevents crashes when the widget is disposed during the await.")
  fi
fi

# ============================================================
# RULE F5: No empty catch blocks
# Silently swallowing errors hides bugs. At minimum log the
# error or rethrow it.
# ============================================================
matches5=$(grep -E 'catch\s*\([^)]*\)\s*\{\s*\}' "$tmp_content" || true)
if [ -n "$matches5" ]; then
  violations+=("RULE F5 - No empty catch blocks: Never silently swallow errors. At minimum, log the error with debugPrint() or rethrow it. Detected: $matches5")
fi

# ============================================================
# RULE F6: Prefer ListView.builder for lists
# Using ListView with children: [] is inefficient for long
# or dynamic lists. Use ListView.builder instead.
# DISABLED: False positive for fixed small widget lists
# ============================================================
# matches6=$(grep -E 'ListView\s*\(' "$tmp_content" | grep -v 'ListView\.builder\|ListView\.separated\|ListView\.custom' || true)
# if [ -n "$matches6" ]; then
#   violations+=("RULE F6 - Prefer ListView.builder: Using ListView with children is inefficient for dynamic/long lists. Use ListView.builder or ListView.separated for better performance. Detected: $matches6")
# fi

# ============================================================
# RULE F7: Dispose controllers
# TextEditingController, ScrollController, AnimationController,
# FocusNode, etc. must be disposed.
# Uses full file context for Edit operations so existing
# dispose() calls are not missed.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Check new content for controller creation
  has_controller=$(grep -E '(TextEditingController|ScrollController|AnimationController|TabController|PageController|FocusNode)\(' "$tmp_content" || true)
  if [ -n "$has_controller" ]; then
    # Check full file for dispose calls (covers existing dispose in Edit mode)
    has_dispose=$(grep -E '\.dispose\(\)' "$tmp_full" || true)
    if [ -z "$has_dispose" ]; then
      violations+=("RULE F7 - Dispose controllers: TextEditingController, ScrollController, AnimationController, FocusNode, etc. must be disposed in the dispose() method to prevent memory leaks. No .dispose() call found. Detected: $has_controller")
    fi
  fi
fi

# ============================================================
# RULE F8: No excessive null assertion (!.) pattern
# Prefer null-aware operators or proper null checks.
# ============================================================
bang_count=$(grep -c -E '\w+!\.' "$tmp_content" || true)
if [ "$bang_count" -gt 3 ]; then
  violations+=("RULE F8 - Excessive null assertion (!.): Found $bang_count uses of the bang operator (!.). Prefer null-aware operators (?., ??, ??=) or proper null checks to avoid runtime null errors.")
fi

# ============================================================
# RULE F9: No GlobalKey usage for state access
# Prefer proper state management over GlobalKey<State>
# for accessing widget state across the tree.
# ============================================================
matches9=$(grep -E 'GlobalKey<.*State>' "$tmp_content" | grep -v 'GlobalKey<NavigatorState>\|GlobalKey<FormState>\|GlobalKey<ScaffoldState>\|GlobalKey<ScaffoldMessengerState>' || true)
if [ -n "$matches9" ]; then
  violations+=("RULE F9 - No GlobalKey for state access: Do not use GlobalKey<CustomWidgetState> to access widget state. Use proper state management instead. GlobalKey<FormState>, GlobalKey<NavigatorState>, and GlobalKey<ScaffoldState> are acceptable. Detected: $matches9")
fi

# ============================================================
# RULE F10: REMOVED — const constructor detection produces too
# many false positives. Most widget constructors take runtime
# parameters and cannot be const. Dart analyzers handle this
# better with the prefer_const_constructors lint rule.
# ============================================================

# ============================================================
# RULE F11: Use SizedBox for fixed sizing instead of Container
# More efficient and semantically correct.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  matches11=$(grep -E 'Container\s*\((height|width):' "$tmp_content" | grep -v 'decoration:\|color:\|margin:\|padding:' || true)
  if [ -n "$matches11" ]; then
    violations+=("RULE F11 - Use SizedBox instead of Container: When only setting height/width without decoration, use SizedBox for better performance and clarity. Detected: $matches11")
  fi
fi

# ============================================================
# RULE F12: No dynamic type for widget parameters
# Use specific types or generics instead of dynamic.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  matches12=$(grep -E '^\s*(final|const)?\s*dynamic\s+[a-zA-Z_][a-zA-Z0-9_]*' "$tmp_content" || true)
  if [ -n "$matches12" ]; then
    violations+=("RULE F12 - No dynamic type for widget parameters: Avoid using dynamic type for widget fields. Use specific types or generics to maintain type safety. Detected: $matches12")
  fi
fi

# ============================================================
# RULE F13: Prefer named constructors for different states
# Improves code readability and maintainability.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Check for widget classes with only default constructor
  widget_classes=$(grep -E 'class\s+[A-Z][a-zA-Z0-9_]*\s+(extends|implements|with|{)' "$tmp_content" | grep -v '_test\.dart' || true)
  if [ -n "$widget_classes" ]; then
    has_named_constructor=$(grep -E '^\s*[A-Z][a-zA-Z0-9_]*\.[a-zA-Z_][a-zA-Z0-9_]*\s*\(|factory\s+[A-Z]' "$tmp_content" || true)
    if [ -z "$has_named_constructor" ]; then
      # Count number of positional parameters
      positional_params=$(grep -E '^\s*[A-Z][a-zA-Z0-9_]*\s*\([^)]*\)' "$tmp_content" | head -1 || true)
      if [ -n "$positional_params" ]; then
        param_count=$(echo "$positional_params" | tr ',' '\n' | wc -l | tr -d ' ')
        if [ "$param_count" -gt 3 ]; then
          violations+=("RULE F13 - Prefer named constructors: Widget with $param_count positional parameters should use named constructors for better readability. Example: MyWidget.loading() instead of MyWidget(null, null, true, false)")
        fi
      fi
    fi
  fi
fi

# ============================================================
# RULE F14: Use appropriate state management lifecycle
# initState should not contain async operations directly.
# Handles @override on a separate line from void initState().
# ============================================================
if [ "$is_presentation_file" = true ]; then
  has_initstate=$(grep -E 'void\s+initState\s*\(' "$tmp_content" || true)
  if [ -n "$has_initstate" ]; then
    # Use awk to scope the check to the initState method body
    has_async_in_initstate=$(awk '
      /void\s+initState/ { in_init = 1; brace_count = 0 }
      in_init && /{/ { brace_count++ }
      in_init && /}/ { brace_count--; if (brace_count <= 0) in_init = 0 }
      in_init && /await\s+[a-zA-Z]|\.then\(|Future\./ { found = 1 }
      END { if (found) print "violation" }
    ' "$tmp_content")
    if [ -n "$has_async_in_initstate" ]; then
      violations+=("RULE F14 - No async operations in initState: Do not perform async operations directly in initState(). Use WidgetsBinding.instance.addPostFrameCallback() or a state management solution for async initialization.")
    fi
  fi
fi

# ============================================================
# RULE F15: Prefer readable EdgeInsets constructors
# EdgeInsets.fromLTRB is harder to read than alternatives.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  matches15=$(grep -E 'EdgeInsets\.fromLTRB\(' "$tmp_content" || true)
  if [ -n "$matches15" ]; then
    violations+=("RULE F15 - Prefer readable EdgeInsets: Use EdgeInsets.symmetric(), EdgeInsets.all(), or EdgeInsets.only() instead of EdgeInsets.fromLTRB() for better readability. Detected: $matches15")
  fi
fi

# ============================================================
# RULE F16: REMOVED — Magic number detection is too aggressive
# for a blocking hook. Numeric literals for spacing, sizing,
# and padding are normal in Flutter widget code. Use Dart
# analysis options or code review for this concern instead.
# ============================================================

# ============================================================
# RULE F17: Use keys for dynamic lists
# Required for proper widget state preservation.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  has_listview_builder=$(grep -E 'ListView\.builder' "$tmp_content" || true)
  if [ -n "$has_listview_builder" ]; then
    # Accept Key, ValueKey, ObjectKey, UniqueKey, GlobalKey
    has_key_assignment=$(grep -E 'key:\s*(Key|ValueKey|ObjectKey|UniqueKey|GlobalKey)\(' "$tmp_content" || true)
    if [ -z "$has_key_assignment" ]; then
      violations+=("RULE F17 - Missing keys for list items: When using ListView.builder with stateful widgets or items that can be reordered, add a Key to each item. Example: key: ValueKey(item.id)")
    fi
  fi
fi

# ============================================================
# RULE F18: Avoid excessive hardcoded styling
# A few hardcoded colors/styles are fine, but widespread use
# indicates missing theme integration. Threshold: >5 instances.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  hardcoded_color_count=$(grep -c -E 'color:\s*Colors\.[a-zA-Z]+' "$tmp_content" || true)
  hardcoded_textstyle_count=$(grep -c -E 'style:\s*TextStyle\(' "$tmp_content" || true)

  total_hardcoded=$((hardcoded_color_count + hardcoded_textstyle_count))
  if [ "$total_hardcoded" -gt 5 ]; then
    violations+=("RULE F18 - Excessive hardcoded styling: Found $total_hardcoded hardcoded colors/text styles. Use Theme.of(context) or a custom theme class for consistent theming across the app. A few inline styles are fine, but widespread use indicates missing theme integration.")
  fi
fi

# ============================================================
# RULE F19: No unnecessary stateful widgets
# Convert to stateless if no mutable state is needed.
# Uses full file context for Edit operations.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  has_stateful_widget=$(grep -E 'class\s+[A-Z][a-zA-Z0-9_]*\s+extends\s+StatefulWidget' "$tmp_content" || true)
  if [ -n "$has_stateful_widget" ]; then
    # Check full file for state usage (covers existing code in Edit mode)
    has_setstate=$(grep -E 'setState\s*\(' "$tmp_full" || true)
    has_lifecycle=$(grep -E 'void\s+(initState|dispose|didChangeDependencies|didUpdateWidget)\s*\(' "$tmp_full" || true)
    has_mutable_fields=$(grep -E '^\s+(late\s+)?[A-Z][a-zA-Z0-9_<>?]*\s+[a-z_][a-zA-Z0-9_]*\s*[=;]' "$tmp_full" | grep -v '^\s*final\|^\s*const\|^\s*static\|^\s*@override' || true)

    if [ -z "$has_setstate" ] && [ -z "$has_lifecycle" ] && [ -z "$has_mutable_fields" ]; then
      violations+=("RULE F19 - Unnecessary StatefulWidget: This widget doesn't use any mutable state. Convert it to StatelessWidget for better performance.")
    fi
  fi
fi

# ============================================================
# RULE F20: Use proper error boundaries
# Wrap risky widgets with ErrorWidget.builder or try/catch.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  has_network_image=$(grep -E 'Image\.network\(' "$tmp_content" || true)
  has_future_builder=$(grep -E 'FutureBuilder\(' "$tmp_content" || true)

  if [ -n "$has_network_image" ] || [ -n "$has_future_builder" ]; then
    has_error_handling=$(grep -E '\.catchError|try\s*\{|ErrorWidget\.builder|errorBuilder:|onError:|snapshot\.hasError' "$tmp_content" || true)
    if [ -z "$has_error_handling" ]; then
      violations+=("RULE F20 - Missing error handling: Network operations and async builders should have error handling. Use errorBuilder for Image.network, check snapshot.hasError for FutureBuilder, or use try/catch blocks.")
    fi
  fi
fi

# ============================================================
# RULE F21: Max lines in UI files (400 lines maximum)
# Keeps files manageable and focused on single responsibility.
# Uses full file context for Edit operations.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  line_count=$(wc -l < "$tmp_full" | tr -d ' ')
  if [ "$line_count" -gt 400 ]; then
    violations+=("RULE F21 - File too large: UI files should not exceed 400 lines. Current file has $line_count lines. Split into smaller, focused widgets following Single Responsibility Principle.")
  fi
fi

# ============================================================
# RULE F22: REMOVED — The heuristic for detecting "complex
# widget trees" via consecutive lines ending in commas was too
# unreliable, matching function calls, list literals, and other
# valid patterns. Widget extraction is better enforced through
# the F21 file length limit and code review.
# ============================================================

# ============================================================
# RULE F23: Use project navigation service, not Navigator.of(context)
# Maintains consistency and enables easier testing/mocking.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  matches23=$(grep -E 'Navigator\.of\(context\)\.(push|pop|pushNamed|pushReplacement|pushAndRemoveUntil|canPop)' "$tmp_content" || true)
  if [ -n "$matches23" ]; then
    # Check if project has a navigation service (heuristic: look for NavigationService class)
    has_nav_service=$(grep -E 'NavigationService|navigationService|NavigatorService' "$tmp_content" || true)
    if [ -z "$has_nav_service" ]; then
      violations+=("RULE F23 - Use project navigation service: Do not use Navigator.of(context) directly. Use the project's established NavigationService (e.g., locator<NavigationService>().push()) for consistency, testability, and easier maintenance.")
    fi
  fi
fi

# ============================================================
# RULE F24: No direct data layer calls in presentation layer
# Presentation layer should only communicate through domain layer.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Common direct data layer calls that should be avoided
  direct_calls=$(grep -E '(Firebase\.|Firestore\.|ApiClient\.|Http\.|Dio\(\)\.|SharedPreferences\.|Hive\.|Sqflite\.|getIt<DataService>)' "$tmp_content" || true)

  # Check for repository/service calls that should go through BloC/Cubit/Provider
  if [ -n "$direct_calls" ]; then
    # Allow if state management is present in full file context
    has_state_management=$(grep -E 'BlocBuilder|CubitBuilder|Provider\.of|context\.read|context\.watch|Consumer|StateNotifierProvider' "$tmp_full" || true)

    if [ -z "$has_state_management" ]; then
      violations+=("RULE F24 - No direct data layer calls: Presentation layer should not directly call data sources (Firebase, APIs, databases). Use the established architecture pattern: Data -> Domain -> Presentation. Inject repositories/services and use them through BloC/Cubit/Provider/GetX.")
    fi
  fi
fi

# ============================================================
# RULE F25: Use abstractions (interfaces) for services
# Enables easier refactoring and testing.
# DISABLED: False positives on UI widgets - the pattern matching
# incorrectly flags StatelessWidget classes with callback fields
# ============================================================
# if [ "$is_presentation_file" = true ] || [[ "$file_path" == */domain/* || "$file_path" == */data/* ]]; then
#   # Look for direct instantiations of concrete implementations
#   concrete_instantiations=$(grep -E '=\s*(new\s+)?[A-Z][a-zA-Z0-9_]*\s*\(|:\s*(new\s+)?[A-Z][a-zA-Z0-9_]*\s*\(' "$tmp_content" | grep -v 'Widget\|Stateless\|Stateful\|BuildContext\|Key\|String\|int\|double\|bool\|List\|Map\|Set' || true)
#
#   # Check if these are services that should be abstracted
#   if [ -n "$concrete_instantiations" ]; then
#     # Look for interfaces/abstract classes in the project (heuristic)
#     has_abstract=$(grep -E 'abstract class|interface|implements|with.*Service|@override' "$tmp_content" || true)
#
#     if [ -z "$has_abstract" ]; then
#       violations+=("RULE F25 - Use abstractions: Depend on abstractions (interfaces/abstract classes), not concrete implementations. This enables easier testing, mocking, and refactoring. Example: Use 'AuthRepository' interface instead of 'FirebaseAuthRepository' concrete class.")
#     fi
#   fi
# fi

# ============================================================
# RULE F26: REMOVED — Flagging files with >3 uses of SizedBox,
# Container, EdgeInsets, etc. triggers on virtually every
# Flutter widget file. These are fundamental building blocks,
# not signs of missing abstraction.
# ============================================================

# ============================================================
# RULE F27: No inline event handlers with business logic
# Extract event handlers to private methods.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Look for inline event handlers with more than simple expressions
  inline_handlers=$(grep -B1 -A1 'onPressed:\s*(' "$tmp_content" | grep -E 'await\|\.then\|Firebase\|Api\|setState' || true)

  if [ -n "$inline_handlers" ]; then
    violations+=("RULE F27 - Extract event handlers: Inline event handlers (onPressed, onTap, onChange) should not contain business logic. Extract to private methods (e.g., _onSubmitPressed(), _onItemSelected()) for better separation of concerns and testability.")
  fi
fi

# ============================================================
# RULE F28: Use dependency injection, not singletons
# Singletons create tight coupling and make testing difficult.
# DISABLED: False positives on static final data lists in UI widgets
# ============================================================
# if [ "$is_presentation_file" = true ]; then
#   # Look for singleton patterns in UI code
#   singletons=$(grep -E '\.instance\.|\.shared\.|\.getInstance\(\)|Singleton\(\)|static final.*=' "$tmp_content" | grep -v 'NavigatorState\|ScaffoldMessengerState\|MediaQuery\.of' || true)
#
#   if [ -n "$singletons" ]; then
#     # Check if dependency injection is being used
#     has_di=$(grep -E 'Provider\.of\|Get\.find\|locator\.\|injector\.\|BlocProvider\.create\|RepositoryProvider' "$tmp_content" || true)
#
#     if [ -z "$has_di" ]; then
#       violations+=("RULE F28 - Avoid singletons: Use dependency injection instead of singletons (e.g., Firebase.instance, ApiClient.shared). Singletons create tight coupling and make testing difficult. Use Provider, GetIt, or your project's DI solution.")
#     fi
#   fi
# fi

# ============================================================
# RULE F29: Follow proper architecture layers
# Don't mix presentation, domain, and data layer concerns.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Check for data models in presentation layer (should use domain models)
  data_models=$(grep -E 'FirebaseDocument|FirestoreDocument|ApiResponse|Dto|DataModel' "$tmp_content" || true)

  if [ -n "$data_models" ]; then
    violations+=("RULE F29 - Layer separation: Presentation layer should only use domain models, not data layer models (DTOs). Convert data models to domain models before passing to presentation layer.")
  fi
fi

# ============================================================
# RULE F30: Use proper state management patterns
# Don't use setState for complex state or business logic.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  # Count setState calls (indicates manual state management)
  setstate_count=$(grep -c 'setState' "$tmp_content" || true)

  # Look for complex state that should be in BloC/Cubit/Provider
  has_complex_state=$(grep -E 'List<.*>.*=.*\[\]|Map<.*,.*>.*=.*\{\}|StreamController|ValueNotifier' "$tmp_content" || true)

  if [ "$setstate_count" -gt 2 ] && [ -n "$has_complex_state" ]; then
    violations+=("RULE F30 - Use proper state management: For complex state (lists, maps, streams) or multiple state variables, use proper state management (BLoC, Cubit, Provider, Riverpod) instead of multiple setState calls.")
  fi
fi

# ============================================================
# ADDITIONAL COMMON LLM PATTERNS THAT CAUSE TECHNICAL DEBT:
# ============================================================
# 1. Overusing FutureBuilder directly in UI (should be in BloC/Cubit)
# 2. Direct API error handling in UI (should be in repository/use case)
# 3. Hardcoded strings for labels/messages (should be in localization)
# 4. Direct DateTime.now() calls (makes testing difficult)
# 5. Mixing navigation with business logic
# 6. Using BuildContext across async gaps without mounted check
# 7. Not handling loading/error/empty states
# 8. Over-nesting widgets without extraction
# 9. Using MediaQuery.of(context) directly in business logic
# 10. Not using responsive design patterns
# ============================================================

# ============================================================
# RULE F31: No direct FutureBuilder/StreamBuilder in complex UIs
# Complex async states should be managed by state management.
# ============================================================
if [ "$is_presentation_file" = true ]; then
  future_stream_count=$(grep -c -E 'FutureBuilder|StreamBuilder' "$tmp_content" || true)

  # If multiple FutureBuilders/StreamBuilders, suggest state management
  if [ "$future_stream_count" -gt 1 ]; then
    violations+=("RULE F31 - Avoid multiple FutureBuilder/StreamBuilder: Multiple async widgets create nested conditions and poor UX. Use state management (BLoC, Cubit) to handle multiple async states centrally.")
  fi
fi

# ============================================================
# RULE F32: Handle all UI states (loading, error, success, empty)
# Don't assume data will always be available.
# DISABLED: False positives on static data lists with ListView.builder
# ============================================================
# if [ "$is_presentation_file" = true ]; then
#   # Check for data display without loading/error states
#   has_data_display=$(grep -E 'ListView\.builder|GridView\.builder|ListTile|Text.*data' "$tmp_content" || true)
#   has_state_handling=$(grep -E -i 'loading|isLoading|error|isEmpty|empty|\.when\(|snapshot\.hasError|snapshot\.connectionState|BlocBuilder|BlocConsumer' "$tmp_content" || true)
#
#   if [ -n "$has_data_display" ] && [ -z "$has_state_handling" ]; then
#     violations+=("RULE F32 - Handle all UI states: Always handle loading, error, success, and empty states. Don't assume data will always load successfully. Use state management to track these states and display appropriate UI.")
#   fi
# fi

# ============================================================
# RULE F33: REMOVED — Hardcoded dimensions are normal in Flutter
# for component-internal sizing (icon sizes, spacing, padding).
# Responsive design is better enforced through code review and
# layout testing on multiple screen sizes.
# ============================================================

# ============================================================
# RULE F34: No duplicate private widgets when public widget exists
# If a widget file exists (e.g., login_prompt.dart), don't create
# a private version (_LoginPrompt) in another file. Import instead.
# ============================================================
# Extract private widget class names (start with underscore)
private_widgets=$(echo "$content" | grep -oE 'class _[A-Z][a-zA-Z0-9_]* extends StatelessWidget' | sed 's/class //; s/ extends.*//' || true)

if [ -n "$private_widgets" ]; then
  # Get the directory of the current file
  file_dir=$(dirname "$file_path")

  for widget in $private_widgets; do
    # Remove underscore to get public name
    public_name="${widget#_}"

    # Try multiple possible filename patterns
    # Pattern 1: login_prompt.dart (standard snake_case)
    possible_pattern_1="$file_dir/$(echo "$public_name" | sed 's/\([a-z]\)\([A-Z]\)/\1_\2/g' | tr '[:upper:]' '[:lower:]').dart"

    # Pattern 2: loginprompt.dart (all lowercase)
    possible_pattern_2="$file_dir/$(echo "$public_name" | tr '[:upper:]' '[:lower:]').dart"

    # Check if any pattern matches an existing file
    for potential_file in "$possible_pattern_1" "$possible_pattern_2"; do
      if [ -f "$potential_file" ]; then
        violations+=("RULE F34 - Duplicate widget detected: You're creating private widget '$widget' but '$public_name' already exists in $(basename "$potential_file"). Import and use the existing widget instead of duplicating it. Delete the private '$widget' class and import $(basename "$potential_file").")
        break
      fi
    done
  done
fi

# --- Report results ---
if [ ${#violations[@]} -gt 0 ]; then
  reason="FLUTTER BEST PRACTICE VIOLATION(S) in $file_path:"$'\n\n'
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
  }'
  exit 0
fi

# No violations — allow the tool call
exit 0
