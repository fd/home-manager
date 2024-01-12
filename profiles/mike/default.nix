{}:
{
  programs.starship.enable = false;
  programs.bash.initExtra =
    ''
      _bash_prompt() {
          if [[ $? == 0 ]]; then
              echo "\e[32m;\e[0m"
          else
              echo "\e[31m;\e[0m"
          fi
      }

      # Green ';' when exit status is 0, red otherwise.
      PS1="$(_bash_prompt)"
    '';
}
