# This module makes sure the latests nix is used.
# 
# It also makes sure that the tests fail when the next version is released.
{ pkgs
, ...
}:
{
  assertions = [
    {
      assertion = !(pkgs.nixVersions ? nix_2_20);
      message = "Nix 2.20 is available, please update this config.";
    }
  ];

  nix.package =
    # Update to the latest version of Nix
    assert !(pkgs.nixVersions ? nix_2_20);
    pkgs.nixVersions.nix_2_19;
}
