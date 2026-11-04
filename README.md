Nous avons terminé la première implémentation du Mock LMC dans le dossier mock-lmc-orq-poc.

Je veux maintenant uniquement réussir à lancer cette application dans mon navigateur.

CONTEXTE

Nous travaillons dans le Dev Container de LEA_Workspace.

Le Dev Container utilise Python 3.14.8, alors que notre backend nécessite Python 3.12 ou 3.13.

Nous avons trouvé une image Docker interne déjà disponible localement :

carma.corp.thales/docker/python:3.13-slim

Nous avons vérifié son fonctionnement :

* Python 3.13.15 : OK.
* pip 26.2.1 : OK.
* FastAPI : non installé.
* Uvicorn : non installé.
* SQLAlchemy : non installé.

Nous souhaitons donc utiliser cette image Docker pour exécuter notre backend, sans modifier notre Dev Container.

OBJECTIF

Rendre le Mock LMC entièrement fonctionnel en local avec :

* Frontend : React + TypeScript + Vite.
* Backend : FastAPI.
* Base de données : SQLite.
* Backend exécuté dans Docker avec Python 3.13.

TRAVAIL DEMANDÉ

1. Inspecte l’implémentation actuelle du dossier mock-lmc-orq-poc.
2. Configure le backend pour fonctionner avec l’image Docker :
    carma.corp.thales/docker/python:3.13-slim
3. Crée un Dockerfile minimal pour le backend.
4. Utilise les dépendances déclarées dans backend/pyproject.toml.
5. Identifie la méthode appropriée pour installer les dépendances Python dans notre environnement Thales, en privilégiant les registres internes autorisés et les configurations de certificats existantes.
6. Configure la persistance de SQLite pour conserver les données après redémarrage du conteneur.
7. Expose le backend FastAPI sur le port 8000.
8. Configure correctement la communication entre le frontend React et le backend.
9. Prépare une méthode simple de lancement du Mock LMC, idéalement avec Docker Compose si cela simplifie réellement le démarrage.
10. Vérifie que la configuration est cohérente et que les services peuvent démarrer. Effectue uniquement les vérifications locales nécessaires.

CONTRAINTES IMPORTANTES

* Ne modifie pas le vrai LMC (lcc).
* Ne modifie pas Engineering Companion.
* Ne modifie pas la configuration du Dev Container.
* Ne change pas la version Python du POC.
* Ne désactive pas la vérification des certificats SSL.
* Ne stocke aucun identifiant ou token dans le Dockerfile.
* Utilise les images Docker internes déjà disponibles.
* Ne développe aucune nouvelle fonctionnalité.
* Ne réalise aucun appel à Orq.ai.
* N’ajoute pas d’infrastructure inutile.
* Ne modifie que les fichiers nécessaires dans mock-lmc-orq-poc.

Si l’installation des dépendances est bloquée par les restrictions réseau ou les registres Python de l’entreprise, identifie précisément le problème et propose la correction minimale. Ne multiplie pas les tentatives ou les solutions alternatives sans justification.

RÉSULTAT ATTENDU

Je veux pouvoir :

1. Lancer le Mock LMC facilement.
2. Ouvrir son interface React dans mon navigateur.
3. Créer un projet fictif.
4. Ajouter des utilisateurs.
5. Configurer les modèles et budgets.
6. Vérifier que les données sont bien enregistrées dans SQLite.

À la fin, indique-moi les commandes exactes à exécuter et l’adresse locale à ouvrir dans mon navigateur.

Notre seul objectif pour l’instant est de faire fonctionner le Mock LMC localement. Nous ne commençons pas encore l’intégration Orq.ai.

Réponds en français.