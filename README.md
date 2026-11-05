Mission — Complete UX/UI Redesign of Mock LMC

1. Contexte

Nous développons un POC appelé Mock LMC, situé dans :

/workspace/LEA_Workspace/mock-lmc-orq-poc

Il simule une partie du LEA Management Center (LMC) et permet à un Project Manager de configurer un projet puis de provisionner automatiquement ses ressources dans Orq.ai.

Le projet utilise actuellement :

* React, TypeScript et Vite pour le frontend.
* FastAPI pour le backend.
* SQLite pour la persistance.
* Le SDK Python Orq.ai pour le provisioning.

Le POC est déjà fonctionnel.

Il permet notamment de gérer et provisionner :

* Les projets Orq.ai.
* Les utilisateurs synthétiques.
* Les Identities Orq.ai.
* Les membres et rôles des projets.
* Les budgets globaux des projets.
* Les budgets associés aux Identities.
* Les configurations de modèles.
* Les autorisations de modèles côté Mock LMC.
* Les prompts des agents.
* Les agents Engineering Companion, Jira Specialist et GitLab Specialist.
* Les relations entre orchestrateur et sous-agents.
* Les outils MCP associés aux spécialistes.

Les prompts sont partagés au niveau du projet lorsque cela correspond à l’implémentation actuelle, tandis que les agents sont personnalisés par utilisateur et par projet.

Les agents et les ressources provisionnés sont persistants. Ils ne doivent pas être supprimés à la déconnexion d’un utilisateur.

Lorsque la configuration évolue, le système doit mettre à jour les ressources existantes plutôt que les recréer systématiquement.

État des fonctionnalités

Le provisioning des projets, Identities, budgets, modèles, prompts et agents fonctionne déjà.

En revanche :

* Le contrôle d’accès natif Orq.ai des modèles n’est pas implémenté.
* Les autorisations de modèles sont actuellement conservées côté Mock LMC.
* Les Routing Rules ne sont pas encore intégrées.
* L’application Engineering Companion n’a pas encore été adaptée pour appliquer ces autorisations.

Ne considère pas ces fonctionnalités comme opérationnelles.

⸻

2. Objectif de cette mission

Je souhaite une refonte complète de l’expérience utilisateur et de l’interface graphique du Mock LMC.

Le design actuel est esthétique, mais il présente plusieurs problèmes :

* Une page principale extrêmement longue.
* Trop de scrolling.
* Trop de configurations affichées simultanément.
* Un panneau latéral qui mélange plusieurs responsabilités.
* Plusieurs boutons de provisioning qui rendent le parcours peu intuitif.
* Une distinction peu claire entre configuration locale et ressources réellement provisionnées dans Orq.ai.
* Une lecture difficile des statuts, des erreurs et des modifications.
* Une expérience peu adaptée aux changements effectués après un premier provisioning.

Je veux que tu abordes cette mission comme un Senior Product Designer / UX Designer spécialisé dans les applications SaaS B2B et les consoles d’administration complexes.

L’objectif n’est pas simplement de rendre l’application plus jolie.

Il faut concevoir une expérience :

* Moderne.
* Élégante.
* Professionnelle.
* Très intuitive.
* Cohérente.
* Efficace.
* Adaptée à la gestion de projets techniques.
* Facile à comprendre pour un Project Manager.

Tu disposes d’une liberté importante concernant la mise en page, les composants, l’organisation et les interactions.

En revanche, il faut préserver les fonctionnalités existantes.

⸻

3. Direction artistique

Le design actuel possède déjà une identité visuelle intéressante.

Il utilise notamment des teintes vert foncé, des fonds clairs et des accents orangés.

Tu peux conserver et faire évoluer cette direction artistique.

Je recherche une interface premium, avec une qualité visuelle comparable à celle d’un produit SaaS professionnel moderne.

Principes attendus :

