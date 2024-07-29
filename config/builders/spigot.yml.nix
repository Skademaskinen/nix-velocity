{pkgs, lib, ...}: let
    utils = import ../../utils { inherit pkgs lib; };
in spigot-options: pkgs.writeText "spigot.yml" (utils.nix2yml spigot-options)