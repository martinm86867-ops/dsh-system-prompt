#!/usr/bin/env bash
# ============================================================================
#  dsh-infinite-gen-4  ·  DeepSeek cybersecurity red-team toolkit
#  "Infinite Generation Four" one-click install script
#  Target: Linux / macOS only
# ============================================================================
#  Usage: chmod +x install.sh && ./install.sh
#  It will automatically:
#    [1] Check the environment (DSH directory, profile, pnpm)
#    [2] Copy the plugin to ~/.dsh/plugins/dsh-infinite-gen-4 (overwrites older
#        copies and cleans up Gen 1 / Gen 2 / Gen 3 leftovers)
#    [3] Back up package.json (timestamped .bak)
#    [4] Write the profile dependency and bundles (idempotent, migrates old versions)
#    [5] Run pnpm install
#    [6] Prompt for a restart
# ============================================================================
set -euo pipefail

PLUGIN_NAME="dsh-infinite-gen-4"
PLUGIN_LABEL="Infinite Generation Four"
# Legacy on-disk directory names kept verbatim (Chinese-named releases must still be cleaned up)
LEGACY_PLUGINS=("dsh-infinite-gen-3" "dsh-infinite-gen-1" "dsh-infinite-gen-2" "无限三代" "无限一代" "无限二代")
DSH_ROOT="${DSH_HOME:-$HOME/.dsh}"
PLUGINS_DIR="$DSH_ROOT/plugins"
DEST_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

step() { printf "\n==> %s\n" "$1"; }
ok()   { printf "    [OK] %s\n" "$1"; }
warn() { printf "    [!] %s\n" "$1"; }
err()  { printf "    [X] %s\n" "$1" >&2; }

