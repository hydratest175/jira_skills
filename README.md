Merci pour l’analyse. Je suis favorable à un mécanisme de migrations PostgreSQL dédié, distinct du démarrage normal du LMC, mais je ne veux pas introduire prématurément de changements Kubernetes ou CI/CD.

Avant toute implémentation, je souhaite approfondir la stratégie de migration.

Objectif : garantir que les futures migrations Alembic pourront être appliquées de manière fiable, sans détruire les données existantes ni modifier inutilement le fonctionnement normal du LMC.

Analyse en lecture seule :

1. Les mécanismes existants de migration et de bootstrap PostgreSQL.
2. Les différents états possibles des bases déployées, notamment avec ou sans table alembic_version.
3. Les risques liés à l’adoption d’Alembic sur une base historiquement créée à partir des scripts SQL.
4. Les préconditions nécessaires avant de considérer qu’une base correspond réellement à la révision 0002.
5. Les conséquences sur les déploiements futurs, les redémarrages, les rollbacks et les déploiements concurrents.
6. La possibilité d’utiliser les outils et images de production existants sans nouvelle dépendance.
7. Le découpage minimal des changements nécessaires dans une micro-MR distincte, en préservant MR 0 et MR 1.

Ne considère jamais la présence de schema_migrations comme une preuve suffisante pour initialiser automatiquement alembic_version.

Ne fais aucun alembic stamp ni aucune migration sur une base existante sans vérification explicite et autorisation.

Propose une stratégie pour tester localement, sur des bases jetables, les différents états historiques et le mécanisme envisagé.

Contraintes :

* Aucun changement du code pour l’instant.
* Aucun déploiement ni accès modifiant les environnements distants.
* Aucun commit, branche, push, merge, rebase ou création de Merge Request.
* Préserver tous les fichiers et modifications MR 0 et MR 1.
* Ne pas modifier le mécanisme de démarrage existant du LMC.
* Documentation technique en anglais.

Présente en français les solutions possibles, les risques, la solution recommandée et le découpage envisagé.

Arrête-toi après cette étude. Nous déciderons ensuite si une micro-MR spécifique est nécessaire et comment l’insérer dans notre stack.