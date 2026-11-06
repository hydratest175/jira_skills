Les projets LMC sont désormais intégrés dans Engineering Companion.

Nous allons continuer progressivement.

Objectif

Implémenter la sélection des modèles autorisés dans Engineering Companion, en utilisant les informations déjà récupérées depuis le Mock LMC.

Fonctionnement attendu

Lorsqu’un utilisateur sélectionne un projet :

1. Récupérer les modèles autorisés pour cet utilisateur dans ce projet.
2. Afficher uniquement ces modèles dans le sélecteur existant, ou dans un composant adapté.
3. Présélectionner le modèle par défaut configuré dans le Mock LMC.
4. Permettre à l’utilisateur de choisir un autre modèle autorisé.
5. Actualiser les modèles disponibles lorsqu’il change de projet.
6. Gérer les situations où aucun modèle n’est autorisé ou disponible.

Points importants

Avant de modifier le code, vérifie si une partie de cette fonctionnalité existe déjà.

Réutilise les composants et les API existants.

Conserve le design actuel d’Engineering Companion.

Les modèles doivent provenir des autorisations du Mock LMC.

Ne recrée pas de catalogue parallèle.

Les contrôles d’autorisation doivent rester côté backend.

Limites de cette étape

Ne modifie pas encore :

* L’exécution des agents Orq.ai.
* Les modèles configurés sur les agents existants.
* Les prompts.
* Les connecteurs MCP.
* Les Routing Rules.
* Le provisioning Mock LMC.

La sélection doit être préparée dans l’interface, sans modifier silencieusement le modèle réellement utilisé par le chat.

L’interface doit clairement distinguer le modèle sélectionné du modèle effectivement utilisé tant que leur raccordement n’est pas implémenté.

Validation

Effectue uniquement les vérifications locales nécessaires.

Je testerai personnellement la sélection des modèles dans le navigateur.

Une fois terminé, explique les modifications réalisées et arrête-toi.

Nous connecterons ensuite cette sélection aux agents Orq.ai provisionnés par le Mock LMC.