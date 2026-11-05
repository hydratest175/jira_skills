Je souhaite maintenant travailler sur la gestion des mises à jour et la synchronisation des ressources Orq.ai depuis notre Mock LMC.

Contexte

Actuellement, nous pouvons provisionner :

* Les projets.
* Les Identities.
* Les budgets.
* Les configurations de modèles.
* Les prompts.
* Les agents Engineering Companion, Jira Specialist et GitLab Specialist.

Le provisioning initial fonctionne et la nouvelle interface est terminée.

Notre architecture repose sur des ressources Orq.ai persistantes. Nous ne souhaitons pas recréer systématiquement les ressources à chaque modification.

Objectif

Je veux pouvoir modifier un projet déjà provisionné dans le Mock LMC, puis cliquer sur « Synchroniser » pour appliquer les changements nécessaires dans Orq.ai.

Comportement attendu

Lorsqu’un Project Manager effectue une modification, le système doit identifier les ressources concernées.

Exemples :

1. Modification du modèle par défaut d’un utilisateur

Les agents personnels concernés doivent être mis à jour pour utiliser le nouveau modèle autorisé.

Les agents des autres utilisateurs ne doivent pas être modifiés inutilement.

2. Modification d’un budget

Le budget Orq.ai existant doit être mis à jour lorsque l’API le permet.

Ne pas créer un second budget pour la même ressource.

3. Ajout d’un nouvel utilisateur à un projet

Le système doit provisionner les ressources manquantes de ce nouvel utilisateur, sans recréer celles des membres existants.

4. Modification d’une configuration de modèle

Les ressources concernées doivent être synchronisées correctement, en tenant compte de leurs dépendances.

5. Relance sans modification

Une synchronisation répétée ne doit pas créer de doublons.

Contraintes importantes

Avant de développer, inspecte les mécanismes de création, de mise à jour et de réconciliation déjà présents dans le backend.

Ne réimplémente pas des fonctionnalités qui existent déjà.

Conserve les identifiants et les mappings des ressources Orq.ai.

Réutilise les API et le système de provisioning existants.

Ne supprime aucune ressource Orq.ai automatiquement.

Si une modification nécessite de recréer une ressource, explique-le plutôt que de le faire silencieusement.

Préserve la nouvelle interface et intègre les évolutions UX nécessaires uniquement si elles apportent une réelle valeur.

L’utilisateur doit comprendre si sa configuration est enregistrée localement, si des modifications attendent une synchronisation ou si les ressources Orq.ai sont à jour.

N’ajoute pas de Routing Rules ni de fonctionnalités Engineering Companion dans cette étape.

Vérifications

Effectue les tests locaux nécessaires, avec des mocks si besoin.

Ne déclenche pas automatiquement des opérations réelles Orq.ai pour valider les scénarios.

Je testerai moi-même les modifications et les résultats dans Orq Studio.

Résultat attendu

Un Mock LMC capable non seulement de créer les ressources, mais également de maintenir leur configuration à jour dans Orq.ai.

Privilégie une implémentation simple, fiable et réutilisant au maximum l’existant.