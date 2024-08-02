{pkgs, ...}: {
    paper = {
        name = "paper.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://api.papermc.io/v2/projects/paper/versions/1.21/builds/109/downloads/paper-1.21-109.jar";
            sha256 = "sha256-dsYGExSUEl8GTcLtQBuUbUoS4IvwzNvzLtqgi2Yzwwo=";
        };
    };
    fabric = {
        name = "fabric.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://meta.fabricmc.net/v2/versions/loader/1.21/0.15.11/1.0.1/server/jar";
            sha256 = "sha256-ZRSgXk5CChjXYnNTTudV1fV1ijc/Nh4Jd9NDQKZVkYU=";
        };
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://meta.fabricmc.net/v2/versions/loader/1.20.1/0.15.11/1.0.1/server/jar";
            sha256 = "sha256-/j9wIzYSoP+ZEfeRJSsRwWhhTNkTMr+vN40UX9s+ViM=";
        };
    };
    mods.fabric-proxy-lite = {
        name = "fabric-proxy-lite.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://github.com/OKTW-Network/FabricProxy-Lite/releases/download/v2.9.0/FabricProxy-Lite-2.9.0.jar";
            sha256 = "sha256-wIQA86Uh6gIQgmr8uAJpfWY2QUIBlMrkFu0PhvQPoac=";
        };
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/8dI2tmqs/versions/XJmDAnj5/FabricProxy-Lite-2.6.0.jar";
            sha256 = "sha256-1HGReTU9eQRTBhwUtBSJlP9DGsV6EmVVswCc6adI1sc=";
        };
    };
    mods.fabric-api = {
        name = "fabric-api.jar";
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/P7dR8mSH/versions/P7uGFii0/fabric-api-0.92.2%2B1.20.1.jar";
            sha256 = "sha256-RQD4RMRVc9A51o05Y8mIWqnedxJnAhbgrT5d8WxncPw=";
        };
    };
    mods.servux = {
        name = "servux.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/MBfJui8X/servux-fabric-1.21.0-0.2.0.jar";
            sha256 = "sha256-td2eH5IDDH+7u22l1TNyBsiisMvvpMJXS00aOB0YtDY=";
        };
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/zQhsx8KF/versions/I7wfvH49/servux-fabric-1.20.0-0.1.0.jar";
            sha256 = "sha256-zUsjuD2tQKcLPHU1rdx24Wbp6vguH7CLOeDwPrzj0H0=";
        };
    };
    mods.worldedit = {
        name = "worldedit.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/srWerknn/worldedit-mod-7.3.5.jar";
            sha256 = "sha256-dtJQ9DMZ2RqVlIzUwHRtydFdXpV3c7hDIZhB0ftsn3I=";
        };
    };
    mods.immersive-portals = {
        name = "immersive-portals.jar";
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/zJpHMkdD/versions/155jtqJi/immersive-portals-3.3.9-mc1.20.1-fabric.jar";
            sha256 = "sha256-vrNfdLmLU3t7V3Q7aFT88ZAAqabZP2EfZJQBOD5mAE4=";
        };
    };
    mods.cross-stitch = {
        name = "cross-stitch.jar";
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/YkOyn1Pn/versions/dJioNlO8/crossstitch-0.1.6.jar";
            sha256 = "sha256-z1qsXFV5sc6xsr0loV8eLcySJvV2cBY60fhBsvkFuC4=";
        };
    };
    mods.create = {
        name = "create.jar";
        versions."1.20.1" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/Xbc0uyRg/versions/h2HgGyvA/create-fabric-0.5.1-f-build.1417%2Bmc1.20.1.jar";
            sha256 = "sha256-EahQ02ibR3HV+nBf+n3XEYJ8abcQgpVll+XQUUccwe4=";
        };
    };
    plugins.decent-holograms = {
        name = "decentholograms.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://github.com/DecentSoftware-eu/DecentHolograms/releases/download/2.8.9/DecentHolograms-2.8.9.jar";
            sha256 = "sha256-rEV5rbPXA5WFPwU+K3XO0LMC2i0PvTA0SYtE/1wTMbA=";
        };
    };
    plugins.iportal-updated = {
        name = "iportal.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://github.com/JuL1En1997/Iportal/releases/download/major-update/Iportal-Updated-2.0.jar";
            sha256 = "sha256-uF4Izym8nvQVo8jhm41AG5re4RrUYUmVjFPsHIuBiyI=";
        };
    };
    plugins.worldedit = {
        name = "worldedit.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/1u6JkXh5/versions/Jo76t1oi/worldedit-bukkit-7.3.5.jar";
            sha256 = "sha256-xMIsPMKop0pNWThOFsiA0TTrwEotN4FYkpy+MF8ctSA=";
        };
    };
    plugins.dynmap = {
        name = "dynmap.jar";
        versions."1.21" = pkgs.fetchurl {
            url = "https://cdn.modrinth.com/data/fRQREgAc/versions/QtTWJjW6/Dynmap-3.7-beta-6-spigot.jar";
            sha256 = "sha256-c1gWhb/JBZ8aD5fWE7vqVOhqGwlPAi08aZ82SIRSU94=";
        };
    };
}
