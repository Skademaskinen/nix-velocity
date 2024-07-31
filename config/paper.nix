{config, pkgs, lib, ...}: let
    cfg = config.minecraft;
    
    paper-wrapped = server: pkgs.stdenv.mkDerivation {
        name = "paper-wrapped-${server.name}";
        src = ./.;
        installPhase = ''
            mkdir -p $out/{bin,share/config}


            cp ${(import ./builders/server.properties.nix { inherit pkgs lib config; }) server} $out/share/server.properties

            cp ${(import ./builders/paper-global.yml.nix { inherit pkgs lib; }) server.paper-global} $out/share/config/paper-global.yml

            cp ${(import ./builders/paper-world-defaults.yml.nix { inherit pkgs lib; }) server.paper-world} $out/share/config/paper-world-defaults.yml

            cp ${(import ./builders/spigot.yml.nix { inherit pkgs lib; }) server.spigot} $out/share/spigot.yml

            cp ${(import ./builders/bukkit.yml.nix { inherit pkgs lib; }) server.bukkit} $out/share/bukkit.yml

            ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: ''
                mkdir -p $(dirname $out/share/${name})
                echo "${value}" > $out/share/${name}
            '') server.extra-configs))}

            cat > $out/bin/paper-wrapped << EOF
                mkdir -p ${cfg.prefix}/${server.name}/{config,plugins}
                cd ${cfg.prefix}/${server.name}
                ln -sf ${pkgs.writeText "eula.txt" "eula=${if cfg.eula then "true" else "false"}"} ${cfg.prefix}/${server.name}/eula.txt
                cp -r $out/share/* ${cfg.prefix}/${server.name}
                rm -f ${cfg.prefix}/${server.name}/plugins/*.jar

                ${builtins.concatStringsSep "\n" (map (plugin: "ln -sf ${plugin.versions.${server.version}} ${cfg.prefix}/${server.name}/plugins/${plugin.name}") server.plugins)}

                chmod +rw ${cfg.prefix}/${server.name}/{bukkit.yml,spigot.yml,server.properties,config/paper-world-defaults.yml,config/paper-global.yml}
                ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: ''
                    chmod +rw $(dirname ${cfg.prefix}/${server.name}/${name})
                    chmod +rw ${cfg.prefix}/${server.name}/${name}
                '') server.extra-configs))}

                ${pkgs.jdk21}/bin/java -jar ${server.jars.paper.versions.${server.version}}
EOF
            chmod +x $out/bin/paper-wrapped
        '';
    };
in paper-wrapped
