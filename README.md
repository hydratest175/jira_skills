Je souhaite apporter une précision importante concernant ProjectOrqSaga et la table saga_project_orq.

Cette table a été créée spécifiquement pour notre future intégration Orq.ai. Nous sommes libres d’en faire évoluer le schéma, les champs, les contraintes et le fonctionnement.

Nous ne sommes donc pas obligés de conserver sa structure actuelle.

L’objectif principal est de respecter les conventions existantes du LMC et de réutiliser ses mécanismes Saga, Repair, diagnostic et support.

1. Nouvelle orientation privilégiée

Puisque notre propre table orq_project_provisioning_operations n’a pas encore été publiée ni déployée officiellement, je souhaite privilégier la réutilisation directe de saga_project_orq comme unique table d’opérations de provisioning Orq.

L’idée est de reprendre le schéma final et les garanties développées dans MR5, MR6 et MR7, puis de les intégrer au modèle ProjectOrqSaga existant.

Nous souhaitons idéalement conserver trois tables aux responsabilités distinctes :

* saga_project_orq : opérations de provisioning, statuts, générations, diagnostics, mutations et résultats.
* orq_project_mappings : mapping durable et identité vérifiée des projets Orq.
* orq_project_temporal_start_outbox : livraison fiable des demandes de démarrage Temporal.

Nous ne souhaitons pas maintenir simultanément saga_project_orq et orq_project_provisioning_operations si elles remplissent les mêmes responsabilités.

Aucune double écriture ni duplication temporaire inutile.

2. Réutilisation de nos développements

Analyse comment transférer notre schéma final vers ProjectOrqSaga en conservant au maximum :

* Notre Store PostgreSQL.
* Nos contrats V2.
* Nos Activities V2.
* Notre Workflow Temporal.
* Notre logique de réconciliation T1.
* Nos mécanismes CAS.
* Nos générations.
* Nos snapshots immuables.
* Notre réservation durable avant mutation.
* Notre gestion des résultats candidats et confirmés.
* Notre gestion de UNKNOWN_OUTCOME et NEEDS_RECONCILIATION.
* Nos tests existants.

Privilégie une adaptation du modèle SQLAlchemy, des migrations et des références dans notre code plutôt qu’une réimplémentation de la logique métier.

Vérifie précisément quelles modifications sont réellement nécessaires.

3. Réutilisation des champs Saga existants

Analyse les champs et conventions actuellement présents dans ProjectOrqSaga.

Conserve ou adapte les éléments pertinents, notamment :

* La relation avec le projet LMC.
* Le type d’opération.
* Les statuts.
* Le timestamp de claim.
* La référence de support.
* Les codes d’erreur.
* Les messages de diagnostic sécurisés.
* Les timestamps.

Évite de créer de nouveaux champs si un champ existant peut remplir exactement la même responsabilité sans perte de garantie.

En revanche, ne fusionne pas deux champs ayant des significations différentes uniquement pour réduire le nombre de colonnes.

Vérifie les différences entre notre machine à états et les statuts Saga existants.

4. Cardinalité et historique

Vérifie que le modèle enrichi permet de représenter toutes les opérations nécessaires au cours du cycle de vie d’un projet.

Il doit notamment permettre :

* Plusieurs opérations historiques pour un même projet.
* Plusieurs générations de provisioning.
* Une distinction entre PLAN et APPLY.
* Une seule opération non résolue lorsque cette restriction est nécessaire.
* La conservation des résultats confirmés.
* La conservation des mutations ambiguës.
* Une association fiable avec l’outbox Temporal.

Ne reproduis pas automatiquement le mécanisme de suppression des Sagas après réussite utilisé pour d’autres ressources du LMC.

Notre historique d’opérations et les preuves nécessaires à la prévention des doublons doivent être conservés.

5. Migrations Alembic

Dans le cadre de la convergence vers la dernière version du LMC, étudie une migration additive qui enrichit directement saga_project_orq.

Ne crée pas notre ancienne table orq_project_provisioning_operations pour ensuite la renommer ou la supprimer si cette étape n’est pas nécessaire.

Ne supprime pas non plus la table Saga existante sans justification technique.

Vérifie la compatibilité avec les éventuelles données déjà présentes, les contraintes existantes et les migrations officielles.

Adapte les relations de l’outbox afin qu’elles référencent le modèle d’opération retenu.

Conserve intégralement nos anciens espaces de travail et leurs migrations historiques.

6. Intégration Repair

Le mécanisme de support doit rester celui du LMC existant.

Réutilise les conventions et services associés à :

* ProjectOrqSaga.
* LmcRepairProjectModal.tsx.
* POST /v1/projects/{project_ref}/repair.
* GET /v1/projects/{project_ref}/operation-progress.
* Les permissions SpiceDB existantes.

Il ne doit exister qu’une seule source autoritative pour les statuts des opérations de provisioning Orq.

Une action Repair ne doit jamais permettre de contourner les protections contre les mutations ambiguës ou de rejouer automatiquement une création Orq potentiellement effectuée.

7. Mise à jour de la roadmap

Prends cette nouvelle orientation en compte dans l’analyse de convergence et la roadmap C0 à C10+.

C0 reste consacré à la qualification de la nouvelle base.

C1 doit concerner le mapping durable.

C2 doit désormais privilégier l’enrichissement de ProjectOrqSaga et l’intégration de l’outbox, en reprenant notre schéma final existant.

C3 doit privilégier le portage et l’adaptation de nos composants métier et de persistance, sans réimplémentation inutile.

Indique précisément les modifications nécessaires et les tests pouvant être directement réutilisés.

Si cette approche présente une incompatibilité structurelle importante, explique-la avant de proposer une alternative.

8. Contraintes

Pour le moment, mets à jour l’analyse et la roadmap. Poursuis uniquement la qualification C0 déjà autorisée.

Ne commence pas C1, C2 ou C3 avant validation.

Préserve tous les espaces existants, notamment la nouvelle base située dans :

/workspace/LEA_Workspace/lcc_last_version/lcc

Aucune opération Git ou GitLab, aucune modification de l’infrastructure existante, aucun appel distant Orq ou Temporal et aucun déploiement.

La procédure standard de lancement du LMC doit rester inchangée.

Documentation technique en anglais et restitution en français.

Notre priorité est de réutiliser au maximum nos développements, de respecter les conventions existantes du LMC et d’éviter toute duplication fonctionnelle.