{config, pkgs, lib, ...}: let
    cfg = config.services.minecraft;
    utils = import ../utils { inherit pkgs lib;};

    paper-wrapped = import ./paper.nix { inherit config pkgs lib; };
    fabric-wrapped = import ./fabric.nix { inherit config pkgs lib; };
    velocity-wrapped = import ./velocity.nix { inherit config pkgs lib; };
in {
    users.users.minecraft = {
        isSystemUser = true;
        group = "minecraft";
        packages = with pkgs; [jdk21];
    };
    users.groups.minecraft = {};
    systemd.services = let 
        services = {
            velocity = {
                enable = true;
                serviceConfig = {
                    User = "minecraft";
                    ExecStart = "${pkgs.bash}/bin/bash ${velocity-wrapped}/bin/velocity-wrapped";
                    StandardInput = "socket";
                    StandardOutput = "journal";
                    StandardError = "journal";
                    Sockets = "velocity.socket";
                };
                wantedBy = ["default.target"];
                after = ["minecraft-setup.service"];
            };
            minecraft-setup = {
                enable = true;
                serviceConfig = {
                    Type = "oneshot";
                    ExecStart = "${pkgs.bash}/bin/bash ${pkgs.writeScriptBin "minecraft-setup" ''
                        mkdir -p ${cfg.prefix}/{velocity,${builtins.concatStringsSep "," (builtins.attrNames cfg.servers)}}
                        mkdir -p ${cfg.prefix}/sockets
                        chown -R minecraft:minecraft ${cfg.prefix}
                    ''}/bin/minecraft-setup";
                };
                wantedBy = ["network-online.target"];
            };
        };
    in if (utils.attrLength cfg.servers) > 0 then services // builtins.mapAttrs (name: server: {
        enable = true;
        serviceConfig = {
            User = "minecraft";
            ExecStart = "${pkgs.bash}/bin/bash ${
                if server.type == "paper" then 
                    paper-wrapped (pkgs.lib.mergeAttrs {name = name;} server)
                else if server.type == "fabric" then
                    fabric-wrapped (pkgs.lib.mergeAttrs {name = name;} server)
                else ""}/bin/${server.type}-wrapped";
            StandardInput = "socket";
            StandardOutput = "journal";
            StandardError = "journal";
            Sockets = "${name}.socket";
        };
        wantedBy = ["network-online.target"];
        after = ["minecraft-setup.service"];
    }) cfg.servers else {};
    systemd.sockets = let
        velocity = {
            enable = true;
            description = "velocity STDIN socket";
            socketConfig = {
                ListenFIFO = "${cfg.prefix}/sockets/velocity.stdin";
                Service = "velocity.service";
            };
        };
    in if (utils.attrLength cfg.servers) > 0 then pkgs.lib.mergeAttrs { velocity = velocity; } (builtins.mapAttrs (name: server: {
        enable = true;
        description = "${name} STDIN socket";
        socketConfig = {
            ListenFIFO = "${cfg.prefix}/sockets/${name}.stdin";
            Service = "${name}.service";
        };
    }) cfg.servers) else {};
}
