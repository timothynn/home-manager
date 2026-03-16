{ pkgs, ... }:

let
  superdash = pkgs.writeShellApplication {
    name = "superdash";
    runtimeInputs = with pkgs; [ gum coreutils ];
    text = ''
      set -euo pipefail

      FG="#cdd6f4"
      BG="#1e1e2e"
      ACCENT="#cba6f7"

      clear
      gum style --border double --border-foreground "$ACCENT" --foreground "$FG" --background "$BG" --padding "1 2" --align center \
        "Catppuccin SuperDash" \
        "Choose an action"

      choice="$(gum choose \
        "Git: lazygit" \
        "Files: yazi" \
        "Monitor: btm" \
        "Network: bandwhich" \
        "Editor: helix" \
        "Editor: neovim" \
        "Rebuild: sudo nixos-rebuild switch --flake .#default" \
        "Quit")"

      case "$choice" in
        "Git: lazygit") lazygit ;;
        "Files: yazi") yazi ;;
        "Monitor: btm") btm ;;
        "Network: bandwhich") sudo bandwhich ;;
        "Editor: helix") hx ;;
        "Editor: neovim") nvim ;;
        "Rebuild: sudo nixos-rebuild switch --flake .#default") sudo nixos-rebuild switch --flake .#default ;;
        *) exit 0 ;;
      esac
    '';
  };
in
{
  home.packages = [ superdash pkgs.gum ];
}
