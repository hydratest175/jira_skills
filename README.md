Nous avons confirmé qu’une condition CEL sur project ne transforme pas une Routing Rule globale en ressource nativement limitée à un projet Orq.ai.

Cependant, notre architecture prévoit que les utilisateurs finaux n’accèdent jamais directement à Orq.ai. Toutes les requêtes passent par le backend Engineering Companion, qui est responsable de l’authentification, de l’autorisation des utilisateurs et de la sélection des modèles.

Je souhaite donc continuer à étudier l’utilisation de Routing Rules globales, mais avec une stratégie de sécurité robuste.

Avant toute modification, analyse l’architecture existante et propose une solution répondant aux exigences suivantes.

1. Contrôle des autorisations dans Engineering Companion

Le backend doit être l’unique autorité pour :

* Identifier l’utilisateur via Keycloak.
* Identifier son projet LMC actif.
* Vérifier son appartenance au projet.
* Vérifier les modèles autorisés pour cet utilisateur dans ce projet.
* Résoudre les références Orq.ai depuis les mappings persistés.
* Construire les métadonnées de routage.

Le frontend ne doit jamais pouvoir fournir directement une Agent Key, un modèle Orq arbitraire, une expression CEL ou une configuration de routage libre.

2. Isolation des projets Orq.ai

Étudie l’utilisation d’une API Key Orq.ai de service par projet LMC/Orq.ai, avec des permissions minimales et sans accès direct depuis le frontend.

Vérifie comment intégrer cette stratégie à la résolution des credentials déjà présente dans Engineering Companion.

La Management Key doit rester exclusivement dédiée aux opérations de provisioning et d’administration.

3. Conditions des Routing Rules

Propose une stratégie CEL restrictive combinant, lorsque les données sont disponibles :

* L’identifiant réel du projet Orq.ai.
* La référence du modèle ou de l’agent concerné.
* Un marqueur spécifique aux requêtes Engineering Companion.
* Le modèle cible demandé et autorisé.

Explique précisément l’intérêt et les limites de chaque condition.

Je souhaite notamment comprendre si un marqueur backend de type nonce apporte une réelle protection supplémentaire ou s’il constitue simplement un filtre de routage.

Vérifie quels champs sont réellement évalués par les Routing Rules et quelles métadonnées sont effectivement propagées aux inférences internes des Managed Agents.

Ne suppose pas que les métadonnées transmises à l’orchestrateur sont automatiquement propagées à ses sous-agents.

4. Risques liés aux règles globales

Analyse :

* Les collisions avec les autres Routing Rules du workspace.
* La gestion des priorités.
* Le risque d’affecter une autre application.
* Les erreurs de configuration CEL.
* Les interactions avec les modèles des sous-agents Jira/GitLab.
* Les conséquences en termes de coûts, budgets et traçabilité.
* Les scénarios dans lesquels une règle globale pourrait être déclenchée involontairement.

Propose des protections réalistes.

5. Préparation du POC

Définis un protocole permettant de démontrer qu’une Routing Rule peut modifier le modèle d’inférence interne d’un orchestrateur Engineering Companion sans remplacer son agent, ses instructions, ses outils MCP ni son équipe de sous-agents.

Le POC devra utiliser uniquement des ressources de test explicitement identifiées et vérifier l’absence d’impact sur les autres projets et applications.

N’utilise pas de ressources opérationnelles pour une expérimentation susceptible d’affecter d’autres utilisateurs.

6. Contraintes

* Ne modifie pas Engineering Companion ou Mock LMC pour le moment.
* Ne crée et n’active aucune nouvelle Routing Rule sans mon accord.
* Ne modifie aucune règle existante.
* Ne révèle aucun token, secret ou credential dans les logs.
* Ne considère pas les conditions CEL comme des mécanismes d’authentification ou d’autorisation.
* Distingue systématiquement les comportements documentés, les comportements observés et les hypothèses à tester.

Résultat attendu

Je veux une proposition d’architecture sécurisée et un protocole de POC précis.

L’objectif est de déterminer si nous pouvons utiliser des Routing Rules globales avec un contrôle d’accès centralisé dans Engineering Companion, sans compromettre l’isolation entre projets.

Ne passe pas à l’implémentation avant cette analyse.