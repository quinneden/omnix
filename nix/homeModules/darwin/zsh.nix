{
  inputs,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
  hostname = "macmini";
in {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      custom = mkIf isDarwin "/Users/quinn/.scripts/zsh";
      plugins = mkMerge [
        (mkIf isDarwin ["zsh-navigation-tools" "nix-zsh-completions" "iterm2" "direnv"])
        (mkIf isLinux ["zsh-navigation-tools" "direnv" "eza"])
      ];
      extraConfig = mkIf isDarwin ''
        zstyle ':omz:update' mode auto
        zstyle ':omz:update' frequency 13
      '';
    };
    shellAliases = mkMerge [
      (mkIf isDarwin {
        "alx.builds" = "curl -sL https://fedora-asahi-remix.org/builds | EXPERT=1 sh";
        "alx.dev" = "curl -sL https://alx.sh/dev | EXPERT=1 sh";
        "alx.sh" = "curl -sL https://alx.sh | EXPERT=1 sh";
        bs = "stat -f%z";
        cdflake = "cd $DARWIN";
        cdfl = "cd $DARWIN";
        cddl = "cd ~/Downloads";
        code = "codium";
        code-flake = "cd ~/Darwin && codium .";
        darwin-switch = "darwin-rebuild switch --flake $(readlink ~/Darwin)#macmini";
        df = "df -h";
        du = "du -h";
        flake-tree = "eza -aT ~/Darwin -I '.git*|.vscode*|*.DS_Store|Icon?'";
        fuck = "sudo rm -rf";
        gst = "git status";
        gsur = "git submodule update --init --recursive";
        l = "eza -la --group-directories-first";
        ll = "eza -glAh --octal-permissions --group-directories-first";
        ls = "eza -A";
        lsblk = "diskutil list";
        push = "git push";
        py = "python";
        reboot = "sudo reboot";
        repos = "cd ~/Repositories";
        rf = "rm -rf";
        shutdown = "sudo shutdown -h now";
        sed = "gsed";
        surf = "sudo rm -rf";
        tree = "eza -aT -I '.git*'";
        lsudo = "lima sudo";
      })
      (mkIf isLinux {
        code = "codium";
        df = "df -h";
        du = "du -h";
        fuck = "sudo rm -rf";
        gst = "git status";
        gsur = "git submodule update --init --recursive";
        l = "eza -la --group-directories-first";
        ll = "eza -glAh --octal-permissions --group-directories-first";
        ls = "eza -A";
        push = "git push";
        rf = "rm -rf";
        tree = "eza -aT -I '.git*'";
      })
    ];
    sessionVariables = mkIf isDarwin {
      BAT_THEME = "Dracula";
      DARWIN = "/Users/quinn/Darwin";
      EDITOR = "micro";
      EZA_ICON_SPACING = "2";
      HOMEBREW_CELLAR = "/opt/homebrew/Cellar";
      HOMEBREW_PREFIX = "/opt/homebrew";
      HOMEBREW_REPOSITORY = "/opt/homebrew/Library/.homebrew-is-managed-by-nix";
      INFOPATH = "/opt/homebrew/share/info:${INFOPATH:-}";
      LANG = "en_US.UTF-8";
      MANPATH = "/opt/homebrew/share/man${MANPATH+:$MANPATH}:";
      MICRO_TRUECOLOR = "1";
      PATH = "/Library/Frameworks/Python.framework/Versions/Current/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/Users/quinn/.local/bin:/run/current-system/sw/bin:/opt/podman/bin:/run/current-system/etc/profiles/per-user/quinn/bin:$PATH";
      SD = "/Users/quinn/.scripts/zsh/";
      ZSH = "/Users/quinn/.oh-my-zsh";
      workdir = "$HOME/workdir";
      compdir = "$HOME/.scripts/zsh-custom/completions";
    };
    initExtra = mkIf isDarwin ''
      for f (~/.scripts/zsh/[^plugins]**/*(.)); do source $f; done

      test -e /Users/quinn/.iterm2_shell_integration.zsh && source /Users/quinn/.iterm2_shell_integration.zsh || true

      [ -e /opt/homebrew/bin/zoxide ] && alias cd="z" || true

      compdef '_files -W ~/Darwin' cfg
      zstyle ':completion:*:*:cfg:*' file-patterns '[^Icon*,README*]*/*'
      zstyle ':completion:*:*:cfg:*' file-sort name
    '';
  };
}
