pi user configuration lives here.

Managed by:
- modules/home/pi/default.nix

The live files in ~/.pi/agent/ are symlinked back to this repo, so you can edit either:
- the files under modules/home/pi/
- or the matching files under ~/.pi/agent/

Edit these repo files to change your global pi setup:
- modules/home/pi/settings.json     -> general pi settings
- modules/home/pi/keybindings.json -> keyboard shortcuts
- modules/home/pi/models.json      -> custom providers/models
- modules/home/pi/extensions/      -> global extensions (*.ts, *.js)
- modules/home/pi/prompts/         -> global prompt templates (*.md)
- modules/home/pi/skills/          -> global skills (name/SKILL.md)
- modules/home/pi/themes/          -> custom themes (*.json)

Notes:
- pi stores credentials in ~/.pi/agent/auth.json when you use /login.
- auth.json is not managed here because it contains secrets/tokens.
- Project-local pi config lives in .pi/ inside a repo, not here.
