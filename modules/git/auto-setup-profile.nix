{ config, pkgs, ... }:
let
  ghCredsFile = "${config.home.homeDirectory}/.config/gh/hosts.yml";

  do-setup = pkgs.writeShellScript "do-setup" ''
    set -e
    
    mkdir -p ${config.home.homeDirectory}/.config/git
    touch ${config.home.homeDirectory}/.config/git/config_profile
    config_profile="${config.home.homeDirectory}/.config/git/config_profile"

    profile=$(${pkgs.gh}/bin/gh api /user)
    name="$(echo "$profile" | ${pkgs.jq}/bin/jq -r '.name')"
    email="$(echo "$profile" | ${pkgs.jq}/bin/jq -r '.email')"

    ${pkgs.git}/bin/git config --file "$config_profile" user.name "$name"
    ${pkgs.git}/bin/git config --file "$config_profile" user.email "$email"
  '';
in
{
  programs.git = {
    extraConfig = {
      include = { path = "config_profile"; };
    };
  };

  # Rerun when the github credentials file changes
  systemd.user.paths.git-auto-setup-profile = {
    Unit = {
      Description = "Setup git profile";
    };

    Path = {
      PathChanged = ghCredsFile;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.git-auto-setup-profile = {
    Unit = {
      Description = "Setup git profile";
    };

    Service = {
      Type = "oneshot";
      ExecStart = do-setup;
      RestartSec = 2;
    };
  };
}
