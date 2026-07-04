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

  fixedPitch = epkgs.trivialBuild {
    pname = "fixed-pitch";
    version = "0.0.0";
    src = pkgs.fetchFromGitHub {
      owner = "cstby";
      repo = "fixed-pitch-mode";
      rev = "112610111ea33c24ca7807eb884ec1ac7785fba4";
      sha256 = "1cv7g2ijchhvfbn75wx1hkrky8axfrczvk220xcp89jia80lf90d";
    };
  };

  obJson = pkgs.writeText "ob-json.el" ''
    ;;; ob-json.el --- Minimal Org Babel support for JSON  -*- lexical-binding: t; -*-

    (require 'ob)

    (defvar org-babel-default-header-args:json
      '((:results . "code")
        (:exports . "code"))
      "Default arguments for evaluating a JSON source block.")

    (defun org-babel-execute:json (body _params)
      "Return BODY unchanged for JSON source blocks."
      body)

    (defun org-babel-prep-session:json (&rest _)
      "JSON Babel blocks do not support sessions."
      (user-error "JSON Babel blocks do not support sessions"))

    (provide 'ob-json)
    ;;; ob-json.el ends here
  '';

  obYaml = pkgs.writeText "ob-yaml.el" ''
    ;;; ob-yaml.el --- Minimal Org Babel support for YAML  -*- lexical-binding: t; -*-

    (require 'ob)

    (defvar org-babel-default-header-args:yaml
      '((:results . "code")
        (:exports . "code"))
      "Default arguments for evaluating a YAML source block.")

    (defun org-babel-execute:yaml (body _params)
      "Return BODY unchanged for YAML source blocks."
      body)

    (defun org-babel-prep-session:yaml (&rest _)
      "YAML Babel blocks do not support sessions."
      (user-error "YAML Babel blocks do not support sessions"))

    (provide 'ob-yaml)
    ;;; ob-yaml.el ends here
  '';

  obToml = pkgs.writeText "ob-toml.el" ''
    ;;; ob-toml.el --- Minimal Org Babel support for TOML  -*- lexical-binding: t; -*-

    (require 'ob)

    (defvar org-babel-default-header-args:toml
      '((:results . "code")
        (:exports . "code"))
      "Default arguments for evaluating a TOML source block.")

    (defun org-babel-execute:toml (body _params)
      "Return BODY unchanged for TOML source blocks."
      body)

    (defun org-babel-prep-session:toml (&rest _)
      "TOML Babel blocks do not support sessions."
      (user-error "TOML Babel blocks do not support sessions"))

    (provide 'ob-toml)
    ;;; ob-toml.el ends here
  '';

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

  lawtexSrc = pkgs.fetchzip {
    url = "https://downloads.sourceforge.net/project/lawtex/lawtex-2014-10-07.zip";
    hash = "sha256-Cer5rO3+DQsp99FC87tYIv8UQE0TgAGVzxwbNl0Ka8o=";
    stripRoot = false;
  };

  texForOrg = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      collection-latexextra
      contract
      ieeetran
      lato
      revtex4-1
      schola-otf
      yfonts-otf
      ;
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

  customCss = pkgs.writeText "custom.css" ''
    /* Minimal Org HTML export styling */

    :root {
      --page-bg: #fcfbf7;
      --panel-bg: #f3efe6;
      --text: #222222;
      --muted: #5f6368;
      --rule: #ddd6c8;
      --link: #1f5fa8;
      --code-bg: #f5f5f5;
    }

    html {
      font-size: 18px;
    }

    body {
      margin: 0;
      background: var(--page-bg);
      color: var(--text);
      font-family: Inter, "Helvetica Neue", Arial, sans-serif;
      line-height: 1.7;
    }

    #content {
      box-sizing: border-box;
      margin: 0 auto;
      padding: 3rem 1.5rem 4rem;
      width: 100%;
      max-width: 78ch;
    }

    @media (min-width: 1100px) {
      #content {
        width: 50vw;
        max-width: 90ch;
      }
    }

    p,
    ul,
    ol,
    dl,
    blockquote,
    pre,
    table,
    figure,
    .details,
    .footdef,
    .org-src-container {
      margin: 0 0 1.5rem;
    }

    h1,
    h2,
    h3,
    h4,
    h5,
    h6 {
      line-height: 1.25;
      margin: 2.5rem 0 0.9rem;
      font-weight: 700;
    }

    h1.title {
      margin-top: 0;
      margin-bottom: 0.5rem;
      text-align: center;
    }

    .subtitle,
    .author,
    .date {
      color: var(--muted);
      text-align: center;
      margin-bottom: 0.75rem;
    }

    #table-of-contents {
      background: var(--panel-bg);
      border: 1px solid var(--rule);
      border-radius: 10px;
      padding: 1.25rem 1.5rem;
      margin: 0 0 2.5rem;
    }

    #table-of-contents h2 {
      margin-top: 0;
    }

    #table-of-contents ul {
      margin-bottom: 0;
    }

    a {
      color: var(--link);
      text-decoration: none;
    }

    a:hover {
      text-decoration: underline;
    }

    img,
    figure img {
      display: block;
      margin: 2rem auto;
      width: 70%;
      max-width: 100%;
      height: auto;
    }

    figure {
      text-align: center;
    }

    pre,
    code {
      font-family: "JetBrains Mono", "Iosevka", "Fira Code", monospace;
    }

    pre {
      background: var(--code-bg);
      border: 1px solid var(--rule);
      border-radius: 8px;
      padding: 1rem 1.25rem;
      overflow-x: auto;
    }

    code {
      white-space: pre-wrap;
    }

    table {
      width: 100%;
      border-collapse: collapse;
    }

    th,
    td {
      border: 1px solid var(--rule);
      padding: 0.6rem 0.8rem;
      text-align: left;
      vertical-align: top;
    }

    blockquote {
      border-left: 4px solid var(--rule);
      padding-left: 1rem;
      color: var(--muted);
    }

    hr {
      border: 0;
      border-top: 1px solid var(--rule);
      margin: 2.5rem 0;
    }
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
      epkgs.svg-tag-mode
      epkgs.flycheck
      epkgs.flycheck-vale
      epkgs.json-mode
      epkgs.toml-mode
      epkgs.yaml
      epkgs.yaml-mode
      fixedPitch
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
      vale
      texForOrg
      evince
    ];

    services.emacs = {
      enable = true;
      package = pkgs.emacs;
      client.enable = true;
      startWithUserSession = true;
    };

    systemd.user.services.emacs.Service = lib.mkIf (config.homelab.sops.enable or false) {
      Environment = [
        "OPENAI_API_KEY_FILE=${config.sops.secrets.openai_api_key.path}"
      ];
      ExecStart = lib.mkForce ''${pkgs.runtimeShell} -l -c 'if [ -n "''${OPENAI_API_KEY_FILE:-}" ] && [ -f "$OPENAI_API_KEY_FILE" ]; then export OPENAI_API_KEY="$(<"$OPENAI_API_KEY_FILE")"; fi; exec ${pkgs.emacs}/bin/emacs --fg-daemon ${lib.escapeShellArgs config.services.emacs.extraOptions}' '';
    };

    home.file.".emacs.d/init.el".source = "${tangledInit}/init.el";
    home.file.".emacs.d/init.org".source = ./init.org;
    home.file.".emacs.d/custom.css".source = customCss;
    home.file.".emacs.d/site-lisp/fixed-pitch.el".source = "${fixedPitch}/share/emacs/site-lisp/fixed-pitch.el";
    home.file.".emacs.d/site-lisp/ob-json.el".source = obJson;
    home.file.".emacs.d/site-lisp/ob-yaml.el".source = obYaml;
    home.file.".emacs.d/site-lisp/ob-toml.el".source = obToml;
    home.file.".emacs.d/capture-templates".source = ./capture-templates;
    home.file.".config/vale/.vale.ini".source = ./vale/.vale.ini;
    home.file.".config/vale/styles/write-good".source = "${pkgs.valeStyles.write-good}/share/vale/styles/write-good";
    home.file.".config/vale/styles/proselint".source = "${pkgs.valeStyles.proselint}/share/vale/styles/proselint";
    home.file.".config/vale/styles/alex".source = "${pkgs.valeStyles.alex}/share/vale/styles/alex";
    home.file.".config/vale/styles/Readability".source = "${pkgs.valeStyles.readability}/share/vale/styles/Readability";
    home.file.".config/vale/styles/John".source = ./vale/styles/John;
    home.file."texmf/tex/latex/minimal-memo/CSMinimalMemo.cls".source = ./latex-templates/minimal-memo/CSMinimalMemo.cls;
    home.file."texmf/doc/latex/minimal-memo/template.tex".source = ./latex-templates/minimal-memo/template.tex;
    home.file."texmf/tex/latex/lawtex/arbitrationbrief.cls".source = "${lawtexSrc}/lawtex/arbitrationbrief.cls";
    home.file."texmf/tex/latex/lawtex/bluebook.sty".source = "${lawtexSrc}/lawtex/bluebook.sty";
    home.file."texmf/tex/latex/lawtex/lawbrief.cls".source = "${lawtexSrc}/lawtex/lawbrief.cls";
    home.file."texmf/tex/latex/lawtex/lawmemo.cls".source = "${lawtexSrc}/lawtex/lawmemo.cls";
    home.file."texmf/tex/latex/lawtex/multind.sty".source = "${lawtexSrc}/lawtex/multind.sty";
    home.file."texmf/tex/latex/lawtex/SupremeCourt.pdf".source = "${lawtexSrc}/lawtex/samples/SupremeCourt.pdf";
    home.file."texmf/makeindex/lawtex/arbitrationcitations.ist".source = "${lawtexSrc}/lawtex/arbitrationcitations.ist";
    home.file."texmf/makeindex/lawtex/lawcitations.ist".source = "${lawtexSrc}/lawtex/lawcitations.ist";
    home.file."texmf/doc/latex/lawtex/README".source = "${lawtexSrc}/lawtex/README";
    home.file."texmf/doc/latex/lawtex/lawtex-doc.tex".source = "${lawtexSrc}/lawtex/lawtex-doc.tex";
    home.file."texmf/doc/latex/lawtex/lawtex-doc.pdf".source = "${lawtexSrc}/lawtex/lawtex-doc.pdf";
  };
}
