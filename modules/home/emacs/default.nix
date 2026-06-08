# modules/home/emacs/default.nix
{
  lib,
  config,
  pkgs,
  ...
}:

let
  enabled = config.homelab.emacs.enable or false;
  epkgs = pkgs.emacsPackages;

  mdTsMode = epkgs.trivialBuild {
    pname = "md-ts-mode";
    version = "0.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "dnouri";
      repo = "md-ts-mode";
      rev = "8644e1f5391d6915c386440807f2ff421a8d5c5b";
      sha256 = "16j8shjn5jlvgjx561ih6fqif1s93bzdi2hi1jyhi488h0is7qfr";
    };
  };

  markdownTableWrap = epkgs.trivialBuild {
    pname = "markdown-table-wrap";
    version = "0.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "dnouri";
      repo = "markdown-table-wrap";
      rev = "afc8214c6a2109891c5adf5ee7f75b8d8a2c4a35";
      sha256 = "0n21p6r3bdnpj611m79qlipr54rwk3sbg2bqqcybb9qnx8sfwl3g";
    };
  };

  piCodingAgent = epkgs.trivialBuild {
    pname = "pi-coding-agent";
    version = "2.3.1";
    src = pkgs.fetchFromGitHub {
      owner = "dnouri";
      repo = "pi-coding-agent";
      rev = "a23785b1ff6482b26d5ee48b73af18744a74ffee";
      sha256 = "00gyhklicxig1xvdxsd87laslqpih8ymcgs8sibsxrbr43wmffwj";
    };
    packageRequires = [
      epkgs.transient
      mdTsMode
      markdownTableWrap
    ];
  };

  tangleInit = pkgs.writeShellScript "tangle-emacs-init" ''
    set -euo pipefail

    if [ "$#" -ne 2 ]; then
      echo "usage: $0 INPUT.org OUTPUT.el" >&2
      exit 1
    fi

    input=$1
    output=$2
    emacs_bin=''${EMACS:-emacs}

    mkdir -p "$(dirname "$output")"

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    cp "$input" "$tmpdir/init.org"

    {
      printf '%s\n' "(require 'org)"
      printf '%s\n' "(require 'ob-tangle)"
      printf '%s\n' "(let ((default-directory \"$tmpdir/\")"
      printf '%s\n' "      (org-confirm-babel-evaluate nil))"
      printf '%s\n' "  (org-babel-tangle-file \"$tmpdir/init.org\"))"
    } > "$tmpdir/tangle.el"

    "$emacs_bin" --batch --quick -l "$tmpdir/tangle.el"
    cp "$tmpdir/init.el" "$output"
  '';

  tangledInit = pkgs.runCommand "emacs-init" {
    nativeBuildInputs = [ pkgs.emacs ];
  } ''
    export HOME="$TMPDIR"
    mkdir -p "$HOME" "$out"
    EMACS=${pkgs.emacs}/bin/emacs ${tangleInit} ${./init.org} "$out/init.el"
  '';
in
{
  options.homelab.emacs.enable = lib.mkEnableOption "Enable emacs with literate init.org";

  config = lib.mkIf enabled {
    home.packages = with pkgs; [
      emacs
      emacsPackages.eat
      epkgs.transient
      mdTsMode
      markdownTableWrap
      piCodingAgent
      bash
      gcc
      gnumake
      python3
      nodejs
      nodePackages.coffee-script
      mermaid-cli
    ];

    services.emacs = {
      enable = true;
      package = pkgs.emacs;
      client.enable = true;
      startWithUserSession = true;
    };

    home.file.".emacs.d/init.el".source = "${tangledInit}/init.el";
    home.file.".emacs.d/init.org".source = ./init.org;
    home.file.".emacs.d/capture-templates".source = ./capture-templates;
  };
}
