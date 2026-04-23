##############################################################################
# home/shell/node.nix  [Home Manager module]
#
# Node.js runtime + a user-writable npm global prefix so that
# `npm install -g <pkg>` works as the user, without sudo, and without
# trying to write under /nix/store (which is read-only).
#
# CLIs installed this way land in ~/.npm-global/bin, which is prepended
# to PATH via home.sessionPath. Uninstall with `npm uninstall -g <pkg>`
# or just `rm -rf ~/.npm-global` to wipe everything.
##############################################################################
{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    nodejs_24
  ];

  # Declarative ~/.npmrc — pinning `prefix` is the piece that redirects
  # `npm -g` to a user-owned directory. HM's programs.npm module expects
  # an attrset of INI key/values via `settings`, not a raw string.
  programs.npm = {
    enable = true;
    settings = {
      prefix            = "${config.home.homeDirectory}/.npm-global";
      init-author-name  = "timothynn";
      init-author-email = "timothynn08@gmail.com";
      fund              = false;
      audit             = false;
    };
  };

  # Make sure the prefix exists before the first `npm -g` invocation so
  # npm does not race on directory creation.
  home.activation.createNpmGlobalPrefix =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "${config.home.homeDirectory}/.npm-global/bin"
    '';

  # Prepend the user-global bin dir to PATH for login shells, Wayland
  # session, and systemd user services.
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
  ];
}
