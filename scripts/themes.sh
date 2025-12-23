#!/usr/bin/env bash
set -Eeuo pipefail



# -------------------------
# Config
# -------------------------

CURRENT_THEME="$(omarchy-theme-current)"

THEMES=(
  "https://github.com/JJDizz1L/aetheria.git"
  "https://github.com/tahfizhabib/omarchy-amberbyte-theme.git"
  "https://github.com/vale-c/omarchy-arc-blueberry.git"
  "https://github.com/davidguttman/archwave.git"
  "https://github.com/bjarneo/omarchy-ash-theme.git"
  "https://github.com/bjarneo/omarchy-aura-theme.git"
  "https://github.com/guilhermetk/omarchy-all-hallows-eve-theme.git"
  "https://github.com/HANCORE-linux/omarchy-blackgold-theme.git"
  "https://github.com/HANCORE-linux/omarchy-blackturq-theme.git"
  "https://github.com/Luquatic/omarchy-catppuccin-dark.git"
  "https://github.com/HANCORE-linux/omarchy-demon-theme.git"
  "https://github.com/ShehabShaef/omarchy-drac-theme.git"
  "https://github.com/celsobenedetti/omarchy-evergarden.git"
  "https://github.com/JaxonWright/omarchy-midnight-theme.git"
  "https://github.com/bjarneo/omarchy-monokai-theme.git"
  "https://github.com/RiO7MAKK3R/omarchy-neovoid-theme.git"
  "https://github.com/ITSZXY/pink-blood-omarchy-theme.git"
  "https://github.com/Grey-007/purple-moon.git"
  "https://github.com/HANCORE-linux/omarchy-shadesofjade-theme.git"
  "https://github.com/tahayvr/omarchy-sunset-drive-theme.git"
  "https://github.com/Ahmad-Mtr/omarchy-temerald-theme.git"
  "https://github.com/vyrx-dev/omarchy-void-theme.git"
)

echo
echo "🎨 Install themes?"
echo "  [A]ll installs all themes"
echo "  [Y]es to choose one-by-one"
echo "  [N]o skips installing any themes"
echo

read -rsn1 -p "> " CHOICE </dev/tty
echo

case "$CHOICE" in
  a|A)
    echo "Installing all themes..."
    for url in "${THEMES[@]}"; do
      omarchy-theme-install "$url"
    done
    ;;

  y|Y)
    for url in "${THEMES[@]}"; do
      echo
      echo "Install theme:"
      echo "  $url"
      read -n1 -r -p "  [y/n] > " yn
      echo

      case "$yn" in
        y|Y)
          omarchy-theme-install "$url"
          ;;
        n|N)
          echo "Skipping."
          ;;
        *)
          echo "Invalid input, skipping."
          ;;
      esac
    done
    ;;

  n|N)
    echo "Skipping all themes."
    exit 0
    ;;

  *)
    echo "Invalid choice. Skipping themes."
    exit 0
    ;;
esac

# Switch back to the original theme
if [ omachy-theme-current != "$CURRENT_THEME" ]; then
  echo "Switching from new theme $(omarchy-theme-current) back to $CURRENT_THEME"
  omarchy-theme-set "$CURRENT_THEME"
fi

echo
echo "✅ Themes installed/updated"

