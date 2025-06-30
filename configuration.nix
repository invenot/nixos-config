# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, pkgs, config, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./packages.nix
      inputs.spicetify-nix.nixosModules.default
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.graphics = {
    enable = true;
  };

  programs.spicetify =
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = true;
    powerManagement.enable = true;
  };
  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."luks-65f4f2e1-651d-46df-a2ef-a92359ed81e7".device = "/dev/disk/by-uuid/65f4f2e1-651d-46df-a2ef-a92359ed81e7";
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Vilnius";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  security.doas.enable = true;
  security.sudo.enable = false;
  security.doas.extraRules = [{
    users = [ "inv" ];
    keepEnv = true;
    persist = true;
  }];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  programs.zsh.enable = true; programs.fish.enable = true;

  users.defaultUserShell = pkgs.fish;
  users.users.inv = {
    isNormalUser = true;
    description = "Inv Rainworld";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    shell = pkgs.fish;
  };

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [
    nerd-fonts._0xproto
    material-symbols
    material-icons
  ];
  fonts.fontconfig.defaultFonts.monospace = ["0xProto Nerd Font"];

  services.flatpak.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam ={
    enable=true;
    remotePlay.openFirewall=false;
    dedicatedServer = {
      openFirewall=true;
    };
    localNetworkGameTransfers.openFirewall=true;
  };
  programs.dconf.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-rofi;
    enableSSHSupport=true;
  };
  services.dbus.packages = [pkgs.gcr];
  qt.platformTheme = "qt5ct";

  services.tor = {
    enable = true;
    openFirewall = true;
    relay = {
      enable = true;
      role = "relay";
    };
    settings = {
      ContactInfo = "invenot@protonmail.ch";
      Nickname = "inv";
      ORPort = 9001;
      ControlPort = 9051;
      BandWidthRate = "1 MBytes";
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    #wlr.enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      #pkgs.xdg-desktop-portal-hyprland
      #pkgs.xdg-desktop-portal-kde
      pkgs.xdg-desktop-portal-wlr
    ];


    config.common.default = [ "*" ];
  };
  #xdg.enable = true;
  xdg.mime.enable = true;
  #xdg.mimeApps.enable = true;
  #xdg.mimeApps.defaultApplications = {
  #    "x-scheme-handler/roblox-player" = ["org.vinegarhq.Sober.desktop"];
  #    "x-scheme-handler/https" = ["app.zen-browser.zen.desktop"];
  #};
	  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };
  programs.zsh.promptInit = "source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-substituters = ["https://prismlauncher.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" "prismlauncher.cachix.org-1:9/n/FGyABA2jLUVfY+DEp4hKds/rwO+SCOtbOkDzd+c="];
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
# Edit this configuration file to define what should be installed on
