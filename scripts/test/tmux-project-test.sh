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

# Route every tmux call made by tmux-project onto the throwaway socket.
mkdir -p "$workdir/bin"
cat >"$workdir/bin/tmux" <<EOF
#!/usr/bin/env bash
exec "$REAL_TMUX" -S "$SOCKET" "\$@"
EOF
chmod +x "$workdir/bin/tmux"
export PATH="$workdir/bin:$PATH"

tmuxt() { "$REAL_TMUX" -S "$SOCKET" "$@"; }
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

# The marker is not restricted to windows this tool created. A window opened by
# hand, carrying no identity and left on automatic-rename, must still take it.
scratch="$workdir/scratch"
mkdir -p "$scratch"
handmade=$(tmuxt new-window -d -t '=code' -c "$scratch" -P -F '#{window_id}')
tmuxt set-option -w -t "$handmade" automatic-rename on
handmade_name=$(window_name "$handmade")

"$TMUX_PROJECT" mark "$scratch"
check 'mark: marks a hand-made window that has no project identity' \
  "🔔 $handmade_name" "$(window_name "$handmade")"
check 'mark: disables automatic-rename so the shell cannot erase the marker' \
  'off' "$(tmuxt show-option -w -t "$handmade" -qv automatic-rename)"
check 'mark: claims no project identity on a hand-made window' \
  '' "$(tmuxt show-option -w -t "$handmade" -qv @project_path)"

"$TMUX_PROJECT" clear "$scratch"
check 'clear: restores a hand-made window to its original name' \
  "$handmade_name" "$(window_name "$handmade")"
check 'clear: restores automatic-rename it turned off' \
  'on' "$(tmuxt show-option -w -t "$handmade" -qv automatic-rename)"

# A session in a parent directory must not sweep up every window beneath it
"$TMUX_PROJECT" mark "$workdir"
check 'mark: a parent directory does not mark windows of nested projects' \
  'checkout/add-widget' "$(window_name "$first")"
check 'mark: a parent directory does not mark hand-made nested windows' \
  "$handmade_name" "$(window_name "$handmade")"

printf '\n%d passed, %d failed\n' "$passed" "$failed"
[[ $failed -eq 0 ]]
