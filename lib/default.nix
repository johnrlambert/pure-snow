{ lib, ... }:

{
  hasRole = role: roles:
    let
      path = if builtins.isList role then role else lib.splitString "." role;
      dotted = lib.concatStringsSep "." path;
      value =
        if builtins.isAttrs roles
        then lib.attrByPath path null roles
        else null;
    in
    if roles == null then false
    else if builtins.isList roles then builtins.elem dotted roles
    else if builtins.isBool value then value
    else if builtins.isAttrs value then value.enable or false
    else false;
}
