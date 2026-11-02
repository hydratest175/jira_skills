export OPENCODE_CONFIG_CONTENT="$(python3 - <<'PY'
import json

path = "/root/.config/opencode/model-catalogs/c3-ca/thales-azure-sso.json"

with open(path) as f:
    models = json.load(f)

config = {
    "provider": {
        "thales-azure-sso": {
            "models": models
        }
    }
}

print(json.dumps(config))
PY
)"