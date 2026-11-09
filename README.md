Mission — Implémenter le changement dynamique de modèle par versioning des Managed Agents Orq.ai

1. Contexte et objectif

Nous avons terminé les POC concernant le changement dynamique de modèle des Managed Agents Orq.ai.

Les Routing Rules ont été invalidées pour notre besoin.

En revanche, le POC de versioning a confirmé qu’il est possible d’utiliser plusieurs versions d’un même Managed Agent, chacune associée à un modèle différent, et de les invoquer indépendamment.

Nous voulons maintenant implémenter cette architecture dans notre Mock LMC et notre Engineering Companion.

Il ne s’agit plus de réaliser une étude ou un POC isolé.

Je veux une implémentation fonctionnelle de bout en bout, en conservant les fonctionnalités existantes.

Important : hors périmètre

Ne travaille pas sur les Skills, la marketplace ou l’EAL.

Nous traiterons ce sujet ultérieurement.

Ne mets pas non plus en place de Routing Rules.

⸻

2. Architecture cible

Nous conservons :

* Un projet Orq.ai par projet LMC.
* Un orchestrateur Engineering Companion personnel par utilisateur et par projet.
* Un Jira Specialist personnel par utilisateur et par projet.
* Un GitLab Specialist personnel par utilisateur et par projet.
* Des spécialistes communs à toutes les versions de l’orchestrateur personnel.
* Des Identities Orq par utilisateur.
* Les budgets projet et utilisateur.
* Les credentials Jira/GitLab propres à chaque utilisateur.
* Le provisioning persistant déclenché par le Project Manager depuis le LMC.

Nouveau fonctionnement

Chaque orchestrateur personnel possède plusieurs versions publiées.

Chaque version correspond à un modèle autorisé dans le projet LMC.

Exemple :

Projet LMC : Alpha
│
└── User A
    │
    ├── Engineering Companion
    │   │
    │   ├── v1.1.0 → Mistral Small
    │   ├── v1.2.0 → Mistral Medium
    │   └── v1.3.0 → Gemma
    │
    ├── Jira Specialist
    │
    └── GitLab Specialist

Il s’agit d’un seul orchestrateur logique, avec une seule Agent Key et plusieurs versions.

Ne crée pas un nouvel orchestrateur pour chaque modèle.

Les modèles des spécialistes restent fixes et indépendants du modèle choisi pour l’orchestrateur.

Exécution

Si l’utilisateur sélectionne Mistral Small :

agent/<personal-orchestrator-key>@1.1.0

S’il sélectionne Mistral Medium :

agent/<personal-orchestrator-key>@1.2.0

S’il sélectionne Gemma :

agent/<personal-orchestrator-key>@1.3.0

Les numéros sont des exemples.

Utilise toujours les versions réellement publiées et retournées par Orq.ai.

Aucun PATCH ne doit être effectué lors d’un simple changement de modèle dans le chat.

⸻

3. Commencer par examiner le code existant

Les principaux projets sont :

Mock LMC

LEA_Workspace/mock-lmc-orq-poc

Backend FastAPI, interface React/Vite et persistance SQLite.

Engineering Companion

LEA_Workspace/use-case-engineering-companion

Identifie le frontend réellement utilisé ainsi que les routes backend responsables :

* De la sélection du projet.
* De la sélection du modèle.
* De l’autorisation des utilisateurs.
* De la résolution des orchestrateurs.
* De l’exécution des agents Orq.
* De la persistance des conversations.

POC validé

LEA_Workspace/agent-versioning-poc

Lis impérativement :

* REPORT.md
* SUMMARY.json
* report-final.json
* report-v6.json

Examine également les scripts Python du POC.

Réutilise les méthodes qui ont réellement fonctionné.

Ne réimplémente pas le versioning sur la base d’hypothèses.

Contraintes

Avant toute modification, comprends l’architecture existante.

Ne réécris pas les applications.

Préserve les API et composants qui fonctionnent déjà lorsque c’est possible.

⸻

4. Première partie — Implémentation dans Mock LMC

4.1. Adapter le provisioning des orchestrateurs

Actuellement, le Mock LMC sait déjà provisionner les ressources Orq.ai d’un projet.

Nous voulons conserver ce fonctionnement.

En revanche, lorsqu’un utilisateur dispose de plusieurs modèles autorisés, le provisioning doit créer les versions correspondantes de son orchestrateur personnel.

