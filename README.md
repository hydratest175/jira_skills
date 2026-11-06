Mission — Refonte complète de la gestion des projets et conversations dans Engineering Companion

1. Contexte général

Nous avons considérablement avancé sur l’intégration entre Engineering Companion, le Mock LMC et Orq.ai.

Actuellement, plusieurs fonctionnalités sont opérationnelles :

* Le Mock LMC provisionne des projets Orq.ai.
* Les Identities et les budgets sont provisionnés.
* Les configurations de modèles sont provisionnées.
* Les prompts et les agents personnels sont provisionnés.
* Chaque utilisateur dispose de son orchestrateur Engineering Companion et de ses deux spécialistes Jira et GitLab.
* Engineering Companion communique avec le Mock LMC.
* Les projets et les modèles autorisés sont récupérés.
* L’orchestrateur personnel est résolu à partir de l’utilisateur et du projet.
* Les clés API adaptées permettent désormais d’exécuter les agents.
* L’exécution dans Orq.ai fonctionne et les traces remontent correctement.

Nous avons donc une chaîne d’intégration opérationnelle.

Il est essentiel de préserver ce fonctionnement.

En revanche, la gestion actuelle des conversations présente des problèmes fonctionnels et des incohérences UX importantes.

Cette mission consiste à repenser cette partie de l’application.

⸻

2. Problèmes actuels à corriger

2.1. Création d’une conversation sans projet

Actuellement, Engineering Companion permet de créer une conversation sans l’associer immédiatement à un projet.

Lorsqu’on crée une conversation, puis qu’on essaie d’envoyer un message, l’application affiche :

Assign this conversation to a project before sending a message.

Cette erreur est compréhensible techniquement, puisque l’exécution d’un agent nécessite désormais un contexte projet.

Cependant, le parcours utilisateur est incohérent.

L’application autorise la création d’une conversation qu’elle refuse ensuite d’utiliser.

Je ne souhaite pas conserver ce fonctionnement.

2.2. Affectation à un projet qui ne fonctionne pas

Lorsqu’on essaie de déplacer cette conversation sans projet dans un dossier projet existant, l’opération ne fonctionne pas correctement.

Dans certains cas :

* Rien ne se passe.
* La conversation ne rejoint pas le projet.
* L’interface ne reflète pas la modification.
* La conversation reste inutilisable.

Le renommage des conversations a également présenté des dysfonctionnements.

Des corrections ont déjà été apportées à ces fonctionnalités, mais leur bon fonctionnement doit être revérifié.

Je veux que tu identifies les causes exactes de ces problèmes.

Cependant, je ne souhaite pas simplement réparer ce parcours pour continuer à l’utiliser.

Notre objectif est de supprimer le besoin de déplacer une nouvelle conversation vers un projet.

2.3. Mauvaise logique de navigation

Aujourd’hui, le parcours ressemble à ceci :

Créer une conversation → Choisir un projet → Affecter la conversation → Envoyer un message

Ce fonctionnement n’est plus adapté à notre architecture.

Le projet détermine notamment :

* Les autorisations de l’utilisateur.
* L’orchestrateur personnel utilisé.
* Les modèles disponibles.
* L’Identity Orq.ai.
* Le périmètre des connecteurs.
* Les ressources et connaissances potentiellement accessibles.
* Les budgets et règles applicables.
* Le contexte métier de la conversation.

Une conversation ne devrait donc pas exister comme espace de chat utilisable sans qu’un projet ait été déterminé.

Cela soulève également des problèmes de confidentialité et d’isolation du contexte.

⸻

3. Nouvelle architecture UX : Project-first

Je souhaite adopter une approche Project-first.

Le projet doit devenir l’espace de travail principal dans Engineering Companion.

Le nouveau fonctionnement doit être :

Sélection du projet → Accès à son espace de travail → Création d’une conversation → Exécution de l’orchestrateur personnel.

Une conversation est créée directement dans son projet.

Il n’existe plus d’étape intermédiaire consistant à créer une conversation sans projet, puis à la déplacer.

Cette logique doit être appliquée à la fois dans l’interface et dans le backend.

⸻

4. Expérience utilisateur attendue

4.1. Arrivée dans Engineering Companion

