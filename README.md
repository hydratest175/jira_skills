python3 - <<'PY'
from pathlib import Path

p = Path("/root/.config/opencode/plugins/azure-sso/dist/index.js")

old = 'resolveEnvTemplate(raw?.provider)?.trim() || "openai"'
new = 'resolveEnvTemplate(raw?.provider)?.trim() || "thales-azure-sso"'

content = p.read_text()

if content.count(old) != 1:
    raise SystemExit("Modification annulée : ligne attendue introuvable ou ambiguë.")

backup = p.with_name("index.js.bak")
backup.write_text(content)

p.write_text(content.replace(old, new, 1))

print("Provider corrigé : thales-azure-sso")
print("Sauvegarde créée :", backup)
PY