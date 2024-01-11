{
  description = "Home Manager configuration";

  inputs = {
    home-manager.url = "github:fd/home-manager";
  };

  outputs = { self, home-manager }:
    let
      cfg = import ./settings.nix;
    in
    {
      homeConfigurations."${cfg.username}" = home-manager.lib.mkHomeManagerConfiguration cfg.system cfg.username;
    };
}
