{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../common/default.nix
    ./kanshi.nix
  ];

  # ホスト名を設定
  networking.hostName = "nixos";

  # ブートローダー設定
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Bluetooth設定
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  hardware.bluetooth.settings = {
    General = {
      FastConnectable = true;
      JustWorksRepairing = "always";
      Privacy = "off";
    };
    Policy = {
      AutoEnable = true;
    };
    LE = {
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
      ConnectionSupervisionTimeout = 100;
    };
  };
  services.blueman.enable = true;

  # ハードウェア・カーネル関連の設定
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = [ pkgs.linux-firmware ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [
    {
      name = "btusb-add-13d3-3614-mt7922";
      patch = ./btusb-mt7922-3614.patch;
    }
  ];
}