Exemple :

Un projet autorise :

* Mistral Small.
* Mistral Medium.
* Gemma.

Lors du provisioning :

1. Vérifier ou créer l’orchestrateur personnel.
2. Publier une configuration avec Mistral Small.
3. Publier une autre version avec Mistral Medium.
4. Publier une troisième version avec Gemma.
5. Vérifier que les versions existent et utilisent leurs modèles respectifs.
6. Conserver les références retournées par Orq.
7. Préserver les associations aux spécialistes personnels.

Les trois versions doivent partager :

* La même Agent Key.
* Les mêmes instructions d’orchestration.
* Les mêmes outils.
* Les mêmes références aux spécialistes Jira/GitLab.
* La même configuration commune, sauf les paramètres spécifiques au modèle.

Les versions ne doivent différer que par les paramètres explicitement liés au modèle.

Idempotence

Le provisioning doit rester idempotent.

Si je clique à nouveau sur « Provisionner » sans modifier la configuration :

Aucune nouvelle version inutile ne doit être créée.

Si un modèle autorisé est ajouté, créer uniquement les versions manquantes.

Si un modèle est retiré, désactiver son mapping pour les nouvelles exécutions sans supprimer brutalement les anciennes conversations.

Si la configuration commune change, publier les nouvelles versions nécessaires et mettre à jour les mappings.

Ne jamais modifier silencieusement une version utilisée par une conversation existante.

⸻

5. Persistance des mappings modèle → version

C’est une partie essentielle.

Le POC a montré que les endpoints permettant de récupérer l’historique complet des versions n’étaient pas disponibles dans notre environnement.

Nous devons donc gérer nous-mêmes les correspondances.

Utiliser SQLite dans le Mock LMC.

Créer une structure persistante permettant de retrouver, pour un utilisateur donné :

LMC Project ID
       +
Keycloak User ID
       +
LMC Model Configuration ID
       ↓
Orq Project ID
       +
Personal Orchestrator Key
       +
Published Agent Version

Exemple conceptuel :

Projet	Utilisateur	Modèle	Agent Key	Version
Alpha	User A	Small	ec-user-a	1.1.0
Alpha	User A	Medium	ec-user-a	1.2.0
Alpha	User A	Gemma	ec-user-a	1.3.0

Cette table doit être persistante et cohérente avec l’état réel d’Orq.ai.

Prévoir notamment :

* Une contrainte d’unicité adaptée.
* La référence exacte du modèle Orq.
* L’état du provisioning.
* Une empreinte de configuration permettant de détecter les changements.
* La version effectivement publiée.
* Une date de mise à jour.

Le mapping doit être propre à chaque couple utilisateur/projet.

Deux utilisateurs ne doivent pas partager accidentellement le même orchestrateur personnel.

Gestion des erreurs

Si une publication échoue :

* Ne pas enregistrer un mapping faussement provisionné.
* Ne pas perdre les mappings déjà valides.
* Permettre une reprise idempotente.
* Exposer une erreur compréhensible dans le Mock LMC.

Compatibilité avec le provisioning existant

Nous avons déjà des orchestrateurs personnels qui fonctionnent.

Ne les supprime pas et ne les recrée pas systématiquement.

Prévois une migration progressive et non destructive.

Si une version existante peut être associée de manière fiable au modèle déjà provisionné, réutilise-la.

Sinon, publie les versions nécessaires sans casser l’orchestrateur existant.

⸻

6. Mise à jour de la configuration des modèles dans LMC

La configuration du projet LMC reste la source de vérité.

Un Project Manager doit pouvoir :

* Autoriser plusieurs modèles.
* Définir un modèle par défaut.
* Modifier les modèles autorisés.
* Relancer le provisioning.

Lors d’une modification, le provisioning doit réconcilier les versions de l’orchestrateur avec les modèles actuellement autorisés.

Exemple

Initialement :

Small  → v1.1.0
Medium → v1.2.0

Le Project Manager ajoute Gemma.

Après synchronisation :

Small  → v1.1.0
Medium → v1.2.0
Gemma  → v1.3.0

Si aucune configuration commune ne change, Small et Medium doivent conserver leurs mappings existants.

Mise à jour des instructions communes

Lorsqu’une modification des instructions de l’orchestrateur doit être propagée à toutes les variantes de modèles, publier de nouvelles versions.

Par exemple :

Small  → v1.4.0
Medium → v1.5.0
Gemma  → v1.6.0

