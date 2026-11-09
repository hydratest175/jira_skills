Mission — POC Orq.ai : Multi-model Agent Versioning & Conversation Continuity

1. Contexte

Nous développons Engineering Companion, une application utilisant les Managed Agents Orq.ai.

Notre architecture actuelle repose sur :

* Un projet Orq.ai par projet LMC.
* Un orchestrateur Engineering Companion personnel par utilisateur et par projet.
* Deux sous-agents personnels : Jira Specialist et GitLab Specialist.
* Des outils MCP associés aux spécialistes.
* Des modèles, prompts, Identities et budgets provisionnés depuis le Mock LMC.
* Un provisioning persistant et idempotent.
* Une application Engineering Companion fonctionnelle avec une navigation Project-first et des conversations persistantes.

Nous souhaitons permettre à un utilisateur de changer de modèle pendant une conversation.

Nous avons précédemment étudié les Routing Rules.

Le POC a démontré que, sur notre instance Orq.ai Thales actuelle, elles peuvent router des appels LLM directs, mais ne modifient pas le modèle d’inférence interne de nos Managed Agents.

Nous souhaitons désormais tester une nouvelle architecture reposant sur le versioning natif des Managed Agents.

Cette mission est un POC technique isolé.

Ne modifie pas Engineering Companion ni le Mock LMC.

⸻

2. Nouvelle architecture à étudier

Nous souhaitons conserver un seul orchestrateur logique par couple utilisateur/projet.

Cependant, cet orchestrateur disposerait de plusieurs versions publiées, chacune utilisant un modèle différent.

Exemple conceptuel :

Projet Alpha
│
└── User A
    │
    ├── Engineering Companion
    │   │
    │   ├── Version A → Mistral Small
    │   ├── Version B → Mistral Medium
    │   └── Version C → GPT
    │
    ├── Jira Specialist
    │   └── Modèle fixe
    │
    └── GitLab Specialist
        └── Modèle fixe

IMPORTANT :

Les lettres A, B et C représentent des versions distinctes. Les véritables numéros devront être récupérés depuis Orq.ai.

Nous ne voulons pas supposer que les versions seront nécessairement 1.0.0, 1.1.0 et 1.2.0.

Principe

Le Mock LMC provisionnerait à terme toutes les versions nécessaires à l’avance.

Lorsque l’utilisateur sélectionne un modèle dans Engineering Companion, le backend sélectionnerait directement la version correspondante.

Exemple :

Mistral Small
    → agent/ec-user-a@VERSION_A
Mistral Medium
    → agent/ec-user-a@VERSION_B
GPT
    → agent/ec-user-a@VERSION_C

Aucun PATCH ne serait effectué lors du changement de modèle dans une conversation.

Les PATCH seraient exclusivement utilisés lors du provisioning ou de la synchronisation des configurations depuis le LMC.

Les anciennes versions seraient invoquées directement par leur référence explicite.

L’objectif est de permettre plusieurs conversations utilisant différents modèles sans modifier continuellement la configuration de l’agent.

⸻

3. Décision concernant les sous-agents

Nous avons également retenu une décision architecturale importante.

Seul le modèle de l’orchestrateur doit changer selon la sélection de l’utilisateur.

Jira Specialist et GitLab Specialist doivent conserver leurs propres modèles fixes.

Exemple :

Engineering Companion @Version A
    Modèle : Mistral Small
         │
         ├── Jira Specialist
         │     Modèle : Mistral Small
         │
         └── GitLab Specialist
               Modèle : Mistral Small
Engineering Companion @Version B
    Modèle : Mistral Medium
         │
         ├── Jira Specialist
         │     Modèle : Mistral Small
         │
         └── GitLab Specialist
               Modèle : Mistral Small

Les deux versions de l’orchestrateur doivent référencer les mêmes spécialistes.

Nous ne souhaitons pas créer une copie des spécialistes pour chaque modèle de l’orchestrateur.

L’objectif est de conserver trois agents logiques :

1. Engineering Companion.
2. Jira Specialist.
3. GitLab Specialist.

Le nombre de versions de l’orchestrateur peut augmenter, mais celui des spécialistes doit rester stable.

Ce comportement doit être démontré expérimentalement.

⸻

4. Objectifs du POC

Nous voulons répondre à six questions principales.

Question 1 — Versioning

Peut-on publier plusieurs versions d’un Managed Agent utilisant des modèles distincts ?

