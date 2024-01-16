{ config, pkgs, lib, ... }:
{
  assertions = [
    {
      assertion = !(pkgs.nixVersions ? nix_2_20);
      message = "Nix 2.20 is available, please update this config.";
    }
  ];

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # Tools for working with mrhenry projects.
    pkgs.vault
    pkgs.attic-client

    # Basic tools
    pkgs.curl
    pkgs.dig
    pkgs.openssh

    # Nix language server
    pkgs.nil
    pkgs.nixpkgs-fmt

    # Install the _update and switch_ script
    (pkgs.writeShellScriptBin "do-update-home-manager" ''
      nix flake check github:mrhenry/home-manager \
        --extra-substituters https://alpha.pigeon-blues.ts.net/attic/release-public \
        --extra-trusted-public-keys release-public:RLOvxX/CMLa6ffQ5oUDXA5zt/qjMN3u4z6GW+xZ1gWw= \
        --refresh
      exec home-manager switch --refresh --update-input home-manager -b backup
    '')

    # Install the _open a browser_ tools
    (pkgs.writeShellScriptBin "x-www-browser" ''
      echo "Opening $@" > /dev/stderr
      exec mac open "$@"
    '')

    # Install a alias in your Mac profile to open VSCode on the remote server
    # ```sh
    # alias orbcode="orb orbcode $(realpath $1)"
    # ```
    (pkgs.writeShellScriptBin "orbcode" ''
      set -e
      exec mac code "--remote=ssh-remote+$USER@$(hostname)@orb" "$@"
    '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ".vscode-server/data/Machine/settings.json".text = builtins.toJSON {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "${pkgs.nil}/bin/nil";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = [
              # "nixpkgs-fmt"
              "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"
            ];
          };
        };
      };
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/mike/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
    GH_BROWSER = "x-www-browser";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.vim.enable = true;
  programs.bash.enable = true;
  programs.bash.enableCompletion = true;
  # Make sure completions are loaded
  programs.bash.initExtra =
    ''
      export XDG_DATA_DIRS=$HOME/.nix-profile/share:$XDG_DATA_DIRS
    '';
  programs.starship.enable = lib.mkDefault true;
  programs.atuin.enable = lib.mkDefault true;
  programs.git = {
    enable = true;
    ignores = [ ".DS_Store" ];
  };
  programs.gh.enable = true;
  programs.gh.gitCredentialHelper.enable = true;
  programs.direnv.enable = lib.mkDefault true;
  programs.direnv.nix-direnv.enable = true;
  programs.htop.enable = true;

  programs.vscode.userSettings = {
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "${pkgs.nil}/bin/nil";
    "nix.serverSettings" = {
      "nil" = {
        "formatting" = {
          "command" = [
            # "nixpkgs-fmt"
            "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt"
          ];
        };
      };
    };
  };

  nix.package =
    # Update to the latest version of Nix
    assert !(pkgs.nixVersions ? nix_2_20);
    pkgs.nixVersions.nix_2_19;

  nix.settings = {
    extra-substituters = [
      "https://alpha.pigeon-blues.ts.net/attic/develop"
      "https://alpha.pigeon-blues.ts.net/attic/build"
      "https://alpha.pigeon-blues.ts.net/attic/release-public"
      "https://alpha.pigeon-blues.ts.net/attic/release-private"
    ];
    extra-trusted-public-keys = [
      "develop:g8DK7dPXGkipkqGEz92jSvbqFI87mFBRcnin0g2WbYY="
      "build:ks4ql2Pq6tLQOENz6AHWZpB8Qc+If/AOC0jjj65PkR8="
      "release-public:RLOvxX/CMLa6ffQ5oUDXA5zt/qjMN3u4z6GW+xZ1gWw="
      "release-private:QFn22PlqxQAQYaaRhrQXE0otSVzxx35VWos8qyRGijs="
    ];
  };

  systemd.user.startServices = "sd-switch";
}