* Design sobre et élégant.
* Hiérarchie visuelle très claire.
* Navigation immédiatement compréhensible.
* Espacements généreux mais maîtrisés.
* Typographie soignée.
* Couleurs cohérentes.
* Cartes et panneaux bien structurés.
* États interactifs visibles.
* Animations légères et utiles.
* Transitions fluides.
* Icônes cohérentes.
* Mise en page responsive.
* Bonne accessibilité et contrastes lisibles.

Évite les interfaces trop chargées, les effets décoratifs inutiles et les dashboards remplis de métriques sans intérêt.

L’objectif est de produire une interface visuellement remarquable mais surtout extrêmement pratique.

Ne te limite pas à reproduire l’interface actuelle avec des composants plus modernes.

Repense réellement son organisation.

⸻

4. Nouvelle architecture de navigation

Je souhaite abandonner l’organisation actuelle en une grande page avec un catalogue permanent à droite.

Propose une nouvelle organisation reposant sur une navigation claire.

4.1 Navigation globale

L’application devrait permettre d’accéder facilement aux espaces suivants :

Projects

Liste des projets Mock LMC.

Pour chaque projet, afficher notamment :

* Nom.
* Description courte.
* Statut de configuration/provisioning.
* Dernière synchronisation, si l’information est disponible.
* Accès rapide au projet.

Permettre de créer un nouveau projet facilement.

La création d’un projet doit être simple : nom, description et autres champs réellement nécessaires.

Après création, rediriger vers son espace de configuration.

Users

Catalogue global des utilisateurs synthétiques.

Permettre :

* De consulter les utilisateurs.
* D’en créer.
* De voir leurs informations principales.
* De distinguer leur identité locale de leur Identity Orq.ai.
* De consulter leur statut de provisioning lorsque disponible.

Ne pas confondre l’utilisateur global et son appartenance à un projet.

Model Catalog

Catalogue global des modèles disponibles.

Permettre :

* De consulter les modèles configurés localement.
* D’ajouter une configuration.
* De modifier les configurations supportées.
* De consulter les caractéristiques du modèle.
* De distinguer les configurations locales des ressources Orq.ai.

L’interface doit clairement expliquer la différence entre un modèle du catalogue et une configuration de modèle utilisée dans un projet.

Conserver l’architecture actuelle et les mécanismes existants de gestion des credentials.

Ne jamais exposer de valeur de clé API dans le frontend.

⸻

5. Espace de gestion d’un projet

Lorsqu’un Project Manager ouvre un projet, il doit accéder à un espace dédié.

Je propose une navigation interne comprenant :

1. Overview
2. Members
3. Models
4. Budgets
5. Agents
6. Provisioning

Tu peux ajuster les noms et l’organisation si cela améliore réellement l’expérience.

5.1 Overview

Cette page est le tableau de bord principal du projet.

Elle doit permettre de comprendre immédiatement :

* Quel projet est sélectionné.
* Son état actuel.
* S’il a déjà été provisionné.
* Si des modifications doivent être synchronisées.
* Combien d’utilisateurs sont membres.
* Combien de modèles sont associés.
* Combien d’agents sont provisionnés.
* Si les budgets sont configurés.
* Si des erreurs de provisioning nécessitent une intervention.

Ces informations doivent être récupérées depuis l’état réel disponible dans l’application.

Ne pas inventer de statistiques.

Présenter un récapitulatif élégant avec quelques cartes et indicateurs pertinents.

Ajouter des raccourcis vers les configurations à compléter.

Prévoir une action principale clairement identifiable :

Provisionner si le projet n’a jamais été provisionné.

Synchroniser si des modifications doivent être appliquées.

Lorsque le projet est déjà à jour, afficher cet état clairement.

5.2 Members

Créer une vraie interface de gestion des membres du projet.

Elle doit permettre :

* D’ajouter un utilisateur existant.
* De définir son rôle.
* De consulter les membres.
* De modifier les rôles.
* De retirer un membre lorsque cette opération est supportée.
* De configurer les modèles autorisés.
* De sélectionner le modèle par défaut des agents, parmi les modèles autorisés.
* D’accéder facilement au budget Identity associé.

Éviter les très grandes cartes verticales répétées pour chaque utilisateur.

