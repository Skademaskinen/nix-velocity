{pkgs, instances, ...}: let

    test-versions = versions: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (version: drv: "\t${version}:\t${drv}") versions));
    process-instance-set = set: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: instance: "${instance.name}:\n${test-versions instance.versions}") set));

in pkgs.writeScriptBin "test-instances" ''
    #!${pkgs.bash}/bin/bash
    echo "Running tests..."
    echo "- Testing plugins..."
    echo "${process-instance-set instances.plugins}"
    echo "- Testing mods..."
    echo "${process-instance-set instances.mods}"
    echo "- Testing server jars..."
    echo "${process-instance-set { "paper" = instances.paper; "fabric" = instances.fabric; }}"
    echo "Test finished"
''