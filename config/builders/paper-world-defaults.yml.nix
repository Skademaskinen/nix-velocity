{pkgs, lib, ...}: let
    utils = import ../../utils { inherit pkgs lib; };
in opts: pkgs.writeText "paper-world-defaults.yml" (utils.nix2yml opts)