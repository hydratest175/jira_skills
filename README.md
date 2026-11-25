Je valide C3b sur son périmètre de qualification locale.

Notre nouvelle référence est désormais :

* 285 cas JUnit.
* 258 cas JUnit réussis.
* 229 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques strictement identiques.
* 49 tests Temporal ciblés réussis avec SDK.
* 36 tests ciblés réussis sans SDK installé.
* Aucune nouvelle régression.
* SDK optionnel temporalio==1.18.2.
* Lock des dépendances identique à T2.
* Head Alembic unique : 0004_orq_saga_outbox.
* 32 tables applicatives.
* Aucune modification du fonctionnement standard du LMC.

Nous pouvons maintenant commencer C3c — Provisioning Contracts and Deterministic Workflow V2.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c3c-provisioning-workflow-v2

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c3b-temporal-foundation

Notre référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Réutilisation du travail existant

Notre objectif est de porter les contrats et le Workflow V2 déjà développés, et non de les réimplémenter.

Relis notamment :

* lcc-t3-orq-project-workflow
* lcc-mr6-provisioning-contracts
* lcc-mr7-postgresql-state-store
* ORQ_PROJECT_WORKFLOW_T3.md
* PROVISIONING_CONTRACTS_MR6.md
* POSTGRESQL_STATE_STORE_MR7.md
* C3B_TEMPORAL_FOUNDATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.

Identifie la version cumulative finale des contrats et du Workflow V2.

Vérifie les éventuels durcissements apportés dans MR7 qui concernent directement ces composants.

Réutilise les fichiers et tests existants au maximum.

Ne porte pas encore les implémentations concrètes du Store PostgreSQL et des Activities.

3. Contrats de provisioning V2

Porte les contrats versionnés précédemment développés dans MR6.

Reprends notamment les structures permettant de transporter :

* operation_ref.
* project_ref.
* generation.
* Mode PLAN/APPLY.
* Version et hash désirés.
* Identité Orq vérifiée.
* Identifiant Orq candidat.
* Résultat de réconciliation.
* Action de réconciliation.
* Statut et classification de l’échec.
* Snapshot de l’opération.

Préserve les types, limites, validations et règles de cohérence historiques.

Ne transporte aucun credential, token, clé API, payload arbitraire, réponse SDK brute ou diagnostic non assaini.

Vérifie que la clé projet Orq est bien un identifiant non secret avant d’autoriser son transport dans les contrats Temporal.

Les informations sensibles doivent rester dans les mécanismes de stockage appropriés.

Préserve les contrats V1 lorsqu’ils sont nécessaires à la compatibilité historique, sans modifier leur comportement ni créer un second chemin de provisioning actif.

4. Compatibilité avec ProjectOrqSaga

Notre nouvelle architecture de persistance est composée de :

* orq_project_mappings : identité distante et mapping durable.
* saga_project_orq : unique table d’opérations de provisioning Orq.
* orq_project_temporal_start_outbox : état de livraison Temporal.

Vérifie la correspondance entre les contrats V2 et les champs introduits dans C1 et C2.

Identifie notamment les adaptations nécessaires concernant :

* Le remplacement de l’ancien modèle OrqProjectProvisioningOperation par ProjectOrqSaga.
* operation_ref comme clé primaire.
* Les générations.
* Les statuts spécifiques à Orq.
* Les résultats candidats et confirmés.
* Les références support et les diagnostics.
* operation_started_at.
* Les informations nécessaires au futur CAS.

Les contrats doivent rester indépendants des modèles ORM.

Ne recrée pas orq_project_provisioning_operations.

Aucune modification du schéma ou nouvelle migration Alembic n’est attendue.

Si une incompatibilité structurelle réellement bloquante est découverte, présente-la avant toute modification du schéma.

5. Workflow ID déterministe

Porte la logique de construction du Workflow ID V2 précédemment qualifiée.

Le format historique est :

lmc-orq-project-provision-v2-p-{project_ref}-g-{generation}-o-{operation_ref}

Vérifie ce format dans le code source historique.

Préserve les garanties suivantes :

* Même opération persistée : même Workflow ID.
* Générations différentes : Workflow IDs distincts.
* Opérations différentes : Workflow IDs distincts.
* Validation stricte des identifiants.
* Compatibilité avec la longueur maximale prévue dans l’outbox.
* Aucun identifiant sensible dans le Workflow ID.
* Aucune dépendance à l’heure courante ou à une valeur aléatoire.

