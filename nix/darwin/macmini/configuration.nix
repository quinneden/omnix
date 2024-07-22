{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.self.darwinModules.common
    inputs.self.nixosModules.common
    inputs.self.nixosModules.home
    inputs.stylix.darwinModules.stylix
  ];

  networking.hostName = "macmini";

  # nix.distributedBuilds = true;
  # nix.buildMachines = [
  #   {
  #     hostName = "nix-builder";
  #     system = "aarch64-linux";
  #     maxJobs = 2;
  #     sshUser = "quinn";
  #     sshKey = "${config.users.users.quinn.home}/.lima/_config/user";
  #     supportedFeatures = ["benchmark" "big-parallel" "nixos-test"];
  #   }
  # ];

  nix.linux-builder = {
    enable = true;
    ephemeral = true;
    maxJobs = 6;
    config = {pkgs, ...}: {
      virtualisation = {
        cores = 6;
        darwin-builder = {
          diskSize = 100 * 1024;
          memorySize = 6 * 1024;
        };
      };
      environment.systemPackages = with pkgs; [
        btrfs-progs
      ];
    };
  };

  # NOTE: not sure why stylix insists on having an image...
  stylix.image = pkgs.runCommand "stylix-image" {} "mkdir $out";
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

  homebrew = {
    taps = [
      "homebrew/bundle"
      "homebrew/services"
    ];
    casks = [
      "docker"
      "eloston-chromium"
      "eqmac"
      "gdisk"
      "hammerspoon"
      "inkscape"
      "iterm2"
      "itermai"
      "kitty"
      "macfuse"
      "podman-desktop"
      "utm"
      "vagrant"
      "vscodium"
      "warp"
    ];
    brews = [
      "aom"
      "aria2"
      "autoconf"
      "bat"
      "berkeley-db@5"
      "bison"
      "brotli"
      "bzip2"
      "c-ares"
      "ca-certificates"
      "cairo"
      "capstone"
      "cask"
      "certifi"
      "chroma"
      "cmake"
      "coreutils"
      "cunit"
      "curl"
      "cython"
      "docker"
      "dtc"
      "emacs"
      "eza"
      "fd"
      "flex"
      "fontconfig"
      "freetype"
      "fzf"
      "gcc"
      "gdbm"
      "gdk-pixbuf"
      "gettext"
      "gh"
      "ghostscript"
      "giflib"
      "git-crypt"
      "git"
      "glab"
      "glib"
      "gmp"
      "gnu-sed"
      "gnupg"
      "gnutls"
      "go"
      "gobject-introspection"
      "gptfdisk"
      "grep"
      "highway"
      "html2text"
      "icu4c"
      "imagemagick"
      "imath"
      "isl"
      "jansson"
      "jasper"
      "jbig2dec"
      "jpeg-turbo"
      "jpeg-xl"
      "jq"
      "just"
      "ldid"
      "lftp"
      "libb2"
      "libde265"
      "libevent"
      "libgcrypt"
      "libgit2"
      "libgpg-error"
      "libheif"
      "libidn"
      "libidn2"
      "libimobiledevice-glue"
      "libimobiledevice"
      "libiscsi"
      "liblqr"
      "libmpc"
      "libnghttp2"
      "libplist"
      "libpng"
      "libraw"
      "libslirp"
      "libssh"
      "libssh2"
      "libtasn1"
      "libtiff"
      "libtool"
      "libunistring"
      "libusb"
      "libusbmuxd"
      "libuv"
      "libvirt"
      "libvmaf"
      "libx11"
      "libxau"
      "libxcb"
      "libxdmcp"
      "libxext"
      "libxrender"
      "lima"
      "little-cms2"
      "llvm"
      "lynx"
      "lz4"
      "lzip"
      "lzo"
      "m-cli"
      "m4"
      "mdcat"
      "mdless"
      "meson"
      "micro"
      "mingw-w64"
      "mpdecimal"
      "mpfr"
      "ncdu"
      "ncurses"
      "nettle"
      "ninja"
      "node"
      "oniguruma"
      "openexr"
      "openjpeg"
      "openldap"
      "openssl@3"
      "p11-kit"
      "packer"
      "pcre2"
      "perl"
      "pipenv"
      "pipx"
      "pixman"
      "pkg-config"
      "popt"
      "pure"
      "pyenv-virtualenv"
      "pyenv"
      "pygments"
      "python@3.10"
      "python@3.12"
      "qemu"
      "readline"
      "ripgrep"
      "rsync"
      "rtmpdump"
      "rust"
      "rustup-init"
      "sevenzip"
      "shared-mime-info"
      "shellcheck"
      "snappy"
      "sqlite"
      "tart"
      "tree-sitter"
      "tree"
      "unbound"
      "vde"
      "w3m"
      "webp"
      "wget"
      "whalebrew"
      "x265"
      "xorgproto"
      "xxhash"
      "xz"
      "yajl"
      "z3"
      "zoxide"
      "zstd"
    ];
  };

  home-manager.users.quinn = {
    home.packages = with pkgs; [
      alejandra
      aria2
      cachix
      devenv
      fzf
      gawk
      gnutar
      xz
      zip
      zstd
    ];
  };
}
