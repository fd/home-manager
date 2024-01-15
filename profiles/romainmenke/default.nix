{ config, pkgs, ... }:
{
  programs.starship.enable = false;
  programs.atuin.enable = false;
  programs.bash.initExtra =
    ''
      # Green ';;' when exit status is 0, red otherwise.
      PS1='$(if [ $? -eq 0 ]; then printf "\[\033[32m\];;\[\033[0m\]"; else printf "\[\033[31m\];;\[\033[0m\]"; fi)'
    '';
}