Préserve les politiques de réutilisation et de conflit précédemment retenues, notamment REJECT_DUPLICATE et FAIL lorsqu’elles sont applicables au futur lancement.

La construction déterministe du Workflow ID ne constitue pas à elle seule une garantie exactly-once sur Orq.

Aucun lancement Temporal réel ne doit être effectué dans C3c.

6. Workflow métier V2

Porte le Workflow déterministe développé dans MR6.

Préserve la séparation des quatre responsabilités :

1. Chargement et validation du contexte de l’opération.
2. Réconciliation du projet Orq.
3. Persistance du mapping vérifié.
4. Finalisation de l’opération.

Le Workflow doit uniquement orchestrer ces responsabilités.

Il ne doit effectuer directement aucun :

* Appel HTTP Orq.
* Accès PostgreSQL.
* Accès Vault.
* Accès filesystem.
* Appel réseau.
* Traitement non déterministe.

Ces opérations devront être réalisées par les futures Activities.

Utilise uniquement les contrats et interfaces nécessaires à l’orchestration.

Ne développe pas une deuxième logique métier de réconciliation à l’intérieur du Workflow.

7. Protection contre les mutations ambiguës

Conserve impérativement les garanties historiques de T1, T3, MR6 et MR7 :

* maximum_attempts=1 pour l’Activity mutative.
* Aucun retry aveugle après une mutation potentielle.
* Aucun retry automatique de transport susceptible de rejouer une mutation Orq.
* Toute nouvelle tentative logique doit être explicitement autorisée par un résultat connu comme RETRYABLE et mutation_attempted=False, conformément aux garanties historiques.
* Un timeout, une panne de Worker ou une perte de résultat après une mutation potentielle doit conduire à un résultat incertain.
* UNKNOWN_OUTCOME doit rester distinct d’un échec connu.
* NEEDS_RECONCILIATION doit préserver les preuves et empêcher toute nouvelle création automatique non sûre.
* Aucun projet adopté uniquement sur la base de son nom.
* Aucun DELETE ou mécanisme de compensation automatique.
* Aucun résultat candidat considéré comme identité vérifiée.

Vérifie que le Workflow préserve les attentes du futur Store PostgreSQL concernant la réservation durable avant mutation.

Ne présente pas cette réservation comme effective tant que le Store et les Activities ne sont pas raccordés.

8. Validation du snapshot et du contexte

Préserve les contrôles V2 concernant :

* L’identité de l’opération.
* Le projet.
* La génération.
* Le mode.
* La version désirée.
* Le hash désiré.
* Le statut de l’opération.

Un contexte incompatible ou obsolète ne doit déclencher aucune mutation distante.

Conserve le traitement historique de STALE_CONTEXT.

Une opération présentant déjà un UNKNOWN_OUTCOME ne doit pas déclencher automatiquement une nouvelle réconciliation mutative.

La persistance et la vérification autoritative de ces informations seront raccordées dans C3d et C3e.

9. Mode PLAN

Préserve le comportement historique MR6.

Le mode PLAN peut être représenté dans les contrats, mais ne doit pas être exécuté par le Workflow APPLY.

Un lancement PLAN incompatible doit être rejeté avant toute Activity susceptible d’effectuer un appel distant.

Ne développe pas encore le mécanisme complet de dry-run.

Le provisioning unifié PLAN/APPLY reste dans notre roadmap fonctionnelle finale.

10. Temporal optionnel et déterminisme

Préserve intégralement les garanties de C3b :

* Temporal désactivé par défaut.
* SDK optionnel.
* Aucun import obligatoire depuis FastAPI.
* Aucun démarrage automatique de Worker.
* Aucun appel réseau implicite.
* Aucun changement des dépendances normales du LMC.
* Aucun couplage au lifespan FastAPI.

Vérifie le déterminisme du Workflow avec les outils locaux du SDK disponibles.

Vérifie notamment sa préparation dans le sandbox Temporal, la sérialisation des contrats et la compatibilité des types.

N’utilise aucun serveur Temporal local ou distant.

Ne prétends pas avoir réalisé un replay réel si aucun historique compatible n’est disponible.

Distingue les tests de déterminisme locaux d’une qualification complète sur un serveur Temporal.

