Je valide C4-Q comme qualification réelle limitée du Worker métier V2.

Les résultats acquis sont les suivants :

* Scénarios nominal et réutilisation réussis.
* Résultat ambigu correctement classé UNKNOWN_OUTCOME.
* Redémarrage réel du Worker conservant LOCAL_PERSISTENCE et empêchant tout double POST simulé.
* Workflow de redémarrage terminé FAILED, confirmant la limitation C3e/C7.
* Trois historiques Temporal réels rejoués avec succès.
* Historique du scénario de redémarrage non conservé pour des raisons de sécurité.
* 395 tests pytest réussis.
* 27 échecs historiques identiques.
* Backend C4 inchangé.
* Ressources Docker temporaires et tunnel nettoyés.
* Aucun appel réel Orq.

Ne présente pas C4-Q comme une qualification intégralement réussie.

Nous pouvons poursuivre vers C5 — Transactional Provisioning Enqueue and Generation Allocation.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-c5-transactional-provisioning-enqueue

Utilise comme base cumulative :

/workspace/LEA_Workspace/lcc-c4-temporal-provisioning-worker

C4-Q constitue une référence de qualification, pas la nouvelle base applicative :

/workspace/LEA_Workspace/lcc-c4q-temporal-real-qualification

La référence LMC originale reste :

/workspace/LEA_Workspace/lcc_last_version/lcc

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel, historique Temporal brut ou artefact de qualification sensible.

2. Documentation à relire

Relis notamment :

* C1_ORQ_PROJECT_MAPPING.md
* C2_ORQ_SAGA_OUTBOX.md
* C3C_PROVISIONING_WORKFLOW_V2.md
* C3D_POSTGRESQL_STATE_STORE.md
* C3E_PROVISIONING_ACTIVITIES_V2.md
* C4_TEMPORAL_PROVISIONING_WORKER.md
* C4Q_TEMPORAL_REAL_QUALIFICATION.md
* LMC_SAGA_REPAIR_CONVERGENCE_ANALYSIS.md
* LMC_WORKSPACE_INDEX.md
* La roadmap de convergence.
* Les documents historiques MR5, MR6 et MR7.

Inspecte également les mécanismes existants du LMC concernant :

* Les permissions SpiceDB.
* Les opérations de provisioning existantes.
* Les Sagas.
* Le Repair.
* L’audit et les références de support.
* Les transactions SQLAlchemy.
* Les modifications et suppressions de projets.

Réutilise les conventions existantes lorsque cela est possible.

3. Objectif de C5

Implémente un service applicatif permettant de préparer durablement une demande de provisioning Orq.

Ce service doit assurer :

* La validation de l’intention.
* La validation des permissions.
* Le chargement du projet.
* La construction de l’état désiré.
* L’allocation transactionnelle de la génération.
* La déduplication des demandes.
* La création de ProjectOrqSaga.
* La création de l’entrée outbox correspondante.
* La génération du Workflow ID déterministe.

C5 ne doit effectuer aucun démarrage Temporal et aucun appel Orq.

Le service reste non raccordé aux endpoints publics et au frontend pendant cette étape.

4. Architecture et sources autoritatives

Conserve strictement les responsabilités suivantes :

* Le projet LMC représente la configuration métier désirée.
* ProjectOrqSaga représente les opérations et leur statut métier.
* orq_project_mappings représente l’identité distante autoritative.
* orq_project_temporal_start_outbox représente la livraison des demandes à Temporal.
* Temporal représente l’orchestration, pas la source de vérité métier.

Ne recrée pas orq_project_provisioning_operations.

Ne crée aucune nouvelle Saga parallèle.

Aucune double écriture.

Réutilise le schéma C2 et les composants C3 existants.

Aucune nouvelle migration n’est attendue. Si le schéma actuel empêche une garantie indispensable, documente précisément le blocage et propose une correction minimale avant de l’implémenter.

5. Autorisation

Identifie les permissions LMC existantes permettant de demander une opération de provisioning sur un projet.

Inspecte notamment les conventions de contrôle d’accès du Repair et des opérations de provisioning existantes.

Ne suppose pas automatiquement que la permission Repair autorise une nouvelle création Orq.