Question 2 — Invocation

Peut-on appeler librement une ancienne version ou une nouvelle version sans modifier la configuration de l’agent ?

Question 3 — Concurrence

Peut-on exécuter simultanément deux conversations utilisant deux versions différentes du même orchestrateur, sans interférence ?

Question 4 — Sous-agents

Les différentes versions peuvent-elles utiliser les mêmes spécialistes Jira et GitLab, avec leurs modèles fixes ?

Question 5 — Continuité conversationnelle

Une conversation peut-elle passer de la version A à la version B puis revenir à la version A sans perdre les informations importantes des échanges précédents ?

Question 6 — Maintenance

Comment maintenir les versions à jour lorsqu’on modifie les prompts, les outils, les Skills ou les instructions de l’orchestrateur ?

⸻

5. Environnement de travail

Commence par examiner les POC existants dans LEA_Workspace.

Notamment :

LEA_Workspace/routing-rules-poc

Et, s’il existe déjà :

LEA_Workspace/agent-model-switch-poc

Réutilise un environnement de POC existant uniquement s’il est adapté et ne contient pas de ressources à préserver.

Sinon, crée :

LEA_Workspace/agent-versioning-poc

Tu peux consulter en lecture seule :

* LEA_Workspace/mock-lmc-orq-poc
* LEA_Workspace/use-case-engineering-companion
* LEA_Workspace/use-case-engineering-companion/thales_orq_provisioning

Adapte les chemins à l’arborescence réelle.

Réutilise le SDK Orq.ai et les configurations réseau déjà disponibles.

Software Companion ne dispose pas d’un accès Internet public. Inspecte donc le SDK installé et les implémentations locales plutôt que de dépendre de documentation en ligne.

Ne modifie aucun dépôt applicatif existant.

⸻

6. Phase 1 — Investigation du SDK et de l’API

Avant les tests, inspecte les mécanismes disponibles pour :

* Créer un Managed Agent.
* Modifier son modèle.
* Publier une nouvelle version.
* Récupérer son historique de versions.
* Récupérer une version spécifique.
* Invoquer une version spécifique.
* Conserver les références aux sous-agents.
* Utiliser previous_response_id.

La documentation Orq.ai présente notamment :

PATCH /v2/agents/{agent_key}

Avec une gestion de version pouvant utiliser :

versionIncrement

Et une invocation de version via :

agent/<agent_key>@<version>

Vérifie les signatures et comportements réellement disponibles sur notre instance Thales.

Ne suppose pas que le SDK installé utilise exactement les mêmes paramètres que la documentation publique.

Vérifications spécifiques

Détermine si :

1. Chaque PATCH crée effectivement une nouvelle version publiée.
2. Les versions précédentes restent accessibles.
3. Les snapshots contiennent le modèle, les instructions, les outils et les sous-agents.
4. Les versions peuvent être invoquées indépendamment.
5. Une référence @version correspond réellement à une configuration figée.
6. Une mise à jour ultérieure de latest n’affecte pas une ancienne version épinglée.

Si l’un de ces comportements n’est pas supporté, documente-le précisément.

⸻

7. Phase 2 — Créer les agents de test

Utilise exclusivement un projet Orq.ai dédié au POC.

Ne modifie aucun projet actuellement utilisé par Engineering Companion.

Agents à provisionner

Créer trois agents :

Engineering Companion POC

Orchestrateur principal.

Il doit posséder :

* Une clé fonctionnelle stable.
* Un system prompt identifiable.
* Un modèle initial.
* Une équipe contenant Jira Specialist et GitLab Specialist.
* Des paramètres d’exécution simples.
* Un outil natif inoffensif, si disponible.

Jira Specialist POC

Sous-agent simulant Jira.

Il doit :

* Utiliser un modèle fixe.
* Posséder un prompt clairement identifiable.
* Pouvoir renvoyer des informations fictives déterministes.

GitLab Specialist POC

Sous-agent simulant GitLab.

Il doit :

* Utiliser un modèle fixe.
* Posséder un prompt clairement identifiable.
* Pouvoir renvoyer des informations fictives déterministes.

Ne connecte aucun serveur MCP réel.

Ne réalise aucun appel vers les véritables données Jira ou GitLab.

⸻

8. Phase 3 — Publier plusieurs versions de l’orchestrateur

Utilise deux modèles réellement distincts et déjà disponibles dans notre environnement.

Par exemple :

