{pkgs, lib, ...}: let
    utils = import ../../utils { inherit pkgs lib; };
in bukkit-options: pkgs.writeText "bukkit.yml" (utils.nix2yml bukkit-options)