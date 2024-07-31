{
    description = "Nix PaperMC and Fabric Options";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-24.05";
    };

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
    in rec {
        packages.${system} = let
            web-port = 8080;
        in {
            default = let
                cfg = {config, pkgs, lib, ...}: {
                    system.stateVersion = "24.05";
                    minecraft.servers = {
                        fabric = {
                            type = "fabric";
                            mods = with instances.mods; [
                                servux
                                fabric-proxy-lite
                            ];
                        };
                        paper = {
                            type = "paper";
                            plugins = with instances.plugins; [
                                decent-holograms
                                iportal-updated
                                dynmap
                            ];
                            extra-configs."plugins/dynmap/configuration.txt" = ''
                                webserver-port: ${builtins.toString web-port}
                            '';
                        };
                    };
                    minecraft.port = 25565;
                    minecraft.eula = true;

                    users.users.root.packages = with pkgs; [nmap htop (mc-cmd config)];
                    users.users.root.password = "root";
                    users.users.root.shell = pkgs.zsh;
                    programs.zsh.enable = true;
                    virtualisation.vmVariant = {
                        virtualisation.graphics = false;
                        virtualisation.forwardPorts = [
                            { from = "host"; host.port = 2222; guest.port = 22; }
                            { from = "host"; host.port = web-port; guest.port = web-port; }
                            { from = "host"; host.port = config.minecraft.port; guest.port = config.minecraft.port; }
                        ];
                        virtualisation.memorySize = 8192;
                        virtualisation.cores = 4;

                    };
                    services.getty.autologinUser = "root";
                    networking.firewall.enable = false;
                    networking.hostName = "nix-velocity";
                    services.openssh.enable = true;
                    services.openssh.settings.PermitRootLogin = "yes";

                };
            in (nixpkgs.lib.nixosSystem {
                inherit system;
                modules = [
                    nixosModules.default
                    cfg
                ];
            }).config.system.build.vm;

            test-instances = import ./utils/test-instances.nix {inherit pkgs instances;};
        };
        
        nixosModules.default = import ./.;
        mc-cmd = config: import ./utils/mc-cmd.nix {inherit pkgs config;};
        instances = import ./instances { inherit pkgs; };
        utils = import ./utils {inherit pkgs; lib = pkgs.lib; };
    };

}