* Mistral Small.
* Mistral Medium.

Si un troisième modèle est disponible, nous pourrons étendre l’expérience.

Deux modèles suffisent pour valider le mécanisme principal.

Version A

Créer et publier Engineering Companion avec le modèle A.

Récupérer :

* Agent Key.
* Agent ID.
* Numéro exact de version.
* Référence du modèle.
* Configuration des instructions.
* Références des spécialistes.

Version B

Effectuer un PATCH pour utiliser le modèle B.

Publier la nouvelle version selon les mécanismes réellement supportés.

Récupérer les mêmes informations.

Vérification des snapshots

Comparer les configurations des deux versions.

Nous voulons que seule la configuration nécessaire au changement de modèle diffère.

Vérifier notamment :

* Même Agent Key.
* Même system prompt.
* Mêmes instructions.
* Mêmes outils.
* Mêmes spécialistes.
* Modèle différent.

Si d’autres paramètres ont changé, expliquer pourquoi.

Ne réalise aucun PATCH supplémentaire pendant les tests d’exécution.

⸻

9. Phase 4 — Vérifier l’invocation des versions

C’est notre premier test décisif.

Appeler explicitement la version A.

Exemple conceptuel :

{
  "model": "agent/ec-poc@VERSION_A",
  "input": "Présente ton rôle et utilise tes spécialistes."
}

Vérifier dans Orq Studio :

* La version réellement exécutée.
* Le modèle utilisé par l’orchestrateur.
* L’application de ses instructions.
* L’appel aux spécialistes.
* Les modèles utilisés par les spécialistes.

Effectuer ensuite exactement le même test avec la version B.

Résultat attendu

Version A :

* Orchestrateur → modèle A.
* Jira Specialist → modèle fixe.
* GitLab Specialist → modèle fixe.

Version B :

* Orchestrateur → modèle B.
* Jira Specialist → même modèle fixe.
* GitLab Specialist → même modèle fixe.

Les deux exécutions doivent utiliser le même Agent Key.

Aucun PATCH ne doit être nécessaire entre les deux appels.

⸻

10. Phase 5 — Tester la continuité conversationnelle

C’est la partie la plus importante du POC.

Nous voulons déterminer si le versioning permet réellement de changer de modèle tout en conservant le contexte.

Test A — Conversation sans changement de version

Démarrer une conversation avec la version A.

Message 1 :

« Je travaille sur le projet Phoenix. Nous avons trois risques : une API en retard, un pipeline instable et une dépendance externe bloquante. »

Enregistrer le response_id.

Message 2 :

« Quels sont les trois risques dont nous avons parlé ? »

Utiliser previous_response_id.

Vérifier que la réponse est correcte.

Ce test constitue notre référence.

Test B — Passage de la version A à la version B

Démarrer une nouvelle conversation avec la version A.

Fournir plusieurs informations précises.

Faire intervenir un spécialiste de test.

Enregistrer le dernier response_id.

Passer ensuite à la version B en utilisant le même Agent Key et une référence @version différente.

Transmettre le previous_response_id obtenu avec la version A.

Demander à l’orchestrateur de restituer :

* Les informations précédemment fournies.
* Les décisions déjà prises.
* Les résultats importants du spécialiste.
* Le contexte général de la conversation.

Nous voulons vérifier :

1. Si l’API accepte previous_response_id.
2. Si la version B utilise réellement le modèle B.
3. Si le contexte reste accessible.
4. Si les résultats des spécialistes sont conservés.
5. Si des informations sont perdues.
6. Si le comportement agentique reste intact.

Une réponse HTTP 200 ne suffit pas à considérer le test comme réussi.

Test C — Retour à la version A

Continuer la même conversation :

Version A → Version B → Version A.

Utiliser le response_id du dernier tour effectué sous B pour tester la continuité vers A.

Ne réutilise pas artificiellement un ancien response_id de A qui ignorerait les échanges intermédiaires.

Vérifier que les informations ajoutées pendant la période B restent disponibles.

Test D — Reconstruction du contexte

Si la continuité via previous_response_id ne fonctionne pas correctement entre versions, tester une alternative.

Reconstituer le contexte depuis les messages persistés du POC.

Transmettre explicitement l’historique utile à la nouvelle version.

Comparer le résultat avec le test précédent.

Si nécessaire, tester également un checkpoint structuré contenant les faits importants, décisions et résultats d’outils.

