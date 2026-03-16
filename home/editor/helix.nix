{ ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        line-number = "relative";
        mouse = true;
        cursorline = true;
        color-modes = true;
        true-color = true;
        gutters = [ "diagnostics" "spacer" "line-numbers" "spacer" "diff" ];
        soft-wrap.enable = false;
        auto-save = true;
        auto-format = true;
        lsp.display-messages = true;
      };
      keys.normal = {
        esc = [ "collapse_selection" "keep_primary_selection" ];
      };
    };

    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "nixfmt";
        }
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "ruff";
            args = [ "format" "-" ];
          };
        }
      ];
    };
  };
}