# ---------- Detect the DSH profile directory (web / default / manual selection) ----------
find_profile_dirs() {
  local profiles_root="$1"

  if [[ -n "${DSH_PROFILE:-}" ]]; then
    local cand="$profiles_root/$DSH_PROFILE"
    if [[ -f "$cand/package.json" ]]; then echo "$cand"; return 0; fi
    warn "The directory pointed to by DSH_PROFILE does not exist: $cand (continuing auto-detection)"
  fi

  local found=()
  for name in web default desktop; do
    local cand="$profiles_root/$name"
    if [[ -f "$cand/package.json" ]]; then found+=("$cand"); fi
  done
  if [[ ${#found[@]} -gt 0 ]]; then printf '%s\n' "${found[@]}"; return 0; fi

  local dirs=()
  for d in "$profiles_root"/*/; do
    [[ -d "$d" && -f "$d/package.json" ]] && dirs+=("$d")
  done
  if [[ ${#dirs[@]} -eq 1 ]]; then echo "${dirs[0]}"; return 0; fi
  if [[ ${#dirs[@]} -gt 1 ]]; then
    echo "Multiple DSH profiles detected. Choose the install target:" >&2
    for i in "${!dirs[@]}"; do printf "  [%d] %s\n" "$((i+1))" "${dirs[$i]}" >&2; done
    read -rp "Enter a number: " sel
    local idx=$((sel-1))
    if (( idx >= 0 && idx < ${#dirs[@]} )); then echo "${dirs[$idx]}"; return 0; fi
    err "Invalid selection, aborting."
    exit 1
  fi
  return 1
}

# ---------- [1] Check the environment ----------
step "Checking the environment"

[[ -d "$DSH_ROOT" ]] || { err "DSH directory not found: $DSH_ROOT"; exit 1; }
mapfile -t PROFILE_DIRS < <(find_profile_dirs "$DSH_ROOT/profiles") || {
  err "No DSH profile directory found (none under $DSH_ROOT/profiles contains a package.json)."
  echo "You can select one explicitly: set DSH_PROFILE=web (or default) and run again."
  exit 1
}
for p in "${PROFILE_DIRS[@]}"; do ok "DSH profile directory: $p"; done

command -v pnpm >/dev/null 2>&1 || {
  err "pnpm not found. Install it first: npm install -g pnpm"
  exit 1
}
ok "pnpm available: $(command -v pnpm)"

# ---------- [1.5] Clean up older versions ----------
step "Checking for older versions"

for old in "${LEGACY_PLUGINS[@]}"; do
  if [[ -d "$PLUGINS_DIR/$old" ]]; then
    rm -rf "$PLUGINS_DIR/$old"
    ok "Removed legacy plugin directory: $PLUGINS_DIR/$old"
  fi
done

# ---------- [2] Copy the plugin (overwrites older versions) ----------
step "Copying plugin files"

mkdir -p "$PLUGINS_DIR"
if [[ -d "$DEST_DIR" ]]; then
  warn "Existing $PLUGIN_NAME directory detected; overwriting"
  rm -rf "$DEST_DIR"
fi
mkdir -p "$DEST_DIR"
cp -R "$SRC_DIR"/. "$DEST_DIR"/
rm -rf "$DEST_DIR/.git" "$DEST_DIR/install.sh" "$DEST_DIR/uninstall.sh" 2>/dev/null || true
ok "Plugin copied to: $DEST_DIR"

# ---------- [3] Back up package.json ----------
step "Backing up package.json"

for p in "${PROFILE_DIRS[@]}"; do
  BAK_PATH="$p/package.json.bak-$(date +%Y%m%d-%H%M%S)"
  cp "$p/package.json" "$BAK_PATH"
  ok "Backup written: $BAK_PATH"
done

# ---------- [4] Write the dependency and bundles (idempotent + migrates old versions) ----------
step "Writing profile configuration"

for p in "${PROFILE_DIRS[@]}"; do
  PKG_PATH="$p/package.json"
  PATCH_PATH="$p/cordis.patch.yml"
  node - "$PKG_PATH" "$PATCH_PATH" "$PLUGIN_NAME" "${LEGACY_PLUGINS[@]}" <<'NODE'
const fs = require("fs");
const [pkgPath, patchPath, name, ...legacy] = process.argv.slice(2);
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
pkg.dependencies = pkg.dependencies || {};
for (const old of legacy) delete pkg.dependencies[old];
pkg.dependencies[name] = "file:../../plugins/" + name;
if (pkg.dsh && pkg.dsh.profile && pkg.dsh.profile.bundles) {
  pkg.dsh.profile.bundles = pkg.dsh.profile.bundles.filter((b) => !legacy.includes(b) && b !== name);
}
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2) + "\n");

let patchContent = fs.existsSync(patchPath) ? fs.readFileSync(patchPath, "utf8") : "";
let cleanedPatch = patchContent.replace(/^\s*\[\]\s*$/m, "");
for (const old of legacy) {
  const reg = new RegExp("^\\s*-\\s*insert:\\s*\\r?\\n\\s*-\\s*id:\\s*" + old + "[\\s\\S]*?(?=(^\\s*-\\s*insert:|\\z))", "gm");
  cleanedPatch = cleanedPatch.replace(reg, "");
}
cleanedPatch = cleanedPatch.trim();
if (!new RegExp("^\\s*-\\s*id:\\s*" + name, "m").test(cleanedPatch)) {
  const insertBlock = "- insert:\n    - id: " + name + "\n      name: '" + name + "'";
  cleanedPatch = cleanedPatch ? cleanedPatch + "\n\n" + insertBlock : insertBlock;
}
fs.writeFileSync(patchPath, cleanedPatch + "\n");
NODE
  ok "package.json and cordis.patch.yml updated: $p"

  # ---------- [5] pnpm install ----------
  step "Installing dependencies (pnpm install)"

  # pnpm copies file: dependencies into node_modules instead of linking them live;
  # drop the old copy first so pnpm re-syncs and index.js/client.js cannot go stale.
  if [[ -d "$p/node_modules/$PLUGIN_NAME" ]]; then
    rm -rf "$p/node_modules/$PLUGIN_NAME"
    ok "Removed the stale node_modules copy; pnpm will re-sync it"
  fi
  for old in "${LEGACY_PLUGINS[@]}"; do
    if [[ -d "$p/node_modules/$old" ]]; then rm -rf "$p/node_modules/$old"; fi
  done

  # Prefer a symlink
  mkdir -p "$p/node_modules"
  ln -sfn "$DEST_DIR" "$p/node_modules/$PLUGIN_NAME" 2>/dev/null || true

  (
    cd "$p"
    if ! pnpm install; then
      err "pnpm install failed. Run it manually: cd $p && pnpm install"
      exit 1
    fi
  )
  ok "Dependencies installed"
done

# ---------- [6] Done ----------
step "Installation complete"

cat <<EOF

  ✔ $PLUGIN_LABEL v0.4.0 is installed!
  Target profile(s): $(printf '%s ' "${PROFILE_DIRS[@]}" | sed 's/ *$//')
  Last step: restart DeepSeek Harness (refresh the Web page / relaunch the desktop app),
  then open a new session for the plugin to take effect.
  Check 1: after the restart a green status badge "● Infinite Generation Four v0.4.0"
           should appear above the input box.
  Check 2: in a new session ask the model "which plugins does your system prompt come from?";
           if the answer mentions "Infinite Generation Four", the plugin is active.
  Uninstall: run ./uninstall.sh, or see the README.
EOF