Préférer une présentation compacte et lisible : tableau moderne, liste structurée ou cartes avec détails repliables.

Par exemple, un tableau affichant :

User	Role	Authorized Models	Default Model	Identity	Actions

Cliquer sur un utilisateur pourrait ouvrir un panneau latéral contextuel ou une vue détaillée.

Ce panneau permettrait de modifier ses paramètres sans encombrer la page principale.

Attention : les autorisations de modèles restent pour l’instant des configurations Mock LMC. Elles ne sont pas encore appliquées par Engineering Companion.

Ne pas présenter cela comme une protection effective de l’accès aux modèles.

5.3 Models

Créer une interface dédiée aux modèles disponibles dans le projet.

Elle doit présenter :

* Les modèles sélectionnés dans le catalogue.
* Leur configuration runtime.
* Leur état de provisioning Orq.ai.
* Leur disponibilité pour les membres du projet.
* Les éventuelles erreurs de configuration.

Séparer clairement :

Catalogue de modèles : définitions réutilisables.

Configuration de projet : instance/configuration associée à un projet LMC.

Autorisations utilisateurs : modèles que chaque utilisateur peut sélectionner dans Engineering Companion.

Ces trois notions ne doivent plus être mélangées.

Les détails techniques comme Base URL, provider, Model ID, type, température, max tokens et capacités doivent être accessibles dans un formulaire clair.

Ne pas demander à l’utilisateur de saisir plusieurs fois les mêmes informations.

Ne pas afficher les credentials.

Les clés et références techniques peuvent apparaître dans une section avancée lorsque cela est utile.

5.4 Budgets

Créer une page dédiée aux budgets.

Distinguer clairement :

Project Budget

Budget associé au projet Orq.ai.

Identity Budgets

Budgets associés aux Identities des utilisateurs.

Une Identity peut être réutilisée entre plusieurs projets. Ne pas présenter son budget global comme un budget indépendant propre à chaque projet si ce n’est pas le cas.

Prévoir des formulaires simples pour modifier :

* Le plafond financier.
* La limite de tokens.
* La limite de requêtes.
* La période.

Afficher clairement :

* La configuration enregistrée.
* L’état de provisioning.
* Les éventuelles modifications en attente.
* Les erreurs.

Si les données de consommation réelle sont disponibles, elles pourront être affichées.

Sinon, ne pas inventer de jauges de consommation.

Ne pas transformer cette mission en développement d’un système complet de monitoring.

5.5 Agents

Créer une section dédiée à l’architecture agentique provisionnée.

Cette section doit permettre de comprendre facilement les agents associés au projet et aux utilisateurs.

L’architecture actuelle comprend :

Engineering Companion
→ Jira Specialist
→ GitLab Specialist

Engineering Companion est l’orchestrateur.

Jira Specialist et GitLab Specialist sont des sous-agents.

Les spécialistes sont configurés avec leurs outils MCP.

Les agents sont personnalisés par utilisateur et par projet.

Les prompts peuvent être partagés au niveau du projet conformément à l’implémentation actuelle.

Visualisation

Je souhaite une représentation visuelle élégante de cette architecture.

Par exemple :

Engineering Companion
├── Jira Specialist
│   └── Jira MCP Tools
└── GitLab Specialist
└── GitLab MCP Tools

Il ne s’agit pas nécessairement de développer un éditeur de graphes complexe.

Une visualisation statique ou semi-dynamique, construite à partir des données disponibles, suffit pour ce POC.

L’utilisateur doit pouvoir :

* Sélectionner un membre du projet.
* Voir ses agents.
* Voir le modèle configuré pour ces agents.
* Comprendre les relations entre orchestrateur et spécialistes.
* Consulter le statut de provisioning.
* Accéder aux détails techniques si nécessaire.

Ne pas afficher des connexions fictives.

Ne pas rendre éditables des paramètres qui ne sont pas réellement modifiables dans le backend.

Les Skills, les Knowledge Bases et les Routing Rules ne sont pas dans le périmètre de cette refonte.

⸻

6. Repenser complètement le parcours de provisioning

