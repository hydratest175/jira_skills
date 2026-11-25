Je ne souhaite pas arrêter, supprimer, recréer ou modifier les conteneurs de mon LMC actuel.

Je privilégie une qualification entièrement isolée, comme nous l’avions précédemment réalisée pour MR 0 et MR 1.

Tu es autorisé à créer une stack Docker locale temporaire exclusivement dédiée à la qualification de lcc-local-integration.

Cette stack doit disposer de ses propres :

* Noms de conteneurs.
* Ports.
* Volumes.
* Réseaux.
* Base PostgreSQL.
* Configurations de test.

Vérifie l’absence de conflit avec toutes les ressources existantes avant son lancement.

Tu peux utiliser un override Docker Compose temporaire uniquement pour les besoins de cette qualification, à condition de respecter les contraintes suivantes :

* Ne modifie aucun Docker Compose original.
* Ne modifie aucun script standard de lancement du LMC.
* Ne modifie aucune configuration VS Code existante.
* Ne modifie aucun conteneur, volume, réseau ou service existant.
* N’intègre pas cet override dans le futur périmètre des Merge Requests.
* N’introduis aucune modification fonctionnelle uniquement pour faciliter les tests.
* N’utilise jamais les bases de données existantes.
* Ne copie pas automatiquement le fichier .env original ni ses credentials.

Indique-moi précisément comment initialiser le fichier .env nécessaire à cette qualification en utilisant notre procédure habituelle.

L’objectif est de valider réellement le fonctionnement cumulé de MR 0, MR 1, T1, T2 et T3, notamment les migrations Alembic, PostgreSQL, le backend, le frontend et les fonctionnalités existantes.

Documente explicitement la différence entre cette qualification isolée et une qualification utilisant strictement la procédure standard de lancement.

Nous effectuerons ultérieurement une qualification complémentaire avec la procédure standard inchangée, dans un environnement disponible et sans conflit.

Notre procédure habituelle de lancement du LMC doit impérativement rester inchangée.

Aucune opération Git ou GitLab, aucune modification Kubernetes, aucun appel distant Orq.ai et aucun nouveau Workflow Temporal distant.

Préserve intégralement tous nos espaces de travail.

Documentation en anglais et restitution en français.

Tu peux poursuivre la qualification dans ce périmètre.