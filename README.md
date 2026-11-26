Nous avons changé de session Software Companion après C7e. La nouvelle session a implémenté C8, mais n’a pas réussi à terminer sa qualification.

Je reviens temporairement vers toi pour bénéficier de ton expérience historique du projet et de notre environnement.

Je souhaite que tu réalises une revue technique indépendante de C8, que tu corriges les problèmes éventuels et que tu qualifies réellement l’implémentation.

1. Références

* Base précédente : /workspace/LEA_Workspace/lcc-c7e-provisioning-api-integration
* C8 : /workspace/LEA_Workspace/lcc-c8-frontend-orq-integration
* Mémoire projet : /workspace/LEA_Workspace/project-memory/

Consulte la documentation C8 et les documents pertinents de la mémoire projet. Toutes nos décisions et contraintes précédentes restent applicables.

Si des corrections sont nécessaires, crée un workspace cumulatif isolé lcc-c8-reviewed-frontend-orq-integration. Sinon, conserve C8 comme référence.

2. Revue technique

Analyse le delta C7e/C8 sans utiliser Git.

Évalue la qualité, la simplicité, la maintenabilité, la sécurité, la conformité aux contrats backend et la non-régression du frontend existant.

Vérifie particulièrement :

* Permissions et déclenchement explicite du provisioning.
* Protection contre les doubles soumissions.
* Distinction entre acceptation HTTP et succès métier.
* Polling exact par operation_ref, concurrence, changement de projet, rafraîchissement et arrêt des timers.
* Gestion des erreurs et des réponses HTTP incertaines.
* Intégration au Repair existant, sans relance automatique des actions.
* Possibilité d’étendre ultérieurement le provisioning aux autres ressources du Mock LMC.

Attention : après une perte de réponse au POST, retrouver la dernière opération disponible ne prouve pas nécessairement qu’elle correspond à la demande dont la réponse a été perdue.

Je t’autorise à corriger directement les bugs et à améliorer l’implémentation lorsque cela est pertinent, sans validation intermédiaire pour les corrections mineures.

Évite les refactorings disproportionnés. Ne modifie pas les contrats backend, permissions, migrations ou dépendances sans mon accord.

3. Résoudre les blocages de qualification

La nouvelle session rapporte :

* 17/17 tests frontend réussis.
* Contrôle TypeScript ciblé réussi.
* 52/52 tests backend ciblés réussis.
* Backend C7e/C8 identique.
* Build npm standard bloqué.
* Aucun navigateur disponible.
* 127 tests PostgreSQL ignorés.

Ces difficultés m’interpellent puisque nous avions précédemment résolu plusieurs de ces problèmes.

Réutilise ton expérience concernant Node/npm, les registres internes, Artifactory, les certificats, l’authentification, Docker et PostgreSQL 18.4.

Identifie les causes réelles des blocages. Ne recommence pas inutilement les investigations déjà réalisées.

Si mon intervention est nécessaire, communique-moi les commandes exactes et le terminal concerné.

4. Qualification

Exécute autant que possible :

* Installation des dépendances existantes sans modification du lockfile.
* Build frontend standard et contrôle TypeScript complet.
* Tests frontend, renforcés selon les résultats de ta revue.
* Vérification réelle des parcours React dans un navigateur, avec données synthétiques.
* Qualification PostgreSQL et non-régression complète.

Si le navigateur reste inaccessible, prépare une procédure de vérification manuelle.

Notre référence complète C7e reste : 689 tests pytest réussis, 29 sous-tests réussis, 27 échecs historiques, PostgreSQL 18.4 et head Alembic 0004_orq_saga_outbox.

Analyse également les neuf vulnérabilités npm héritées sans modifier les dépendances.

Distingue clairement les tests réellement exécutés, simulés, ignorés et bloqués. Conserve les preuves assainies.

5. Contraintes

Respecte intégralement project-memory/AGENTS.md et nos règles historiques.

En particulier : aucune opération Git/GitLab, aucun déploiement, aucun appel distant Temporal ou Orq, aucune modification Kubernetes ou des ressources Docker existantes, aucun changement de la procédure habituelle de lancement du LMC.

Ne commence aucune nouvelle fonctionnalité.

6. Documentation et restitution

Crée documentation/C8_INDEPENDENT_REVIEW_AND_QUALIFICATION.md.

Documente les problèmes identifiés, les corrections apportées, leurs justifications et leurs preuves de validation.

Mets à jour la mémoire projet, notamment les solutions d’environnement qui auraient manqué à la nouvelle session.

Présente-moi en français :

* Ton évaluation indépendante de C8.
* Les corrections et améliorations réalisées.
* Les causes et solutions des blocages.
* Les résultats réels du build et des tests.
* Les limitations restantes.
* Le workspace applicatif recommandé.
* Ton évaluation de la qualité de notre passation.
* Les prérequis du premier lancement fonctionnel du LMC.

Classe C8 comme ACCEPTED, LIMITED ou BLOCKED.

Tu peux commencer la revue, les corrections ciblées et la qualification. Ne commence pas l’étape suivante sans mon accord.