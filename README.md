J’ai étudié ton plan de rollback et je valide son principe général.

Nous voulons revenir sur les changements inutiles liés à l’incident MCP, puisque la véritable cause était un problème de déploiement externe désormais corrigé.

En revanche, je veux que le rollback soit extrêmement ciblé.

Je veux préserver intégralement :

* Le versioning des orchestrateurs.
* Les mappings SQLite modèle/version.
* Le provisioning Mock LMC.
* La sélection dynamique du modèle.
* La continuité conversationnelle.
* Les spécialistes Jira/GitLab.
* La logique de projet LMC qui existait avant notre dernière intervention.
* Les améliorations de sécurité indépendantes de l’incident : validation TLS, suppression des tokens des logs et commandes, protection des chemins Vault.

Je veux retirer uniquement les ajouts devenus inutiles, notamment les éléments du nouveau contrat Mock LMC/MCP, après vérification qu’aucun composant encore utilisé n’en dépend.

La gestion de l’autorisation métier par projet dans le MCP reste un chantier séparé. Ne la retire pas implicitement pendant ce premier rollback.

Procédure :

1. Crée une sauvegarde locale sécurisée de l’état actuel, incluant les modifications non commitées et les fichiers non suivis pertinents, sans copier de secrets.
2. Prépare un rollback hunk par hunk, jamais par remplacement de fichiers entiers.
3. Vérifie les dépendances entre les modifications avant de supprimer du code.
4. Ne supprime aucune table SQLite et ne migre aucune donnée.
5. N’utilise pas git reset --hard, git clean ou de restauration globale.
6. Ne touche ni à Vault, ni aux ressources Orq, ni à Kubernetes ou aux déploiements distants.
7. Exécute les tests de non-régression sur Engineering Companion, Mock LMC et MCP.
8. Vérifie notamment que le changement de modèle Small → Medium → Small continue de fonctionner.
9. Vérifie que le chemin Jira/GitLab reste compatible avec le MCP actuellement redéployé.
10. Présente un bilan des modifications réellement annulées et conservées.

Avant d’appliquer le rollback, montre-moi le périmètre exact des portions de code que tu vas annuler et attends mon accord.

Je veux surtout éviter de détruire nos évolutions de versioning ou de réintroduire des vulnérabilités pour revenir à un état antérieur.

Le but est de simplifier le code, pas d’annuler tout le travail récent.