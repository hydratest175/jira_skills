La qualification réelle de la connexion Temporal préproduction est réussie :

* SDK Python temporalio 1.18.2.
* Namespace default.
* Connexion SDK validée.
* Santé du serveur validée.
* Visibilité du namespace validée.
* Aucun Workflow créé ou modifié.

Nous allons maintenant poursuivre T2.

Commence par documenter précisément les résultats de cette qualification, notamment :

* L’environnement depuis lequel le test a réellement été exécuté : DevEnv ou Dev Container.
* Le mécanisme de connexion utilisé.
* L’endpoint utilisé.
* La configuration TLS et authentification effective.
* Les commandes exécutées.
* Les permissions effectivement vérifiées.
* Les limites de cette validation.

Ensuite :

1. Détermine comment nous pouvons reproduire cette connexion depuis le Dev Container sans installer kubectl, gcloud ou Temporal CLI dans celui-ci.
2. Privilégie la réutilisation du tunnel Kubernetes établi manuellement depuis le DevEnv, uniquement via un mécanisme réseau autorisé et sans exposition du frontend Temporal à toutes les interfaces.
3. Prépare les fondations Python de notre intégration Temporal dans un espace de travail local isolé.
4. Analyse les conventions existantes du LMC pour les dépendances, la configuration, la journalisation et les tests.
5. Prévois une configuration Temporal optionnelle afin que le LMC puisse continuer de fonctionner normalement lorsque Temporal est indisponible ou désactivé.
6. Implémente les tests unitaires et les tests mockés nécessaires.
7. Prépare un premier Workflow no-op, sans activité métier ni appel Orq.ai, avec un Worker local et une Task Queue dédiée.
8. Vérifie que le namespace et la Task Queue sont autorisés avant toute exécution réelle du Workflow.
9. Une fois ces conditions réunies, exécute le test no-op et documente précisément ses résultats.

Ne lance aucun Workflow sur une Task Queue existante.

Aucune modification de Kubernetes, Docker, des services existants ou des Workers Engineering Companion.

Aucune création de ressource Orq.ai.

Préserve intégralement MR 0, MR 1 et T1.

Aucune opération Git ou GitLab.

Documentation technique en anglais et résultats en français.

Distingue les tests réellement exécutés des tests mockés et des validations restant à effectuer.

Poursuis de manière autonome dans ce périmètre et sollicite-moi uniquement lorsque mon intervention manuelle ou une autorisation supplémentaire est nécessaire.