{
  lib,
  pkgs,
  fetchCatppuccinPort,
}: {
  port,
  rev,
  hash,
  extraSubstitutions ? [],
}: let
  pristine = fetchCatppuccinPort {
    inherit port rev hash;
  };

  replacementTable = [
    ["#cdd6f4" "#f4f4f4"] # text
    ["#bac2de" "#e0e0e0"] # subtext1
    ["#a6adc8" "#c6c6c6"] # subtext0
    ["#9399b2" "#a8a8a8"] # overlay2
    ["#7f849c" "#8d8d8d"] # overlay1
    ["#6c7086" "#6f6f6f"] # overlay0
    ["#585b70" "#525252"] # surface2
    ["#45475a" "#393939"] # surface1
    ["#313244" "#262626"] # surface0
    ["#1e1e2e" "#161616"] # base
    ["#181825" "#0b0b0b"] # mantle
    ["#11111b" "#000000"] # crust
  ];

  replacements = replacementTable ++ extraSubstitutions;

  sedScript = ''
    ${lib.concatMapStringsSep "\n"
      (p: "s,${lib.escapeShellArg (builtins.elemAt p 0)},${lib.escapeShellArg (builtins.elemAt p 1)},g")
      replacements}
  '';

  grepFlags =
    lib.concatMapStringsSep " "
    (p: "-e ${lib.escapeShellArg (builtins.elemAt p 0)}")
    replacements;
in
  pkgs.runCommandLocal "catppuccin-${port}-patched" {src = pristine;} ''
    cp -r $src $out

    # Only touch files that actually contain one of the patterns
    grep -IlR --null ${grepFlags} $out \
      | xargs -0 sed -i -e ${lib.escapeShellArg sedScript}
  ''
