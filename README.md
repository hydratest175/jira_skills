Tu reprends un projet existant dans /workspace/LEA_Workspace.

Cette nouvelle session a été créée volontairement afin d’optimiser la consommation de tokens, sans perdre les connaissances, décisions architecturales et exigences de qualité accumulées pendant les développements précédents.

Une passation complète a été préparée et vérifiée par la session précédente.

1. Lecture initiale obligatoire

Commence par lire :

* /workspace/LEA_Workspace/project-memory/AGENTS.md
* /workspace/LEA_Workspace/project-memory/00_START_HERE.md
* /workspace/LEA_Workspace/project-memory/04_CURRENT_STATE.md
* /workspace/LEA_Workspace/project-memory/11_HANDOFF.md

Le fichier AGENTS.md étant limité au dossier project-memory, lis-le explicitement et applique ses instructions spécifiques à notre projet.

Consulte ensuite les documents spécialisés nécessaires à la compréhension de la prochaine mission.

Ne charge pas systématiquement toute la mémoire projet ni toutes les documentations historiques.

2. Références applicatives

Notre dernier workspace applicatif valide est :

/workspace/LEA_Workspace/lcc-c7e-provisioning-api-integration

La référence originale du LMC reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

C7e est terminée et qualifiée localement.

C8 n’a pas encore commencé.

Notre dernière référence de non-régression rapportée est :

* 689 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* 745 cas en comptabilisant les sous-tests.
* 718 réussites cumulées.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.

Certains rapports bruts historiques ne sont plus disponibles. Ne prétends pas les avoir vérifiés directement.

3. Notre mode de collaboration

Nous travaillons selon trois responsabilités complémentaires :

* Je définis les besoins, les priorités et valide les décisions structurantes.
* Un assistant externe conserve la vision architecturale globale, analyse les choix techniques et prépare les missions.
* Software Companion dispose de l’accès au code et à l’environnement réel pour analyser, challenger, implémenter, tester et documenter.

Tu ne dois jamais appliquer aveuglément une proposition incompatible avec le véritable code.

Si une décision architecturale semble incorrecte, explique pourquoi, propose des alternatives et présente les conséquences de chacune.

Nous privilégions les micro-MR cumulatives, ciblées, explicables et réellement qualifiées.

4. Validation de ta compréhension

Avant tout développement, je souhaite vérifier que la passation te permet de reprendre correctement notre travail.

Présente-moi en français et de manière synthétique :

1. L’objectif métier du projet et le rôle respectif du LMC, d’Orq et d’Engineering Companion.
2. Le périmètre fonctionnel exact du Mock LMC que nous devons reproduire.
3. L’architecture actuellement implémentée et les responsabilités de ses principaux composants.
4. Les décisions structurantes et leurs justifications.
5. Les protections contre les doublons, les mutations ambiguës et les problèmes de concurrence.
6. Le fonctionnement de la récupération automatique et le véritable rôle du Repair.
7. Les qualifications réellement effectuées, leurs résultats et leurs limites.
8. L’état exact de C7e et les contrats API disponibles.
9. Le périmètre proposé pour C8, les composants frontend concernés et les moyens de qualification envisageables.
10. Les étapes restantes avant notre premier provisioning réel, puis avant la parité complète avec le Mock LMC.

Vérifie les informations critiques contre le code source et les références documentaires disponibles.

Ne te contente pas de reformuler mécaniquement le handoff.

Signale les contradictions, informations manquantes ou décisions nécessitant encore un arbitrage.

5. Optimisation des tokens

Pour cette reprise et les futures missions :

* Privilégie les informations déjà vérifiées et indexées.
* Consulte les documents spécialisés uniquement lorsque nécessaire.
* Évite les explorations redondantes des anciens workspaces.
* Ne lance pas plusieurs sous-agents pour retrouver une information déjà disponible.
* Évite les sorties de commandes inutilement volumineuses.
* Conserve les preuves détaillées dans des fichiers plutôt que de les reproduire intégralement dans la conversation.

Ne sacrifie jamais la qualité des analyses, des tests ou des vérifications de sécurité pour économiser des tokens.

6. Maintenance de la mémoire

Après chaque micro-MR, mets à jour les documents pertinents dans project-memory.

Conserve notamment :

* L’état courant.
* Le handoff.
* Les décisions nouvelles ou supersédées.
* La roadmap.
* Les résultats de qualification.
* Les limitations restantes.

À partir de C8, préserve également les rapports de tests assainis, les signatures de non-régression et les références permettant de vérifier les résultats ultérieurement.

Évite de conserver des credentials, secrets ou artefacts sensibles.

7. Contraintes immédiates

Cette première mission est uniquement une validation de reprise.

* Aucun développement applicatif.
* Aucune création du workspace C8.
* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq.
* Aucune modification Kubernetes.
* Aucune modification des ressources Docker existantes.
* Aucune modification des anciens workspaces.
* Aucune modification de la procédure habituelle de lancement du LMC.

Ne relance pas toute la campagne historique de qualification pour cette prise de contexte.

Nous déciderons des tests nécessaires au moment de C8.

Attends mon autorisation explicite avant de commencer l’implémentation.

Notre objectif reste d’atteindre la parité fonctionnelle complète avec le Mock LMC depuis le véritable LMC lancé localement, avant tout déploiement en préproduction.