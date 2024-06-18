# This module makes sure the latests nix is used.
# 
# It also makes sure that the tests fail when the next version is released.
{ pkgs
, ...
}:
{
  assertions = [
    {
      assertion = !(pkgs.nixVersions ? nix_2_23);
      message = "Nix 2.23 is available, please update this config.";
    }
  ];

  nix.package =
    # Update to the latest version of Nix
    pkgs.nixVersions.nix_2_22;
}
