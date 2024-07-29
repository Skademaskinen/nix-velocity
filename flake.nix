{
    description = "Nix PaperMC and Fabric Options";

    inputs = {
        nixpkgs.url = "nixpkgs/nixos-24.05";
    };

    outputs = { self, nixpkgs }: let
        system = "x86_64-linux";
        pkgs = import nixpkgs {inherit system;};
    in rec {
        packages.${system} = {
            default = let
                cfg = {config, pkgs, lib, ...}: {
                    system.stateVersion = "24.05";
                    minecraft.servers = {
                        fabric = {
                            server-port = 25566;
                            type = "fabric";
                            mods = with instances.mods; [
                                servux
                                fabric-proxy-lite
                            ];
                        };
                        paper = {
                            server-port = 25567;
                            type = "paper";
                            plugins = with instances.plugins; [
                                decent-holograms
                                iportal-updated
                            ];
                        };
                    };
                    minecraft.port = 25565;
                    users.users.root.packages = with pkgs; [nmap htop (import ./utils/mc-cmd.nix {inherit config pkgs lib;})];
                    users.users.root.password = "root";
                    users.users.root.shell = pkgs.zsh;
                    programs.zsh.enable = true;
                    virtualisation.vmVariant = {
                        virtualisation.graphics = false;
                        virtualisation.forwardPorts = [
                            { from = "host"; host.port = 2222; guest.port = 22; }
                            { from = "host"; host.port = config.minecraft.port; guest.port = config.minecraft.port; }
                        ];
                        virtualisation.memorySize = 8192;
                        virtualisation.cores = 4;

                    };
                    services.getty.autologinUser = "root";
                    networking.firewall.allowedTCPPorts = [
                        config.minecraft.port
                        22
                    ];
                    networking.hostName = "nix-velocity";
                    services.openssh.enable = true;
                    services.openssh.settings.PermitRootLogin = "yes";

                };
            in (nixpkgs.lib.nixosSystem {
                inherit system;
                modules = [
                    ./.
                    cfg
                ];
            }).config.system.build.vm;

            test-instances = import ./utils/test-instances.nix {inherit pkgs instances;};
        };
        
        nixosModules.default = import ./.;
        mc-cmd = config: import ./utils/mc-cmd.nix {inherit pkgs config;};
        instances = import ./instances { inherit pkgs; };
    };

}