Ne développe pas une infrastructure complète de mémoire conversationnelle : une expérimentation ciblée suffit.

Distinction obligatoire

Dans les conclusions, distingue :

Continuité technique : l’API accepte-t-elle la chaîne de réponses entre versions ?

Continuité fonctionnelle : le nouveau modèle dispose-t-il réellement des informations nécessaires pour poursuivre ?

Continuité exhaustive : les détails et résultats d’outils sont-ils intégralement conservés ?

Ces trois niveaux ne doivent pas être confondus.

⸻

11. Phase 6 — Tester les conversations concurrentes

Imaginons deux conversations ouvertes par le même utilisateur.

Conversation 1 :

Mistral Small, via version A.

Conversation 2 :

Mistral Medium, via version B.

Les deux conversations utilisent le même Agent Key, mais des versions différentes.

Tests attendus

Démarrer les deux conversations indépendamment.

Leur fournir des informations distinctes.

Exemple :

Conversation A :
« Mon projet s’appelle Phoenix. »

Conversation B :
« Mon projet s’appelle Orion. »

Effectuer des requêtes simultanées.

Vérifier :

* Que chaque exécution utilise le bon modèle.
* Que chaque conversation conserve son propre historique.
* Qu’aucune information de Phoenix n’apparaît dans Orion par contamination du contexte.
* Que les sous-agents restent disponibles.
* Qu’aucun PATCH n’est effectué pendant l’exécution.
* Que l’évolution de latest n’affecte pas les appels épinglés sur une version.

Le test doit être réellement concurrent si l’environnement le permet.

Ne considère pas deux exécutions successives comme une preuve de compatibilité concurrente.

⸻

12. Phase 7 — Tester les mises à jour et la maintenance

C’est un point architectural essentiel.

Nous souhaitons utiliser les versions pour proposer différents modèles.

Mais Orq.ai utilise également les versions pour conserver l’historique des modifications des agents.

Ces deux usages peuvent entrer en conflit.

Exemple

Nous avons :

Version A → Mistral Small
Version B → Mistral Medium

Le Project Manager décide ensuite de modifier le prompt Engineering Companion.

Nous voulons que cette amélioration soit disponible avec les deux modèles.

Or, les anciennes versions publiées sont des snapshots.

Une nouvelle publication ne met pas nécessairement à jour les snapshots précédents.

Étude demandée

Détermine comment nous pourrions maintenir une configuration commune à toutes les variantes de modèles.

Étudie notamment :

* La publication d’une nouvelle version pour chaque modèle après une modification commune.
* La conservation des versions précédentes.
* La récupération des véritables numéros de versions.
* La mise à jour des mappings modèle → version.
* Les conversations utilisant encore d’anciennes versions.
* La gestion des modèles retirés des autorisations.
* L’évolution future des Skills EAL et des outils.
* La compatibilité des références aux spécialistes.

Ne développe pas encore cette synchronisation dans le Mock LMC.

Je veux une proposition de stratégie.

Point important

Nous ne devons jamais supposer :

Version 1.0.0 = Mistral Small pour toujours

Une version représente un snapshot de configuration.

Le Mock LMC devra conserver une correspondance explicite entre le modèle autorisé et la version actuellement retenue pour ce modèle.

Par exemple :

Project Alpha / User A
Mistral Small
    → agent_key : ec-user-a
    → version   : 2.1.0
Mistral Medium
    → agent_key : ec-user-a
    → version   : 2.2.0

Ces numéros sont illustratifs.

Il faudra utiliser les versions réellement publiées.

⸻

13. Phase 8 — Vérifier la stabilité des spécialistes

Nous voulons que Jira Specialist et GitLab Specialist soient indépendants de la sélection du modèle de l’orchestrateur.

Cependant, leurs propres configurations peuvent évoluer.

Il faut donc déterminer comment une version publiée d’Engineering Companion référence ses spécialistes.

Questions à résoudre :

1. La version de l’orchestrateur conserve-t-elle uniquement les Agent Keys des spécialistes ?
2. Peut-elle référencer une version spécifique d’un spécialiste ?
3. Si nous mettons à jour Jira Specialist, les anciennes versions de l’orchestrateur utilisent-elles automatiquement sa nouvelle configuration ?
4. Une mise à jour des spécialistes peut-elle provoquer une incompatibilité avec une ancienne version de l’orchestrateur ?
5. Quelle stratégie de versioning recommandes-tu pour conserver un comportement prévisible ?

