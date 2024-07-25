{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkIf mkMerge optional;
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in {
  users.users.quinn = mkMerge [
    {
      description = "Quinn Edenfield";
      shell = pkgs.zsh;
    }
    (mkIf isLinux {
      home = "/home/quinn";
      isNormalUser = true;
      extraGroups = ["input" "tty" "video" "wheel"];
    })
  ];

  # for nix-direnv
  nix.settings.keep-outputs = true;
  nix.settings.keep-derivations = true;
  environment.pathsToLink = ["/share/nix-direnv"];

  fonts = let
    fnts = with pkgs; [
      font-awesome
      (nerdfonts.override {
        fonts = [
          "CascadiaCode"
          "FiraCode"
          "JetBrainsMono"
          "NerdFontsSymbolsOnly"
          "VictorMono"
        ];
      })
    ];
  in
    # TODO: hack to get around waiting for nix-darwin#870
    {fontDir.enable = true;}
    // mkIf isLinux {packages = fnts;}
    // mkIf isDarwin {packages = fnts;};

  home-manager.useGlobalPkgs = true;
  home-manager.users.quinn = {
    imports = optional isDarwin inputs.self.homeModules.darwin;

    home.stateVersion = "24.11";
    home.packages = mkMerge [
      (with pkgs; [
        # aspell
        # aspellDicts.en
        # aspellDicts.en-computers
        alejandra
        bc
        ffmpeg
        gnumake
        gnupg
        gnused
        jq
        just
        mpv
        nil
        nix-prefetch-git
        nixd
        nmap
        pass
        python3
        ranger
        ripgrep
        rsync
        unzip
        wget
      ])
      (mkIf isLinux [pkgs.podman])
    ];

    home.sessionVariables = {
      PAGER = "less -R";
      EDITOR = "micro";
      PATH =
        if isDarwin
        then "$PATH:/opt/homebrew/bin"
        else "$PATH";
    };

    programs.git = {
      enable = true;
      userName = config.users.users.quinn.description;
      userEmail = "quinnyxboy@gmail.com";
      # signing.key = "";
      # signing.signByDefault = true;
      extraConfig = {
        github.user = "quinneden";
        init.defaultBranch = "main";
      };
    };

    # programs.gpg = {
    #   enable = false;
    #   mutableKeys = false;
    #   mutableTrust = false;
    #   publicKeys = [
    #     {
    #       trust = 5;
    #       source = builtins.fetchurl {
    #         url = "https://github.com/cmacrae.gpg";
    #         sha256 = "0s9qs9r85mrhjs360zzra5ig93rrkbaqqx4ws3xx6mnkxryp7yis";
    #       };
    #     }
    #   ];
    #   settings = {
    #     personal-cipher-preferences = "AES256 AES192 AES";
    #     personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
    #     default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
    #     cert-digest-algo = "SHA512";
    #     s2k-digest-algo = "SHA512";
    #     s2k-cipher-algo = "AES256";
    #     charset = "utf-8";
    #     fixed-list-mode = "";
    #     no-comments = "";
    #     no-emit-version = "";
    #     no-greeting = "";
    #     keyid-format = "0xlong";
    #     list-options = "show-uid-validity";
    #     verify-options = "show-uid-validity";
    #     with-fingerprint = "";
    #     require-cross-certification = "";
    #     no-symkey-cache = "";
    #     use-agent = "";
    #     throw-keyids = "";
    #   };
    # };
    #
    #     services = let
    #       conf = {
    #         enable = true;
    #         enableZshIntegration = true;
    #         enableSshSupport = true;
    #         # sshKeys = [];
    #         pinentryFlavor =
    #           if isDarwin
    #           then "mac"
    #           else "qt";
    #         extraConfig = ''
    #           allow-emacs-pinentry
    #           allow-loopback-pinentry
    #         '';
    #       };
    #     in
    #       # TODO: hack to get around waiting for home-manager#2964
    #       mkMerge [
    #         (mkIf isLinux {gpg-agent = conf;})
    #         (mkIf isDarwin {darwin-gpg-agent = conf;})
    #       ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };

    # programs.firefox = optional isLinux {
    #   enable = true;
    #   package = pkgs.firefox;
    #   profiles.home = mkMerge [
    #     {
    #       id = 0;
    #       extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #         browserpass
    #         betterttv
    #         consent-o-matic
    #         metamask
    #         multi-account-containers
    #         reddit-enhancement-suite
    #         ublock-origin
    #         vimium
    #       ];

    #       search.default = "DuckDuckGo";
    #       search.force = true;

    #       settings = {
    #         "app.update.auto" = false;
    #         "app.normandy.enabled" = false;
    #         "beacon.enabled" = false;
    #         "browser.startup.homepage" = "https://lobste.rs";
    #         "browser.search.region" = "GB";
    #         "browser.search.countryCode" = "GB";
    #         "browser.search.hiddenOneOffs" = "Google,Amazon.com,Bing";
    #         "browser.search.isUS" = false;
    #         "browser.ctrlTab.recentlyUsedOrder" = false;
    #         "browser.newtabpage.enabled" = false;
    #         "browser.bookmarks.showMobileBookmarks" = true;
    #         "browser.uidensity" = 1;
    #         "browser.urlbar.update" = true;
    #         "datareporting.healthreport.service.enabled" = false;
    #         "datareporting.healthreport.uploadEnabled" = false;
    #         "datareporting.policy.dataSubmissionEnabled" = false;
    #         "distribution.searchplugins.defaultLocale" = "en-US";
    #         "extensions.getAddons.cache.enabled" = false;
    #         "extensions.getAddons.showPane" = false;
    #         "extensions.pocket.enabled" = false;
    #         "extensions.webservice.discoverURL" = "";
    #         "general.useragent.locale" = "en-US";
    #         "identity.fxaccounts.account.device.name" = config.networking.hostName;
    #         "privacy.donottrackheader.enabled" = true;
    #         "privacy.donottrackheader.value" = 1;
    #         "privacy.trackingprotection.enabled" = true;
    #         "privacy.trackingprotection.cryptomining.enabled" = true;
    #         "privacy.trackingprotection.fingerprinting.enabled" = true;
    #         "privacy.trackingprotection.socialtracking.enabled" = true;
    #         "privacy.trackingprotection.socialtracking.annotate.enabled" = true;
    #         "reader.color_scheme" = "auto";
    #         "services.sync.declinedEngines" = "addons,passwords,prefs";
    #         "services.sync.engine.addons" = false;
    #         "services.sync.engineStatusChanged.addons" = true;
    #         "services.sync.engine.passwords" = false;
    #         "services.sync.engine.prefs" = false;
    #         "services.sync.engineStatusChanged.prefs" = true;
    #         "signon.rememberSignons" = false;
    #         "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    #         "toolkit.telemetry.enabled" = false;
    #         "toolkit.telemetry.rejected" = true;
    #         "toolkit.telemetry.updatePing.enabled" = false;
    #       };
    #     }
    #     (mkIf isLinux {
    #       userChrome = builtins.readFile ../../conf.d/userChrome.css;
    #     })
    #   ];
    # };

    programs.fzf.enable = true;
    programs.fzf.enableZshIntegration = true;

    # programs.browserpass = optional isLinux {
    #   enable = true;
    #   browsers = ["firefox"];
    # };
  };
}
