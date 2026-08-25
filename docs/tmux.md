# Tmux

## Copy:
1. <prefix> + [ -> enter copy mode
2. Arrows or hjkl to get into the line, can also use /
3. Select in [V]isual or [C-V]isual block
4. [Y]ank it

## Project windows

One tmux window per project directory, inside a single session named `code`.
Opening the same project twice reuses its window instead of adding a tab.

### Commands

| Command | Does |
| --- | --- |
| `tcode` | Opens VSCode on the current directory and selects its tmux window |
| `twt` | Picks a worktree of the current repo with fzf, then opens VSCode on it and selects its tmux window |
| `tmux-project <cmd> [path]` | The underlying tool: `label`, `ensure`, `select`, `attach`, `mark`, `clear` |

Opening a terminal inside VSCode runs `tmux-project attach`, so the terminal lands
on the window belonging to whatever folder that VSCode window has open.

### Window names

Names come from git, not from the directory, because worktree directories carry a
generated hash:

| Directory | Window |
| --- | --- |
| `~/git/personal/useful-commands` | `useful-commands` |
| `~/.stardust/worktrees/useful-commands-9848c409/update-tcode-c3b5eeac` | `useful-commands/update-tcode` |
| a directory outside git | its basename |

A window is identified by its `@project_path` option, which holds the git
toplevel. Every subdirectory of a worktree therefore resolves to the same window,
and renaming a window does not break the lookup.

### Review marker

Claude Code hooks prefix a window with 🔔 when that session wants attention:

| Event | Marker |
| --- | --- |
| `PermissionRequest` | set |
| `Notification` | set |
| `Stop` | set |
| `UserPromptSubmit` | cleared |

Selecting the window also clears it, via the `after-select-window` hook in
`.tmux.conf`.

The marker is not restricted to windows these commands created. A mark lands on
every window whose directory belongs to the session's project, so a session you
started by hand and `cd`'d into the worktree gets marked too. Matching compares
resolved project roots rather than path prefixes, so a session running in a
parent directory does not sweep up the windows of every project beneath it.

Marking saves whatever the window was called and restores it on clear, and turns
`automatic-rename` off for as long as the marker is up, since otherwise the
shell renames the window and the marker vanishes. A project with no window at
all is left alone rather than given one.

Because several VSCode windows attach to the same `code` session, they share the
active window: opening a terminal in one VSCode window moves the other attached
terminals to that window too.

### Setup

`setup-tmux` links `.tmux.conf`. Two settings files live outside this repo and
hold unrelated configuration, so they are edited in place rather than linked:

- VSCode `settings.json` -> `"terminal.integrated.env.osx": { "ZSH_INIT_COMMAND": "tmux-project attach" }`
- `~/.claude/settings.json` -> four `tmux-project-hook` entries, appended alongside any existing hooks

Both point at `~/git/personal/useful-commands/scripts`, so the scripts have to be
on `main` for the hooks and the VSCode terminal to find them.

### Tests

```sh
./scripts/test/tmux-project-test.sh
```

Runs against a throwaway tmux socket in a temp directory, so the real `code`
session is untouched. It needs to be able to start a tmux server, so run it from
a normal terminal; a sandboxed process cannot bind the socket and the suite
aborts with a message rather than reporting false passes.
