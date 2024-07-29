{pkgs, lib, ...}: with lib.types; {
    # reducing character count...
    tbool = lib.mkOption {
        type = bool;
        default = true;
    };
    fbool = lib.mkOption {
        type = bool;
        default = false;
    };
    intopt = v: lib.mkOption {
        type = int;
        default = v;
    };
    fopt = v: lib.mkOption {
        type = float;
        default = v;
    };
    stropt = s: lib.mkOption {
        type = str;
        default = s;
    };
    # slist :: [lib.types.str] -> [lib.types.str]
    slist = v: lib.mkOption {
        type = listOf str;
        default = v;
    };

    parseValue = value: 
        if value == true then 
            "true" 
        else if value == false then 
            "false" 
        else 
            builtins.toString value;

    attrLength = attrs: builtins.length (builtins.attrNames attrs);

    nix2yml = let
        makeIndent = indent: lib.concatMapStrings (_: " ") (lib.range 1 indent);

        _nix2yml = indent: object: builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: value: (
            if builtins.typeOf value == "bool" then
                "${makeIndent indent}${name}: ${if value then "true" else "false"}"
            else if builtins.typeOf value == "list" then
                "${makeIndent indent}${name}:${builtins.concatStringsSep "" (map (item: "\n${makeIndent (indent+2)}- ${item}") value)}"
            else if builtins.typeOf value == "set" then
                "${makeIndent indent}${name}:\n${_nix2yml (indent+2) value}"
            else 
                "${makeIndent indent}${name}: ${builtins.toString value}"
            )) object));
    in _nix2yml 0;
}