Nouvelle information importante : j’ai consulté l’interface Vault du déploiement Engineering Companion.

Dans la configuration du backend déployé, la variable CONNECTOR_SECRET_BACKEND vaut vault.

J’ai également constaté que le chemin uc/connectors/ contient plusieurs sous-dossiers identifiés par des UUID.

Cela suggère que l’architecture historique d’enregistrement des credentials dans Vault existe effectivement.

Je veux maintenant une investigation ciblée, uniquement en lecture seule et sans aucune modification.

Vérifie :

1. Si ces dossiers UUID correspondent effectivement aux Keycloak sub des utilisateurs, sans énumérer ni exposer des données d’autres utilisateurs.
2. Si les chemins construits par lib/connectors/vault.ts dans Engineering Companion correspondent aux chemins recherchés par lea-alm-mcp/app/connector_tokens.py.
3. Si le backend déployé et le MCP distant utilisent le même Vault, le même montage KV et le même chemin logique uc/connectors/.
4. Si la configuration locale CONNECTOR_SECRET_BACKEND=redis explique l’absence de PAT accessibles au MCP.
5. Si le mécanisme Vault déjà implémenté dans Engineering Companion pourrait être réutilisé localement, plutôt que de développer un autre stockage.
6. Quels paramètres et droits sont nécessaires pour ce fonctionnement, sans afficher, copier ou réutiliser les credentials de production.
7. Quels blocages restent indépendants de Vault, notamment X-LMC-Project-ID et l’API d’autorisation du projet LMC.

Ne modifie aucun secret, AppRole, ACL, chemin, configuration distante, ressource Orq ou déploiement Kubernetes.

Ne récupère et n’affiche aucune valeur de PAT, VAULT_SECRET_ID ou autre credential.

Ne modifie pas encore CONNECTOR_SECRET_BACKEND dans l’environnement local.

Je veux que tu me dises précisément si nous pouvons restaurer le fonctionnement historique du backend Vault existant, quelles différences existent entre le local et le déploiement, et quelles actions seraient ensuite nécessaires.

Ne touche pas au versioning des orchestrateurs et ne commence aucune migration.