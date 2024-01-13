{ config, pkgs, ... }:
let
  ghCredsFile = "${config.home.homeDirectory}/.config/gh/hosts.yml";
  nixNetRcFile = "${config.home.homeDirectory}/.config/nix/netrc";

  do-login = pkgs.writeShellScript "do-login" ''
    set -e
    
    echo -e "machine alpha.pigeon-blues.ts.net\npassword $(${pkgs.gh}/bin/gh auth token)" > ${nixNetRcFile}
  '';
in
{
  systemd.user.paths.nix-auto-login = {
    Unit = {
      Description = "Nix auto login to caches";
    };

    Path = {
      # Once per day
      PathChanged = ghCredsFile;
    };

    Install = {
      WantedBy = [ "multi-user.target" ];
    };
  };

  systemd.user.services.nix-auto-login = {
    Unit = {
      Description = "Nix auto login to caches";
    };

    Service = {
      Type = "oneshot";
      ExecStart = do-login;
    };
  };
}
