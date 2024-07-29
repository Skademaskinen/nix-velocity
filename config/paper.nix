{config, pkgs, lib, ...}: let
    cfg = config.minecraft;
    
    paper-wrapped = server: pkgs.stdenv.mkDerivation {
        name = "paper-wrapped-${server.name}";
        src = ./.;
        installPhase = ''
            mkdir -p $out/{bin,share}
            echo "eula=true" > $out/share/eula.txt


            cp ${(import ./builders/server.properties.nix { inherit pkgs lib; }) server} $out/share/server.properties

            cp ${(import ./builders/paper-global.yml.nix { inherit pkgs lib; }) server.paper-global} $out/share/paper-global.yml

            cp ${(import ./builders/paper-world-defaults.yml.nix { inherit pkgs lib; }) server.paper-world} $out/share/paper-world-defaults.yml

            cp ${(import ./builders/spigot.yml.nix { inherit pkgs lib; }) server.spigot} $out/share/spigot.yml

            cp ${(import ./builders/bukkit.yml.nix { inherit pkgs lib; }) server.bukkit} $out/share/bukkit.yml

            cat > $out/bin/paper-wrapped << EOF
                mkdir -p ${cfg.prefix}/${server.name}/{config,plugins}
                cd ${cfg.prefix}/${server.name}
                ln -sf $out/share/eula.txt ${cfg.prefix}/${server.name}/eula.txt
                cp $out/share/paper-global.yml ${cfg.prefix}/${server.name}/config
                cp $out/share/paper-world-defaults.yml ${cfg.prefix}/${server.name}/config
                cp $out/share/server.properties ${cfg.prefix}/${server.name}
                cp $out/share/bukkit.yml ${cfg.prefix}/${server.name}
                cp $out/share/spigot.yml ${cfg.prefix}/${server.name}
                rm -f ${cfg.prefix}/${server.name}/plugins/*.jar

                ${builtins.concatStringsSep "\n" (map (plugin: "ln -sf ${plugin.versions.${server.version}} ${cfg.prefix}/${server.name}/plugins/${plugin.name}") server.plugins)}

                chmod +rw ${cfg.prefix}/${server.name}/{bukkit.yml,spigot.yml,server.properties,config/paper-world-defaults.yml,config/paper-global.yml}

                ${pkgs.jdk21}/bin/java -jar ${server.jars.paper.versions.${server.version}}
EOF
            chmod +x $out/bin/paper-wrapped
        '';
    };
in paper-wrapped
