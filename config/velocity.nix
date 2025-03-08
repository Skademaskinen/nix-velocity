{config, pkgs, lib, ...}: let 
    cfg = config.services.minecraft;
    utils = import ../utils { inherit pkgs lib; };
    
    velocity = pkgs.fetchurl {
        url = "https://api.papermc.io/v2/projects/velocity/versions/3.3.0-SNAPSHOT/builds/412/downloads/velocity-3.3.0-SNAPSHOT-412.jar";
        sha256 = "sha256-KOBsdASYlUxf2np87DK3KnSHFM5hMjPqdYD2Ati8yIQ=";
    };

    velocity-wrapped = pkgs.stdenv.mkDerivation {
        name = "velocity-wrapped";
        src = ./.;
        installPhase = with utils; ''
            mkdir -p $out/{bin,share}
            cat > $out/share/velocity.toml << EOF
                config-version = "${cfg.version}"
                bind = "0.0.0.0:${parseValue cfg.port}"
                motd = "${cfg.motd}"
                show-max-players = ${parseValue cfg.max-players}
                online-mode = ${parseValue cfg.online-mode}
                force-key-authentication = ${parseValue cfg.force-key-authentication}
                prevent-client-proxy-connections = ${parseValue cfg.prevent-client-proxy-connections}
                player-info-forwarding-mode = "${cfg.player-info-forwarding-mode}"
                forwarding-secret-file = "${pkgs.writeText "secret" cfg.secret}"
                annouce-forge = ${parseValue cfg.announce-forge}
                kick-existing-players = ${parseValue cfg.kick-existing-players}
                ping-passthrough = "${cfg.ping-passthrough}"
                enable-player-address-logging = ${parseValue cfg.enable-player-address-logging}
                [servers]
EOF

            cat > $out/share/populate-servers.py << EOF
names = "${parseValue (builtins.attrNames cfg.servers)}".split(" ")
ports = [int(p) for p in "${parseValue (builtins.attrValues (builtins.mapAttrs (name: value: if value.server-port == null then
    parseValue (cfg.port + 1 + (getIndex name (builtins.attrNames cfg.servers)))
else
    parseValue value.server-port) cfg.servers))}".split(" ")]

with open("$out/share/velocity.toml", "a") as file:
    for name, port in zip(names, ports):
        file.write(f'{name} = "127.0.0.1:{port}"\n')
    file.write(f'try = ["${cfg.fallback}"]\n')
    file.write(f'[forced-hosts]\n')
    for name, port in zip(names, ports):
        file.write(f'"{name}.${cfg.host}" = ["{name}"]\n')
EOF

            ${pkgs.python311}/bin/python $out/share/populate-servers.py

            cat >> $out/share/velocity.toml << EOF
                [advanced]
                compression-thresshold = ${parseValue cfg.advanced.compression-threshold}
                compression-level = ${parseValue cfg.advanced.compression-level}
                login-ratelimit = ${parseValue cfg.advanced.login-ratelimit}
                connection-timeout = ${parseValue cfg.advanced.connection-timeout}
                read-timeout = ${parseValue cfg.advanced.read-timeout}
                haproxy-protocol = ${parseValue cfg.advanced.haproxy-protocol}
                tcp-fast-open = ${parseValue cfg.advanced.tcp-fast-open}
                bungee-plugin-message-channel = ${parseValue cfg.advanced.bungee-plugin-message-channel}
                show-ping-requests = ${parseValue cfg.advanced.show-ping-requests}
                failover-on-unexpected-server-disconnect = ${parseValue cfg.advanced.failover-on-unexpected-server-disconnect}
                announce-proxy-commands = ${parseValue cfg.advanced.announce-proxy-commands}
                log-command-executions = ${parseValue cfg.advanced.log-command-executions}
                log-player-connections = ${parseValue cfg.advanced.log-player-connections}
                accepts-transfers = ${parseValue cfg.advanced.accepts-transfers}

                [query]
                enabled = ${parseValue cfg.query.enabled}
                port = ${parseValue cfg.query.port}
                map = "${cfg.query.map}"
                show-plugins = ${parseValue cfg.query.show-plugins}
EOF

            cat > $out/bin/velocity-wrapped << EOF
                mkdir -p ${cfg.prefix}/velocity
                cd ${cfg.prefix}/velocity
                rm -f ${cfg.prefix}/velocity/velocity.toml
                ${if cfg.icon != null then 
                    "ln -s ${cfg.icon} ${cfg.prefix}/velocity/server-icon.png" 
                else 
                    ""}
                cp $out/share/velocity.toml ${cfg.prefix}/velocity/velocity.toml

                rm ${cfg.prefix}/velocity/plugins/*.jar
                ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: path: "cp ${path} ${cfg.prefix}/velocity/plugins/${name}") cfg.plugins))}

                ${pkgs.jdk21}/bin/java -jar ${velocity}
EOF

            chmod +x $out/bin/velocity-wrapped
        '';
    };
in velocity-wrapped
