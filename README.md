Je valide C7d sur son périmètre de qualification locale.

Le chantier spécifiquement consacré au Repair est désormais terminé côté backend.

Nous pouvons commencer C7e — Provisioning API and Operation Progress Integration.

Cette étape est prioritaire. Nous devons désormais avancer rapidement vers le premier provisioning depuis l’interface du véritable LMC.

1. Espace de travail

Utilise comme base applicative cumulative :

/workspace/LEA_Workspace/lcc-c7d-minimal-repair-integration

Crée un nouvel espace isolé :

/workspace/LEA_Workspace/lcc-c7e-provisioning-api-integration

La référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Notre référence applicative C7d est désormais :

* 706 cas JUnit.
* 679 réussites.
* 650 tests pytest et 29 sous-tests réussis.
* 27 échecs historiques strictement identiques après normalisation.
* 126 tests ciblés réussis.
* 74 tests PostgreSQL ciblés réussis.
* 120 tests PostgreSQL cumulés réussis.
* 7 tests SpiceDB réels réussis.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* Catalogue applicatif inchangé : 32 tables, 17 triggers, 4 fonctions, 85 index et 390 contraintes.

2. Documentation et références

Relis notamment :

* C5_TRANSACTIONAL_PROVISIONING_ENQUEUE.md
* C6_TEMPORAL_OUTBOX_DISPATCHER.md
* C6Q_TEMPORAL_REAL_QUALIFICATION.md
* C7A_ORQ_RECOVERY_AND_REPAIR_ANALYSIS.md
* C7B_ACTIVE_WORKFLOW_RECOVERY.md
* C7BQ_ACTIVE_WORKFLOW_RECOVERY_QUALIFICATION.md
* C7C_CLOSED_WORKFLOW_RECOVERY.md
* C7D_MINIMAL_REPAIR_INTEGRATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap canonique.

Inspecte également les conventions REST, les routes projet, les modèles de réponse, les permissions et les mécanismes de polling déjà présents dans le véritable LMC.

C7a était uniquement documentaire. L’intégration HTTP et operation-progress restent donc intégralement à réaliser.

3. Objectif de C7e

Permettre au véritable backend FastAPI du LMC :

* De recevoir une demande de provisioning Orq.
* De déléguer cette demande au service transactionnel C5.
* De retourner une référence d’opération exploitable.
* De suivre l’état de cette opération.
* D’intégrer les statuts Orq dans operation-progress.
* De fournir au futur frontend C8 toutes les informations nécessaires.

Aucune nouvelle logique métier de provisioning ne doit être développée dans l’API.

Nous raccordons les composants existants.

4. Vision fonctionnelle

Notre vision finale reste un provisioning persistant, explicitement déclenché par le Project Manager depuis le véritable LMC.

À terme, un bouton de provisioning global devra permettre de provisionner toutes les ressources nécessaires à Engineering Companion :

* Projet Orq.
* Identities.
* Clés API temporaires.
* Budgets.
* Modèles autorisés.
* Prompts.
* Agents spécialistes.
* Orchestrateurs personnels.
* Connecteurs.

Les modifications ultérieures devront permettre une synchronisation incrémentale des ressources existantes, sans recréation inutile.

Cependant, C7e concerne uniquement le provisioning du projet Orq, puisque les autres ressources ne sont pas encore raccordées.

Ne présente pas la création du projet Orq comme un provisioning complet d’Engineering Companion.

Ne développe pas les autres ressources pendant C7e.

N’introduis aucun provisioning automatique à la création standard d’un projet, à la connexion ou à la déconnexion d’un utilisateur.

5. Endpoint HTTP de provisioning

Inspecte les conventions REST existantes.

Une route telle que :

POST /v1/projects/{project_ref}/provision-orq

peut constituer une proposition, mais sélectionne le nom final selon les conventions du LMC.

L’endpoint doit :

* Utiliser l’identité authentifiée du LMC.
* Vérifier la permission provision_orq_project via les mécanismes existants.
* Respecter strictement le périmètre du projet.
* Appeler directement le véritable service C5.
* Restituer l’opération créée ou retrouvée.
* Retourner une réponse asynchrone cohérente avec les conventions existantes.
* Gérer les demandes identiques et conflictuelles selon les règles C5.
* Refuser explicitement les modes non supportés.

Une réponse HTTP 202 Accepted est une possibilité pour une nouvelle demande asynchrone, sous réserve de compatibilité avec les conventions du LMC.

Distingue une demande acceptée d’un provisioning effectivement réussi.

Ne duplique aucune logique de génération, snapshot, hash, audit, déduplication ou transaction.

Le Dispatcher C6 reste l’unique responsable applicatif du démarrage des Workflows.

L’endpoint ne doit effectuer aucun appel direct à Temporal, Orq ou Vault.

L’indisponibilité de Temporal ne doit pas empêcher l’enregistrement durable d’une demande autorisée lorsque le provisioning est activé.

6. Contrats API

Définis des contrats minimaux, stables et adaptés au frontend.