Ne crée pas de nouvelle permission SpiceDB sans nécessité démontrée.

Prévois une frontière d’autorisation explicite et testable, compatible avec les futures couches API et Repair.

L’autorisation doit être vérifiée avant toute création d’opération et avant toute restitution d’une opération existante.

Un utilisateur non autorisé ne doit pouvoir ni créer une opération, ni découvrir les informations d’une opération existante.

Si aucune permission existante ne convient clairement, documente le problème et présente une proposition avant de modifier la politique d’autorisation.

6. Construction de l’état désiré

Réutilise directement orq_project_desired_state.py.

Conserve les champs actuels :

* Business Line.
* Sensibilité.
* Nom.
* Description.
* teams=None, signifiant équipes Orq non gérées.

Réutilise le hash canonique existant.

Ne duplique pas sa logique.

Ne fais pas confiance à un hash ou une version désirée fournis arbitrairement par le client.

Le snapshot doit être construit depuis les données autoritatives du LMC.

Il n’existe toujours pas de compteur indépendant de version désirée sur le projet.

Identifie comment allouer et valider la version nécessaire aux contrats V2 sans inventer une source autoritative inexistante.

Distingue explicitement génération d’opération et version de l’état désiré.

Teste également les modifications A vers B, puis B vers A, afin de ne pas confondre une configuration précédemment utilisée avec une nouvelle intention métier.

7. Allocation transactionnelle de la génération

La génération doit être allouée côté serveur et protégée contre les accès concurrents.

Vérifie la cohérence avec :

* Les générations historiques de ProjectOrqSaga.
* Le mapping existant.
* Les contraintes C2.
* Les attentes CAS du Store C3d.

Deux demandes concurrentes ne doivent jamais obtenir la même génération pour deux opérations différentes.

N’utilise pas un simple MAX(generation)+1 sans protection transactionnelle effective.

Identifie le mécanisme de verrouillage approprié en respectant l’ordre historique du Store C3d :

Saga, projet, outbox, mapping.

Vérifie cet ordre directement dans le code.

Accorde une attention particulière au cas où aucune Saga n’existe encore.

Ne verrouille pas naïvement le projet puis une Saga existante si cela introduit un ordre contradictoire avec C3d.

Documente la stratégie retenue et teste réellement les accès concurrents avec plusieurs sessions PostgreSQL indépendantes.

8. Création atomique de la Saga et de l’outbox

La création de ProjectOrqSaga et de son entrée outbox doit se produire dans une seule transaction PostgreSQL.

La Saga doit contenir les informations prévues par C2 et les contrats V2, notamment :

* operation_ref.
* Projet interne.
* Type d’opération.
* Génération.
* Mode.
* Version du contrat.
* Version et hash désirés.
* Référence support.
* Statut PENDING.

L’outbox doit référencer operation_ref et contenir le Workflow ID déterministe ainsi que son état initial.

Réutilise directement le générateur de Workflow ID V2 existant.

Préserve les contraintes d’unicité.

Ne persiste aucun credential ni payload arbitraire.

Si la création de l’outbox échoue, la Saga ne doit pas subsister seule.

Si la création de la Saga échoue, aucune outbox orpheline ne doit subsister.

Aucun appel réseau Temporal, Orq ou Vault ne doit intervenir dans cette transaction. Les éventuelles vérifications distantes d’autorisation doivent être réalisées selon les conventions existantes avant l’ouverture de la transaction d’écriture.

9. Politique conservatrice de déduplication

Pour cette première étape, applique les principes suivants :

* Deux demandes strictement identiques et concurrentes doivent converger vers la même opération lorsque les préconditions le permettent.
* Une demande identique à une opération déjà persistée ne doit pas créer automatiquement une nouvelle génération.
* Une demande conflictuelle lorsqu’une opération non résolue existe doit être refusée explicitement.
* Un résultat UNKNOWN_OUTCOME doit bloquer toute nouvelle création.
* Une opération NEEDS_RECONCILIATION ne doit pas être contournée par une nouvelle génération.
* Un échec terminal ne doit pas autoriser implicitement une nouvelle création à configuration identique.
* Aucun retry manuel forcé ne doit être implémenté pendant C5.
* Les opérations historiques doivent être conservées.

