{config, pkgs, lib, ...}: let
    cfg = config.minecraft;

    fabric-wrapped = server: pkgs.stdenv.mkDerivation {
        name = "paper-wrapped-${server.name}";
        src = ./.;
        installPhase = ''
            mkdir -p $out/{bin,share/mods}
            echo "eula=true" > $out/share/eula.txt


            cp ${(import ./builders/server.properties.nix { inherit pkgs lib config; }) server} $out/share/server.properties

            cp ${(import ./builders/spigot.yml.nix { inherit pkgs lib; }) server.spigot} $out/share/spigot.yml

            cp ${(import ./builders/bukkit.yml.nix { inherit pkgs lib; }) server.bukkit} $out/share/bukkit.yml

            cat > $out/bin/fabric-wrapped << EOF
                mkdir -p ${cfg.prefix}/${server.name}/{mods,config}
                cd ${cfg.prefix}/${server.name}
                ln -s $out/share/eula.txt ${cfg.prefix}/${server.name}/eula.txt
                cp $out/share/server.properties ${cfg.prefix}/${server.name}
                cp $out/share/bukkit.yml ${cfg.prefix}/${server.name}
                cp $out/share/spigot.yml ${cfg.prefix}/${server.name}
                rm -f ${cfg.prefix}/${server.name}/mods/*.jar

                ${builtins.concatStringsSep "\n" (map (mod: "ln -s ${mod.versions.${server.version}} ${cfg.prefix}/${server.name}/mods/${mod.name}") server.mods)}

                echo "secret = \"${cfg.secret}\"" > ${cfg.prefix}/${server.name}/config/FabricProxy-Lite.toml

                chmod +rw ${cfg.prefix}/${server.name}/{bukkit.yml,spigot.yml,server.properties}

                ${pkgs.jdk21}/bin/java -jar ${server.jars.fabric.versions.${server.version}}
EOF
            chmod +x $out/bin/fabric-wrapped
        '';
    };
in fabric-wrapped
