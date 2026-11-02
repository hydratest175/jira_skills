python3 - <<'PY'
import json

path = "/root/.config/opencode/model-catalogs/c3-ca/thales-azure-sso.json"

with open(path) as f:
    data = json.load(f)

print("Clés principales :", list(data.keys()))

def inspect(obj, path="root", depth=0):
    if not isinstance(obj, dict) or depth > 3:
        return

    if "models" in obj and isinstance(obj["models"], dict):
        print("Modèles trouvés dans", path)
        print(list(obj["models"].keys()))

    for key, value in obj.items():
        if isinstance(value, dict) and key != "models":
            inspect(value, path + "." + key, depth + 1)

inspect(data)
PY