Mission — Raccorder le chat aux agents Orq.ai provisionnés par le Mock LMC

Contexte

La communication entre Mock LMC et Engineering Companion fonctionne.

La sélection des projets et des modèles autorisés est maintenant implémentée dans Engineering Companion.

Le Mock LMC provisionne déjà dans Orq.ai, pour chaque utilisateur et chaque projet, trois agents persistants :

* Engineering Companion (orchestrateur)
* Jira Specialist
* GitLab Specialist

Les orchestrateurs sont déjà configurés pour appeler leurs spécialistes respectifs.

Les identifiants exacts des agents sont enregistrés dans les mappings du Mock LMC et récupérables depuis Engineering Companion.

Objectif

Je souhaite maintenant qu’Engineering Companion utilise réellement l’orchestrateur personnel provisionné par le Mock LMC lorsqu’un utilisateur envoie un message.

Cette étape doit rester limitée à l’exécution des agents existants.

1. Analyse préalable

Avant toute modification, analyse précisément la chaîne actuelle d’exécution du chat dans Engineering Companion.

Identifie notamment comment sont actuellement déterminés :

* L’utilisateur connecté.
* Le projet associé à la conversation.
* La clé de l’agent Orq.ai exécuté.
* Les credentials utilisés pour appeler Orq.ai.
* L’Identity transmise à l’exécution.
* L’historique et les identifiants de conversation.

Réutilise les mécanismes existants.

2. Résolution de l’orchestrateur

Lorsqu’un utilisateur envoie un message dans une conversation associée à un projet LMC :

1. Identifier l’utilisateur depuis son authentification Keycloak.
2. Vérifier côté backend son appartenance au projet.
3. Récupérer la configuration correspondante depuis le Mock LMC.
4. Vérifier que le projet et les ressources nécessaires sont synchronisés.
5. Retrouver l’identifiant exact de son orchestrateur Orq.ai.
6. Exécuter cet orchestrateur avec les credentials backend appropriés.

Ne jamais reconstruire approximativement une clé d’agent.

Ne jamais permettre au frontend de sélectionner arbitrairement un identifiant d’agent à exécuter.

3. Modèle utilisé

Pour cette première intégration, utiliser uniquement le modèle par défaut déjà provisionné sur l’orchestrateur personnel.

Ne pas modifier dynamiquement la configuration des agents.

Si l’utilisateur sélectionne un autre modèle dans l’interface, ne pas prétendre que ce modèle est appliqué.

Conserver une indication explicite et empêcher toute ambiguïté entre le modèle sélectionné et le modèle réellement exécuté. Si nécessaire, bloquer temporairement l’envoi avec un modèle différent du modèle provisionné.

Nous traiterons la sélection dynamique des modèles dans une étape ultérieure.

4. Exécution et Identity

Réutilise la logique actuelle d’exécution des agents.

Transmets l’Identity Orq.ai correspondant à l’utilisateur si l’API actuelle le permet et si le mapping a été validé.

Conserve le rattachement de la conversation au bon projet.

Préserve l’historique et le fonctionnement du chat existant.

Les spécialistes Jira et GitLab sont déjà associés à l’orchestrateur lors du provisioning. Ne recrée pas ces connexions et ne modifie pas leurs configurations.

5. Contraintes

* Aucun nouveau provisioning Orq.ai.
* Aucune modification des templates d’agents ou des prompts.
* Aucune modification des connecteurs MCP.
* Aucun changement des budgets.
* Aucune modification des Routing Rules.
* Aucune modification de l’interface Mock LMC.
* Aucune refonte inutile du frontend Engineering Companion.
* Aucun contournement des autorisations backend.

Les ressources Orq.ai existantes doivent être réutilisées.

6. Vérifications

Effectue les tests locaux nécessaires avec des mocks lorsque c’est pertinent.

Ne déclenche pas automatiquement des conversations réelles ou des appels MCP pour valider le fonctionnement.

Je réaliserai moi-même les tests fonctionnels dans Engineering Companion et vérifierai les traces dans Orq Studio.

7. Résultat attendu

Je veux pouvoir ouvrir Engineering Companion, sélectionner un projet LMC et envoyer un message à mon orchestrateur personnel déjà provisionné dans Orq.ai.

À la fin, explique précisément comment le backend résout l’agent utilisé, quelles vérifications de sécurité sont réalisées et comment je peux vérifier manuellement que la requête a bien été exécutée par le bon orchestrateur.

Arrête-toi après cette étape pour que je puisse valider le fonctionnement avant de continuer.