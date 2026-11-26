Je valide C7e sur son périmètre de qualification locale.

Nous venons d’atteindre un jalon important : l’intégration backend du provisioning du projet Orq est disponible, et C8 n’a pas encore commencé.

La session Software Companion actuelle est devenue très volumineuse. Nous allons donc changer de session avant C8 afin de réduire les consommations de contexte redondantes, tout en préservant la qualité du travail et l’ensemble des connaissances importantes.

Ta dernière mission dans cette session est de préparer une passation complète, fiable et optimisée pour la reprise.

Ne commence pas C8.

1. Référence applicative actuelle

Le dernier workspace applicatif cumulatif est :

/workspace/LEA_Workspace/lcc-c7e-provisioning-api-integration

La référence originale du LMC reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les workspaces précédents.

Notre dernière référence de non-régression est :

* 689 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* JUnit brut : 716 cas, 689 réussites, 27 échecs.
* Comptabilité incluant les sous-tests : 745 cas, 718 réussites, 27 échecs.
* 96 tests ciblés réussis.
* 77 tests PostgreSQL ciblés réussis.
* 125 tests PostgreSQL cumulés réussis.
* 7 tests SpiceDB réels réussis.
* 52 tests ciblés réussis sans SDK Temporal.
* PostgreSQL 18.4.
* Head Alembic : 0004_orq_saga_outbox.
* Catalogue applicatif : 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

Vérifie ces informations contre les rapports et preuves disponibles.

2. Objectif de la passation

Une nouvelle session, sans accès à l’historique conversationnel actuel, doit pouvoir reprendre le projet avec une compréhension suffisante pour poursuivre le travail avec la même rigueur.

Elle doit retrouver :

* La vision métier.
* L’architecture actuelle.
* Les décisions techniques et leurs justifications.
* Les alternatives rejetées ou supersédées.
* La méthode de travail.
* L’état exact du code.
* Les qualifications réellement effectuées.
* Les limitations restantes.
* Les prochaines tâches.
* Les références vers la documentation détaillée et les fichiers sources.

Ne produis pas uniquement un résumé de la conversation.

Construis une mémoire de reprise opérationnelle, vérifiée contre les sources locales.

Si une information historique n’est plus accessible ou ne peut pas être vérifiée, signale-le explicitement.

3. Organisation de la passation

Crée un dossier spécifique :

/workspace/LEA_Workspace/project-memory/

Ne mets pas encore en place de base de connaissances globale pour les autres projets.

Cette tâche concerne uniquement la continuité du projet LMC/Orq.

Crée les documents suivants :

* 00_START_HERE.md : point d’entrée compact et instructions de lecture.
* 01_PROJECT_CONTEXT.md : vision métier et périmètre fonctionnel.
* 02_ARCHITECTURE.md : architecture implémentée et architecture cible.
* 03_DECISIONS.md : décisions validées, justifications, alternatives rejetées et décisions ouvertes.
* 04_CURRENT_STATE.md : état exact de l’implémentation et dernier workspace valide.
* 05_ROADMAP.md : étapes restantes et critères d’acceptation.
* 06_WORKING_RULES.md : méthode de travail et contraintes impératives.
* 07_QUALIFICATION.md : résultats, références de tests et preuves.
* 08_KNOWN_LIMITATIONS.md : limitations et décisions non résolues.
* 09_SOURCE_INDEX.md : index des fichiers, symboles, tests et documentations.
* 10_ENVIRONMENT_RUNBOOK.md : environnement local et procédures qualifiées.
* 11_HANDOFF.md : transmission opérationnelle vers C8.

Réutilise au maximum les documents existants.

Ne recopie pas intégralement les documentations C0 à C7e.

La mémoire doit servir de synthèse structurée et d’index vers les sources autoritatives.

4. Instructions permanentes

Inspecte les éventuels AGENTS.md déjà présents et vérifie les mécanismes réellement pris en charge par notre version de Software Companion.

Si cela est approprié et sans impact sur les projets indépendants, prépare un AGENTS.md compact et spécifique à ce projet.

Il doit référencer la mémoire projet et expliquer la procédure de reprise.

Ne modifie aucune configuration globale de Software Companion pendant cette tâche.

Ne remplace aucune instruction existante sans analyse préalable.

5. Contexte métier à préserver

Documente notamment :

