# modules/home/fish/default.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.fonts.enable or false;
in
{
  options.homelab.fonts.enable = lib.mkEnableOption "Get some solid fonts for icons, etc.";

  config = lib.mkIf enabled {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.symbols-only
      nerd-fonts.jetbrains-mono
      gyre-fonts
      helvetica-neue-lt-std
      inter
      jost
      libertinus

      # TeX Gyre Schola gives us a Century Schoolbook-like serif for legal docs.
      # Jost supplies the slightly more geometric / Bauhaus-ish headings.
      # If your nixpkgs doesn't support override above, try:
      # nerd-fonts-symbols
    ];
  };
}
