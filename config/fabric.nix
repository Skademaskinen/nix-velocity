{config, pkgs, lib, ...}: let
    cfg = config.services.minecraft;

    fabric-wrapped = server: pkgs.stdenv.mkDerivation {
        name = "paper-wrapped-${server.name}";
        src = ./.;
        installPhase = ''
            mkdir -p $out/{bin,share/mods}


            cp ${(import ./builders/server.properties.nix { inherit pkgs lib config; }) server} $out/share/server.properties

            cp ${(import ./builders/spigot.yml.nix { inherit pkgs lib; }) server.spigot} $out/share/spigot.yml

            cp ${(import ./builders/bukkit.yml.nix { inherit pkgs lib; }) server.bukkit} $out/share/bukkit.yml

            ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: ''
                mkdir -p $(dirname $out/share/${name})
                echo "${value}" > $out/share/${name}
            '') server.extra-configs))}

            cat > $out/bin/fabric-wrapped << EOF
                mkdir -p ${cfg.prefix}/${server.name}/{mods,config}
                cd ${cfg.prefix}/${server.name}
                ln -sf ${pkgs.writeText "eula.txt" "eula=${if cfg.eula then "true" else "false"}"} ${cfg.prefix}/${server.name}/eula.txt
                cp -r $out/share/* ${cfg.prefix}/${server.name}
                rm -f ${cfg.prefix}/${server.name}/mods/*.jar

                ${builtins.concatStringsSep "\n" (map (mod: "ln -s ${mod.versions.${server.version}} ${cfg.prefix}/${server.name}/mods/${mod.name}") server.mods)}

                echo "secret = \"${cfg.secret}\"" > ${cfg.prefix}/${server.name}/config/FabricProxy-Lite.toml

                chmod +rw ${cfg.prefix}/${server.name}/{bukkit.yml,spigot.yml,server.properties}
                ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: ''
                    chmod +rw $(dirname ${cfg.prefix}/${server.name}/${name})
                    chmod +rw ${cfg.prefix}/${server.name}/${name}
                '') server.extra-configs))}

                ${pkgs.jdk21}/bin/java ${builtins.concatStringsSep " " server.jvm-args} -jar ${server.jars.fabric.versions.${server.version}}
EOF
            chmod +x $out/bin/fabric-wrapped
        '';
    };
in fabric-wrapped