Les nouvelles conversations doivent utiliser les versions correspondant à la configuration actuellement active.

Les anciennes versions ne doivent pas être supprimées sans politique explicite de conservation.

Ne suppose jamais que la version la plus récente correspond à un modèle précis.

⸻

7. Spécialistes Jira et GitLab

Nous conservons exactement deux spécialistes personnels par utilisateur/projet :

* Jira Specialist.
* GitLab Specialist.

Ils sont partagés par toutes les versions de l’orchestrateur personnel.

Leurs modèles sont configurés indépendamment de la sélection effectuée dans le chat.

Le POC a confirmé que ce partage fonctionne.

Il a également montré que les anciennes versions de l’orchestrateur peuvent résoudre la dernière version des spécialistes.

Nous acceptons ce fonctionnement pour le moment.

En revanche :

* Ne tente pas de référencer un spécialiste avec une syntaxe de version explicitement rejetée par le POC.
* Préserve leurs credentials spécifiques à l’utilisateur.
* Préserve leurs outils MCP.
* Ne duplique pas les spécialistes pour chaque modèle.
* Évite les modifications de configuration qui casseraient les anciennes versions de l’orchestrateur.

⸻

8. Deuxième partie — Intégration dans Engineering Companion

Une fois le provisioning et les mappings fonctionnels, connecte-les au backend Engineering Companion.

8.1. Sélection réelle du modèle

Aujourd’hui, le sélecteur de modèle est principalement visuel.

Nous voulons maintenant que la sélection détermine réellement l’orchestrateur exécuté.

Lorsqu’un utilisateur sélectionne un modèle :

1. Le frontend transmet uniquement l’identifiant LMC du modèle sélectionné.
2. Le backend authentifie l’utilisateur.
3. Le backend retrouve le projet LMC associé à la conversation.
4. Il vérifie que l’utilisateur appartient toujours au projet.
5. Il vérifie que le modèle est autorisé.
6. Il récupère le mapping personnel auprès du Mock LMC.
7. Il résout l’Agent Key et sa version exacte.
8. Il sélectionne la clé d’exécution Orq correspondant au projet.
9. Il exécute le Managed Agent avec la version explicitement sélectionnée.

Exemple :

{
  "model": "agent/<personal-orchestrator-key>@1.2.0",
  "input": "Analyse mes issues Jira"
}

La version doit être récupérée depuis le mapping réel.

Ne construis jamais une version supposée à partir du nom du modèle.

Sécurité

Le frontend ne doit jamais choisir librement :

* Une Agent Key.
* Une version Orq.
* Un Orq Project ID.
* Une clé API.
* Une référence de modèle Orq arbitraire.

Il peut uniquement sélectionner un modèle appartenant à la liste autorisée renvoyée par le backend.

Le backend doit revérifier cette autorisation à chaque exécution.

Si le mapping est manquant ou non provisionné, renvoyer une erreur explicite.

Ne pas utiliser silencieusement un autre modèle.

Ne pas basculer silencieusement vers une clé globale multi-projets.

⸻

9. Persistance du modèle sélectionné

Nous voulons conserver le fonctionnement actuel des conversations.

Chaque thread reste associé à un projet LMC immuable.

Ajouter une gestion persistante du modèle sélectionné.

Exemple

Conversation #123 :

Projet : Alpha
Utilisateur : User A
Modèle sélectionné : Mistral Medium

Lorsqu’on recharge la page, le sélecteur doit afficher le modèle réellement sélectionné.

Lorsqu’on change de conversation, chaque thread doit retrouver son propre modèle.

Lorsqu’on crée une conversation, utiliser le modèle par défaut autorisé du projet.

Historique des modèles utilisés

Pour chaque réponse de l’assistant, conserver les informations nécessaires à l’audit :

* Modèle LMC demandé.
* Modèle Orq réellement résolu.
* Agent Key.
* Version Orq exécutée.
* Response ID.
* Trace ID, si disponible.

Ces informations doivent rester côté backend ou dans les métadonnées persistantes appropriées.

L’utilisateur doit pouvoir retrouver ses messages même après avoir changé de modèle.

Compatibilité

Ne casse pas les conversations existantes.

Prévois une valeur par défaut ou une migration pour les threads créés avant l’implémentation.

Ne modifie pas les Project IDs existants.

Ne mélange jamais les conversations de deux projets différents.

⸻

