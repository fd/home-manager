{ pkgs, stdenv, system, home-manager, ... }:
assert stdenv.isLinux;
let
  cmd = "${home-manager.packages.${system}.default}/bin/home-manager";
in
pkgs.writeShellScriptBin "home-installer"
  ''
    set -e

    hmConfigDir="$HOME/.config/home-manager"

    mkdir -p "$hmConfigDir"

    cat <<EOF > "$hmConfigDir/settings.nix"
    {
      username = "$USER";
      system = "${system}";
    }
    EOF

    cat ${./flake-template.nix} > "$hmConfigDir/flake.nix"

    exec ${cmd} switch
  ''
