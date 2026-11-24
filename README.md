Je souhaite étudier la possibilité de te donner un accès permanent à Kubernetes depuis mon Dev Container, de manière similaire à ton accès Docker actuel.

Depuis mon environnement extérieur au Dev Container, j’ai déjà accès à Kubernetes et j’utilise gcloud pour mon authentification.

Dans un premier temps, réalise uniquement une analyse de faisabilité.

1. Analyse la configuration actuelle du Dev Container, son Dockerfile, son devcontainer.json et les éventuelles configurations Docker Compose.
2. Analyse la manière dont ton accès Docker a déjà été configuré.
3. Identifie les composants nécessaires pour disposer de kubectl, gcloud et, si nécessaire, gke-gcloud-auth-plugin.
4. Recherche les possibilités d’installation depuis nos repositories Artifactory internes et les sources autorisées.
5. Propose une solution permettant d’utiliser une configuration Kubernetes dédiée à la préproduction, sans intégrer de credentials ou de secrets dans le Dockerfile.
6. Étudie la possibilité de disposer d’un accès Kubernetes strictement limité à la lecture seule via RBAC/IAM, sans accès aux valeurs des Secrets.
7. Prévois une configuration persistante après redémarrage du PC et du Dev Container.
8. Identifie les éventuelles contraintes réseau, proxy, certificats et authentification.

L’objectif est que tu puisses ensuite inspecter les Pods, Deployments, Services, ConfigMaps et logs de Kubernetes de manière autonome, notamment pour poursuivre la qualification de Temporal préproduction.

Pour l’instant, ne modifie aucun fichier, aucune image, aucun conteneur Docker et aucune ressource Kubernetes. N’effectue aucune installation ni aucun rebuild.

Ne récupère aucun credential depuis l’environnement hôte sans mon autorisation.

Présente-moi d’abord la solution technique envisagée, les fichiers qui seraient concernés, les risques éventuels et les informations dont tu as besoin pour poursuivre.

Préserve intégralement l’environnement Software Companion actuel, son accès Docker, MR 0, MR 1 et T1.

Aucune opération Git ou GitLab.