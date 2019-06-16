# AutoHotKey Script

This is the AHK script I use daily. Some functions are written by me, while others are modified or copied from online. For the latter, I have included links to the original authors. See comments for function descriptions and usages.

Note that files specified in the `#include` commands in `Daily.ahk` are not uploaded (i.e. `AutoCorrect.ahk`) because they contain private information.

## Windows Configuration

### Auto Startup (no admin privilege)

1. create script shortcut and put it in startup folder

2. folder location: <kbd>Win</kbd>+<kbd>r</kbd> &rightarrow; `shell:common startup`

### Auto Startup (admin privilege)

1. use built-in task scheduler (avoids UAC prompt): <kbd>Win</kbd> &rightarrow; `task scheduler`

2. click `Create Task`, then go to

   - `General` &rightarrow; enter task name &rightarrow; check `run with highest privileges`

   - `Triggers` &rightarrow; `New` &rightarrow; `at log on`

   - `Actions` &rightarrow; `New` &rightarrow; `Browse` for script location

## Issues

- **conflicting title**:

  - `Discord` and `Google Chrome` have the same `ahk_class`

  - `File Explorer` and `Taskbar` have the same `ahk_exe`

  - `File Explorer` and `Control Center` have the same `ahk_class`

  - `File Explorer` has no consistent title (i.e. `- window title`)

  - `Discord` home page is `Discord` instead of `... - Discord`

- **web title**:

  - tab that is currently playing audio (shows `This tab is playing audio` in tab title) cannot be detected

## Todo

- use <kbd>Shift</kbd> as secondary function

## Notes

Some command parameters do not allow expression syntax, so legacy syntax is needed (i.e. `%Var%` or `% Var`)

All function parameters allow expression syntax, meaning variables do not need to be wrapped with percent sign

**Variables**: variables store everything on the right side as _String_. Not case sensitive. No need to declare/specify type of variables

**Hotstring**:

- `{{}` = `{`
- `{}}` = `}`
- `{Return}`,`{Enter}`,`` `n`` = new line
- `{Tab}`,`` `t`` = tab