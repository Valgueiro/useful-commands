#!/usr/bin/env bash
# ABOUTME: Tests tmux-project label derivation, window deduplication and review markers.
# ABOUTME: Runs against a throwaway tmux socket, so the real "code" session is never touched.

set -uo pipefail

SCRIPTS_DIR=$(cd "$(dirname "$0")/.." && pwd)
TMUX_PROJECT="$SCRIPTS_DIR/tmux-project"
REAL_TMUX=$(command -v tmux || echo /opt/homebrew/bin/tmux)

workdir=$(mktemp -d)
workdir=$(cd "$workdir" && pwd -P) # macOS hands out /var symlinks; git reports /private/var
SOCKET="$workdir/tmux.sock"
passed=0
failed=0

cleanup() {
  "$REAL_TMUX" -S "$SOCKET" kill-server >/dev/null 2>&1
  rm -rf "$workdir"
}
trap cleanup EXIT

# Route every tmux call made by tmux-project onto the throwaway socket. -f
# /dev/null keeps the real ~/.tmux.conf out: its automatic-rename and
# after-select-window hook would otherwise rename windows mid-test.
mkdir -p "$workdir/bin"
cat >"$workdir/bin/tmux" <<EOF
#!/usr/bin/env bash
exec "$REAL_TMUX" -f /dev/null -S "$SOCKET" "\$@"
EOF
chmod +x "$workdir/bin/tmux"
export PATH="$workdir/bin:$PATH"

tmuxt() { "$REAL_TMUX" -f /dev/null -S "$SOCKET" "$@"; }
window_count() { tmuxt list-windows -a 2>/dev/null | wc -l | tr -d ' '; }
window_name() { tmuxt display-message -p -t "$1" '#{window_name}'; }

# tmux exits 0 even when it cannot bind its socket, so probe for a real window
# rather than trusting the exit status. Without this, every tmux-backed
# assertion below would compare empty to empty and report a false pass.
tmuxt new-session -d -s preflight -c "$workdir" >/dev/null 2>&1
if [[ $(window_count) != 1 ]]; then
  printf 'cannot start a tmux server on %s\n' "$SOCKET" >&2
  printf 'run this suite from a normal terminal, not a sandboxed process\n' >&2
  exit 1
fi
tmuxt kill-server >/dev/null 2>&1

check() {
  local label=$1 expected=$2 actual=$3
  if [[ $expected == "$actual" ]]; then
    printf 'ok   %s\n' "$label"
    passed=$((passed + 1))
  else
    printf 'FAIL %s\n       expected: %q\n       actual:   %q\n' "$label" "$expected" "$actual"
    failed=$((failed + 1))
  fi
}

# Fixtures: a checkout, a worktree with a stardust-style hashed directory, a plain directory.
repo="$workdir/checkout"
git init -q "$repo"
git -C "$repo" -c user.email=t@t -c user.name=t -c commit.gpgsign=false \
  commit -q --allow-empty -m init
mkdir -p "$repo/nested/deep"

worktree="$workdir/trees/add-widget-c3b5eeac"
git -C "$repo" worktree add -q -b add-widget "$worktree" >/dev/null

plain="$workdir/plain dir"
mkdir -p "$plain"

# Label derivation
check 'label: main checkout is the repo name' \
  'checkout' "$("$TMUX_PROJECT" label "$repo")"
check 'label: worktree is repo/branch, never the hashed directory' \
  'checkout/add-widget' "$("$TMUX_PROJECT" label "$worktree")"
check 'label: non-git directory falls back to basename' \
  'plain dir' "$("$TMUX_PROJECT" label "$plain")"
check 'label: subdirectory resolves to its repo' \
  'checkout' "$("$TMUX_PROJECT" label "$repo/nested/deep")"

# The repo part of a label is the last hyphen segment, capped at eight chars.
longrepo="$workdir/my-cool-toolbelt-service"
git init -q "$longrepo"
git -C "$longrepo" -c user.email=t@t -c user.name=t -c commit.gpgsign=false \
  commit -q --allow-empty -m init
check 'label: long repo name shrinks to its last hyphen segment, capped at 8' \
  'service' "$("$TMUX_PROJECT" label "$longrepo")"

verbose="$workdir/one-verylongword"
git init -q "$verbose"
git -C "$verbose" -c user.email=t@t -c user.name=t -c commit.gpgsign=false \
  commit -q --allow-empty -m init
check 'label: a long final segment is truncated to eight chars' \
  'verylong' "$("$TMUX_PROJECT" label "$verbose")"

# Window creation
first=$("$TMUX_PROJECT" ensure "$worktree")
check 'ensure: creating the session leaves no stray default window' \
  '1' "$(window_count)"
check 'ensure: window takes the repo/branch label' \
  'checkout/add-widget' "$(window_name "$first")"
check 'ensure: window opens in the worktree directory' \
  "$worktree" "$(tmuxt display-message -p -t "$first" '#{pane_current_path}')"

# Deduplication: the whole point of the exercise
again=$("$TMUX_PROJECT" ensure "$worktree")
check 'ensure: a second call reuses the same window' "$first" "$again"
check 'ensure: a second call adds no tab' '1' "$(window_count)"