Lorsqu’un utilisateur se connecte à Engineering Companion via Keycloak, l’application doit récupérer ses projets autorisés depuis le Mock LMC.

Je souhaite que l’utilisateur puisse choisir le projet dans lequel il veut travailler.

Deux comportements sont acceptables :

Option A — Sélection initiale

Lorsqu’aucun projet n’est encore sélectionné, afficher un écran élégant présentant les projets accessibles.

L’utilisateur sélectionne son projet avant d’accéder aux conversations.

Option B — Restauration du dernier projet

Si l’utilisateur avait précédemment sélectionné un projet, l’application peut rouvrir directement ce projet, à condition que ses autorisations soient toujours valides.

Je te laisse choisir l’expérience UX la plus pertinente en fonction de l’interface existante.

Dans tous les cas, un projet doit être sélectionné avant de pouvoir créer une conversation.

Si l’utilisateur n’a aucun projet accessible, afficher un état vide clair et soigné.

Ne jamais lui proposer de créer une conversation inutilisable.

4.2. Le projet devient l’espace de travail actif

Une fois le projet sélectionné, toute l’interface conversationnelle doit s’adapter à ce projet.

Le projet actif doit être clairement identifiable.

Je souhaite notamment retrouver :

* Le nom du projet actif.
* Les conversations appartenant à ce projet.
* Un bouton permettant de créer une nouvelle conversation.
* Les modèles autorisés dans ce projet.
* Les fonctionnalités de chat existantes.

Le sélecteur de projet doit rester facilement accessible.

Il doit permettre de changer rapidement de contexte sans avoir à revenir systématiquement sur une page d’accueil.

4.3. Navigation entre les projets

Imaginons que l’utilisateur possède deux projets :

Projet Alpha

* Conversation : Analyse des tickets Jira.
* Conversation : Sprint planning.
* Conversation : Review GitLab.

Projet Beta

* Conversation : Architecture backend.
* Conversation : Documentation API.

Lorsqu’il sélectionne Alpha, il voit uniquement les conversations d’Alpha.

Lorsqu’il passe sur Beta :

* La sidebar affiche les conversations de Beta.
* Les conversations d’Alpha ne sont plus affichées.
* Les modèles autorisés sont actualisés.
* Le contexte projet actif change.
* Les futures conversations créées appartiennent à Beta.

Cependant, les conversations d’Alpha ne sont ni supprimées ni déplacées.

Lorsqu’il retourne sur Alpha, il doit retrouver ses conversations avec leur historique intact.

Changer de projet signifie changer d’espace de travail, et non modifier l’appartenance des conversations.

4.4. Création d’une nouvelle conversation

Lorsqu’un utilisateur se trouve dans le projet Alpha et clique sur New Chat, la conversation doit automatiquement appartenir à Alpha.

Il ne doit pas avoir besoin de choisir une deuxième fois son projet.

Le backend doit créer la conversation directement avec le bon project_id.

Je veux éviter le fonctionnement suivant :

1. Création d’une conversation sans projet.
2. Affectation du projet dans une deuxième requête.

Je souhaite une création cohérente et atomique.

Si la création réussit, la conversation apparaît immédiatement dans la liste du projet actif.

Si elle échoue, l’interface doit afficher une erreur compréhensible.

Elle ne doit pas laisser croire qu’une conversation utilisable a été créée.

4.5. Interface de conversation

Lorsqu’un utilisateur ouvre une conversation :

* Le projet associé est connu.
* Le modèle par défaut est chargé.
* Les modèles autorisés restent sélectionnables.
* L’orchestrateur personnel correspondant peut être résolu.
* L’historique de la conversation est chargé.
* L’utilisateur peut envoyer des messages normalement.

Je veux conserver le fonctionnement actuel de l’exécution des agents.

Le but de cette mission n’est pas de modifier l’orchestration Orq.ai.

Il faut simplement que les nouvelles conversations soient correctement créées dans leur contexte projet.

Le chat doit fonctionner directement, sans opération manuelle supplémentaire.

⸻

5. Refonte de la navigation et de la sidebar

Je souhaite que tu repenses intelligemment la navigation actuelle d’Engineering Companion.

L’objectif n’est pas de reproduire exactement l’ancien système de dossiers.

Le projet doit devenir une véritable notion d’espace de travail.