La restitution d’une opération existante ne doit pas transformer artificiellement un FAILED ou NEEDS_RECONCILIATION en succès.

Vérifie la compatibilité de cette politique avec les contraintes C2 et les contrats V2.

Toute incompatibilité ou décision métier supplémentaire doit être exposée avant modification.

10. Modification concurrente du projet

La configuration désirée doit correspondre à l’état réellement observé au moment de l’enqueue transactionnel.

Vérifie notamment :

* Modification du projet avant l’allocation.
* Modification concurrente pendant l’enqueue.
* Modification après l’enqueue mais avant l’exécution du Worker.
* Soft delete.
* Hard delete.
* Modification de project_ref.

Réutilise la revalidation autoritative C3d avant mutation.

Une demande devenue obsolète ne doit pas permettre une création distante.

Ne modifie pas les fonctionnalités actuelles d’édition ou de suppression des projets du LMC.

La politique globale de modification concurrente reste une décision ouverte.

Documente précisément ce que C5 garantit et ce qui reste non couvert.

11. PLAN et APPLY

Préserve les contrats PLAN/APPLY existants.

Cependant, le Workflow V2 actuel est limité au chemin APPLY et rejette PLAN.

C5 ne doit donc jamais créer une demande Temporal APPLY à partir d’une intention PLAN.

Pour cette étape :

* Qualifie prioritairement le chemin APPLY.
* Rejette explicitement les usages PLAN non encore supportés.
* Ne crée pas d’outbox pour un PLAN incompatible.
* Ne développe pas un nouveau moteur de dry-run.

Le provisioning unifié PLAN/APPLY reste un jalon fonctionnel obligatoire avant la parité complète avec le Mock LMC.

12. Audit et diagnostics

Réutilise les conventions existantes du LMC concernant :

* L’identité de l’acteur.
* Les références de support.
* Les codes d’erreur.
* Les événements d’audit.
* La corrélation des opérations.

Ne développe pas de système d’audit parallèle.

Vérifie si les mécanismes actuels permettent de tracer durablement l’intention autorisée.

Distingue l’audit effectivement implémenté de celui qui reste à compléter.

Ne prétends pas que l’audit est atomique avec l’enqueue s’il ne l’est pas.

Aucun token, credential, header, DSN, secret, payload brut ou exception fournisseur ne doit être persisté ou exposé.

13. Temporal indisponible

C5 doit être indépendant de la disponibilité effective du serveur Temporal.

Lorsque le provisioning est explicitement autorisé et activé, une demande valide doit pouvoir être persistée sans connexion réseau à Temporal.

Le futur dispatcher C6 sera responsable de sa livraison.

Lorsque le provisioning est désactivé par configuration, aucun comportement de provisioning ne doit être activé implicitement.

Préserve le fonctionnement normal du LMC sans SDK Temporal installé.

Ne démarre aucun Worker ni Workflow.

14. Limitation C4-Q à conserver dans la roadmap

Le scénario de redémarrage réel C4-Q a confirmé :

* Conservation des preuves LOCAL_PERSISTENCE.
* Absence de deuxième POST.
* Workflow terminé FAILED.

Cette limitation doit devenir un critère d’acceptation obligatoire de C7.

Le futur Repair devra distinguer :

* Une mutation distante réellement incertaine.
* Une identité distante confirmée dont la persistance locale doit être réparée.
* Un mapping déjà persisté dont la finalisation reste nécessaire.

Le Repair devra utiliser les preuves autoritatives de ProjectOrqSaga et du mapping.

Il ne devra jamais rejouer automatiquement une création ambiguë.

Ne corrige pas cette limitation pendant C5, mais conserve explicitement le besoin d’une nouvelle qualification réelle après l’implémentation du Repair.

15. Qualification PostgreSQL réelle

Utilise PostgreSQL 18.4 sur des ressources temporaires strictement isolées.

Teste au minimum :

