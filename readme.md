# nix-velocity
This is an isolation of my original minecraft setup, my thought is that someone else would probably also be interested in a hassle-free velocity setup. The options are defined like:

```nix
    minecraft = {
        icon = ./files/icon.png; # has to be 64x64
        # relevant velocity settings can also be set here
        # host and port has been split for convenience
        host = "example.org";
        port = 25565;
        motd = "<rainbow>Hello world!"; # field in velocity, supports minimessage
        online-mode = true;

        # servers will go into their own directories
        servers = {
            hub = {
                version = "1.21";
                type = "paper"; # can also be fabric, replace the plugins below with a mods attr instead
                # plugins are just a set with a name field and a versions field, versions is accessed with server.version, and should evaluate to a path type
                plugins = with (import ./instances { inherit pkgs; }).plugins; [
                    decent-holograms
                    iportal-updated
                ];
                # config options, the root level ones are placed into server.properties, spigot options are placed in spigot.yml etc.
                # supported configs are spigot.yml, bukkit.yml, paper-global.yml, paper-world-defaults.yml and server.properties
                server-port = 25566; # has to be unique per server instance
                gamemode = "adventure";
                spigot.players.disable-saving = true;
            };
        };
    };

```
This repo also contains a flake to run a test server in a virtual machine

## Sources

[Velocity Documentation](https://docs.papermc.io/velocity)
[Papermc Documentation](https://docs.papermc.io/paper)