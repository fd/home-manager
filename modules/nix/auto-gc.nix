{ pkgs, ... }:
let
  # Expire older home-manager generations and do a full garbage collection
  do-gc = pkgs.writeShellScriptBin "do-gc" ''
    set -e

    # Expire older home-manager generations
    ${pkgs.home-manager}/bin/home-manager expire-generations '-30 days'

    # Do a full garbage collection
    ${pkgs.nix}/bin/nix-collect-garbage
  '';
in
{
  systemd.user.timers.nix-auto-gc = {
    Unit = {
      Description = "Nix auto garbage collection";
    };

    Timer = {
      # Once per week
      OnCalendar = "Mon *-*-* 00:00:00";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  systemd.user.services.nix-auto-gc = {
    Unit = {
      Description = "Nix auto garbage collection";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${do-gc}/bin/do-gc";
    };
  };
}