* Enqueue nominal.
* Cohérence Saga/outbox.
* Workflow ID déterministe.
* Allocation de génération.
* Utilisateur non autorisé.
* Projet inexistant.
* Projet supprimé.
* Snapshot obsolète.
* Demandes identiques concurrentes.
* Demandes différentes concurrentes.
* Allocation concurrente sans Saga préexistante.
* Conflit avec une opération non résolue.
* Blocage après UNKNOWN_OUTCOME.
* Blocage après NEEDS_RECONCILIATION.
* Répétition après succès.
* Répétition après échec.
* Retour à une ancienne configuration désirée.
* Rollback après échec de création de l’outbox.
* Absence de Saga isolée.
* Absence d’outbox orpheline.
* Perte simulée d’acquittement du commit.
* Reprise après redémarrage du service.
* Compatibilité avec les accès concurrents du Store C3d.
* Absence d’appel Temporal ou Orq.
* Fonctionnement sans SDK Temporal.

Pour les tests de concurrence, utilise réellement plusieurs sessions indépendantes et des mécanismes de synchronisation permettant d’observer les résultats.

Ne te limite pas à des mocks de transactions ou de contraintes SQL.

16. Non-régression

Utilise C4 comme référence applicative :

* 451 cas JUnit.
* 424 réussites JUnit.
* 395 tests pytest réussis.
* 29 sous-tests réussis.
* 27 échecs historiques identiques.
* PostgreSQL 18.4.
* Head Alembic 0004_orq_saga_outbox.
* 32 tables.
* 17 triggers.
* 4 fonctions.
* 85 index.
* 390 contraintes applicatives.

Exécute :

* Les tests ciblés C5.
* Les tests PostgreSQL réels.
* Les tests cumulés C1 à C5.
* La suite complète.
* La compilation Python.
* pip check.
* Les vérifications pertinentes sans SDK Temporal.

Compare les node IDs, traces normalisées et signatures des échecs historiques.

Vérifie l’intégrité des garanties C3a à C4.

Ne modifie aucun test historique uniquement pour obtenir artificiellement une suite verte.

17. Limitation du périmètre

C5 doit rester consacrée à l’allocation de génération et à l’enqueue transactionnel.

Ne commence pas :

* C6 : dispatcher Temporal.
* C7 : Repair backend.
* C8 : frontend.
* C9 : résolution privilégiée.
* Provisioning des autres ressources Orq.

Ne crée aucun nouvel endpoint public.

Ne développe aucune seconde logique d’orchestration.

Aucun Workflow réel ne doit être lancé.

18. Contraintes impératives

* Aucune opération Git ou GitLab.
* Aucun déploiement.
* Aucun changement Kubernetes.
* Aucun appel distant Temporal ou Orq.
* Aucun serveur Temporal local.
* Aucune installation de Temporal CLI.
* Aucun Worker connecté.
* Aucune modification des ressources Docker existantes.
* Seules les ressources Docker temporaires strictement isolées nécessaires aux tests sont autorisées.
* Aucune modification de Docker Compose.
* Aucune modification des Dockerfiles existants.
* Aucune modification des migrations existantes.
* Aucune modification du pont Alembic.
* Aucune modification des scripts 01/02/03.
* Aucune modification des configurations VS Code.
* Préservation intégrale des espaces précédents.

La procédure habituelle de lancement du LMC doit rester strictement inchangée.

19. Documentation et restitution

Crée une documentation technique en anglais :

documentation/C5_TRANSACTIONAL_PROVISIONING_ENQUEUE.md

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap de convergence.

Pour chaque fichier créé ou modifié, documente son rôle, les composants réutilisés, le comportement avant/après, les décisions techniques et leur justification.

Présente-moi en français :

* Le fonctionnement de l’enqueue.
* Les fichiers créés ou modifiés.
* La politique d’autorisation retenue.
* La stratégie d’allocation des générations.
* L’ordre de verrouillage.
* Les garanties transactionnelles réellement vérifiées.
* Les résultats des tests de concurrence.
* La politique de déduplication.
* Les résultats de non-régression.
* Les limitations et décisions restantes.
* Les prérequis nécessaires à C6.

Conserve toutes les limitations historiques encore ouvertes, notamment Python cible, audit CVE, migrations historiques, pont Alembic, retry manuel, hard delete et résolution privilégiée.

Notre objectif reste d’atteindre rapidement la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, en réutilisant les mécanismes existants de Repair, avant tout déploiement en préproduction.

Tu peux commencer C5 dans ce périmètre. Ne commence pas C6 sans mon accord.