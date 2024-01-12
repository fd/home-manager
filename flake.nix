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
      in
      {
        # Ensure we can build Home Manager activation package
        checks = {
          hm = (self.lib.mkHomeManagerConfiguration system "testuser").activationPackage;
          installer = self.packages.${system}.default;
        };

        # Expose the installer
        packages = {
          default = pkgs.callPackage ./installer/command.nix { inherit self home-manager; };
        };

        devShells.default = pkgs.devshell.mkShell ({ config, ... }: {
          commands = [
            {
              help = "Push release artifacts to our public attic cache";
              name = "do-push-release";
              command = ''
                ${pkgs.attic-client}/bin/attic push alpha:release-public \
                  $(nix build .#checks.x86_64-linux.hm --no-link --print-out-paths) \
                  $(nix build .#checks.aarch64-linux.hm --no-link --print-out-paths) \
                  $(nix build .#checks.x86_64-linux.installer --no-link --print-out-paths) \
                  $(nix build .#checks.aarch64-linux.installer --no-link --print-out-paths)
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
            ./home.nix
            ./auto-gc.nix
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    };
}
