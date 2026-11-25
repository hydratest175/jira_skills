Je valide la sauvegarde et l’isolation de MR 1.

Nous disposons désormais de deux chaînes de développement préservées :

* MR 0 + MR 1 dans lcc-mr1-orq-project-mapping.
* T1 + T2 + T3 dans lcc-t3-orq-project-workflow.

Je souhaite maintenant étudier la possibilité de réunir ces deux chaînes dans un nouvel espace d’intégration local afin de débloquer notre dépendance envers Alembic.

Notre objectif est de continuer le développement du véritable LMC en local sans attendre la finalisation du chantier officiel Alembic, si cela est techniquement possible.

1. Analyse de faisabilité

* Analyse les différences entre les deux chaînes et leurs bases de référence.
* Identifie les éventuels conflits de code, de dépendances, de modèles SQLAlchemy et de migrations.
* Vérifie si les migrations Alembic 0001, 0002 et 0003 peuvent être conservées dans un environnement réunissant MR 0, MR 1, T1, T2 et T3.
* Identifie les adaptations minimales nécessaires pour réunir ces travaux.
* Détermine si nous pouvons utiliser une base PostgreSQL locale neuve et isolée pour qualifier l’ensemble.
* Identifie la persistance supplémentaire nécessaire pour les opérations de provisioning, les mappings et la gestion durable de UNKNOWN_OUTCOME.
* Analyse les risques de divergence avec le futur chantier officiel Alembic.
* Propose la méthode d’intégration la plus simple, sans duplication de code ni système de migrations parallèle.

Si cette approche est viable, propose la création ultérieure d’un nouvel espace isolé nommé lcc-local-integration.

2. Préservation du fonctionnement et du démarrage actuel du LMC

Il s’agit d’une contrainte fondamentale pour l’ensemble de notre intégration.

Le LMC doit continuer à être lancé exactement de la même manière qu’actuellement. Nos développements doivent s’intégrer dans son architecture et ses mécanismes existants, sans imposer une nouvelle procédure de démarrage.

Commence par analyser précisément :

* La procédure actuelle de lancement du LMC.
* Les commandes et scripts existants.
* Les configurations Docker et Docker Compose.
* L’initialisation du backend, du frontend et de PostgreSQL.
* Le mécanisme actuel d’exécution des migrations Alembic.
* La gestion des variables d’environnement et des dépendances.
* Le cycle de démarrage et d’arrêt des différents composants.

Notre intégration ne doit pas :

* Remplacer la procédure actuelle de démarrage.
* Imposer de nouvelles commandes obligatoires pour lancer normalement le LMC.
* Introduire un Docker Compose alternatif comme solution définitive.
* Modifier inutilement les scripts de lancement existants.
* Imposer une nouvelle architecture de développement local.
* Introduire une étape manuelle supplémentaire pour appliquer les migrations dans le fonctionnement standard, si les mécanismes existants permettent de l’éviter.

Les nouveaux composants nécessaires au provisioning, notamment le Worker Temporal, devront s’intégrer proprement au cycle de vie applicatif ou aux mécanismes de gestion des services existants.

Si un composant supplémentaire nécessite réellement une évolution du mécanisme de démarrage, justifie précisément cette nécessité, présente les alternatives et attends ma validation.

Une procédure spécifique peut être utilisée pour des tests isolés, mais elle ne doit pas devenir la nouvelle procédure standard de lancement du LMC.

Le LMC doit continuer à démarrer et à fonctionner normalement lorsque l’intégration Temporal et Orq.ai est désactivée ou indisponible.

3. Plan de qualification

Prépare un plan de qualification comprenant :

* Validation de la chaîne Alembic et de son head unique.
* Validation du schéma PostgreSQL et des modèles ORM.
* Tests de non-régression de MR 0, MR 1, T1, T2 et T3.
* Comparaison des échecs avec les références appropriées.
* Démarrage réel du backend et du frontend LMC.
* Vérification que le LMC démarre en utilisant sa procédure habituelle, sans commande supplémentaire obligatoire.
* Vérification des fonctionnalités existantes depuis l’interface locale.
* Vérification du comportement lorsque Temporal est désactivé ou indisponible.
* Vérification de l’absence de régression dans les mécanismes existants de démarrage, de configuration et d’arrêt.

Ne contourne pas Alembic avec du SQL manuel ou create_all().

4. Objectif fonctionnel final

Notre objectif reste d’obtenir une parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement.

Nous devons pouvoir créer un projet, déclencher son provisioning et retrouver toutes les ressources correspondantes dans Orq.ai.

Aucun déploiement de notre nouvelle version du LMC en préproduction ne sera envisagé avant cette qualification fonctionnelle complète en local.

5. Contraintes impératives

* Pour le moment, réalise uniquement l’analyse de faisabilité et présente-moi ton plan avant l’implémentation.
* Préserve intégralement tous les espaces de travail existants.
* Ne modifie pas le dossier lcc original.
* Ne modifie pas la procédure actuelle de démarrage du LMC.
* Ne crée pas de système de migrations concurrent.
* Aucune opération Git ou GitLab.
* Aucune modification Kubernetes.
* Aucune modification des conteneurs Docker existants.
* Aucune modification Docker Compose sans validation préalable.
* Aucune modification des bases de données existantes.
* Aucun appel distant à Orq.ai.
* Aucun déploiement.
* Documentation technique en anglais et restitution en français.

Indique-moi clairement si Alembic constitue encore un véritable blocage pour notre développement local et si nous pouvons poursuivre en réutilisant nos travaux précédents, tout en conservant strictement le fonctionnement et la procédure de lancement actuels du LMC.

Privilégie systématiquement la simplicité, la réutilisation de l’existant et des modifications minimales.