La réponse doit notamment permettre d’obtenir, lorsque pertinent :

* project_ref.
* operation_ref.
* Statut métier.
* Statut de livraison.
* Indication de création ou de réutilisation de l’opération.
* Diagnostic symbolique.
* Référence de support.
* Informations nécessaires au suivi.

Réutilise les modèles existants autant que possible.

Ne retourne aucun credential, token, secret, payload Temporal brut, snapshot sensible ou exception fournisseur.

Le client ne doit pas pouvoir fournir arbitrairement l’identité de l’acteur, la génération, le hash ou les preuves de provisioning.

Ces données restent sous le contrôle du backend.

Le mode APPLY est actuellement le seul mode exécutable. PLAN reste à intégrer ultérieurement conformément à notre objectif de parité avec le Mock LMC.

7. Intégration à operation-progress

Enrichis :

GET /v1/projects/{project_ref}/operation-progress

avec une projection Orq compatible avec les réponses historiques.

Réutilise le modèle de lecture développé pendant C7d.

Ne crée pas de deuxième logique de diagnostic concurrente.

La projection doit permettre au frontend de distinguer :

* Projet jamais provisionné.
* Provisioning désactivé.
* Demande persistée.
* Livraison en cours.
* Livraison confirmée.
* Exécution métier en cours.
* Provisioning réussi.
* Échec métier.
* Échec de livraison.
* Démarrage Temporal incertain.
* LOCAL_PERSISTENCE.
* UNKNOWN_OUTCOME.
* Snapshot obsolète.
* Conflit d’identité ou de mapping.
* Intervention support éventuellement nécessaire.

Ne présente que des états réellement démontrables depuis les données persistées.

Une outbox STARTED ne prouve pas qu’un Worker est actuellement actif.

Une Saga SUCCEEDED ne doit pas être dégradée uniquement parce que l’acquittement de livraison est incomplet.

Conserve la distinction entre statut métier, statut de livraison et diagnostic.

Préserve intégralement la compatibilité avec les Sagas Looker, Keycloak, SDA et les connecteurs.

8. Suivi par operation_ref

Le frontend doit pouvoir suivre précisément l’opération déclenchée, notamment après :

* Un rafraîchissement de la page.
* Une perte de réponse HTTP.
* Une nouvelle demande identique.
* Une modification concurrente.
* Une nouvelle génération ultérieurement autorisée.

Inspecte les mécanismes existants de suivi et de polling.

Réutilise operation-progress si son contrat peut être enrichi proprement. N’introduis un endpoint de consultation supplémentaire que si cela est réellement nécessaire.

Toute consultation par operation_ref doit vérifier l’appartenance de l’opération au projet concerné.

Un utilisateur ne doit jamais pouvoir consulter une opération d’un autre projet en fournissant sa référence.

Les lectures doivent rester strictement sans effet de bord.

Aucun polling ne doit déclencher une réparation, une mutation, un retry ou un appel réseau Temporal/Orq.

9. Permissions

Conserve la permission provision_orq_project introduite pendant C5.

Utilise uniquement les permissions de lecture projet existantes pour les consultations ordinaires, après vérification de leur pertinence.

Préserve la permission project#repair pour les interventions de support.

Ne considère pas ces trois responsabilités comme équivalentes.

Les diagnostics réservés au support ne doivent pas être exposés à un utilisateur disposant uniquement d’une permission de lecture ordinaire.

Vérifie notamment :

* Project Manager autorisé sur son périmètre.
* Project Manager refusé hors périmètre.
* Project Viewer incapable de provisionner.
* Consultation autorisée selon les droits existants.
* Restitution idempotente protégée.
* Refus sécurisé lorsque SpiceDB est indisponible.

N’introduis aucune nouvelle permission sans nécessité démontrée.

10. Sources autoritatives

Conserve strictement :

* Projet LMC : configuration désirée.
* ProjectOrqSaga : état métier.
* orq_project_mappings : identité distante autoritative.
* orq_project_temporal_start_outbox : livraison Temporal.
* Temporal : orchestration et historique d’exécution.

Les informations API doivent être dérivées de ces sources.

Évite les lectures incohérentes entre plusieurs tables pendant une transition concurrente.

Ne crée aucune nouvelle table de suivi ni aucune nouvelle Saga.

Aucune migration n’est attendue.

11. Préservation du Repair

C7d a terminé l’intégration backend du Repair Orq avec :

* DIAGNOSE.
* LOOKUP_TEMPORAL_DELIVERY.
* CONVERGE_LOCAL.

Ne redéveloppe aucune de ces fonctionnalités.

Préserve le comportement historique du POST repair sans corps.

Le Repair reste un outil résiduel de debug et d’intervention manuelle destiné au développeur.

La récupération automatique qualifiée pendant C7b-Q reste indépendante du Repair.

La récupération après fermeture développée dans C7c reste actuellement déclenchée manuellement.

Ne développe aucun nouveau mécanisme de récupération pendant C7e.

12. Préparation concrète de C8

