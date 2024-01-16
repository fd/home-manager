# Push development caches to our attic server
{ config
, pkgs
, lib
, ...
}:
let
  atticConfigFile = "${config.home.homeDirectory}/.config/attic/config.toml";

  cfg = config.programs.attic-watch;
in
{
  options = {
    programs.attic-watch = {
      enable = lib.mkEnableOption "attic-watch";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.paths.attic-watch-creds = {
      Unit = {
        Description = "Watch attic credentials file";
      };

      Path = { PathChanged = atticConfigFile; };
      Install = { WantedBy = [ "default.target" ]; };
    };

    systemd.user.services.attic-watch-creds = {
      Unit = {
        Description = "Nix auto login to caches";
      };

      Service = {
        Type = "oneshot";
        ExecStart = "systemctl --user restart attic-watch-store.service";
        RestartSec = 2;
      };
    };

    systemd.user.services.attic-watch-store = {
      Unit = {
        Description = "Push developer caches to attic";
        ConditionPathExists = atticConfigFile;
      };

      Service = {
        ExecStart = "${pkgs.attic-client}/bin/attic watch-store alpha:develop";
      };

      Install = { WantedBy = [ "default.target" ]; };
    };
  };
}
