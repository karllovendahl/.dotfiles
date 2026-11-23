#!/bin/bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$SCRIPT_DIR/$SOURCE"
done

REPO_ROOT="$(cd -P "$(dirname "$SOURCE")" && pwd)"

PACMAN_PACKAGES=(
  git
  stow
  zsh
  zsh-completions
  neovim
  tmux
  fzf
  zoxide
  eza
  fd
  ripgrep
  wezterm
  direnv
  ttf-hack-nerd
)

AUR_PACKAGES=(
  zsh-theme-powerlevel10k-git
)

log_info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

install_pacman_packages() {
  log_info "Installing Arch packages with pacman..."
  sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"
  log_success "Arch packages installed"
}

install_aur_packages() {
  if [ "${#AUR_PACKAGES[@]}" -eq 0 ]; then
    return
  fi

  if ! command_exists yay; then
    log_warning "Skipping AUR packages because yay is not installed: ${AUR_PACKAGES[*]}"
    return
  fi

  log_info "Installing AUR packages with yay..."
  yay -S --needed "${AUR_PACKAGES[@]}"
  log_success "AUR packages installed"
}

stow_packages() {
  if ! command_exists stow; then
    log_error "stow is not installed"
    exit 1
  fi

  link_resolves_under() {
    local target="$1" source_root="$2" link_source
    [[ -L "$target" ]] || return 1
    link_source="$(readlink -- "$target")"
    [[ "$link_source" == /* ]] || link_source="$(dirname -- "$target")/$link_source"
    link_source="$(realpath -ms -- "$link_source")"
    [[ "$link_source" == "$source_root/"* ]]
  }

  legacy_linux_link() {
    link_resolves_under "$1" "$REPO_ROOT/linux"
  }

  migrate_legacy_linux_links() {
    local package="$1" migration_dir manifest archive profile_manifest profile_archive target relative
    migration_dir="$(mktemp -d)"
    manifest="$migration_dir/legacy-links"
    archive="$migration_dir/legacy-links.tar"
    profile_manifest="$migration_dir/profile-links"
    profile_archive="$migration_dir/profile-links.tar"

    for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
      [[ -e "$root" || -L "$root" ]] || continue
      while IFS= read -r -d '' target; do
        if legacy_linux_link "$target"; then
          relative=".${target#"$HOME"}"
          printf '%s\0' "$relative" >>"$manifest"
        fi
      done < <(find -P "$root" -maxdepth 6 -type l -print0)
    done

    if [[ ! -s "$manifest" ]]; then
      stow --simulate --dir="$REPO_ROOT" --target="$HOME" --restow "$package"
      stow --dir="$REPO_ROOT" --target="$HOME" --restow "$package"
      rm -rf "$migration_dir"
      return 0
    fi
    (
      cd "$HOME"
      tar --null --files-from="$manifest" --create --file="$archive"
    )

    archive_profile_links() {
      for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
        [[ -e "$root" || -L "$root" ]] || continue
        while IFS= read -r -d '' target; do
          if link_resolves_under "$target" "$REPO_ROOT/$package"; then
            relative=".${target#"$HOME"}"
            printf '%s\0' "$relative" >>"$profile_manifest"
          fi
        done < <(find -P "$root" -maxdepth 6 -type l -print0)
      done
      [[ -s "$profile_manifest" ]] || return 0
      (
        cd "$HOME"
        tar --null --files-from="$profile_manifest" --create --file="$profile_archive"
      )
    }

    remove_profile_links() {
      local current_profile_links="$migration_dir/current-profile-links"
      : >"$current_profile_links"
      for root in "$HOME/.config" "$HOME/.local" "$HOME/.Xresources" "$HOME/.xprofile"; do
        [[ -e "$root" || -L "$root" ]] || continue
        while IFS= read -r -d '' target; do
          if link_resolves_under "$target" "$REPO_ROOT/$package"; then
            printf '%s\0' "$target" >>"$current_profile_links"
          fi
        done < <(find -P "$root" -maxdepth 6 -type l -print0)
      done
      while IFS= read -r -d '' target; do rm -- "$target"; done <"$current_profile_links"
    }

    restore_legacy_links() {
      while IFS= read -r -d '' relative; do rm -f -- "$HOME/${relative#.}"; done <"$manifest"
      (
        cd "$HOME"
        tar --extract --file="$archive"
      )
      log_error "Legacy Linux links restored after migration failed."
    }

    restore_profile_links() {
      remove_profile_links
      [[ -s "$profile_manifest" ]] || return 0
      (
        cd "$HOME"
        tar --extract --file="$profile_archive"
      )
    }

    remove_legacy_links() {
      local removal_failed=0
      while IFS= read -r -d '' relative; do
        rm -- "$HOME/${relative#.}" || removal_failed=1
      done <"$manifest"
      return "$removal_failed"
    }

    archive_profile_links
    if ! remove_legacy_links ||
      ! stow --simulate --dir="$REPO_ROOT" --target="$HOME" --restow "$package"; then
      restore_legacy_links
      rm -rf "$migration_dir"
      return 1
    fi
    if ! stow --dir="$REPO_ROOT" --target="$HOME" --restow "$package"; then
      restore_profile_links || true
      restore_legacy_links || true
      rm -rf "$migration_dir"
      return 1
    fi
    rm -rf "$migration_dir"
  }

  log_info "Stowing shared configuration into $HOME..."
  stow --dir="$REPO_ROOT" --target="$HOME" --restow common
  log_info "Migrating legacy Linux links and stowing Omarchy configuration..."
  migrate_legacy_linux_links omarchy
  # Render dotfiles templates from Omarchy's current theme.
  bash "$HOME/.config/omarchy/hooks/theme-set"
  log_success "Stowed common and Omarchy packages"
}

bootstrap_neovim() {
  log_info "NeoVim plugins are managed by vim.pack and will install on first launch"
}

bootstrap_tmux() {
  local tpm_dir="$HOME/.config/tmux/plugins/tpm"

  if [ -d "$tpm_dir" ]; then
    return
  fi

  log_info "Installing Tmux Plugin Manager..."
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm_dir"
  log_success "Tmux Plugin Manager installed"
}

main() {
  echo -e "${CYAN}=== Karl's dotfiles installation script for Omarchy ===${NC}"
  echo -e "${CYAN}=== Starting installation from: ${REPO_ROOT} ===${NC}\n"

  if ! command_exists pacman; then
    log_error "This installer supports Omarchy and other Arch-based systems with pacman"
    exit 1
  fi

  install_pacman_packages
  install_aur_packages
  stow_packages
  bootstrap_neovim
  bootstrap_tmux

  echo -e "\n${GREEN}=== Installation complete! ===${NC}"
  echo -e "${YELLOW}Notes:${NC}"
  echo -e "1. Restart your shell so zsh, powerlevel10k, and completions reload"
  echo -e "2. For tmux, launch it and press ${YELLOW}prefix + I${NC} to install plugins"
  echo -e "3. For NeoVim, launch it once and let ${YELLOW}vim.pack${NC} install plugins automatically"
}

main "$@"
