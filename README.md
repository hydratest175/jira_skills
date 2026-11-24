Nous allons privilégier Temporal en préproduction plutôt que d’installer un serveur Temporal local.

Temporal est déjà déployé en préproduction et est utilisé par des workflows de traitement de documents provenant d’Engineering Companion. Nous voulons réutiliser cette infrastructure pour notre future orchestration du provisioning Orq.ai.

Je ne souhaite installer ni Temporal CLI ni serveur Temporal sur mon PC professionnel.

Le SDK Python Temporal peut être utilisé dans le Dev Container, en respectant les mécanismes de dépendances déjà autorisés dans notre environnement.

Pour la suite de T2 :

1. Vérifie les possibilités de connexion du SDK Python à Temporal préprod depuis le Dev Container.
2. Identifie l’endpoint SDK/gRPC, le namespace autorisé, les exigences TLS/authentification et les conventions de Task Queue. Ne confonds pas l’URL de l’interface Web avec l’adresse SDK.
3. N’invente aucun paramètre manquant et ne contourne aucune restriction réseau ou de sécurité.
4. Prévois une Task Queue dédiée à notre intégration, distincte des workflows de documents existants.
5. Prépare une configuration optionnelle afin que le LMC continue de fonctionner normalement sans Temporal.
6. Dans un premier temps, réalise uniquement des vérifications de connexion non destructives et des tests locaux sans activité métier distante.
7. Si la connexion est validée et l’environnement de test autorisé, propose ensuite un premier workflow réel sans effet externe, exécuté par un Worker local dans le Dev Container, avant de passer aux appels Orq.
8. Nous pourrons ultérieurement tester la création de véritables ressources Orq de test. Chaque ressource créée devra être identifiable, traçable et pouvoir être nettoyée manuellement. Ne lance pas encore ces créations sans définir précisément le test.

Ne modifie pas les workflows ou Workers de documents déjà présents en préproduction.

Préserve MR 0, MR 1 et T1. Toute nouvelle implémentation doit rester dans un espace local isolé.

Aucun changement Docker Compose, Kubernetes, déploiement ou configuration officielle du LMC sans nécessité validée.

Documentation technique en anglais, résultats de tests en français.

Aucun commit, branche, push, merge, rebase ou création de Merge Request : je m’occupe seul de toutes les opérations Git et GitLab.

Commence par la qualification de connexion et l’analyse de configuration. Arrête-toi en cas de paramètre indispensable manquant ou d’accès non autorisé.