Ces questions doivent être vérifiées dans le SDK et, lorsque c’est possible, expérimentalement.

Ne suppose pas que les sous-agents sont automatiquement figés avec le snapshot de l’orchestrateur.

⸻

14. Sécurité et isolation

Toutes les expérimentations doivent être réalisées dans un environnement isolé.

Ne modifie pas :

* Engineering Companion.
* Mock LMC.
* Les projets Orq.ai opérationnels.
* Les orchestrateurs personnels existants.
* Les sous-agents Jira/GitLab existants.
* Les Routing Rules existantes.
* Les configurations de modèles opérationnelles.

Aucune Management Key ne doit être utilisée pour les inférences.

Les secrets ne doivent jamais apparaître dans les logs ou les rapports.

N’utilise aucune donnée professionnelle réelle pour tester la continuité.

Le versioning ne doit pas être considéré comme une frontière d’autorisation.

Dans l’architecture cible, les modèles restent autorisés par le LMC, et Engineering Companion devra vérifier ces autorisations côté backend avant de résoudre la version correspondante.

⸻

15. Nettoyage

À la fin :

* Arrêter les exécutions.
* Conserver les références de traces utiles.
* Nettoyer uniquement les ressources temporaires appartenant au POC.
* Ne supprimer aucune ressource préexistante.
* Ne pas forcer la suppression d’un projet si Orq.ai la refuse en raison de traces.
* Documenter les ressources temporaires éventuellement conservées.

Ne modifie aucune règle de routage.

⸻

16. Rapport final attendu

Je souhaite un rapport technique suffisamment détaillé pour décider si cette architecture est viable.

A. Versioning

Peut-on conserver un seul Agent Key avec plusieurs versions utilisant différents modèles ?

B. Exécution

Peut-on invoquer indépendamment ces versions sans PATCH à chaque changement ?

C. Continuité

Que se passe-t-il lorsqu’une conversation passe de A à B puis revient à A ?

Le previous_response_id permet-il de conserver le contexte ?

Si non, quelle alternative fonctionne le mieux ?

D. Concurrence

Deux conversations peuvent-elles utiliser deux versions différentes simultanément sans interférence ?

E. Sous-agents

Les spécialistes Jira et GitLab peuvent-ils rester communs et conserver leur propre modèle ?

F. Maintenance

Comment maintenir les versions cohérentes lorsqu’on modifie le prompt, les outils ou les Skills ?

G. Comparaison

Compare les approches suivantes :

Architecture	Agents logiques	Continuité	Concurrence	Maintenance
Un agent avec PATCH runtime	Faible	À mesurer	À risque	Moyenne
Un agent avec versions épinglées	Faible	À mesurer	À mesurer	À étudier
Un agent distinct par modèle	Plus élevé	À reconstruire	Bonne	Plus lourde
Un agent avec Routing Rules	Faible	Non démontrée	Non démontrée	Non retenue actuellement

H. Recommandation

Je veux une conclusion explicite :

VALIDÉ — L’approche est compatible avec nos exigences.

PARTIELLEMENT VALIDÉ — Elle fonctionne, mais nécessite des mécanismes supplémentaires.

INVALIDÉ — Elle ne répond pas à nos besoins.

INDÉTERMINÉ — Les tests ne permettent pas de conclure.

Pour chaque conclusion importante, indique les traces, configurations ou réponses API qui la justifient.

Ne présente pas comme validée une fonctionnalité uniquement documentée.

⸻

17. Consignes finales

Ce POC doit se concentrer sur une seule décision architecturale :

Peut-on utiliser plusieurs versions publiées d’un même Managed Agent comme variantes de modèles, tout en conservant deux spécialistes communs et une continuité conversationnelle satisfaisante ?

Les tests les plus importants sont :

1. L’invocation de plusieurs versions sans PATCH runtime.
2. La concurrence entre versions.
3. La continuité de conversation A → B → A.
4. La stabilité des spécialistes Jira et GitLab.
5. La maintenance des variantes lors d’une évolution du prompt.

Tu peux exécuter les tests réels sur les ressources temporaires isolées de ce POC.

Ne lance aucune modification sur les applications opérationnelles.

N’implémente pas encore cette architecture dans Engineering Companion ou le Mock LMC.

À la fin, fournis les résultats détaillés et une recommandation.

Nous déciderons ensuite ensemble si cette stratégie doit devenir notre architecture cible.