C’est l’une des parties les plus importantes de la mission.

6.1 Principe fonctionnel

Le Project Manager doit pouvoir :

1. Créer un projet.
2. Ajouter ses membres.
3. Associer les modèles.
4. Configurer les autorisations et les modèles par défaut.
5. Définir les budgets.
6. Vérifier la configuration des agents.
7. Cliquer sur un bouton principal pour provisionner l’ensemble.

Le backend est responsable de l’orchestration des ressources Orq.ai.

Le Project Manager ne doit pas avoir besoin de connaître l’ordre technique de création des ressources.

6.2 Une seule action principale

Conserver une action principale :

Provisionner / Synchroniser

L’interface doit adapter son libellé au contexte.

Les actions individuelles actuellement disponibles pour provisionner les modèles, les Identities, les budgets, les prompts ou les agents ne doivent plus être omniprésentes.

Elles peuvent être conservées dans des actions avancées si cela est nécessaire au développement ou au diagnostic.

Elles ne doivent plus structurer le parcours utilisateur principal.

Ne pas supprimer leurs fonctionnalités backend.

6.3 Prévisualisation avant provisioning

Avant le provisioning, afficher un récapitulatif des ressources concernées.

Par exemple :

* Projet Orq.ai.
* Identities.
* Budgets.
* Modèles.
* Prompts.
* Agents par utilisateur.

Lorsque l’application sait déterminer les opérations à effectuer, indiquer :

* À créer.
* À mettre à jour.
* Déjà à jour.
* Non configuré.
* Erreur ou configuration invalide.

Attention : ne pas inventer de moteur de comparaison.

Si le backend ne dispose pas encore de toutes les informations nécessaires pour garantir un vrai diff entre l’état local et Orq.ai, afficher uniquement ce qui peut être déterminé de manière fiable.

Identifier les éventuels besoins backend au lieu de simuler une synchronisation exacte.

6.4 Progression

Lors du provisioning, afficher une interface de progression claire.

Exemple :

Project — Succeeded

Identities — Succeeded

Budgets — Succeeded

Models — Succeeded

Prompts — Succeeded

Agents — In Progress

Cette progression doit refléter les véritables étapes et statuts renvoyés par le backend.

Si le backend actuel ne permet pas un suivi temps réel, proposer une présentation honnête et simple, sans inventer d’événements ni de pourcentages.

6.5 Gestion des erreurs

Les erreurs doivent être compréhensibles.

Éviter d’afficher uniquement :

FAILED

ou :

502 Bad Gateway

Préférer des messages contextualisés.

Par exemple :

Impossible de provisionner le modèle

La configuration du fournisseur semble incomplète.

Vérifiez les paramètres du modèle puis réessayez.

Ou :

Erreur lors de la synchronisation d’un agent

L’agent Jira Specialist de cet utilisateur n’a pas pu être mis à jour.

Les autres ressources correctement provisionnées restent disponibles.

Prévoir un accès aux détails techniques pour le développeur.

Ne jamais afficher les secrets ou tokens dans ces détails.

Ne pas masquer les erreurs réelles derrière des messages trompeurs.

6.6 Gestion des modifications

Après un premier provisioning, le Project Manager doit pouvoir modifier une configuration.

Par exemple :

* Ajouter un utilisateur.
* Modifier un rôle.
* Changer un modèle autorisé.
* Modifier le modèle par défaut d’un utilisateur.
* Modifier un budget.
* Modifier une configuration de modèle.

L’interface doit distinguer clairement :

Configuration enregistrée localement

et

Configuration synchronisée avec Orq.ai

Lorsque des modifications nécessitent une nouvelle synchronisation, afficher un indicateur visible.

Éviter toute ambiguïté entre sauvegarder et provisionner.

Une modification locale ne doit pas déclencher automatiquement une opération Orq.ai sans que cela corresponde explicitement au comportement retenu.

Le provisioning doit rester persistant et idempotent.

Les mises à jour doivent réutiliser les ressources existantes lorsque les mécanismes backend le permettent.

Ne pas introduire de suppression automatique des agents à la déconnexion.

