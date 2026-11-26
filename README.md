Je valide ta reprise du projet et ta compréhension de la mémoire préparée par la session précédente.

Les incohérences et limitations que tu as identifiées sont pertinentes. Conserve-les dans la documentation et la mémoire projet, mais ne cherche pas à toutes les résoudre pendant C8.

Je t’autorise explicitement à commencer C8 — Frontend Orq Provisioning Integration.

1. Workspace

Base applicative cumulative :

/workspace/LEA_Workspace/lcc-c7e-provisioning-api-integration

Nouveau workspace isolé :

/workspace/LEA_Workspace/lcc-c8-frontend-orq-integration

Préserve intégralement tous les espaces précédents.

Applique les règles contenues dans project-memory/AGENTS.md et consulte uniquement les documents spécialisés nécessaires à cette mission.

2. Objectif

Raccorder le véritable frontend React du LMC aux fonctionnalités backend C7e et C7d.

C8 doit permettre :

* Le déclenchement explicite du provisioning du projet Orq.
* L’affichage de son état.
* Le suivi asynchrone de l’opération.
* La reprise du suivi après rafraîchissement.
* L’intégration minimale des diagnostics et actions Orq dans la modale Repair existante.

Ne présente pas le provisioning du seul projet Orq comme un provisioning complet d’Engineering Companion.

L’objectif final reste un provisioning global de toutes les ressources du Mock LMC.

3. Périmètre des modifications

Inspecte et enrichis principalement :

* frontend/src/types/index.ts
* frontend/src/api/client.ts
* frontend/src/components/LmcProject.tsx
* frontend/src/components/LmcRepairProjectModal.tsx
* frontend/src/styles/LmcRepairProjectModal.css

Une modification CSS additive supplémentaire est acceptable si elle est réellement nécessaire.

Réutilise les composants, styles, conventions, traductions éventuelles et mécanismes de gestion d’état existants.

Ne refactorise pas l’ensemble du frontend.

Ne crée aucune nouvelle page ou modale dédiée au Repair Orq.

4. Contrats backend

Utilise les véritables contrats C7e et C7d :

* POST /v1/projects/{project_ref}/orq-provisioning
* GET /v1/projects/{project_ref}/operation-progress
* GET /v1/projects/{project_ref}/operation-progress?operation_ref={operation_ref}
* POST /v1/projects/{project_ref}/repair

Vérifie les types et les champs exacts dans le backend.

Le POST doit envoyer explicitement le mode APPLY.

Ne développe pas PLAN pendant C8.

Distingue correctement :

* HTTP 202 : nouvelle intention de provisioning acceptée.
* HTTP 200 : opération existante retrouvée par déduplication.
* HTTP 409 : conflit métier.
* Erreurs d’autorisation.
* Erreurs transitoires.
* Résultat HTTP incertain.

Une réponse HTTP 200 ou 202 ne signifie pas que le provisioning est terminé.

5. Bouton de provisioning

Intègre un bouton dans l’interface projet existante.

Il doit être visible uniquement lorsque enqueue_enabled et can_provision l’autorisent.

Respecte les conventions visuelles actuelles du LMC.

Le bouton doit :

* Déclencher une action APPLY explicite.
* Empêcher les doubles clics et requêtes simultanées accidentelles.
* Afficher un état de soumission.
* Conserver immédiatement operation_ref dès réception.
* Ne pas être présenté comme un bouton de retry métier.

Le backend reste seul responsable de l’autorisation.

Aucun provisioning automatique lors de l’ouverture de la page, de la création standard du projet, de la connexion ou de la déconnexion.

6. Suivi de l’opération

Réutilise les mécanismes de polling existants lorsque pertinent.

Le suivi Orq doit rester indépendant du suivi SDA/Looker.

Utilise le statut Orq, notamment response.orq.operation.overall_status selon le contrat exact, et non le overall_status historique de premier niveau.

Après réception de operation_ref, le polling doit cibler précisément cette référence.

Lors d’un rafraîchissement, retrouve l’opération pertinente depuis les données backend puis fixe le suivi sur sa référence exacte.

Si une référence précédemment suivie est conservée côté client, assure son isolation par projet et par contexte utilisateur.

Ne bascule pas silencieusement vers une autre génération pendant le suivi.

Préserve la dernière projection utile lors des erreurs réseau transitoires.

Utilise un polling borné, avec arrêt sur les états terminaux ou nécessitant une intervention, et un budget maximal de cinq minutes conformément à ta proposition.

Un arrêt du polling pour dépassement de délai ne signifie pas que le provisioning a échoué. Permets une nouvelle consultation sans nouvelle mutation.

Arrête également les requêtes lorsque le composant est démonté ou que l’utilisateur change de projet.

7. Gestion des erreurs et acquittements incertains

Traite explicitement :

* Perte de réponse HTTP après le POST.
* Demande identique retrouvée.
* Conflit avec une opération existante.
* Livraison Temporal incertaine.
* Erreur de persistance locale.
* UNKNOWN_OUTCOME.
* Snapshot obsolète.
* Provisioning désactivé.
* Autorisation devenue indisponible.

En cas de perte de réponse au POST, consulte d’abord la progression persistée.