* Le rôle du LMC.
* Le rôle d’Engineering Companion.
* Le rôle d’Orq dans l’architecture.
* Le Mock LMC comme référence de parité fonctionnelle.
* Le provisioning persistant explicitement déclenché par le Project Manager.
* L’objectif d’un provisioning global des ressources nécessaires.
* La séparation des projets et des ressources utilisateurs.
* Les décisions relatives aux modèles et aux versions épinglées des agents.
* Les connecteurs Jira et GitLab.
* La propagation du LMC Project ID jusqu’aux MCP.
* Les ressources réellement provisionnées par le Mock LMC.
* Les fonctionnalités explicitement hors périmètre.

Inspecte le Mock LMC et ses documents pour vérifier l’exhaustivité du périmètre.

Ne confonds pas la création du projet Orq avec le provisioning complet d’Engineering Companion.

6. Architecture à préserver

Documente précisément les responsabilités et interactions entre :

* FastAPI et React.
* PostgreSQL.
* SpiceDB.
* ProjectOrqSaga.
* orq_project_mappings.
* orq_project_temporal_start_outbox.
* Service d’enqueue C5.
* Dispatcher C6.
* Temporal.
* Worker C4.
* Workflow V2.
* Activities.
* Gateway Orq.
* Store PostgreSQL.
* Récupération C7b et C7c.
* Repair C7d.
* API C7e.

Conserve les frontières transactionnelles, les ordres de verrouillage, les mécanismes CAS, les leases, les protections de génération et les règles de réconciliation.

Indique les fichiers et symboles permettant de retrouver chaque composant.

Documente les garanties réelles et leurs limites.

Ne revendique aucune garantie exactly-once distribuée.

7. Décisions structurantes

Préserve notamment :

* La réutilisation de ProjectOrqSaga plutôt que la création d’une table d’opérations parallèle.
* La séparation entre statut métier, identité distante et livraison Temporal.
* L’utilisation de Temporal préproduction existant, sans serveur Temporal local.
* Le Worker et le Dispatcher séparés et désactivés par défaut.
* La réservation durable avant mutation.
* L’interdiction de relancer une mutation ambiguë à l’aveugle.
* L’absence de compensation DELETE automatique.
* Le Workflow ID déterministe.
* La permission dédiée provision_orq_project.
* La distinction entre provisioning, consultation et Repair.
* La récupération automatique sûre comme priorité.
* Le Repair comme outil résiduel de debug destiné au développeur.

Pour chaque décision, préserve autant que possible son contexte, sa justification et les alternatives abandonnées.

Ne réintroduis pas les anciennes orientations supersédées.

8. Qualifications importantes

Conserve les références et résultats précis de :

* T2 : qualification de la connexion Temporal.
* C4-Q : qualification LIMITED du Worker.
* C6-Q : qualification LIMITED de la chaîne complète.
* C7b-Q : qualification ACCEPTED de la récupération automatique après interruption réelle du Worker.
* C7c : récupération post-fermeture qualifiée localement.
* C7d : Repair backend qualifié localement.
* C7e : API et operation-progress qualifiés localement.

Préserve les distinctions entre tests réels, mocks, injections d’erreurs, interruptions de processus et replays.

Documente explicitement que le problème de récupération observé pendant C4-Q a ensuite été corrigé et qualifié réellement dans C7b-Q.

Ne conserve aucun historique sensible, credential ou secret dans la mémoire projet.

9. Prochaine mission : C8

Prépare un handoff particulièrement précis pour le frontend.

Les endpoints C7e sont désormais :

* POST /v1/projects/{project_ref}/orq-provisioning
* GET /v1/projects/{project_ref}/operation-progress
* GET /v1/projects/{project_ref}/operation-progress?operation_ref={operation_ref}
* POST /v1/projects/{project_ref}/repair

Vérifie et documente les contrats exacts depuis le code.

Le POST de provisioning accepte uniquement le mode APPLY.

Il retourne 202 pour une nouvelle opération et 200 pour une déduplication.

Documente précisément :

* Les modèles TypeScript à enrichir.
* Les méthodes API à ajouter.
* Les composants React à modifier.
* Les statuts disponibles.
* Le champ can_provision et ses limites.
* Le suivi par operation_ref.
* Les mécanismes de polling existants.
* Le comportement après perte de réponse HTTP.
* Les permissions.
* Les actions Repair disponibles.
* Les tests frontend existants et ceux à ajouter.

Les fichiers frontend précédemment identifiés sont notamment :

