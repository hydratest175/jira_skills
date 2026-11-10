Nous avons un bug dans le Mock LMC depuis l’implémentation du versioning des orchestrateurs personnels.

Je veux que tu corriges ce bug de façon ciblée, sans modifier les autres fonctionnalités.

1. Problème constaté

Dans le Mock LMC :

1. J’ouvre un projet, par exemple test_autoauto.
2. Je vais dans l’onglet Modèles.
3. Je vois le catalogue global des modèles et les modèles activés pour ce projet.
4. Deux modèles sont actuellement activés :
    * GPT 5.6 POC
    * Mistral test POC
5. Lorsque j’essaie de désactiver l’un de ces modèles, l’application renvoie une erreur HTTP 500.
6. L’erreur apparaît en boucle et je ne peux pas désactiver le modèle.

Je veux pouvoir activer et désactiver normalement les modèles autorisés pour un projet.

2. Investigation obligatoire

Avant de modifier du code, reproduis le problème et identifie précisément sa cause.

Examine :

* Le composant frontend de gestion des modèles du projet.
* L’appel API déclenché par le toggle.
* L’endpoint FastAPI correspondant.
* Les logs et la stack trace de l’erreur HTTP 500.
* La mise à jour des modèles autorisés en base SQLite.
* Les éventuelles dépendances avec la nouvelle table orq_agent_model_versions.
* Les contraintes de clé étrangère et de cohérence.
* Les éventuels mécanismes de provisioning déclenchés par cette opération.

Vérifie également pourquoi l’erreur apparaît en boucle : requêtes répétées, retries, rechargements automatiques ou problème de synchronisation de l’état frontend.

Ne suppose pas que le problème vient du versioning. Identifie la cause réelle.

3. Comportement attendu

Lorsqu’un Project Manager désactive un modèle :

* Le modèle est désactivé uniquement pour le projet concerné.
* Les autres projets ne sont pas affectés.
* Le modèle reste présent dans le catalogue global.
* Les modèles restants continuent de fonctionner.
* Les mappings des versions d’orchestrateur restent cohérents.
* Les versions Orq.ai historiques ne sont pas supprimées.
* Aucun orchestrateur personnel ni spécialiste Jira/GitLab n’est supprimé.
* L’interface affiche correctement le nouvel état du modèle.
* Un rechargement de la page conserve cet état.

Si la désactivation impose une réconciliation du provisioning, respecte le fonctionnement actuel du bouton Provisionner et ne déclenche pas de modification destructive implicite.

Un modèle désactivé ne doit plus être proposé comme modèle autorisé pour les nouvelles exécutions Engineering Companion.

Cas particulier : modèle par défaut

Vérifie également le comportement lorsqu’on désactive le modèle par défaut du projet.

La configuration doit rester cohérente.

Si un autre modèle est encore autorisé, applique la politique de sélection du modèle par défaut prévue par l’application.

Si le projet ne peut pas fonctionner sans modèle actif, affiche une erreur métier explicite plutôt qu’un HTTP 500.

Ne change pas silencieusement les règles métier existantes.

4. Corriger les erreurs répétées

Je veux également que l’interface gère proprement les erreurs.

Si une requête échoue :

* Ne déclenche pas une boucle de requêtes HTTP 500.
* Affiche un message d’erreur compréhensible.
* Conserve ou restaure l’état réel du toggle.
* Permets à l’utilisateur de réessayer.

Le backend doit retourner un code HTTP approprié lorsqu’une opération est refusée pour une raison métier, plutôt qu’une exception non gérée.

5. Tests à effectuer

Après correction, vérifie :

1. Activation d’un modèle.
2. Désactivation d’un modèle.
3. Désactivation du modèle par défaut.
4. Désactivation du dernier modèle autorisé.
5. Réactivation d’un modèle précédemment désactivé.
6. Persistance des changements après rafraîchissement.
7. Absence de requêtes répétées en cas d’erreur.
8. Isolation entre deux projets LMC.
9. Conservation des mappings et versions Orq.ai.
10. Absence de régression sur le provisioning idempotent.

Utilise de préférence des données de test isolées pour les tests automatisés.

6. Périmètre strict

Ne modifie pas Engineering Companion sauf si une correction minimale est absolument indispensable et directement liée au bug.

Ne touche pas :

* Aux Routing Rules.
* Au système de conversation.
* À la gestion des previous_response_id.
* Aux sous-agents Jira/GitLab.
* Aux credentials existants.
* Aux ressources Orq.ai opérationnelles.

Ne réalise aucune suppression destructive de ressources.

Ne travaille pas sur les Skills ou l’EAL.

7. Résultat attendu

Je veux une correction réelle du code, pas uniquement une analyse.

À la fin, donne-moi :

* La cause exacte du HTTP 500.
* Les fichiers modifiés.
* Les corrections apportées.
* Les tests exécutés et leurs résultats.
* La confirmation que les modèles peuvent être désactivés et réactivés depuis l’interface.

Priorité : corriger le toggle des modèles sans casser le versioning des orchestrateurs ni le provisioning existant.

Ne commence aucune autre évolution fonctionnelle.