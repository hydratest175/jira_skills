Nouvelle information importante : nous avons identifié la véritable cause de l’incident Jira/GitLab.

Un collègue avait effectué une mauvaise manipulation sur le serveur MCP. Il l’a redéployé correctement et les appels MCP fonctionnent de nouveau.

Il est donc possible que les nombreuses modifications que nous avons récemment réalisées pour résoudre cette panne soient inutiles.

Je veux que nous revenions à une base stable.

Pour l’instant, ne modifie rien et ne lance aucun revert automatiquement.

Examine les modifications réalisées lors de notre dernière intervention MCP sur Engineering Companion, Mock LMC, lea-alm-mcp et les configurations Docker/TLS.

L’objectif est de retrouver, autant que possible, l’état qui existait juste après l’implémentation du versioning des orchestrateurs, mais avant notre tentative de correction de l’incident MCP.

Il faut impérativement conserver :

* Le versioning des Managed Agents.
* Le mapping persistant modèle → version.
* Le provisioning existant.
* Le changement de modèle dans Engineering Companion.
* La continuité conversationnelle.
* Les spécialistes Jira/GitLab partagés.

Identifie les modifications liées uniquement à la panne MCP désormais résolue, notamment l’ajout de l’endpoint /api/v1/projects/{id}/backends, les changements d’autorisation, la transmission du Project ID, les modifications du serveur MCP et les configurations Docker/TLS.

Classe les modifications entre celles qu’on peut annuler sans risque et celles qui méritent d’être conservées indépendamment de l’incident.

Attention : les modifications renforçant réellement la sécurité ne doivent pas être annulées à l’aveugle, mais elles doivent rester compatibles avec le fonctionnement existant.

Vérifie également si certaines modifications peuvent être interdépendantes.

N’utilise aucune commande destructive comme git reset --hard ou git clean.

Prépare un point de restauration non destructif et un plan de revert sélectif, sans écraser les modifications préexistantes ou celles réalisées pour le versioning.

Ne touche à aucun secret Vault, aucune ressource Orq partagée et aucun déploiement distant.

Je veux à la fin :

1. La liste précise des modifications de notre intervention MCP.
2. Les modifications qu’il est préférable d’annuler.
3. Celles qu’il faut conserver.
4. Les risques éventuels du rollback.
5. Un plan de retour à l’état stable, avec des tests de non-régression.

Ne fais pas encore les annulations. Je veux valider le plan.

Concernant l’isolation des connecteurs par Project ID LMC, nous traiterons ce sujet séparément. Ce n’est plus un correctif de panne, mais une éventuelle évolution de l’autorisation métier.