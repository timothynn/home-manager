{ pkgs, ... }:

{
  programs.nushell = {
    enable = true;
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lah --icons --group-directories-first";
      v = "hx";
      n = "nvim";
      g = "git";
      lg = "lazygit";
      cat = "bat --style=plain";
      find = "fd";
      grep = "rg";
      du = "dust";
    };
    settings = {
      show_banner = false;
      edit_mode = "vi";
      completion_algorithm = "fuzzy";
      history = {
        max_size = 100000;
        sync_on_enter = true;
        file_format = "sqlite";
      };
      # Catppuccin Mocha inspired palette.
      color_config = {
        separator = "#9399b2";
        leading_trailing_space_bg = { attr = "n"; fg = "#1e1e2e"; bg = "#f9e2af"; };
        header = "#89b4fa";
        empty = "#f38ba8";
        bool = "#f5c2e7";
        int = "#fab387";
        filesize = "#a6e3a1";
        duration = "#89dceb";
        date = "#74c7ec";
        range = "#f38ba8";
        float = "#fab387";
        string = "#a6e3a1";
        nothing = "#7f849c";
        binary = "#f38ba8";
        cellpath = "#89b4fa";
        row_index = { fg = "#b4befe"; attr = "b"; };
        record = "#cdd6f4";
        list = "#cdd6f4";
        block = "#cba6f7";
        hints = "#6c7086";
        search_result = { fg = "#1e1e2e"; bg = "#a6e3a1"; };
        shape_and = { fg = "#cba6f7"; attr = "b"; };
        shape_binary = { fg = "#cba6f7"; attr = "b"; };
        shape_block = { fg = "#89b4fa"; attr = "b"; };
        shape_bool = "#f5c2e7";
        shape_custom = "#a6e3a1";
        shape_datetime = { fg = "#89dceb"; attr = "b"; };
        shape_external = "#a6e3a1";
        shape_externalarg = { fg = "#a6adc8"; attr = "b"; };
        shape_filepath = "#89b4fa";
        shape_flag = { fg = "#74c7ec"; attr = "b"; };
        shape_float = { fg = "#fab387"; attr = "b"; };
        shape_garbage = { fg = "#1e1e2e"; bg = "#f38ba8"; attr = "b"; };
        shape_globpattern = { fg = "#89dceb"; attr = "b"; };
        shape_int = { fg = "#fab387"; attr = "b"; };
        shape_internalcall = { fg = "#89b4fa"; attr = "b"; };
        shape_list = { fg = "#89b4fa"; attr = "b"; };
        shape_literal = "#89dceb";
        shape_match_pattern = "#a6e3a1";
        shape_matching_brackets = { attr = "u"; };
        shape_nothing = "#f5c2e7";
        shape_operator = "#f5c2e7";
        shape_or = { fg = "#cba6f7"; attr = "b"; };
        shape_pipe = { fg = "#cba6f7"; attr = "b"; };
        shape_range = { fg = "#f9e2af"; attr = "b"; };
        shape_record = { fg = "#89b4fa"; attr = "b"; };
        shape_redirection = { fg = "#cba6f7"; attr = "b"; };
        shape_signature = { fg = "#a6e3a1"; attr = "b"; };
        shape_string = "#a6e3a1";
        shape_string_interpolation = { fg = "#89dceb"; attr = "b"; };
        shape_table = { fg = "#89b4fa"; attr = "b"; };
        shape_variable = "#f5c2e7";
        shape_vardecl = "#f5c2e7";
      };
    };
    extraConfig = ''
      $env.config = ($env.config | merge {
        use_kitty_protocol: true,
        table: {
          mode: rounded,
          index_mode: auto,
          show_empty: true,
        }
      })
    '';
  };

  # Starship prompt in NuShell as well.
  programs.starship.enableNushellIntegration = true;

  # Nushell should be available on PATH and shell list.
  home.packages = with pkgs; [ nushell ];
}
