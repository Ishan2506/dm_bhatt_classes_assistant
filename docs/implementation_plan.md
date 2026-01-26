# Implementation Plan - Logout Confirmation

## Goal
Add a styled confirmation popup when the user clicks "Logout" in the `AssistantMoreScreen`. The styling should match the app's theme (`Colors.blue.shade900`).

## Proposed Changes

### [MODIFY] [assistant_more_screen.dart](file:///d:/DMBhattAssistant/dm_bhatt_classes_assistant/lib/screen/assistant/assistant_more_screen.dart)
- Create a private method `_showLogoutDialog(BuildContext context)`.
- Use `showDialog` with an `AlertDialog` or customized `Dialog`.
- **UI Details**:
    - **Title**: "Logout" (Bold, Blue).
    - **Content**: "Are you sure you want to logout?"
    - **Buttons**:
        - **Cancel**: Outlined button or TextButton (Grey/Blue).
        - **Logout**: Filled button (Red or Blue, user asked for "application color" so likely Blue, but standard UX for logout is often Red. I will use the App's Primary Blue as requested "like our application color").
- Modify the `onTap` of the Logout tile to call `_showLogoutDialog`.

## Verification Plan
- **Manual Verification**:
    - Go to "More Options".
    - Tap "Logout".
    - Verify dialog appears.
    - Tap "Cancel" -> Dialog closes.
    - Tap "Logout" -> Navigates to Welcome/Login screen.