11. Tests

Porte les tests historiques de MR6 et les durcissements directement applicables au Workflow V2.

Vérifie notamment :

* Validation des contrats.
* Sérialisation et désérialisation.
* Compatibilité des types.
* Déterminisme du Workflow ID.
* Séparation des générations.
* Ordre des Activities.
* Succès simulé.
* Contexte obsolète.
* Contexte incohérent.
* Rejet du mode PLAN.
* Échec connu avant mutation.
* Mutation potentielle.
* Timeout et perte de résultat simulés.
* UNKNOWN_OUTCOME.
* NEEDS_RECONCILIATION.
* Distinction entre candidat et identité confirmée.
* Échec simulé de persistance du mapping.
* Absence de retry mutatif automatique.
* Absence de compensation DELETE.
* Absence de credential ou payload sensible dans les contrats et diagnostics.

Utilise exclusivement des mocks, des Activities factices et des dépendances contrôlées.

Ne démarre aucun Worker connecté à Temporal.

Ne lance aucun Workflow distant.

N’effectue aucun appel réel Orq.

12. Non-régression

Utilise C3b comme nouvelle référence :

* 285 cas JUnit.
* 258 réussites JUnit.
* 229 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables applicatives.

Exécute les tests ciblés et la suite complète.

Compare les node IDs, traces normalisées et signatures des échecs avec C3b.

Vérifie également :

* La compilation Python.
* pip check.
* L’intégrité des migrations C1 et C2.
* L’intégrité de la réconciliation C3a.
* L’intégrité de la fondation Temporal C3b.
* Les imports et le fonctionnement normal du LMC sans SDK Temporal.

Distingue les tests portés, adaptés et nouvellement ajoutés.

Conserve une distinction explicite entre tests pytest, sous-tests et cas JUnit.

13. Limites de qualification à conserver

C3b a identifié deux limites :

* Qualification locale réalisée sous Python 3.14.8, Python 3.12.4 n’étant pas disponible sur l’hôte.
* Audit CVE non effectué en raison des restrictions réseau.

Conserve ces deux points dans la documentation et dans les critères de qualification finale.

Vérifie la version Python cible du LMC à partir des configurations existantes.

N’installe pas de nouvel environnement système et ne contourne aucune restriction réseau.

Ne considère pas pip check comme un audit de sécurité.

Ces limitations ne doivent pas bloquer le portage C3c, sauf incompatibilité technique avérée.

14. Limitation du périmètre

C3c doit rester strictement consacrée aux contrats versionnés et au Workflow déterministe V2.

Ne commence pas :

* C3d : Store PostgreSQL.
* C3e : Activities V2 concrètes.
* C4 : Worker métier.
* Enqueue transactionnel.
* Dispatcher.
* API.
* Frontend.
* Repair.
* Qualification distante.
* Provisioning des autres ressources Orq.

N’active aucun comportement métier dans le LMC existant.

15. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Réutilisation maximale du travail existant.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel distant à Orq.ai ou Temporal.
* Aucun serveur Temporal local.
* Aucune modification des conteneurs, volumes, réseaux ou bases existants.
* Aucune modification de Docker Compose.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations de lancement VS Code.
* Préservation intégrale de tous les espaces précédents.

La procédure habituelle de lancement du LMC doit rester inchangée.

Temporal et Orq.ai doivent rester optionnels.

16. Documentation et restitution

Crée une documentation technique dédiée en anglais :

documentation/C3C_PROVISIONING_WORKFLOW_V2.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente :

* Son origine.
* Son rôle.
* Le comportement avant et après.
* Le code directement réutilisé.
* Les adaptations nécessaires.
* La justification technique.
* Les alternatives éventuelles.

Présente-moi en français :

* Les contrats portés.
* Le fonctionnement du Workflow V2.
* Les fichiers réutilisés depuis MR6.
* Les adaptations liées à ProjectOrqSaga.
* Les garanties effectivement requalifiées.
* Les résultats réels des tests.
* Les limites restantes.
* Les prérequis pour C3d.
* La prochaine micro-MR recommandée.

Notre objectif reste d’atteindre la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, avec les mécanismes existants de support et de réparation, avant tout déploiement en préproduction.

Tu peux commencer C3c dans ce périmètre. Ne commence pas C3d sans mon accord.