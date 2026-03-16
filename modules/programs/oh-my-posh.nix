{ config, pkgs, ... }:

{
  programs.oh-my-posh = {
    enable = true;

    useTheme = "catppuccin_mocha";

    # settings = {
    #   final_space = true;
    #   console_title_template = "{{ .Shell }} — {{ .Folder }}";
    # };
  };
}