10. Continuité conversationnelle

C’est une partie critique de l’implémentation.

Le POC a démontré :

* La continuité technique A → B → A.
* La conservation des faits et décisions dans les scénarios testés.
* La conservation imparfaite de certains anciens résultats d’outils.
* Le succès de la reconstruction explicite de l’historique dans le test exhaustif.

Nous voulons intégrer une stratégie robuste dans Engineering Companion.

10.1. Même version

Lorsque deux tours successifs utilisent exactement la même configuration d’exécution compatible, continuer à exploiter previous_response_id conformément au fonctionnement déjà validé.

10.2. Changement de version

Lorsqu’un utilisateur change de modèle :

* Conserver le même thread.
* Conserver tous les messages précédents.
* Détecter le changement de version.
* Déterminer explicitement la stratégie de continuité.
* Reconstruire le contexte nécessaire si l’on ouvre un nouveau segment d’exécution.

Pour cette première implémentation, privilégier une reconstruction explicite suffisamment complète lors des changements de version, plutôt que de dépendre exclusivement de la continuité implicite d’Orq.

Ne réutilise pas un ancien previous_response_id associé à une branche antérieure en ignorant les messages intermédiaires.

Exemple

Conversation #123
│
├── Message 1 → Small v1.1.0
├── Message 2 → Small v1.1.0
│
├── Changement vers Medium
│
├── Message 3 → Medium v1.2.0
├── Message 4 → Medium v1.2.0
│
├── Changement vers Small
│
└── Message 5 → Small v1.1.0

Le message 5 doit prendre en compte les informations produites aux messages 3 et 4.

Il ne doit pas simplement reprendre une ancienne branche Small ignorant les échanges Medium.

10.3. Résultats d’outils

Le rapport du POC montre que les résultats d’outils précédents ne sont pas toujours récupérés exhaustivement.

Prends ce problème en compte.

Examine comment Engineering Companion persiste actuellement :

* Les messages.
* Les tool calls.
* Les résultats des outils.
* Les parties structurées.
* Les références Jira/GitLab.

Améliore uniquement ce qui est nécessaire pour conserver et réinjecter les informations utiles lors d’un changement de modèle.

Lorsque les données sont disponibles, ne les remplace pas systématiquement par un simple résumé qui pourrait perdre des détails importants.

Prévois une gestion de la taille du contexte pour éviter des reconstructions illimitées.

Si certains résultats ne peuvent pas être récupérés intégralement, documente clairement cette limite.

Objectif : préserver la continuité des conversations et les résultats importants, pas prétendre transférer le raisonnement interne caché d’un modèle à l’autre.

⸻

11. Interface Engineering Companion

Réutilise le sélecteur de modèle existant.

Ne refais pas toute l’interface.

Je veux :

* Afficher uniquement les modèles autorisés dans le projet.
* Afficher le modèle réellement sélectionné.
* Permettre de changer de modèle dans une conversation existante.
* Conserver la conversation affichée.
* Utiliser réellement la version correspondant au modèle choisi.
* Préserver le streaming des réponses.
* Préserver les appels Jira/GitLab.
* Afficher une erreur compréhensible si la version demandée n’est pas provisionnée.

Supprime l’indication selon laquelle la sélection du modèle n’est pas appliquée, uniquement lorsque la fonctionnalité est effectivement opérationnelle.

Ne présente jamais un changement de modèle comme réussi si le backend n’a pas exécuté la bonne version.

⸻

12. Tests obligatoires

Je veux des tests automatisés et des vérifications réelles.

Provisioning

* Un utilisateur avec un seul modèle.
* Un utilisateur avec plusieurs modèles.
* Deux utilisateurs dans le même projet.
* Un utilisateur dans deux projets.
* Reprovisioning sans changement.
* Ajout d’un modèle.
* Retrait d’un modèle.
* Changement du modèle par défaut.
* Échec partiel pendant la publication d’une version.
* Réutilisation des spécialistes existants.

Engineering Companion

* Nouvelle conversation avec le modèle par défaut.
* Sélection de Mistral Small.
* Sélection de Mistral Medium.
* Vérification de la version réellement exécutée.
* Changement Small → Medium.
* Changement Medium → Small.
* Conservation du contexte.
* Conservation des informations issues des outils.
* Rechargement de la page.
* Changement entre deux conversations.
* Deux conversations simultanées avec deux modèles.
* Refus d’un modèle non autorisé.
* Refus d’une version non provisionnée.
* Isolation entre projets.
* Maintien du fonctionnement Jira/GitLab.

