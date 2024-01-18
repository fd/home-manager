{
  description = "A very basic flake";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    attic.url = "github:zhaofengli/attic";

    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, home-manager, attic }:
    (flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlays.default
            attic.overlays.default
          ];
        };

        # list all profiles
        profiles = [ "testuser" ] ++ (
          builtins.filter
            (x: x != null)
            (
              builtins.map
                (name: if builtins.pathExists ./profiles/${name}/default.nix then name else null)
                (builtins.attrNames (builtins.readDir ./profiles))
            )
        );

        activationPackages = builtins.map (x: (self.lib.mkHomeManagerConfiguration system x).activationPackage) profiles;

        allProfiles = pkgs.runCommandNoCC "all-profiles"
          {
            activationPackages = activationPackages;
          }
          ''
            mkdir -p $out
            for profile in $activationPackages; do
              ln -s $profile $out/
            done
          '';
      in
      {
        # Ensure we can build Home Manager activation package
        checks = {
          allProfiles = self.packages.${system}.allProfiles;
          installer = self.packages.${system}.default;
        };

        # Expose the installer
        packages = {
          default = pkgs.callPackage ./installer/command.nix { inherit self home-manager; };
          allProfiles = allProfiles;
        };

        devShells.default = pkgs.devshell.mkShell ({ config, ... }: {
          commands = [
            {
              help = "Push release artifacts to our public attic cache";
              name = "do-push-release";
              command = ''
                ${pkgs.attic-client}/bin/attic push alpha:release-public \
                  $(nix build .#packages.x86_64-linux.allProfiles --no-link --print-out-paths) \
                  $(nix build .#packages.aarch64-linux.allProfiles --no-link --print-out-paths) \
                  $(nix build .#packages.x86_64-linux.default --no-link --print-out-paths) \
                  $(nix build .#packages.aarch64-linux.default --no-link --print-out-paths)
              '';
            }
          ];
        });
      }))
    // {
      # Expose the Home Manager configuration builder
      lib.mkHomeManagerConfiguration = system: username:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              attic.overlays.default
            ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            # User specific setup
            {
              # Home Manager needs a bit of information about you and the paths it should
              # manage.
              home.username = username;
              home.homeDirectory = "/home/${username}";
            }
            ./modules/home.nix
            ./modules/nix/basics.nix
            ./modules/nix/auto-gc.nix
            ./modules/nix/auto-login.nix
            ./modules/nix/watch-cache.nix
            ./modules/git/auto-setup-profile.nix
          ] ++ (if builtins.pathExists ./profiles/${username}/default.nix then [ ./profiles/${username}/default.nix ] else [ ]);

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    };
}
