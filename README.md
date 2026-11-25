Je valide MR4 sur son périmètre de qualification.

Les résultats correspondent à nos attentes :

* 268 tests réussis.
* 27 échecs préexistants identiques.
* 15 sous-tests réussis.
* 5 nouveaux tests réussis.
* Migration 0004 validée sur PostgreSQL 16.
* Conservation des données existantes.
* Absence de nouvelle régression.
* Préservation du LMC original.

Nous pouvons maintenant commencer MR5 — Provisioning Operations & Outbox.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-mr5-provisioning-operations-outbox

Utilise MR4 comme base cumulative.

Préserve intégralement tous les espaces de travail précédents.

Ne copie aucune métadonnée Git, aucun credential, fichier .env, environnement virtuel ou cache inutile.

2. Objectif de cette micro-MR

Préparer la persistance durable des opérations de provisioning et des demandes de démarrage Temporal.

Avant l’implémentation, relis :

* Les contrats T1, T2 et T3.
* Le schéma de mapping introduit dans MR1 et étendu dans MR4.
* Les mécanismes existants de persistance, transactions, audit et gestion des opérations du LMC.
* LOCAL_LMC_PARITY_ROADMAP.md.
* Le comportement correspondant du Mock LMC.

Privilégie les conventions et les abstractions existantes.

Justifie le schéma retenu et vérifie qu’il constitue la solution minimale répondant à nos besoins.

Si le périmètre opérations/outbox est trop important pour une seule micro-MR, propose sa séparation avant de commencer.

3. Persistance des opérations

Prévois les informations strictement nécessaires pour représenter durablement :

* L’identifiant de l’opération.
* Le projet LMC concerné.
* La version et le hash de la configuration désirée, si nécessaires.
* Le statut de l’opération.
* La génération utilisée pour les futures protections CAS.
* L’identifiant du Workflow Temporal.
* Le résultat de la réconciliation.
* L’indicateur de tentative de mutation.
* Le statut UNKNOWN_OUTCOME.
* Une référence de diagnostic non sensible.
* Les timestamps nécessaires.

Aligne les champs et les statuts sur les contrats existants de T3. N’invente pas une seconde machine à états incompatible.

Distingue explicitement une mutation non tentée d’une mutation dont l’état est inconnu.

Un résultat inconnu ne doit jamais être transformé silencieusement en autorisation de relancer une création Orq.

Vérifie également que la suppression ou la modification d’un projet LMC ne puisse pas effacer silencieusement les informations nécessaires à la résolution d’un UNKNOWN_OUTCOME.

4. Outbox transactionnel

Prépare le schéma minimal permettant d’enregistrer durablement une demande de démarrage Temporal.

L’objectif futur est de pouvoir enregistrer l’opération et sa demande de dispatch dans une même transaction PostgreSQL.

Prévois les contraintes nécessaires aux futures protections contre :

* Les demandes dupliquées.
* Les dispatchs concurrents.
* La perte de résultat.
* Le redémarrage du LMC ou du dispatcher.
* Les tentatives obsolètes.

Justifie les champs nécessaires à la gestion future des leases, retries et générations.

Ne développe pas encore le dispatcher ni le mécanisme de traitement effectif de l’outbox.

Ne présente pas les seules contraintes du schéma comme une garantie complète d’idempotence ou de concurrence.

5. Migration Alembic

Ajoute une migration linéaire 0005 et les modèles ORM correspondants.

La chaîne doit rester unique :

0001 → 0002 → 0003 → 0004 → 0005

Ne modifie aucune migration précédente.

Vérifie :

* Le head unique.
* La migration depuis une base vide.
* La migration depuis une base 0004 contenant des données.
* La préservation des mappings existants.
* Les clés étrangères et leur comportement lors des suppressions.
* Les contraintes d’unicité.
* Les contraintes de validité des données.
* Les index réellement nécessaires.
* La cohérence ORM/SQL.
* Le comportement du downgrade.
* Le refus de tout downgrade susceptible de supprimer silencieusement des données utiles.

La chaîne de migrations reste provisoire, locale et non déployable avant adaptation au chantier officiel Alembic.

6. Sécurité

Aucun secret ne doit être enregistré dans les opérations, l’outbox ou les informations de diagnostic.

Ne stocke notamment aucun :

* PAT Jira ou GitLab.
* Token Vault.
* Credential Orq.ai.
* Clé API temporaire.
* Credential utilisateur.
* Contenu brut de réponse SDK potentiellement sensible.

Prévois uniquement les références nécessaires à la récupération ultérieure des informations depuis leurs sources autorisées.

7. Limitation du périmètre

Cette micro-MR concerne exclusivement le schéma de persistance, les modèles ORM, les migrations, les tests et la documentation.

Ne développe pas encore :

* Le store SQL complet.
* Les opérations CAS effectives.
* Le dispatcher Temporal.
* Le Worker métier.
* Les endpoints API.
* Le frontend.
* Le provisioning des autres ressources Orq.

Aucune activation réelle du provisioning à ce stade.

8. Tests

Exécute les tests ciblés, les tests cumulés et la suite complète.

La nouvelle référence de non-régression est :

* 268 tests réussis.
* 27 échecs préexistants.
* 15 sous-tests réussis.

Compare les node IDs, les traces normalisées et leurs signatures avec la référence existante.

Utilise PostgreSQL 16 pour les validations réelles de migrations et de contraintes.

Tu peux réutiliser notre méthode de qualification Docker temporaire isolée, sans affecter aucune ressource existante.

Documente précisément les tests exécutés, les résultats obtenus et les validations restantes.

9. Contraintes impératives

* Micro-MR minimale et facilement explicable.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucun appel réel à Orq.ai.
* Aucun nouveau Workflow Temporal distant.
* Aucune modification des conteneurs, volumes ou bases existants.
* Aucune modification du Docker Compose original.
* Aucune modification des scripts 01, 02 et 03.
* Aucune modification des configurations de lancement VS Code.
* La procédure habituelle de démarrage du LMC doit rester strictement inchangée.
* Temporal et Orq.ai doivent rester optionnels.
* Préserve tous les espaces précédents.

10. Documentation et restitution

Crée une documentation technique dédiée à MR5 en anglais.

Mets à jour LMC_WORKSPACE_INDEX.md et LOCAL_LMC_PARITY_ROADMAP.md.

Explique chaque table, chaque champ, chaque contrainte et chaque décision afin que je puisse facilement présenter cette micro-MR lors d’une future revue.

À la fin, présente-moi en français :

* Les fichiers créés et modifiés.
* Le diff fonctionnel.
* Le schéma retenu.
* La justification de chaque choix.
* Les résultats réels des tests.
* Les garanties effectivement implémentées.
* Les limites restantes.
* La prochaine micro-MR recommandée.

Ne commence pas l’étape suivante sans mon accord.

Notre objectif final reste la parité fonctionnelle complète avec le Mock LMC depuis l’interface du véritable LMC lancé localement, avant tout déploiement en préproduction.

Tu peux commencer MR5 dans ce périmètre.