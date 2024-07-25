{
  config,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.home-manager
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
    inputs.self.nixosModules.common
    inputs.self.nixosModules.graphical
    inputs.self.nixosModules.home

    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;
  boot.extraModprobeConfig = ''
    options hid_apple iso_layout=0
  '';

  boot.initrd.kernelModules = [
    "nvme"
    "usbhid"
    "usb_storage"
    "ext4"
    "dm-snapshot"
  ];

  boot.kernelParams = [];

  zramSwap = {
    enable = true;
    memoryPercent = 100;
  };

  hardware.graphics.enable = true;
  hardware.asahi = {
    # TODO: awaiting upstream support for pure-eval solution.
    #       for now, grab it from a temporary webserver rather
    #       than tracking in git
    # peripheralFirmwareDirectory = ./firmware;
    peripheralFirmwareDirectory = builtins.fetchTarball {
      url = "https://65c4a77cf00c00033cf84d2b--eclectic-horse-092596.netlify.app/firmware.tar.gz";
      sha256 = "01swixbj1vyksm8h1m2ppnyxdfl9p7gqaxgagql29bysvngr8win";
    };

    useExperimentalGPUDriver = true;
    experimentalGPUInstallMode = "replace";
    withRust = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI - NIXOS";
    fsType = "vfat";
  };

  nixpkgs.hostPlatform.system = "aarch64-linux";
  nixpkgs.overlays = [
    inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
    # (final: prev: { mesa = final.mesa-asahi-edge; })
  ];

  networking.hostName = "chimera";
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };

  services.logind.powerKey = "ignore";
  services.logind.suspendKey = "ignore";

  lollypops.tasks = ["rebuild"];
  lollypops.deployment.local-evaluation = true;
  lollypops.extraTasks.rebuild = {
    dir = ".";
    deps = [];
    desc = "Local rebuild: ${config.networking.hostName}";
    cmds = [
      ''
        sudo nixos-rebuild -L switch --impure --flake ${inputs.self}
      ''
    ];
  };

  stylix.image = builtins.fetchurl {
    url = "https://github.com/NixOS/nixos-artwork/blob/master/wallpapers/nix-wallpaper-binary-black.png?raw=true";
    sha256 = "9a14a1d30cf69ed1ff92b8b73c5e59ac5ca48e37502e19a52250c3185408616c";
  };

  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

  system.stateVersion = "24.11";
}