⸻

7. États et feedback utilisateur

Je souhaite une expérience particulièrement soignée concernant les statuts et les interactions.

Prévoir des états visuels cohérents pour :

* Not configured.
* Ready to provision.
* Provisioning.
* Provisioned / In sync.
* Changes pending.
* Partially failed.
* Failed.

Ne pas baser ces états uniquement sur des suppositions frontend.

Ils doivent correspondre aux informations réellement connues.

Notifications

Ajouter des notifications discrètes et élégantes pour les actions importantes :

* Projet créé.
* Configuration enregistrée.
* Utilisateur ajouté.
* Modèle associé.
* Budget modifié.
* Provisioning réussi.
* Provisioning échoué.
* Synchronisation nécessaire.

Formulaires

Ajouter :

* Validation des champs.
* Messages d’erreur contextualisés.
* Indication des champs obligatoires.
* États de chargement.
* Désactivation des boutons pendant les requêtes.
* Protection contre les doubles clics.
* Messages de succès.
* Gestion des réponses réseau en erreur.
* Confirmation des opérations destructrices.
* Avertissement en cas de modifications locales non enregistrées.

Les erreurs doivent rester visibles tant qu’elles n’ont pas été comprises ou résolues.

Détails techniques

Les identifiants Orq.ai, clés fonctionnelles, références de modèles et informations techniques ne doivent plus dominer l’interface.

Les conserver accessibles dans un panneau de détails, une section avancée ou un bouton de copie.

Ne pas supprimer ces informations : elles restent utiles pour le diagnostic.

⸻

8. Améliorations ergonomiques supplémentaires

Tu peux proposer et implémenter des améliorations UX simples lorsqu’elles apportent une valeur réelle.

Quelques idées :

* Recherche et filtrage des projets.
* Recherche dans les membres.
* Navigation par onglets.
* Panneaux de détails contextuels.
* Confirmation des actions importantes.
* Navigation de retour claire.
* Breadcrumbs.
* Indicateurs de configuration incomplète.
* Empty states soignés.
* Tooltips expliquant les termes techniques.
* Boutons de copie pour les identifiants.
* Skeleton loaders.
* Affichage compact des utilisateurs.
* Résumé des dernières opérations.
* Actualisation des statuts après une opération.
* Différenciation visuelle entre ressources locales et ressources Orq.ai.

Ces améliorations doivent rester proportionnées au POC.

Ne transforme pas l’application en une plateforme d’administration générique beaucoup plus complexe.

⸻

9. Contraintes techniques importantes

Préserver l’existant

Cette mission est principalement une refonte frontend.

Il faut absolument préserver le fonctionnement actuel du provisioning.

Ne pas réécrire inutilement :

* Les services Orq.ai.
* Le système de mapping SQLite.
* Les opérations idempotentes déjà fonctionnelles.
* La gestion des Identities.
* La gestion des budgets.
* Le provisioning des modèles.
* Le provisioning des prompts.
* Le provisioning des agents.
* Les relations entre les agents.
* Les mécanismes de configuration des outils MCP.

Réutiliser les API backend existantes.

Des adaptations backend minimales sont acceptables lorsqu’elles sont réellement nécessaires pour offrir une UX cohérente.

Dans ce cas, les justifier et éviter les modifications disproportionnées.

Ne pas inventer de nouveaux endpoints sans avoir inspecté les routes existantes.

Configuration et sécurité

Ne pas modifier les fichiers .env contenant des credentials.

Ne pas afficher les secrets dans le frontend.

Ne pas journaliser les API keys.

Ne pas modifier inutilement Docker Compose ni les Dockerfiles.

Ne pas ajouter de dépendances volumineuses si elles ne sont pas nécessaires.

Ne pas utiliser de services externes de design ou d’API.

Le développement doit être réalisable avec les ressources locales disponibles.

Hors périmètre

Ne pas implémenter dans cette mission :