Je propose une organisation conceptuelle similaire à celle-ci :

ENGINEERING COMPANION
┌─────────────────────────────┐
│                             │
│  PROJECT WORKSPACE          │
│                             │
│  📁 Projet Alpha         ▼  │
│                             │
├─────────────────────────────┤
│                             │
│  + New Conversation         │
│                             │
│  CONVERSATIONS              │
│                             │
│  Analyse Jira               │
│  Sprint Planning            │
│  GitLab Review              │
│                             │
│                             │
├─────────────────────────────┤
│                             │
│  User / Settings            │
│                             │
└─────────────────────────────┘

À droite de cette sidebar, on conserve l’interface de chat.

Le projet actif et la conversation active doivent être clairement distingués.

Exigences UX

Je souhaite :

* Une navigation intuitive.
* Une hiérarchie visuelle claire.
* Un sélecteur de projet élégant.
* Des transitions fluides.
* Une sidebar bien organisée.
* Des conversations faciles à retrouver.
* Des actions de renommage et suppression accessibles.
* Des états de chargement discrets et compréhensibles.
* Des messages d’erreur adaptés.
* Une interface responsive.

Tu disposes d’une certaine liberté pour améliorer l’organisation visuelle.

Cependant, ne réalise pas une refonte graphique radicale.

J’apprécie déjà le design actuel d’Engineering Companion.

Je souhaite conserver son identité visuelle, son style moderne et ses composants existants lorsque c’est pertinent.

La priorité est l’ergonomie, pas l’ajout d’éléments décoratifs.

⸻

6. Règles fondamentales de gestion des conversations

Cette partie est particulièrement importante.

6.1. Une conversation appartient à un seul projet

Chaque nouvelle conversation doit posséder un project_id valide dès sa création.

Ce project_id représente son projet d’appartenance.

Il ne doit pas changer simplement parce que l’utilisateur change de projet actif dans l’interface.

6.2. Le projet d’une conversation est immuable

Une conversation créée dans Alpha reste dans Alpha.

Elle ne doit pas être déplacée automatiquement vers Beta.

Ne développe pas de fonctionnalité permettant de transférer librement des conversations entre projets.

Cela risquerait d’entraîner des mélanges de contexte et des problèmes de confidentialité.

6.3. L’utilisateur doit être autorisé sur le projet

Avant toute création de conversation, le backend doit vérifier que l’utilisateur connecté appartient au projet sélectionné.

L’identité doit provenir de l’authentification Keycloak vérifiée.

Le frontend ne doit pas être considéré comme une source fiable pour les autorisations.

L’utilisateur ne doit pas pouvoir créer une conversation dans un projet auquel il n’a pas accès en modifiant simplement le corps d’une requête HTTP.

6.4. Contrôle des accès aux conversations

Les contrôles d’autorisation doivent également s’appliquer à :

* La consultation d’une conversation.
* La récupération de ses messages.
* L’envoi d’un message.
* Le renommage.
* La suppression.
* La consultation de l’historique.

Vérifie systématiquement l’appartenance de la conversation à l’utilisateur et son accès actuel au projet.

Un utilisateur ne doit jamais pouvoir accéder à une conversation non autorisée simplement en connaissant son identifiant.

6.5. Isolation du contexte entre projets

Le contexte conversationnel doit rester rattaché au projet de la conversation.

Lorsqu’un utilisateur change de projet :

* L’ancienne conversation ne doit pas être réaffectée.
* Son historique ne doit pas être injecté dans une conversation du nouveau projet.
* Le nouvel orchestrateur ne doit pas recevoir des messages de l’ancien projet.
* Les autorisations applicables doivent être recalculées.

Cette isolation doit être garantie côté backend, et pas uniquement par le filtrage de la sidebar.

⸻

7. Gestion des conversations historiques

Nous avons déjà des conversations créées avant cette refonte.

Certaines sont associées à un projet.

D’autres ne possèdent aucun projet.

Je souhaite préserver les données existantes.

Conversations déjà associées à un projet

Elles doivent rester disponibles dans leur projet actuel.

Leurs messages, titres et historiques doivent être conservés.

Aucune migration destructive ne doit être effectuée.

Conversations historiques sans projet

