{ config, lib, pkgs, inputs, ... }:
let
  unstable = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config.allowUnfree = true; };
in
{
  imports = [ ./hardware-configuration.nix ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # BOOTLOADER
  # ═══════════════════════════════════════════════════════════════════════════════
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 3;
    grub.enable = false;
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # NIX
  # ═══════════════════════════════════════════════════════════════════════════════
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.auto-optimise-store = true;
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # NETWORKING
  # ═══════════════════════════════════════════════════════════════════════════════
  networking.hostName = "tankles";
  networking.networkmanager.enable = true;
  networking.extraHosts = ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';

  services.tailscale.enable = true;
  services.openssh.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # LOCALIZATION
  # ═══════════════════════════════════════════════════════════════════════════════
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Denver";

  # ═══════════════════════════════════════════════════════════════════════════════
  # USER
  # ═══════════════════════════════════════════════════════════════════════════════
  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "bluetooth" "networkmanager" ];
    hashedPassword = "$6$DBbezqjoI2AL9.k5$PfVb9OH8fu8zAlQ3OPSuCx7EgE9SZUbmapNHlBgll4toTDIqxsVhlXlwBqyWGRnnYKI2lxD3rQ9UHIq9NDLJY0";
  };
  security.sudo.wheelNeedsPassword = false;

  # ═══════════════════════════════════════════════════════════════════════════════
  # DESKTOP (KDE Plasma 6)
  # ═══════════════════════════════════════════════════════════════════════════════
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde
    pkgs.moonlight-qt ];
  };

  # ═══════════════════════════════════════════════════════════════════════════════
  # NVIDIA (RTX 5090)
  # ═══════════════════════════════════════════════════════════════════════════════
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = true;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:2:0:0";
    };
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # AUDIO (PipeWire)
  # ═══════════════════════════════════════════════════════════════════════════════
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # BLUETOOTH
  # ═══════════════════════════════════════════════════════════════════════════════
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # KDE Wallet (for keyring/password storage)
  security.pam.services.sddm.enableKwallet = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # GAMING
  # ═══════════════════════════════════════════════════════════════════════════════
  programs.steam = {
    enable = true;
    extraCompatPackages = with unstable; [ proton-ge-bin ];
  };
  programs.steam.remotePlay.openFirewall = true;
  programs.gamemode.enable = true;

  # ═══════════════════════════════════════════════════════════════════════════════
  # SYSTEM PACKAGES
  # ═══════════════════════════════════════════════════════════════════════════════
  environment.systemPackages = with pkgs; [
    vim git htop btop wget curl unzip
    bat ripgrep jq magic-wormhole
    unstable.opencode
    firefox unstable.vivaldi chromium
    obsidian libreoffice
    vlc spotify gimp
    discord mumble
    unstable.prismlauncher
    steam steam-run
    nvtopPackages.nvidia
    kdePackages.xdg-desktop-portal-kde
    pkgs.moonlight-qt
  ];

  # ═══════════════════════════════════════════════════════════════════════════════
  # SUNSHINE (Game Streaming Server)
  # ═══════════════════════════════════════════════════════════════════════════════
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    };
    settings = {
      sunshine_name = "tankles";
      encoder = "nvenc";
      capture = "kms";
      adapter_name = "/dev/dri/card1";
    };
    applications.apps = [
      { name = "Desktop"; image-path = "desktop.png"; }
    ];
  };

  hardware.uinput.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };


  system.stateVersion = "25.11";

  # Fix KDE screen locker PAM authentication
  security.pam.services.kscreenlocker = {
    text = ''
      auth       include      login
      account    include      login
      password   include      login
      session    include      login
    '';
  };
}
