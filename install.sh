#!/usr/bin/env bash
set -euo pipefail
case "${1:-}" in
  ""|--no-apply) ;;
  *) echo "Usage: bash install.sh [--no-apply]" >&2; exit 2 ;;
esac
if ! command -v omarchy-theme-set >/dev/null 2>&1; then
  echo "Run this installer from your Omarchy desktop account." >&2
  exit 1
fi
spawn_source="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
spawn_parent="$HOME/.config/omarchy/themes"
spawn_target="$spawn_parent/spawn"
[[ -f "$spawn_source/colors.toml" && -f "$spawn_source/backgrounds/10-ink-and-fire.png" ]] || {
  echo "Theme files are missing. Extract the entire download first." >&2; exit 1;
}
mkdir -p -- "$spawn_parent"
spawn_staged="$(mktemp -d "$spawn_parent/.spawn-v2-install.XXXXXX")"
trap 'if [[ -n ${spawn_staged:-} && -d $spawn_staged ]]; then rm -rf -- "$spawn_staged"; fi' EXIT
cp -a -- "$spawn_source/." "$spawn_staged/"
spawn_backup=""
if [[ -e "$spawn_target" || -L "$spawn_target" ]]; then
  spawn_backup_root="$HOME/.local/state/omarchy/theme-backups"
  mkdir -p -- "$spawn_backup_root"
  spawn_backup="$(mktemp -d "$spawn_backup_root/spawn-$(date +%Y%m%d-%H%M%S)-XXXXXX")/spawn"
  mv -- "$spawn_target" "$spawn_backup"
  echo "Previous Spawn theme backed up: $spawn_backup"
fi
if ! mv -- "$spawn_staged" "$spawn_target"; then
  [[ -z $spawn_backup ]] || mv -- "$spawn_backup" "$spawn_target"
  echo "Installation failed; previous theme restored." >&2; exit 1
fi
spawn_staged=""
echo "Installed Spawn v2: 11 wallpapers and lime-green borders."
if [[ ${1:-} != --no-apply ]]; then
  if omarchy-theme-set spawn; then
    echo "Spawn applied. Cycle wallpapers with: omarchy-theme-bg-next"
  else
    echo "Theme installed, but applying failed. Run omarchy-theme-set spawn from your desktop terminal." >&2
    exit 1
  fi
else
  echo "Apply later with: omarchy-theme-set spawn"
fi
