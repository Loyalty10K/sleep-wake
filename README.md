# Sleep / Wake Script

A PowerShell script that remembers which apps you have open, closes them, and can reopen the exact same set later — like a manual "session save" for your desktop.

## What it does

Run the script and it asks for a command: `sleep` or `wake`.

### `sleep`
1. Scans all running processes that have a visible window (skips background/system processes like `svchost`, `dwm`, `lsass`, etc. — see the safe list in the script).
2. Saves each app's name and executable path to `sleep-apps.json` in your user folder (`%USERPROFILE%`).
3. Tries to close each app gently (`CloseMainWindow`), waits 3 seconds, then force-kills anything still running.
4. Asks if you want to shut down the PC (`yes`/`no`). If yes, shuts down immediately; if no, just exits and leaves the PC on.

### `wake`

1. Reads `sleep-apps.json`.
2. Reopens every saved app from its saved path, with a short delay between each launch so things don't choke on startup.
3. Exits when done.

If no save file exists yet, `wake` just tells you there's nothing to restore.

## Why

Instead of manually closing 15 apps before shutting down and reopening them all again the next day, this does it in two commands. Useful before a shutdown/reboot when you want your workspace back exactly as you left it.

## Usage

```powershell
.\sleep-wake.ps1
```

Then type `sleep` or `wake` when prompted.

## Notes / limitations

- Only restores apps, not their internal state — it reopens the .exe, it doesn't reopen the specific tabs, documents, or windows you had inside each app.
- Apps that don't have a `MainWindowHandle` (background-only tools, some tray apps) won't be captured.
- The save file is overwritten every time you run `sleep`, so it only ever remembers the most recent session.
- Force-closing (`Stop-Process -Force`) means unsaved work in an app that doesn't respond to a normal close request could be lost — save your work before running `sleep`.
- Requires running from a PowerShell session with permission to close/start processes and (if you choose to shut down) trigger `shutdown`.
