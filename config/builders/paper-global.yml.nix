{pkgs, lib, ...}: let
    utils = import ../../utils { inherit pkgs lib; };

in paper-global-settings: pkgs.writeText "paper-global.yml" (utils.nix2yml paper-global-settings)