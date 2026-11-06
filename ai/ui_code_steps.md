Sure, here are the **private class rules and prohibitions** rewritten as practical steps in English:

---

## Step 1: Don't split UI with private `_buildXxx()` methods
- **Forbidden**: Writing `Widget _buildHeader()` inside a `State` class.
- **Correct**: Extract the part into a standalone `class Header extends StatelessWidget`.
- **Why**: Private build methods weaken rebuild boundaries and prevent reuse and independent testing.

## Step 2: Follow "one public class per file"
- **Forbidden**: Putting a main Widget class + a helper data class `_UserModel` + other classes in the same file.
- **Correct**: One public class per `.dart` file.
- **Only exception**: `_MyPageState` may coexist with its Widget class in the same file.

## Step 3: Understand that `_` in Dart is library-level, not class-level
- **Forbidden**: Assuming `_method` inside a `mixin` or `extension` is accessible after moving the code to another file.
- **Correct**: If you need to split complex `State` logic, **do not** use cross-file `mixin` or `part` to force access to private members.
- **Alternative**: Extract child Widgets, pass interaction logic through callbacks, and keep business logic and lifecycle in the original `State` class.

## Step 4: Don't override `operator ==` in Widget classes
- **Forbidden**: Overriding `==` in `StatelessWidget` or `StatefulWidget`.
- **Correct**: Remove the override and rely on Flutter's default Widget identity.
- **Why**: The override makes rebuilds unpredictable and more expensive.

## Step 5: Don't create a class that only holds static members
- **Forbidden**: `class MathUtils { static double pi = 3.14; }` just to group constants.
- **Correct**: Use top-level functions or constants directly without a class wrapper.

## Step 6: Review code before delivery with a quick checklist

| Item | Rule |
|------|------|
| UI splitting | No `_buildXxx()`; use `class XxxWidget` |
| File boundaries | One public class per file (`State` is the exception) |
| Cross-file access | `_` is valid only within the same file, not across mixin/extension |
| Widget equality | Do not override `operator ==` |
| Constant grouping | No "constants holder" class; use top-level |

## Step 7: Enable lint rules to catch violations automatically
- Add the appropriate rules in `analysis_options.yaml` (e.g., customize `flutter_lints`).
- Wire CI to run `dart analyze` so violations can't pass in Pull Requests.

---

Would you like me to turn this into a **copy-ready checklist** or a **Pull Request review template**?