* L’intégration réelle avec Engineering Companion.
* Les Routing Rules.
* L’EAL.
* Le provisioning des Skills.
* Les Knowledge Bases.
* L’authentification SSO réelle.
* Un nouveau système de permissions backend.
* Un nouveau moteur de monitoring.
* Une architecture distribuée.
* Une refonte des templates d’agents.

Ne pas toucher aux autres dépôts sans nécessité.

⸻

10. Méthode de travail attendue

Je souhaite que tu procèdes comme un développeur frontend senior travaillant avec un UX designer expérimenté.

Phase A — Audit de l’interface

Commence par examiner :

* La structure du frontend.
* Les composants React existants.
* Les styles.
* Les routes API.
* Les objets métier.
* Les formulaires.
* Les actions de provisioning.
* Les états de chargement et d’erreur.

Identifie les éléments qui peuvent être réutilisés.

Détermine les limites des données réellement exposées par le backend.

Ne présume pas qu’un statut ou une fonctionnalité est disponible sans l’avoir vérifié dans le code.

Phase B — Architecture UX

Définis brièvement la nouvelle architecture de navigation et les composants principaux.

Privilégie une organisation claire, modulaire et extensible.

Ne reste pas bloqué dans une longue phase de réflexion théorique.

L’objectif est de produire une interface fonctionnelle.

Phase C — Implémentation

Implémente la nouvelle interface.

Tu peux modifier largement le frontend et son organisation.

Tu dois conserver les fonctionnalités existantes.

Utilise des composants réutilisables, des styles cohérents et une gestion propre des états.

Évite un composant React gigantesque qui centralise toute l’application.

Phase D — Vérification

Vérifie :

* La compilation TypeScript.
* Le build frontend.
* Les éventuels tests frontend disponibles.
* La cohérence des appels vers les endpoints existants.
* L’absence de régression évidente.

Ne lance pas automatiquement de provisioning réel Orq.ai pour tester l’interface.

Ne multiplie pas les tests nécessitant des environnements ou des credentials externes.

Je réaliserai moi-même les validations fonctionnelles dans le navigateur et les vérifications des ressources dans Orq Studio.

Ne supprime aucune ressource Orq.ai existante.

⸻

11. Critères de réussite

La refonte sera considérée comme réussie si :

1. L’application possède une identité visuelle premium et cohérente.
2. Il n’est plus nécessaire de parcourir une immense page pour administrer un projet.
3. Les utilisateurs, modèles, budgets et agents sont organisés dans des sections clairement séparées.
4. Le Project Manager comprend immédiatement l’état de son projet.
5. Il sait quelles configurations doivent encore être complétées.
6. Il peut enregistrer ses modifications sans confusion.
7. Il distingue clairement les données locales des ressources provisionnées dans Orq.ai.
8. Le provisioning complet constitue l’action principale de l’application.
9. Les succès, erreurs et modifications en attente sont clairement visibles.
10. Les informations techniques restent disponibles sans encombrer l’interface.
11. Les fonctionnalités de provisioning existantes continuent de fonctionner.
12. Le résultat ressemble à une véritable console professionnelle de gestion de projets IA.

⸻

12. Priorité absolue

Je préfère une interface réellement agréable et intuitive plutôt qu’une accumulation de fonctionnalités supplémentaires.

Le plus important est de créer un parcours cohérent :

Créer un projet → Configurer → Vérifier → Provisionner → Consulter → Modifier → Synchroniser.

Ce parcours doit devenir le principe central de l’application.

Conserve l’approche actuelle de provisioning persistant : les ressources Orq.ai restent créées et sont mises à jour lorsque les configurations changent.

Tu disposes d’une réelle liberté créative sur le design.

Ne conserve pas l’ancienne structure simplement par facilité.

Je veux une véritable refonte UX/UI, pas un simple nettoyage CSS.

En revanche, ne sacrifie jamais la fiabilité du provisioning existant pour améliorer l’apparence.

Commence par auditer rapidement l’application, puis implémente la nouvelle interface en restant concentré sur ce périmètre.

À la fin, résume les principales améliorations, les fichiers modifiés, les vérifications réalisées et les éventuelles limites fonctionnelles qui subsistent.