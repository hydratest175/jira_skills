Nouvelle décision d’architecture confirmée avec mon équipe : le LMC Project ID devra bien être propagé jusqu’au MCP pour permettre le scoping des connecteurs et des autorisations au niveau du projet LMC.

Ce besoin n’est pas nécessairement à implémenter entièrement maintenant, mais il est officiellement prévu.

Cette information change notre stratégie de rollback.

Avant toute annulation, revois le plan en distinguant :

1. Les corrections réalisées uniquement à cause de l’incident MCP, désormais résolu.
2. Les développements qui contribuent à la future autorisation par projet LMC.
3. Les améliorations de sécurité indépendantes de l’incident.

Ne retire donc pas automatiquement lmc_project_id, le contrat d’autorisation projet ou python-jose simplement parce qu’ils ont été ajoutés pendant l’investigation.

Évalue leur utilité, leurs dépendances et leur compatibilité avec le futur LMC réel.

Si le nouvel endpoint Mock LMC doit être conservé temporairement, assure-toi qu’il reste désactivé hors du périmètre de test tant que son contrat et son intégration ne sont pas validés.

Je veux toujours préserver intégralement le versioning des orchestrateurs, le provisioning, les conversations et les spécialistes Jira/GitLab.

Ne modifie ni Vault, ni Orq partagé, ni Kubernetes.

Présente-moi le plan de rollback révisé avant toute exécution.