{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkForce mkIf mkMerge optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  imports = [inputs.lollypops.nixosModules.lollypops];

  lollypops.secrets.default-cmd = "pass";
  lollypops.secrets.cmd-name-prefix = "Tech/nix-secrets/";

  system.configurationRevision = inputs.self.rev or null;

  # TODO: use predicate
  nixpkgs.config.allowUnfree = true;
  nix = {
    registry = builtins.mapAttrs (_: v: {flake = v;}) inputs;
    nixPath =
      mkForce
      (lib.mapAttrsToList
        (k: v: "${k}=${v.to.path}")
        config.nix.registry);
    settings = rec {
      trusted-users =
        (optional isLinux "@wheel")
        ++ (optional isDarwin "@admin");
      auto-optimise-store = true;
      warn-dirty = false;
      experimental-features = "nix-command flakes";
      builders-use-substitutes = true;

      substituters = [
        "https://cache.garnix.io"
        "https://cache.nixos.org"
        "https://cachix.org/api/v1/cache/nix-community"
        "https://cachix.org/api/v1/cache/omnix"
      ];
      trusted-substituters = substituters;
      trusted-public-keys = [
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "omnix.cachix.org-1:ENvT0y7TExLwTzGUmJsKD3NxWQeZXCmQGjHX+xaohdE="
      ];
    };
  };

  programs.zsh.enable = true;
  # environment.systemPackages = with pkgs; [curl file git rsync vim zsh];

  time.timeZone = "America/Los_Angeles";

  security.sudo.wheelNeedsPassword = false;
}
