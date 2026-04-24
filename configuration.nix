{ pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  
  networking.hostName = "tankles";
  networking.networkmanager.enable = true;
  
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Denver";
  
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  users.users.tank = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };
  
  security.sudo.wheelNeedsPassword = false;
  
  environment.systemPackages = with pkgs; [ opencode ];
  
  system.stateVersion = "25.11";
}