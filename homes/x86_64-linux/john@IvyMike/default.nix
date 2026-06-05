{
  lib,
  pkgs,
  inputs,
  config,
  osConfig,
  ...
}:
with lib;
with lib.homelab;

{
  homelab.fish.enable = true;
  homelab.emacs.enable = true;
  homelab.direnv.enable = true;
  homelab.nvim.enable = true;
  homelab.fonts.enable = true;
  homelab.aider.enable = true;
  homelab.pi.enable = true;
  homelab.sops.enable = true;
  homelab.xmonad.enable = true;

  home.stateVersion = lib.mkDefault (osConfig.system.stateVersion or "25.11");

  home.packages = with pkgs; [
    cowsay
    jq
    llm
    pandoc
    (writeShellScriptBin "lamblm" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      usage() {
        cat >&2 <<'EOF'
Usage:
  lamblm "your prompt here"
  lamblm -f path/to/file "your prompt here"
  cat file | lamblm "your prompt here"
EOF
        exit 1
      }

      file_input=""
      while [ "$#" -gt 0 ]; do
        case "$1" in
          -f|--file)
            [ "$#" -ge 2 ] || usage
            file_input="$2"
            shift 2
            ;;
          -h|--help)
            usage
            ;;
          --)
            shift
            break
            ;;
          -*)
            echo "lamblm: unknown option: $1" >&2
            usage
            ;;
          *)
            break
            ;;
        esac
      done

      prompt="$*"
      stdin_input=""
      if [ ! -t 0 ]; then
        stdin_input="$(cat)"
      fi

      if [ -z "$prompt" ] && [ -z "$file_input" ] && [ -z "$stdin_input" ]; then
        usage
      fi

      if [ -n "''${OPENAI_API_KEY:-}" ] || { [ -n "''${OPENAI_API_KEY_FILE:-}" ] && [ -f "$OPENAI_API_KEY_FILE" ]; }; then
        :
      else
        echo "lamblm: OPENAI_API_KEY is not set and OPENAI_API_KEY_FILE is unavailable" >&2
        exit 1
      fi

      if [ -z "''${OPENAI_API_KEY:-}" ] && [ -n "''${OPENAI_API_KEY_FILE:-}" ] && [ -f "$OPENAI_API_KEY_FILE" ]; then
        export OPENAI_API_KEY
        OPENAI_API_KEY="$(<"$OPENAI_API_KEY_FILE")"
      fi

      final_prompt="$prompt"

      if [ -n "$file_input" ]; then
        [ -f "$file_input" ] || {
          echo "lamblm: file not found: $file_input" >&2
          exit 1
        }
        if [ -n "$final_prompt" ]; then
          final_prompt+=$'\n\n'
        fi
        final_prompt+="Contents of $file_input:"
        final_prompt+=$'\n\n'
        final_prompt+="$(cat "$file_input")"
      fi

      if [ -n "$stdin_input" ]; then
        if [ -n "$final_prompt" ]; then
          final_prompt+=$'\n\n'
        fi
        final_prompt+="Piped input:"
        final_prompt+=$'\n\n'
        final_prompt+="$stdin_input"
      fi

      export TERM=dumb
      export NO_COLOR=1
      export CLICOLOR=0

      output="$(${pkgs.llm}/bin/llm prompt \
        --no-stream \
        -m "''${LAMBLM_MODEL:-gpt-4o-mini}" \
        "$final_prompt" \
        2>/dev/null)"

      if [ "''${LAMBLM_NO_PANDOC:-0}" = "1" ]; then
        printf '%s\n' "$output"
      else
        printf '%s' "$output" \
          | ${pkgs.pandoc}/bin/pandoc --wrap=none -f gfm -t org
      fi
    '')
  ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "John Lambert";
      };
      extraConfig = {
        core.editor = "nvim";
        pull.rebase = true;
        init.defaultBranch = "main";
        alias.lg = "log --oneline --graph --decorate";
      };
    };
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/id_ed25519";
      };
    };
  };

  services.ssh-agent.enable = true;

  home.sessionVariables.OPENAI_API_KEY_FILE =
    config.sops.secrets.openai_api_key.path;

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa -lah --icons=always --hyperlink";
      vim = "emacsclient -c -a \"\"";
    };
    interactiveShellInit = ''
      # Make OpenAI-backed CLI tools (llm, aider, gptel, etc.) work in fish.
      if set -q OPENAI_API_KEY_FILE; and test -f $OPENAI_API_KEY_FILE
          set -gx OPENAI_API_KEY (cat $OPENAI_API_KEY_FILE)
      end

      # Apply Gruvbox theme
      set -g fish_color_normal brblack
      set -g fish_color_command brgreen
      set -g fish_color_comment brblue
      set -g fish_color_error brred
      set -g fish_color_selection --background=brblack
      set -g fish_color_search_match --background=brblack
      set -g fish_color_operator brcyan
      set -g fish_color_escape brmagenta
      set -g fish_color_param brcyan
      set -g fish_color_quote bryellow
      set -g fish_color_redirection brmagenta
      set -g fish_color_end brmagenta
    '';
  };
}
