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
  };

  outputs = { self, nixpkgs, home-manager, attic }: {
    checks.x86_64-linux.hm = (self.lib.mkHomeManagerConfiguration "x86_64-linux" "testuser").activationPackage;
    packages.x86_64-linux.default =
      let
        system = "x86_64-linux";
        pkgs = import nixpkgs { inherit system; };
      in
      pkgs.callPackage ./installer/command.nix { inherit home-manager; };

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
        ];


        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
  };
}