Ne déclenche pas automatiquement un nouveau POST pour résoudre une incertitude.

Une nouvelle demande explicite ne doit pas être présentée comme une simple répétition idempotente si la configuration du projet a pu changer entre-temps.

N’affiche jamais un faux succès ou un faux échec.

N’invente aucun pourcentage de progression que le backend ne fournit pas.

8. Intégration au Repair existant

Ajoute une section Orq à LmcRepairProjectModal.tsx.

Notre objectif est simplement d’offrir au développeur du LMC la même expérience de debug et de support que pour SDA et les autres composants.

Réutilise les actions C7d :

* DIAGNOSE
* LOOKUP_TEMPORAL_DELIVERY
* CONVERGE_LOCAL

Je confirme que DIAGNOSE doit être explicitement déclenché depuis la modale.

Aucune exécution automatique de DIAGNOSE pendant la consultation normale de la progression.

Affiche uniquement les actions autorisées et disponibles selon available_actions et le contrat backend.

Préserve strictement le comportement historique de la modale et du Repair sans corps.

Une action Repair peut avoir effectivement modifié PostgreSQL avant qu’une erreur HTTP 503 soit retournée, notamment en cas d’échec d’audit final ou de rafraîchissement de projection.

Dans cette situation :

* Ne relance jamais automatiquement l’action.
* Signale que son résultat nécessite une vérification.
* Rafraîchis les informations de manière non mutative.
* Permets un diagnostic explicite ultérieur.

Ne crée aucune nouvelle action de réparation ou logique d’orchestration côté frontend.

9. Qualification frontend

J’autorise un harness de test React minimal et isolé, à condition qu’il réutilise les dépendances disponibles et n’affecte pas le lancement standard.

Le frontend ne possède actuellement pas de véritable infrastructure de tests automatisés selon ton analyse.

Privilégie donc :

* Les outils déjà disponibles.
* Le build TypeScript/Vite.
* Un harness ciblé avec transports et timers simulés.
* Les tests des comportements critiques.
* Une vérification visuelle desktop/mobile.
* Les contrôles d’accessibilité clavier et ARIA.

Si une nouvelle dépendance est indispensable, présente son nom, sa version, son rôle, son impact et les alternatives avant installation.

Ne développe pas une infrastructure de tests disproportionnée.

Teste notamment :

* Visibilité du bouton selon les permissions.
* Provisioning désactivé.
* Soumission nominale.
* Double clic.
* HTTP 202 et HTTP 200.
* HTTP 409.
* Perte de réponse.
* Polling par operation_ref.
* Changement de projet.
* Rafraîchissement.
* Arrêt du polling.
* Erreurs transitoires.
* États métier et livraison distincts.
* Actions Repair explicitement déclenchées.
* HTTP 503 après une action Repair.
* Non-régression du fonctionnement historique.

Si un navigateur ou un harness n’est pas disponible, distingue clairement les tests exécutés de ceux restant à effectuer.

10. Non-régression

Référence C7e :

* 689 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques rapportés comme identiques.
* JUnit brut : 716 cas, 689 réussites.
* Comptabilité incluant les sous-tests : 745 cas, 718 réussites.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.

Exécute le build frontend, les tests ciblés et les tests backend pertinents, puis la non-régression complète conformément à nos règles.

Les anciens rapports bruts C7e ne sont plus disponibles. Ne prétends pas pouvoir comparer leurs signatures directement si les preuves nécessaires manquent.

Si nécessaire, reconstitue une référence comparable depuis le workspace C7e sans modifier celui-ci.

Conserve cette fois les rapports de qualification assainis, les références des tests et les signatures de non-régression.

11. Contraintes

Toutes les contraintes permanentes du projet restent applicables.

En particulier :

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun appel distant Temporal ou Orq.
* Aucune modification Kubernetes.
* Aucun serveur Temporal local.
* Aucune modification des ressources Docker existantes.
* Aucune modification des migrations ou du pont Alembic.
* Aucune modification de Docker Compose, Dockerfiles, scripts 01/02/03 ou configurations VS Code.
* Aucun changement de la procédure habituelle de lancement.
* Aucun développement des autres ressources Orq.
* Aucun nouveau chantier de récupération automatique.

C8 doit rester essentiellement frontend. Si un blocage impose une modification backend, expose-le avant de modifier le contrat.

12. Documentation et restitution

Crée :

documentation/C8_FRONTEND_ORQ_INTEGRATION.md

Documente les fichiers et symboles modifiés, leur comportement avant/après, les choix techniques et les alternatives.

Mets à jour la mémoire projet, le handoff, l’index canonique, les qualifications et la roadmap.

Présente-moi en français :

* Les fonctionnalités frontend implémentées.
* Les composants modifiés.
* Les parcours utilisateur.
* Le fonctionnement du polling.
* La gestion des erreurs.
* L’intégration au Repair.
* Les résultats des tests.
* Les éventuelles captures synthétiques de l’interface.
* Les limitations restantes.
* Les prérequis précis de C9.

Ne réalise pas encore la qualification distante ni le premier provisioning Orq réel.

Ne commence pas C9 sans mon accord.

Tu peux commencer C8.