À la fin de C7e, le backend doit fournir tous les contrats nécessaires pour permettre au frontend :

* D’afficher un bouton de provisioning aux utilisateurs autorisés.
* De déclencher une demande.
* D’afficher une progression.
* De reprendre le suivi après rafraîchissement.
* D’éviter les demandes multiples accidentelles.
* D’afficher les erreurs compréhensibles.
* De distinguer succès, attente et intervention nécessaire.
* D’enrichir la modale Repair existante avec une section Orq.

Inspecte les composants frontend existants uniquement pour préparer leurs futurs points d’intégration.

Ne modifie aucun fichier frontend pendant C7e.

Ne crée pas de nouvelle page dédiée si les interfaces projet existantes permettent une intégration naturelle.

13. Tests d’intégration API

Qualifie les véritables routes FastAPI avec PostgreSQL 18.4 et SpiceDB isolés lorsque pertinent.

Teste notamment :

* Demande nominale via HTTP.
* Persistance atomique Saga/outbox/audit par C5.
* Demande identique.
* Demandes concurrentes.
* Demande conflictuelle.
* Perte de réponse HTTP suivie d’une nouvelle demande.
* Projet inexistant ou inaccessible.
* Provisioning désactivé.
* Autorisations positives et négatives.
* Consultation par operation_ref.
* Accès inter-projets refusé.
* Temporal indisponible sans perte de demande.
* Fonctionnement sans SDK Temporal.
* Projection operation-progress.
* Stop-B de C6-Q.
* LOCAL_PERSISTENCE.
* UNKNOWN_OUTCOME.
* Succès métier avec acquittement de livraison incomplet.
* Cohérence des lectures concurrentes.
* Compatibilité des réponses historiques.
* Non-régression du Repair C7d.
* Absence de fuite de données sensibles.
* Aucun démarrage direct de Workflow.
* Aucun appel Orq réel.

Réutilise les fixtures et composants qualifiés précédemment.

Ne multiplie pas inutilement les tests reproduisant une logique métier déjà couverte par C5, C6 ou C7d.

14. Non-régression

Utilise C7d comme référence :

* 706 cas JUnit.
* 679 réussites.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* Catalogue applicatif inchangé.

Exécute les tests ciblés, les tests d’intégration API, les tests PostgreSQL et SpiceDB pertinents, la suite complète, la compilation Python et pip check.

Compare les node IDs et les traces normalisées des échecs historiques.

Vérifie également le fonctionnement normal du LMC sans SDK Temporal.

Ne modifie aucun test historique pour masquer une régression.

15. Préparation du lancement fonctionnel

Inspecte et documente les prérequis nécessaires pour notre première qualification depuis le véritable LMC local :

* Compatibilité du schéma PostgreSQL avec Alembic.
* Application du schéma SpiceDB local actualisé.
* Activation explicite du provisioning.
* Configuration du Worker et du Dispatcher.
* Cohérence de leurs Task Queues.
* Connexion Temporal préproduction.
* Configuration Orq.
* Lancement habituel du backend et du frontend.

Nous devons absolument conserver notre manière actuelle de lancer le LMC.

Ne modifie pas encore la procédure standard de lancement ni le pont Alembic.

Identifie les éventuels blocages afin de pouvoir les traiter lors de la qualification fonctionnelle.

Ne suppose pas que les bases historiques sont compatibles avec les nouvelles migrations.

16. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun commit, branche, push, merge, rebase ou création de MR.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq.
* Aucune modification Kubernetes.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucune modification des ressources Docker existantes.
* Seules les ressources temporaires isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose ou des Dockerfiles.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucun changement de la procédure habituelle de lancement.
* Aucun développement frontend.
* Aucun nouveau chantier de Repair.
* Préservation intégrale des espaces précédents.

17. Documentation et restitution

Crée :

documentation/C7E_PROVISIONING_API_INTEGRATION.md

Rédige la documentation technique en anglais et restitue-moi les résultats en français.

Mets à jour l’index canonique et la roadmap.

Documente chaque fichier et symbole créé ou modifié, son rôle, le comportement avant/après, les composants réutilisés, les choix techniques et les alternatives envisagées.

Présente-moi :

* Les endpoints disponibles.
* Les contrats exacts de requête et de réponse.
* Des exemples HTTP synthétiques.
* Les permissions utilisées.
* Les états disponibles pour le frontend.
* Le fonctionnement du suivi par operation_ref.
* Les résultats des tests.
* Les résultats de non-régression.
* Les limitations restantes.
* Les fichiers frontend à modifier pendant C8.
* Les prérequis du premier lancement fonctionnel local.

Ne propose pas une nouvelle grande campagne de qualification isolée C7e-Q.

Nous passerons directement à C8, sous réserve des résultats de C7e, puis à une qualification fonctionnelle intégrée depuis le véritable LMC.

Notre objectif reste la parité fonctionnelle complète avec le Mock LMC en local avant tout déploiement en préproduction.

Tu peux commencer C7e.

Ne commence pas C8 sans mon accord.