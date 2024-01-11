{ pkgs, system, home-manager, ... }:
let
  cmd = "${home-manager.packages.${system}.default}/bin/home-manager";
in
pkgs.writeShellScriptBin "home-installer"
  ''
    set -e

    hmConfigDir="$HOME/.config/home-manager"

    mkdir -p "$hmConfigDir"

    cat <<EOF > "$hmConfigDir/flake.nix"
    let
      username = "$USER";
      system = "${system}";
    in
    EOF
    cat ${./flake-template.nix} >> "$hmConfigDir/flake.nix"

    exec ${cmd} switch
  ''