Je ne souhaite pas les supprimer automatiquement.

Prévois une solution de récupération spécifique.

Par exemple, un espace intitulé :

Conversations non classées

Cet espace serait accessible uniquement pour retrouver les anciennes conversations sans projet.

L’utilisateur pourrait choisir explicitement leur projet de destination.

Avant d’effectuer l’affectation :

* Vérifier qu’il est propriétaire de la conversation.
* Vérifier qu’il possède les autorisations nécessaires sur le projet.
* Prévenir que cette opération fixe le projet d’appartenance.
* Ne pas transférer automatiquement des données sensibles vers un projet arbitraire.
* Empêcher les opérations incohérentes ou concurrentes.

Une fois rattachée à un projet, la conversation devient une conversation classique et son appartenance reste stable.

Cette fonctionnalité est uniquement destinée à la compatibilité avec les anciennes données.

Les nouvelles conversations ne doivent jamais passer par cet espace.

Je souhaite également que tu identifies pourquoi l’affectation actuelle des conversations sans projet ne fonctionne pas correctement et que tu corriges ce mécanisme de récupération.

⸻

8. Gestion du changement de projet

Le changement de projet doit être particulièrement robuste.

Imaginons qu’un utilisateur consulte une conversation du projet Alpha.

Il clique ensuite sur le sélecteur pour passer à Beta.

L’application doit :

1. Mettre à jour le projet actif.
2. Charger les conversations de Beta.
3. Charger les modèles autorisés pour Beta.
4. Réinitialiser les sélections qui ne sont plus valides.
5. Afficher une conversation de Beta uniquement si elle appartient réellement à ce projet.
6. Ne conserver aucun état conversationnel actif provenant d’Alpha dans l’espace Beta.

Il faut également gérer les cas où :

* Une requête réseau se termine après le changement de projet.
* L’utilisateur change rapidement plusieurs fois de projet.
* Le projet précédemment sélectionné n’est plus autorisé.
* Le Mock LMC devient temporairement inaccessible.
* Une conversation ancienne est ouverte depuis une URL directe.
* La page est rechargée.

Évite notamment qu’une réponse tardive de l’ancien projet écrase les données du nouveau projet.

Si une URL pointe vers une conversation existante, l’application doit retrouver son véritable projet et vérifier les autorisations avant de l’afficher.

⸻

9. Gestion des modèles et des agents

Conserve les mécanismes déjà implémentés.

Actuellement :

* Engineering Companion récupère les modèles autorisés depuis le Mock LMC.
* Le modèle par défaut est disponible.
* Les agents personnels sont provisionnés dans Orq.ai.
* Le backend résout l’orchestrateur correspondant à l’utilisateur et au projet.
* L’exécution des agents fonctionne.

Ces mécanismes doivent rester opérationnels après la refonte.

Modèles

Le sélecteur de modèles doit être rattaché au projet actif.

Lorsqu’on change de projet, seuls les modèles autorisés dans le nouveau projet doivent apparaître.

Conserve pour l’instant le comportement actuel :

Le modèle sélectionné dans l’interface n’est pas forcément le modèle réellement appliqué à l’agent.

Le système doit continuer à l’indiquer clairement.

N’implémente pas encore les Routing Rules ni le changement dynamique des modèles.

Orchestrateurs

Lorsqu’un message est envoyé, le backend doit continuer à :

1. Identifier l’utilisateur.
2. Vérifier le projet associé à la conversation.
3. Résoudre l’orchestrateur personnel.
4. Utiliser les credentials Orq.ai adaptés au projet.
5. Transmettre l’Identity appropriée.
6. Exécuter l’agent.

Ne remplace pas ce mécanisme par une résolution basée uniquement sur le projet actif du frontend.

Le projet enregistré sur la conversation doit rester la référence pour l’exécution.

⸻

10. Persistance de l’historique et continuité

Je souhaite conserver intégralement le fonctionnement actuel de l’historique.

Changer de projet dans la navigation ne doit jamais supprimer les conversations précédentes.

Lorsqu’un utilisateur revient sur une conversation existante, il doit retrouver ses messages.

Conserve les mécanismes actuels de gestion de previous_response_id.

En particulier, ne réutilise pas un identifiant de réponse provenant d’un autre orchestrateur.

