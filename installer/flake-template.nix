# This header is automatically generated. Do not edit.
# let
#   username = "__USER__";
#   system = "__SYSTEM__";
# in
{
  description = "Home Manager configuration of ${username}";

  inputs = {
    home-manager.url = "github:fd/home-manager";
  };

  outputs = { self, home-manager }: {
    homeConfigurations."${username}" = home-manager.lib.mkHomeManagerConfiguration system username;
  };
}
