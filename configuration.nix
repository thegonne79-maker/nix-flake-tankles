# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
  ];

  # 1. Audio: PipeWire with Pulse compatibility (Required for Mumble/Discord)
  services.pipewire = { 
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true; 
  };
  services.pulseaudio.enable = false;

  # 2. Hardware & Graphics (Alienware 18 Area 51)
  hardware = {
    sane.enable = true;
    graphics.enable = true;
    graphics.enable32Bit = true;
    nvidia = {
      prime = {
         sync.enable = true;
         nvidiaBusId = "PCI:2:0:0";
         intelBusId = "PCI:0:2:0";
      };
      nvidiaSettings = true;
      open = true;
      modesetting.enable = false;
      powerManagement.enable = true;
    };
  };

  # 3. Networking & Global
  networking = {
    hostName = "tankles";
    networkmanager.enable = true;
  };
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # 4. Bootloader
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # 5. Desktop & Services
  services = {
    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
    };
    desktopManager.plasma6.enable = true;
    libinput.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
  };

  # 6. Users
  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    initialHashedPassword = "$6$TzU.CpFK088tfL/f$Tj2Pd908u4DWD8JLfNVdsA0YbiFDf99Nf87lCvqI63fIw092K8hKgY1CUwkss.qEsxAAlS15CaNTgCjXrAx4a0";
  };

  security.sudo.wheelNeedsPassword = false;

  # 7. Programs & Packages
  programs = {
    steam.enable = true;
    firefox.enable = true;
    chromium.enable = true;
    mtr.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  environment.systemPackages = with pkgs; [
    discord
    flatpak
    lutris
    vivaldi
    vivaldi-ffmpeg-codecs
    (mumble.override { pulseSupport = true; }) # This fixes the JBL headset in Mumble
    pavucontrol
    neovim
    spotify
    tmate
    vim
    wasistlos
    wget
    whatsapp-electron
    wine
    opencode
  ];

  system.stateVersion = "25.11"; 
} 


   
  

 