* frontend/src/types/index.ts
* frontend/src/api/client.ts
* frontend/src/components/LmcProject.tsx
* frontend/src/components/LmcRepairProjectModal.tsx
* frontend/src/styles/LmcRepairProjectModal.css

Vérifie leurs chemins et symboles exacts.

Le prochain agent devra réutiliser l’interface projet et la modale Repair existantes.

Il ne devra pas développer une nouvelle plateforme de support.

10. Préparation du premier lancement réel

Documente les prérequis et limitations concernant :

* La procédure habituelle de lancement du LMC.
* Les scripts 01/02/03.
* Docker Compose.
* Les configurations VS Code.
* PostgreSQL 18.4.
* Le pont Alembic.
* Le schéma SpiceDB actualisé.
* L’activation explicite du provisioning.
* Le Worker et le Dispatcher sur la même Task Queue.
* Le tunnel Temporal depuis le DevEnv.
* La configuration Orq autorisée.

Le principal blocage identifié pendant C7e reste le pont Alembic après le reset historique.

Ne présente pas le stamp Alembic comme une opération générique applicable à n’importe quelle base.

Il doit être précédé de la vérification de la compatibilité exacte du catalogue et limité à une base locale explicitement autorisée.

Préserve toutes les limitations historiques encore ouvertes.

11. Méthode de travail à transmettre

Notre fonctionnement repose sur trois responsabilités :

* Je conserve la responsabilité des arbitrages et des validations structurantes.
* Un assistant externe nous accompagne sur la vision globale, l’architecture, les choix techniques et la rédaction des missions.
* Software Companion possède l’accès au code et aux outils nécessaires pour inspecter, challenger, implémenter, tester et documenter.

Software Companion ne doit jamais exécuter aveuglément une proposition incompatible avec le véritable code.

Préserve notre méthode :

* Micro-MR cumulatives et ciblées.
* Workspaces isolés.
* Préservation des étapes précédentes.
* Documentation technique vivante en anglais.
* Restitution des résultats en français.
* Tests ciblés et non-régression.
* Qualification honnête.
* Validation avant de poursuivre.
* Aucune opération Git ou GitLab par Software Companion.
* Aucun changement Kubernetes.
* Aucun changement des ressources Docker existantes.
* Aucun déploiement LMC avant la parité complète avec le Mock LMC local.
* Aucune mutation distante réelle sans autorisation explicite.
* Préservation de la procédure habituelle de lancement du LMC.

Ces contraintes restent spécifiques à notre projet.

12. Optimisation de la consommation de tokens

La nouvelle session ne doit pas avoir à relire tous les documents historiques systématiquement.

Organise une lecture progressive :

* Instructions permanentes compactes.
* Point d’entrée.
* État courant.
* Handoff.
* Documents spécialisés selon la tâche.
* Sources détaillées uniquement lorsque nécessaire.

Évite les duplications.

Indexe précisément les fichiers et symboles déjà investigués.

Évite de mobiliser plusieurs sous-agents pour redécouvrir des informations déjà vérifiées.

Ne réduis cependant jamais la qualité des tests, des analyses de sécurité ou des validations nécessaires uniquement pour économiser des tokens.

Définis une procédure légère de maintenance de cette mémoire après chaque micro-MR.

13. Validation de la passation

Vérifie :

* L’existence des chemins référencés.
* La cohérence de l’état applicatif.
* Les résultats de non-régression.
* Les contradictions entre anciennes et nouvelles décisions.
* L’exhaustivité du périmètre Mock LMC.
* L’absence de secrets.
* La précision de la prochaine mission.

Si possible, réalise une vérification de reprise à froid avec un agent ne recevant que le point d’entrée et les références documentaires.

Ne lui transmets pas l’intégralité de cette session.

Limite cette vérification à ce qui est nécessaire.

14. Restitution finale

Présente-moi en français :

* Les fichiers créés.
* La structure de la mémoire.
* Les vérifications effectuées.
* Les informations éventuellement manquantes.
* Les décisions ouvertes.
* Le volume approximatif du contexte initial.
* Le dernier workspace applicatif valide.
* Les documents à lire pour C8.
* Un prompt de reprise compact pour la nouvelle session.

Cette tâche est exclusivement documentaire.

Aucune modification applicative, aucune opération Git, aucun appel distant, aucun changement d’infrastructure.

Ne commence pas C8.

Une fois la passation terminée, nous fermerons cette phase de travail et commencerons une nouvelle session Software Companion.