from_subdir=$("$TMUX_PROJECT" ensure "$repo/nested/deep")
check 'ensure: a different project gets its own window' '2' "$(window_count)"
check 'ensure: repo root and subdirectory share one window' \
  "$from_subdir" "$("$TMUX_PROJECT" ensure "$repo")"
check 'ensure: sharing adds no tab' '2' "$(window_count)"

# A window can exist with the right name but no identity, because new-window
# names it before set-option runs. An interrupted create leaves that behind, and
# it must be adopted rather than duplicated.
orphaned="$workdir/trees/orphan-branch-9f9f9f"
git -C "$repo" worktree add -q -b orphan-branch "$orphaned" >/dev/null
orphan=$(tmuxt new-window -d -t '=code' -c "$orphaned" -n 'checkout/orphan-branch' -P -F '#{window_id}')
before_adoption=$(window_count)
check 'ensure: adopts a matching window that carries no identity' \
  "$orphan" "$("$TMUX_PROJECT" ensure "$orphaned")"
check 'ensure: adoption adds no tab' "$before_adoption" "$(window_count)"
check 'ensure: adoption writes the identity onto the adopted window' \
  "$orphaned" "$(tmuxt show-option -w -t "$orphan" -qv @project_path)"
check 'ensure: the adopted window is then found by identity' \
  "$orphan" "$("$TMUX_PROJECT" ensure "$orphaned")"

# Review marker
"$TMUX_PROJECT" mark "$worktree"
check 'mark: prefixes the window name with a bell' \
  '🔔 checkout/add-widget' "$(window_name "$first")"
"$TMUX_PROJECT" mark "$worktree"
check 'mark: repeated marking does not stack prefixes' \
  '🔔 checkout/add-widget' "$(window_name "$first")"
check 'mark: marking leaves the window lookup intact' \
  "$first" "$("$TMUX_PROJECT" ensure "$worktree")"

"$TMUX_PROJECT" clear "$worktree"
check 'clear: restores the plain label' \
  'checkout/add-widget' "$(window_name "$first")"
"$TMUX_PROJECT" mark "$worktree"
"$TMUX_PROJECT" clear "$first"
check 'clear: accepts a window id, as the tmux select hook passes' \
  'checkout/add-widget' "$(window_name "$first")"
"$TMUX_PROJECT" clear "$worktree"
check 'clear: on an unmarked window is a no-op' \
  'checkout/add-widget' "$(window_name "$first")"

# A hook firing for a directory with no window must not conjure one
before=$(window_count)
"$TMUX_PROJECT" mark "$plain"
check 'mark: an unknown directory never creates a window' "$before" "$(window_count)"

# A mark must reach exactly one window. Several windows can sit in the same
# directory, and flagging all of them makes the marker useless.
crowd=$(tmuxt new-window -d -t '=code' -c "$worktree" -P -F '#{window_id}')
crowd_name=$(window_name "$crowd")
"$TMUX_PROJECT" mark "$worktree"
check 'mark: flags the project window' \
  '🔔 checkout/add-widget' "$(window_name "$first")"
check 'mark: does not flag another window sitting in the same directory' \
  "$crowd_name" "$(window_name "$crowd")"
"$TMUX_PROJECT" clear "$worktree"
tmuxt kill-window -t "$crowd"

# Claude running inside tmux passes TMUX_PANE through to its hooks, which names
# the window exactly, even one opened by hand with no project identity.
scratch="$workdir/scratch"
mkdir -p "$scratch"
handmade=$(tmuxt new-window -d -t '=code' -c "$scratch" -P -F '#{window_id}')
tmuxt set-option -w -t "$handmade" automatic-rename on
handmade_pane=$(tmuxt display-message -p -t "$handmade" '#{pane_id}')
handmade_name=$(window_name "$handmade")

TMUX_PANE="$handmade_pane" "$TMUX_PROJECT" mark "$scratch"
check 'mark: TMUX_PANE flags a hand-made window with no project identity' \
  "🔔 $handmade_name" "$(window_name "$handmade")"
check 'mark: disables automatic-rename so the shell cannot erase the marker' \
  'off' "$(tmuxt show-option -w -t "$handmade" -qv automatic-rename)"
check 'mark: claims no project identity on a hand-made window' \
  '' "$(tmuxt show-option -w -t "$handmade" -qv @project_path)"

TMUX_PANE="$handmade_pane" "$TMUX_PROJECT" clear "$scratch"
check 'clear: restores a hand-made window to its original name' \
  "$handmade_name" "$(window_name "$handmade")"
check 'clear: restores automatic-rename it turned off' \
  'on' "$(tmuxt show-option -w -t "$handmade" -qv automatic-rename)"

# Without TMUX_PANE there is nothing representing a bare directory, so no window
# is touched and none is invented. automatic-rename is on here, so the shell may
# rename the window on its own; the check is only that no marker was added.
before=$(window_count)
"$TMUX_PROJECT" mark "$scratch"
check 'mark: a directory with no window is left alone' "$before" "$(window_count)"
after=$(window_name "$handmade")
check 'mark: and marks nothing by proximity' "${after#🔔 }" "$after"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[[ $failed -eq 0 ]]
