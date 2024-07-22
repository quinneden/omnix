{pkgs, ...}: let
  sec = pkgs.writeShellScriptBin "sec" (builtins.readFile ./scripts/sec.sh);
  wipe-linux = pkgs.writeShellScriptBin "wipe-linux" (builtins.readFile ./scripts/wipe-linux.sh);
  nix-clean = pkgs.writeShellScriptBin "nix-clean" (builtins.readFile ./scripts/nix-clean.sh);
in {
  home.packages = with pkgs; [
    sec
    wipe-linux
    nix-clean
  ];
}
