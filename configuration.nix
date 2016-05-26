# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.initrd.luks.cryptoModules = ["aes" "sha256" "xts"];
  boot.initrd.luks.devices = [ { name = "luksroot";
                                 device = "/dev/sda2";
				 preLVM = true;
				 allowDiscards = true; } ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.efiSupport = true;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda";

  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";
  i18n.consoleKeyMap = "uk";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    wget
    emacs
    awesome
    chromium
    roxterm
    slock
    zsh
    gcc
    acpi
    git
    xfce.thunar
    openjdk
    python27Full

    ruby_2_2_3
    bluez5
    tig
    htop
    which
    #dropbox
    keepassx
    slack
    filezilla
    networkmanagerapplet
    pkgconfig
    unzip
    go_1_6
    gnumake380
    tree
    scrot
    rfkill
    postgresql
    libreoffice
  ];

  programs.zsh.enable = true;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  services.mysql = {
    enable = true;
    rootPassword = "";
    package = pkgs.mysql;
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "uk";
  services.xserver.displayManager.sessionCommands = "${pkgs.networkmanagerapplet}/bin/nm-applet &";
  services.xserver.multitouch = {
    enable = true;
    invertScroll = true;
    ignorePalm = true;
    buttonsMap = [ 1 0 3 ];
    additionalOptions = ''
      Option "Sensitivity" "0.3"
      Option "TapButton1" "1"
      Option "TapButton2" "1"
      Option "TapButton3" "1"
      Option "ButtonZonesEnabled" "true"
    '';
  };
  services.xserver.windowManager.awesome.enable = true;

  # some combination of these enable my bluetooth mouse
  hardware.bluetooth.enable = true;
  services.gpsd.readonly = false;
  services.gpm.enable = true;

  security.setuidPrograms = [ "slock" ];

  users.extraUsers."hugo.firth" ={
    isNormalUser = true;
    home = "/home/hugo.firth";
    description = "Hugo Firth";
    extraGroups = [ "wheel" "networkmanager" "docker"];
  };

  systemd.user.services.emacs = {
    description = "Emacs Daemon";
    environment = {
      NIX_PROFILES = "${pkgs.lib.concatStringsSep " " config.environment.profiles}";
      TERMINFO_DIRS = "/run/current-system/sw/share/terminfo";
      GTK_DATA_PREFIX = config.system.path;
      SSH_AUTH_SOCK = "%t/ssh-agent";
      GTK_PATH = "${config.system.path}/lib/gtk-3.0:${config.system.path}/lib/gtk-2.0";
    };
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.bash}/bin/bash -c 'source ${config.system.build.setEnvironment}; ${pkgs.emacs}/bin/emacs --daemon";
      ExecStop = "${pkgs.emacs}/bin/emacsclient --eval (kill-emacs)";
      Restart = "always";
    };
    wantedBy = [ "default.target" ];
  };
  systemd.services.emacs.enable = true;

  powerManagement.enable = true;
  hardware.pulseaudio.enable = true;
  fonts = {
    enableCoreFonts = true;
    enableFontDir = true;
    enableGhostscriptFonts = false;
    fonts = [
      pkgs.terminus_font
    ];
  };
  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "16.03";

}