N’implémente pas encore le transfert de contexte entre modèles.

Nous réaliserons un audit spécifique sur ce sujet ultérieurement.

Cependant, veille à ce que la nouvelle navigation ne casse pas la continuité conversationnelle actuellement disponible.

⸻

11. Actions sur les conversations

Vérifie et stabilise les fonctionnalités existantes.

Renommage

L’utilisateur doit pouvoir renommer une conversation.

Le nouveau nom doit être persisté.

L’interface doit être actualisée immédiatement ou après confirmation du backend.

Une génération automatique de titre ne doit pas écraser un renommage manuel.

Suppression

L’utilisateur doit pouvoir supprimer une conversation selon le comportement déjà prévu par l’application.

Une confirmation adaptée doit être proposée lorsque nécessaire.

Aucune conversation d’un autre projet ne doit être affectée.

Recherche et navigation

Si l’interface actuelle possède une fonctionnalité de recherche de conversations, préserve-la.

Par défaut, privilégie une recherche limitée au projet actif.

Évite de mélanger visuellement les conversations de projets différents.

⸻

12. Gestion des erreurs et états particuliers

Je souhaite améliorer la qualité des retours utilisateur.

Prévois des états spécifiques pour les situations suivantes :

Situation	Comportement attendu
Aucun projet disponible	Écran vide explicatif
Aucun projet sélectionné	Invitation à sélectionner un projet
Projet inaccessible	Message d’autorisation et retour vers un espace valide
Projet non provisionné	Indication claire de son état
Aucun modèle disponible	Message explicite
Conversation introuvable	Message clair et navigation de secours
Échec de création	Erreur visible, sans conversation fantôme
Échec de renommage	Erreur visible et état cohérent
Échec d’affectation historique	Erreur visible, sans modification partielle
Mock LMC indisponible	Message adapté avec possibilité de réessayer
Orq.ai indisponible	Erreur d’exécution compréhensible

Ne masque pas les erreurs backend.

Ne présente pas une opération comme réussie si elle a échoué.

Ne révèle jamais de tokens, de credentials ou de détails sensibles dans l’interface.

⸻

13. Contraintes techniques importantes

Avant toute modification, analyse précisément la codebase existante.

Identifie notamment :

* Les composants de sélection des projets.
* La sidebar de conversations.
* Les mécanismes de création des threads.
* Les endpoints de création et de modification.
* La structure des conversations en base.
* Les adaptateurs Redis ou autres systèmes de persistance.
* Les contrôles d’autorisation existants.
* Les mécanismes de chargement de l’historique.
* Les fonctionnalités de renommage.
* Les références aux dossiers et à l’affectation des projets.

Privilégie une évolution cohérente de l’architecture actuelle.

Évite de créer un second système de conversations en parallèle.

Conserve les contrats API existants lorsqu’ils restent pertinents.

Si certains endpoints doivent évoluer, assure leur cohérence et leur compatibilité avec les consommateurs existants.

Le backend doit devenir responsable de la création d’une conversation directement dans un projet autorisé.

Il ne doit pas dépendre de deux actions successives du frontend pour garantir l’association au projet.

Prévois les validations nécessaires pour empêcher les créations sans projet dans les nouveaux parcours, tout en conservant un accès contrôlé aux conversations historiques non classées.

Ne supprime aucune donnée existante.

N’introduis pas de migration destructive.

⸻

14. Périmètre strict de cette mission

Cette mission concerne exclusivement :

La navigation par projet et la gestion des conversations dans Engineering Companion.

Ne modifie pas :

* Le provisioning du Mock LMC.
* La création des projets Orq.ai.
* La création des Identities.
* La gestion des budgets.
* La création des modèles.
* Les agents et leurs configurations.
* Les prompts provisionnés.
* Les connecteurs MCP.
* Les clés API existantes.
* Les Routing Rules.
* La logique de changement dynamique des modèles.

Ne réalise pas de refonte inutile du système d’authentification.

Ne change pas la stratégie d’orchestration.

Les traces et l’exécution Orq.ai fonctionnent déjà : il faut préserver ce résultat.

⸻

15. Vérifications et tests

Je souhaite que tu réalises les tests locaux nécessaires.

Les tests doivent couvrir au minimum les scénarios suivants.

