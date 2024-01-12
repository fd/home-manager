{ pkgs, ... }:
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
  };

  systemd.user.services.nix-auto-gc = {
    Unit = {
      Description = "Nix auto garbage collection";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "${pkgs.nix}/bin/nix-collect-garbage";
    };
  };
}
