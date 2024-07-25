{
  description = "quinneden's systems configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    nixos-apple-silicon.url = "github:tpwrules/nixos-apple-silicon";
    stylix.url = "github:danth/stylix";
    lollypops.url = "github:pinpox/lollypops";

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight-darwin.url = "github:cmacrae/flakelight-darwin";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    };
  };

  outputs = {
    flakelight,
    flakelight-darwin,
    ...
  } @ inputs:
    flakelight ./. {
      inherit inputs;
      imports = [
        flakelight-darwin.flakelightModules.default
      ];

      withOverlays = with inputs; [
        nur.overlay
        nixos-apple-silicon.overlays.apple-silicon-overlay
      ];

      apps.default = {system, ...}:
        inputs.lollypops.apps.${system}.default {
          configFlake = inputs.self;
        };

      formatter = pkgs: pkgs.alejandra;

      checks.statix = pkgs: let
        conf = pkgs.writers.writeTOML "statix.toml" {
          disabled = ["empty_pattern" "repeated_keys"];
          ignore = ["result" ".direnv"];
        };
      in "${pkgs.statix}/bin/statix check --config ${conf}";
      checks.deadnix = pkgs: "${pkgs.deadnix}/bin/deadnix -f -_ -l --exclude result .direnv";
    };
}
