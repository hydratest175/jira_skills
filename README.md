Tu reprends un projet existant depuis une session entièrement vierge. Toutes les anciennes sessions ont été supprimées volontairement. La documentation constitue désormais ta mémoire projet.

Commence par lire les fichiers suivants dans /workspace/LEA_Workspace/project-memory/ :

* 00_START_HERE.md
* 04_CURRENT_STATE.md
* 06_WORKING_RULES.md
* 11_HANDOFF.md

Consulte ensuite uniquement les documents complémentaires nécessaires à ta mission, notamment le runbook d’environnement et les décisions architecturales pertinentes.

Mission actuelle : ID-CRED-2

La dernière étape validée est ID-CRED-1, dans :

/workspace/LEA_Workspace/lcc-id-cred-1-identity-contracts-fakes

Le premier provisioning réel d’un projet Orq depuis le LMC a également été qualifié avec succès. Je confirme avoir supprimé manuellement le projet distant. Les données historiques locales doivent rester intactes et ne pas être réutilisées pour de nouvelles qualifications.

Je t’autorise à implémenter ID-CRED-2 : migration additive Alembic et modèles de persistance nécessaires aux Identities et aux clés API temporaires.

Vérifie d’abord si cette étape a déjà été partiellement commencée afin de préserver tout travail existant.

Respecte notamment les décisions suivantes :

* Identity globale par utilisateur LMC, réutilisable entre projets.
* Éligibilité basée sur le Product Access Engineering Companion existant.
* External ID stable, display name et email issus du modèle utilisateur LMC.
* Aucun système parallèle de gestion des utilisateurs ou permissions.
* Aucun stockage durable de token brut.
* Mutualisation maximale des fondations déjà développées.
* Préservation du Workflow projet V2 et de ses qualifications.

Travaille dans un workspace cumulatif isolé. Qualifie les migrations, contraintes, mappings et la non-régression sur PostgreSQL 18.4 réel, en réutilisant le runner déjà documenté.

Toutes les règles permanentes de project-memory restent applicables.

Évite les lectures exhaustives inutiles, les investigations redondantes et la multiplication des sous-agents.

Commence par une courte restitution de ta compréhension du projet et de la mission, puis passe directement à l’implémentation si aucune contradiction bloquante n’est identifiée.

Documente les modifications, les tests réellement exécutés et les limitations. Actualise la mémoire projet.

Aucun appel distant. Ne commence ni ID-CRED-3 ni C9.