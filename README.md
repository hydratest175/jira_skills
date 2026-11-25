Je valide la qualification de l’espace lcc-local-integration.

Les résultats correspondent exactement à nos attentes :

* 263 tests réussis.
* 27 échecs préexistants identiques à MR 1.
* 15 sous-tests réussis.
* 31 tables et 14 triggers.
* Chaîne Alembic unique.
* Backend et frontend fonctionnels.
* Interface LMC vérifiée.
* Aucune nouvelle régression.
* Préservation de la stack originale et de la procédure standard de lancement.

Documente et conserve les limitations identifiées, notamment la dérive Alembic préexistante, le warning Compose concernant le quoting du .env et la qualification standard restant à effectuer.

Nous pouvons maintenant commencer la prochaine micro-MR : 0004_orq_project_mapping_state.

1. Espace de travail

Crée un nouvel espace local isolé :

/workspace/LEA_Workspace/lcc-mr4-orq-project-mapping-state

Le nom MR4 désigne uniquement cette nouvelle étape locale et ne doit pas introduire de confusion avec les identifiants des chantiers Temporal T1 à T4. Documente clairement sa place dans la roadmap.

Utilise lcc-local-integration comme base cumulative.

Préserve intégralement tous les espaces précédents.

Ne copie aucune métadonnée Git, aucun credential, aucun fichier .env, environnement virtuel ou cache inutile.

2. Périmètre de cette micro-MR

Implémente uniquement l’évolution du mapping Orq :

* Élargissement de orq_project_id à 256 caractères.
* Ajout de la clé Orq vérifiée.
* Ajout de la version de configuration désirée.
* Ajout du hash de configuration désirée.
* Ajout de la génération nécessaire aux futures opérations CAS.
* Adaptation du modèle ORM.
* Migration Alembic correspondante.
* Tests ciblés et documentation.

Avant de définir les nouvelles colonnes, vérifie leur cohérence avec les contrats T1 et T3, le modèle de projet existant du LMC et le Mock LMC.

Distingue clairement l’identifiant LMC, la clé projet LMC, l’identifiant Orq et la clé projet Orq.

Définis précisément la signification, le type, la nullabilité, les contraintes et les valeurs initiales de chaque nouveau champ.

La limite de 256 caractères constitue une borne défensive interne au LMC et non une limite officielle du SDK Orq.

Aucune troncature silencieuse ne doit être possible.

3. Migrations Alembic

Ajoute une migration linéaire :

0001 → 0002 → 0003 → 0004

Ne modifie pas les migrations précédentes.

Vérifie :

* Le head unique.
* La migration depuis une base PostgreSQL vide.
* La migration depuis une base positionnée en 0003.
* La conservation des mappings déjà présents.
* Les contraintes d’unicité existantes.
* La cohérence ORM/SQL.
* Le comportement du downgrade, notamment si des identifiants de plus de 128 caractères sont présents.

Un downgrade ne doit jamais provoquer une troncature ou une perte silencieuse de données. Documente toute restriction nécessaire.

Notre chaîne Alembic reste provisoire, strictement locale et non déployable avant adaptation au futur head officiel.

4. Limitation du périmètre

Ne développe pas encore :

* La table des opérations de provisioning.
* L’outbox transactionnel.
* Le dispatcher.
* Le store SQL complet.
* Le Worker métier.
* Les endpoints API.
* Le frontend.
* Le provisioning des autres ressources Orq.

La génération CAS doit être préparée dans le schéma, mais ne présente pas sa seule présence comme une protection effective contre la concurrence.

La prochaine micro-MR traitera séparément la persistance des opérations et les mécanismes associés.

5. Tests et qualification

Exécute les tests ciblés et la suite complète.

La référence de non-régression est désormais :

* 263 tests réussis.
* 27 échecs préexistants.
* 15 sous-tests réussis.

Compare les node IDs et les traces normalisées des échecs dans des conditions identiques.

Utilise exclusivement des bases PostgreSQL locales neuves et isolées pour les tests de migration.

Tu peux réutiliser la méthode de qualification Docker temporaire précédemment validée, à condition que toutes les ressources soient strictement isolées et qu’aucune ressource existante ne soit affectée.

Documente les tests réellement exécutés et les éventuelles limitations.

6. Préservation du LMC

La procédure standard de lancement du LMC doit impérativement rester inchangée.

Ne modifie aucun script 01, 02 ou 03, aucune configuration de lancement VS Code et aucun Docker Compose original.

Notre intégration doit rester compatible avec le fonctionnement actuel du LMC.

Temporal et Orq.ai doivent rester optionnels.

7. Contraintes générales

* Micro-MR minimale, ciblée et facilement explicable.
* Réutilisation maximale du code et des conventions existantes.
* Aucune opération Git ou GitLab.
* Aucun changement Kubernetes.
* Aucun déploiement.
* Aucune modification des conteneurs, volumes ou bases existants.
* Aucun appel réel à Orq.ai.
* Aucun nouveau Workflow Temporal distant.
* Documentation technique en anglais.
* Restitution en français.

Mets à jour LMC_WORKSPACE_INDEX.md et la roadmap.

À la fin, présente-moi les fichiers modifiés, le diff fonctionnel, les résultats de tests et les limites restantes.

Ne commence pas la migration 0005 sans mon accord.

Notre objectif final reste la parité complète avec le Mock LMC, depuis l’interface du véritable LMC lancé localement, avant tout déploiement en préproduction.

Tu peux maintenant commencer cette micro-MR.