Scénario 1 — Sélection initiale

Un utilisateur se connecte.

Il voit uniquement ses projets autorisés.

Il sélectionne Alpha.

L’espace de travail Alpha s’ouvre.

Scénario 2 — Création de conversation

L’utilisateur est dans Alpha.

Il clique sur New Chat.

La conversation est créée directement avec le project_id d’Alpha.

Il n’a aucune affectation manuelle à effectuer.

Il peut immédiatement envoyer un message, sous réserve que les ressources d’exécution soient disponibles.

Scénario 3 — Changement de projet

L’utilisateur passe d’Alpha à Beta.

Les conversations d’Alpha disparaissent de la sidebar active.

Celles de Beta apparaissent.

Aucune conversation n’est déplacée.

Scénario 4 — Retour au projet précédent

L’utilisateur revient dans Alpha.

Il retrouve ses conversations et leurs historiques.

Scénario 5 — Renommage

L’utilisateur renomme une conversation.

Le nom est correctement conservé après rechargement de la page.

Scénario 6 — Conversations historiques

Une ancienne conversation sans projet reste récupérable.

L’utilisateur peut explicitement l’affecter à un projet autorisé.

Elle devient ensuite disponible dans ce projet.

Scénario 7 — Sécurité

Un utilisateur tente de créer ou consulter une conversation dans un projet non autorisé.

Le backend refuse l’opération.

Le simple changement d’un identifiant dans une requête ne doit pas permettre de contourner les autorisations.

Scénario 8 — Concurrence

L’utilisateur change rapidement de projet pendant que des requêtes sont en cours.

Les conversations et modèles affichés doivent toujours correspondre au projet réellement actif.

Scénario 9 — Régression du chat

Une conversation créée dans un projet valide doit continuer à utiliser la logique existante de résolution de l’orchestrateur personnel.

Aucune régression sur les modèles, les Identities ou la gestion des credentials.

Utilise des mocks pour les tests automatisés d’exécution.

Ne déclenche pas automatiquement de conversations réelles vers Orq.ai ou les serveurs MCP.

Je réaliserai moi-même les tests fonctionnels réels.

⸻

16. Résultat attendu

À la fin, je veux une expérience Engineering Companion dans laquelle :

1. Je me connecte.
2. Je sélectionne un projet.
3. Je retrouve les conversations de ce projet.
4. Je crée une conversation directement dans ce projet.
5. Je peux immédiatement discuter avec mon orchestrateur personnel.
6. Je peux renommer et gérer mes conversations.
7. Je peux changer de projet simplement.
8. Je retrouve les conversations et modèles du nouveau projet.
9. Je peux revenir dans le projet précédent sans perdre mon historique.
10. Je ne rencontre plus le problème de conversation sans projet nécessitant une affectation manuelle.

Je souhaite une interface moderne, élégante, ergonomique et cohérente avec le design existant.

La nouvelle organisation doit être pensée comme un véritable environnement de travail multiprojet.

Méthode de travail

Procède dans cet ordre :

Étape A — Analyse

Audite les composants, endpoints, modèles de données et mécanismes de navigation existants.

Identifie les causes du dysfonctionnement actuel des affectations.

Étape B — Backend

Garantis la création atomique des conversations dans un projet autorisé et l’isolation des données.

Préserve la compatibilité avec les conversations historiques.

Étape C — Frontend

Implémente la nouvelle navigation Project-first, la sidebar dépendante du projet et les parcours de création.

Étape D — Stabilisation

Corrige les problèmes de renommage, de récupération des conversations historiques, de concurrence et de gestion des erreurs.

Étape E — Vérification

Exécute les tests locaux et les vérifications nécessaires.

Relance Engineering Companion dans l’environnement local existant.

Ne détruis pas les volumes ou bases de données.

Étape F — Compte rendu

Explique :

* Les problèmes identifiés.
* Les décisions techniques prises.
* Les modifications backend.
* Les modifications frontend.
* Les fichiers principaux modifiés.
* Les tests réalisés.
* Les éventuelles limites restantes.
* La procédure de validation manuelle.

Une fois terminé, arrête-toi.

Je souhaite vérifier personnellement la nouvelle navigation et la création des conversations avant de passer à l’étape suivante.