Je veux clarifier une règle d’architecture fondamentale pour la suite de notre développement.

Le workflow historique d’Engineering Companion est déjà fonctionnel.

Nous l’avons confirmé par des tests réels : les orchestrateurs appellent correctement les spécialistes Jira/GitLab, les spécialistes communiquent avec le MCP, le token Keycloak est transmis, le MCP récupère correctement les credentials utilisateurs depuis Vault, et les outils Jira/GitLab fonctionnent.

L’incident précédent venait d’un problème de déploiement externe du MCP, corrigé depuis par un collègue.

Tu ne dois donc plus considérer le workflow d’authentification et d’exécution MCP comme quelque chose à réparer ou à reconstruire.

1. Workflow existant à préserver

Ne modifie pas sans nécessité démontrée :

* L’authentification Keycloak existante.
* La gestion des sessions utilisateur.
* La récupération et la transmission du Keycloak access token.
* La connexion des spécialistes Jira/GitLab au MCP.
* Les handoffs Orq.ai.
* La logique d’authentification du serveur MCP.
* La résolution des connecteurs et des PAT depuis Vault.
* Les appels réels aux API Jira/GitLab.
* La gestion des réponses et résultats d’outils.

Nous voulons conserver la compatibilité avec le workflow historique.

Il ne faut pas introduire de nouvelles dépendances obligatoires dans ce parcours uniquement pour résoudre un incident qui n’existe plus.

2. Examiner les ajouts récents sans modifier le système

Je veux que tu distingues précisément les protections de sécurité sans changement de comportement des modifications susceptibles d’avoir altéré le fonctionnement initial.

Par exemple :

* Les modifications de validation JWT.
* Les nouvelles contraintes sur les credentials Vault.
* Les modifications du filtrage des connecteurs.
* Les changements de traitement des erreurs.
* Les éventuelles nouvelles obligations d’autorisation projet.

Une amélioration de sécurité doit rester compatible avec les requêtes légitimes existantes, sauf décision explicite de changer la politique de sécurité.

Si une modification récente change ce comportement, signale-la clairement et justifie sa nécessité.

Ne fais aucun revert automatiquement.

3. LMC Project ID : évolution future distincte

Mon équipe a confirmé que le scoping MCP par projet LMC devra être implémenté.

Nous pouvons donc conserver les développements préparatoires associés.

En revanche, cette future fonctionnalité ne doit pas modifier ou bloquer le workflow actuel avant d’être intégrée et validée.

Le contrat d’autorisation du véritable LMC et les conditions de son activation restent à confirmer.

4. Versioning et modèles

Conserve intégralement notre nouvelle implémentation :

* Orchestrateurs personnels par utilisateur/projet.
* Versions publiées par modèle.
* Sélection dynamique.
* Mappings persistants.
* Continuité conversationnelle.
* Spécialistes partagés.

Ces fonctionnalités fonctionnent et ne doivent pas être reconstruites.

5. Priorité actuelle : la refonte UI du sélecteur de modèles

Notre prochain travail concerne uniquement le design du sélecteur de modèle dans Engineering Companion.

Je veux déplacer ce sélecteur du haut de la conversation vers le composer, avec une présentation compacte et moderne, idéalement en utilisant les composants déjà disponibles dans Assistant UI.

Il s’agit d’une modification de présentation.

Réutilise le state et les callbacks existants de sélection du modèle.

Ne crée aucun second mécanisme de sélection.

Ne modifie pas les appels backend ou Orq.

Ne modifie pas l’authentification, Redis, Vault, les MCP ou les sous-agents pour cette refonte.

Effectue uniquement les tests de non-régression pertinents pour le sélecteur et le chat.

En résumé : nous avons déjà un workflow opérationnel et un versioning fonctionnel. Nous voulons maintenant améliorer l’expérience utilisateur sans toucher au moteur qui fonctionne derrière.