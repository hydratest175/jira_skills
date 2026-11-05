Nous avons validé les fonctionnalités suivantes dans notre Mock LMC :

* Création et réutilisation des projets Orq.ai.
* Création et réutilisation des Identities.
* Création et synchronisation des budgets projet et Identity.

Tout fonctionne.

Nous passons maintenant à l’étape suivante : le provisioning des modèles LLM et la gestion des accès aux modèles par projet.

1. OBJECTIF

Lorsqu’un modèle est configuré et activé pour un projet dans le Mock LMC, nous voulons pouvoir provisionner la configuration correspondante dans Orq.ai.

Notre objectif est d’avoir des configurations de modèles spécifiques à chaque projet LMC.

Par exemple :

Projet A :

* Configuration GPT 5.6 — Projet A
* Configuration Mistral — Projet A

Projet B :

* Configuration GPT 5.6 — Projet B

Même si deux configurations utilisent le même modèle LLM sous-jacent, nous voulons pouvoir les distinguer pour chaque projet.

2. CRÉATION DES MODÈLES

Dans Orq Studio, la création d’un modèle personnalisé permet de renseigner notamment :

* Model type : Chat Completion, Completion, Embedding, etc.
* Base URL.
* Model ID.
* API Key du fournisseur, si nécessaire.
* Model Name.
* Paramètres complémentaires (max tokens, température, etc.).

Je veux pouvoir reproduire ce mécanisme depuis notre Mock LMC.

Inspecte le SDK orq-ai-sdk 4.13.14 déjà disponible et les patterns du dépôt thales-orq-provisioning.

Utilise les méthodes et schémas réellement pris en charge.

Important : les données fictives du catalogue actuel ne doivent pas être envoyées aveuglément à Orq.ai. Il faut utiliser des configurations valides, correspondant aux modèles et fournisseurs réellement accessibles dans notre environnement.

3. ACCESS CONTROL PAR PROJET

Dans Orq Studio, lorsqu’un modèle existe, il est possible d’ouvrir ses paramètres, de consulter les projets et de gérer son Access Control.

Nous voulons automatiser ce fonctionnement.

Lorsqu’une configuration de modèle est provisionnée :

1. Identifier le projet Orq.ai correspondant au projet Mock LMC.
2. Créer ou retrouver la configuration du modèle.
3. Autoriser l’accès au modèle uniquement pour les projets sélectionnés dans le Mock LMC.
4. Ne pas accorder automatiquement l’accès à tous les projets du workspace.

Point important : vérifie bien la distinction entre création d’un modèle au niveau workspace et autorisation d’utilisation au niveau projet.

La méthode de création des modèles du SDK semble être workspace-scoped. Il ne faut donc pas supposer qu’elle accepte directement un project_id.

Recherche dans les sources locales du SDK comment les autorisations de modèles sont gérées.

Si l’API d’Access Control n’est pas disponible dans le SDK, identifie précisément ce qui manque. N’invente pas d’endpoint.

Si nécessaire, propose une opération HTTP directe uniquement si son contrat officiel a pu être vérifié.

4. AUTORISATIONS PAR UTILISATEUR

Le Mock LMC possède déjà une gestion des modèles autorisés pour chaque utilisateur au sein d’un projet.

Il faut conserver cette distinction :

* Access Control Orq.ai : détermine quels projets peuvent accéder à un modèle.
* Autorisations Mock LMC : déterminent quels utilisateurs d’un projet peuvent sélectionner ce modèle.

Ne suppose pas que l’Access Control d’Orq.ai permet directement de gérer les autorisations individuelles des utilisateurs.

Ces autorisations devront être contrôlées par le backend de l’Engineering Companion lors de l’exécution.

5. IDEMPOTENCE ET PERSISTANCE

Le provisioning doit être idempotent.

* Un modèle déjà provisionné ne doit pas être recréé inutilement.
* Chaque configuration doit posséder une clé fonctionnelle stable.
* Enregistrer dans SQLite les correspondances avec les identifiants Orq.ai.
* Permettre la synchronisation des modifications lorsque c’est techniquement possible.
* Éviter de modifier une configuration appartenant à un autre projet.
* Ne jamais supprimer automatiquement des modèles existants.

6. INTÉGRATION AU WORKFLOW

Lorsqu’on clique sur « Provisionner », le workflow doit désormais être :

1. Créer ou retrouver le projet Orq.ai.
2. Créer ou retrouver les Identities.
3. Synchroniser les budgets.
4. Créer ou retrouver les configurations de modèles du projet.
5. Appliquer les autorisations d’accès aux modèles, si le mécanisme API est disponible.
6. Afficher les résultats et éventuelles erreurs dans le Mock LMC.

Un échec sur les modèles ne doit pas entraîner la suppression des projets, Identities ou budgets déjà provisionnés.

7. CONTRAINTES

* Travailler uniquement dans mock-lmc-orq-poc.
* Ne pas modifier le véritable LMC ou Engineering Companion.
* Réutiliser le SDK existant.
* Ne pas exposer les clés API ou credentials dans le frontend, SQLite ou les logs.
* Conserver les fonctionnalités déjà validées.
* Ne pas développer d’infrastructure inutile.
* Ne pas créer d’agents, folders ou Routing Rules pour l’instant.
* Ne pas effectuer d’opérations réelles sur Orq.ai sans mon autorisation.

8. VALIDATION

Je réaliserai les vérifications manuellement dans Orq Studio.

Je veux pouvoir vérifier :

1. Que les configurations de modèles ont été créées.
2. Que leurs paramètres correspondent à ceux définis dans le Mock LMC.
3. Que les modèles sont bien accessibles uniquement aux projets autorisés.
4. Qu’un deuxième provisioning ne crée pas de doublons.
5. Que les autres ressources Orq.ai restent inchangées.

N’automatise pas les vérifications que je peux effectuer directement dans l’interface.

À la fin, explique-moi ce qui a été implémenté, ce qui reste éventuellement bloqué par les capacités du SDK et comment effectuer la validation.

Ne passe pas aux agents ni aux Routing Rules avant ma validation.

Réponds en français.