Vérification Orq.ai

Utilise les traces pour confirmer :

* La même Agent Key pour les différentes versions personnelles.
* Le bon modèle pour chaque version.
* L’absence de PATCH lors du changement dans le chat.
* La bonne Identity.
* Le bon projet Orq.
* Le fonctionnement des spécialistes.

Ne considère pas qu’un changement visuel dans le sélecteur suffit.

⸻

13. Stratégie d’implémentation

Travaille par étapes pour limiter les régressions.

Étape A — Mock LMC

Implémenter :

* La publication des versions.
* La persistance des mappings.
* L’idempotence.
* La réconciliation des modèles.
* L’exposition des mappings au backend Engineering Companion.

Vérifier que le provisioning fonctionne avant de modifier le chat.

Étape B — Backend Engineering Companion

Implémenter :

* La résolution du modèle autorisé.
* La récupération de la version.
* L’exécution de l’Agent Key versionnée.
* La persistance des informations d’exécution.
* La continuité conversationnelle.

Étape C — Frontend Engineering Companion

Connecter le sélecteur de modèle au backend.

Conserver l’interface existante.

Étape D — Tests end-to-end

Tester le fonctionnement complet :

Mock LMC → Provisioning Orq → Engineering Companion → Changement de modèle → Continuité de conversation.

À chaque étape, exécuter les tests pertinents.

Corriger les régressions avant de continuer.

⸻

14. Précautions sur les ressources existantes

Le projet contient déjà des ressources Orq opérationnelles.

Ne réalise aucune suppression globale.

Ne recrée pas inutilement les projets Orq existants.

Ne supprime pas les orchestrateurs personnels existants.

Ne supprime pas les spécialistes personnels existants.

Ne supprime pas les identités, budgets, configurations ou credentials existants.

Les modifications de provisioning doivent être incrémentales.

Si une ressource existante ne peut pas être migrée proprement, explique le blocage et propose une solution non destructive.

Les opérations de publication sur Orq doivent être limitées aux ressources appartenant au Mock LMC et explicitement ciblées.

Si une opération risque de modifier des agents ou projets partagés hors de notre périmètre, ne l’exécute pas sans validation.

⸻

15. Résultat final attendu

Je veux pouvoir effectuer ce scénario réel :

1. J’ouvre le Mock LMC.
2. Je sélectionne un projet.
3. J’autorise trois modèles.
4. Je lance le provisioning.
5. Je vérifie dans Orq.ai qu’un utilisateur possède un orchestrateur personnel avec trois versions correspondant aux modèles.
6. J’ouvre Engineering Companion.
7. Je sélectionne ce projet.
8. Je démarre une conversation avec Mistral Small.
9. Je demande à l’orchestrateur d’utiliser Jira Specialist.
10. Je continue la conversation.
11. Je sélectionne Mistral Medium.
12. Je demande à l’agent de poursuivre l’analyse précédente.
13. Je vérifie que Medium est réellement utilisé et dispose des informations précédentes.
14. Je reviens à Mistral Small.
15. Je vérifie que les messages échangés sous Medium sont toujours pris en compte.
16. Je recharge l’application et retrouve la conversation et le modèle sélectionné.

Tout cela doit fonctionner sans recréer l’orchestrateur, sans PATCH pendant les conversations et sans changer de thread.

⸻

16. Livrable

Implémente réellement les changements dans les projets existants.

À la fin, fournis :

* Les fichiers modifiés.
* Les migrations SQLite éventuelles.
* Les endpoints créés ou modifiés.
* Les changements de provisioning.
* Les changements du backend Engineering Companion.
* Les changements du frontend.
* Les tests exécutés et leurs résultats.
* Les limites encore connues.
* Les commandes nécessaires pour lancer et tester les applications.

Ne te limite pas à produire une analyse.

Ne crée pas un nouveau POC indépendant.

Notre décision architecturale est prise : un orchestrateur logique personnel, plusieurs versions épinglées correspondant aux modèles autorisés, et des spécialistes Jira/GitLab communs.

L’objectif est maintenant d’obtenir une première implémentation complète et fonctionnelle de cette architecture dans Mock LMC et Engineering Companion.

Travaille de façon incrémentale, conserve l’existant et privilégie le code réellement exécutable aux documents théoriques.