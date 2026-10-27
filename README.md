Analyse préliminaire

Choix architecturaux transverses — Engineering Companion × LMC × Orq.ai

Statut : Analyse préliminaire — Décisions à confirmer
Date : 27 octobre 2026

⸻

1. Objectif

Ce document complète l’analyse comparative des architectures Shared Agents et Personal Agents.

Il présente les principales décisions techniques et organisationnelles à prendre pour assurer le provisioning, l’isolation, la personnalisation et le monitoring des ressources Orq.ai intégrées à Engineering Companion.

Ces décisions sont étudiées indépendamment du choix final entre agents personnels et mutualisés.

2. Organisation des projets Orq.ai

Problématique

Il est nécessaire de définir comment les projets LMC, les utilisateurs et leurs ressources agentiques seront représentés dans Orq.ai.

Orq.ai permet de créer des projets possédant leurs propres ressources et mécanismes de permissions. Les folders permettent quant à eux d’organiser les ressources à l’intérieur d’un projet.

Option A — Un projet Orq.ai par projet LMC

Chaque projet créé dans LMC entraîne la création d’un projet correspondant dans Orq.ai.

Les ressources sont ensuite organisées dans des folders, éventuellement par utilisateur.

Avantages :

* Correspondance directe entre projets LMC et Orq.ai.
* Gouvernance et monitoring simplifiés par projet.
* Possibilité d’utiliser des clés API limitées à chaque projet.
* Organisation cohérente avec le cycle de vie des projets LMC.

Inconvénients :

* Les folders ne garantissent pas une isolation individuelle.
* Les permissions utilisateurs doivent être vérifiées par Engineering Companion.
* Les ressources personnelles restent techniquement regroupées dans un même projet Orq.ai.

Option B — Un projet Orq.ai par utilisateur

Chaque utilisateur possède un projet Orq.ai contenant des folders correspondant aux différents projets LMC auxquels il appartient.

Avantages :

* Organisation centrée sur l’utilisateur.
* Regroupement des ressources personnelles.
* Séparation des configurations entre utilisateurs.

Inconvénients :

* Correspondance moins directe avec les projets LMC.
* Gestion des ressources communes à un projet plus complexe.
* Monitoring et gouvernance par projet métier nécessitant une agrégation supplémentaire.
* Multiplication des projets Orq.ai selon le nombre d’utilisateurs.

Option C — Un projet Orq.ai par couple utilisateur/projet LMC

Chaque appartenance d’un utilisateur à un projet LMC donne lieu à un projet Orq.ai distinct.

Avantages :

* Isolation technique plus forte.
* Permissions et ressources propres à chaque couple utilisateur/projet.
* Possibilité de séparer davantage les clés API et les budgets.

Inconvénients :

* Multiplication importante des projets Orq.ai.
* Provisioning et maintenance plus complexes.
* Duplication potentielle des ressources communes.
* Consolidation des coûts par projet LMC plus complexe.

Recommandation

Privilégier l’option A : un projet Orq.ai par projet LMC.

Cette solution offre le meilleur alignement avec la gouvernance métier et facilite le suivi des ressources par projet.

Des folders utilisateurs peuvent être créés pour organiser les agents personnels, mais ne doivent pas être considérés comme des frontières de sécurité.

L’option C pourrait être envisagée si une exigence formelle impose une isolation native par utilisateur au niveau Orq.ai.

⸻

3. Isolation des utilisateurs et gestion des permissions

Problématique

Lorsque plusieurs utilisateurs partagent un projet Orq.ai, il faut garantir qu’ils ne puissent pas accéder aux agents, Skills, credentials ou données auxquels ils ne sont pas autorisés.

Les permissions Orq.ai sont principalement organisées au niveau des projets. Les folders constituent une organisation logique, sans garantie générale d’isolation individuelle documentée.

Option A — Isolation au niveau des projets Orq.ai

Chaque utilisateur dispose de son propre projet technique ou d’un espace fortement séparé.

Avantage : meilleure séparation native des ressources.

Inconvénient : multiplication des projets et complexité opérationnelle.

Option B — Isolation applicative via Engineering Companion

Les utilisateurs passent exclusivement par Engineering Companion.

Le backend identifie l’utilisateur, vérifie ses permissions LMC et sélectionne les ressources Orq.ai autorisées.

Les MCP appliquent également les permissions lors de l’accès aux systèmes externes.

Avantages :

* Compatible avec un projet Orq.ai partagé entre plusieurs utilisateurs.
* Limite la multiplication des ressources techniques.
* Centralise les règles métier dans LMC.

Inconvénients :

* Nécessite des contrôles d’autorisation robustes.
* La sécurité dépend également de l’implémentation backend et MCP.
* Les utilisateurs ne doivent pas pouvoir contourner ces contrôles en accédant directement aux API Orq.ai avec des clés trop permissives.

Recommandation

Privilégier l’isolation applicative avec LMC comme source de vérité, complétée par les mécanismes natifs de séparation des projets Orq.ai.

Les clés API Orq.ai doivent rester côté serveur et respecter le principe du moindre privilège.

Les accès aux conversations, outils MCP et données RAG doivent être vérifiés indépendamment de la visibilité des agents dans l’interface.

⸻

4. Sélection et changement des modèles LLM

Problématique

LMC définit les modèles autorisés pour chaque utilisateur.

Engineering Companion doit ensuite proposer un sélecteur permettant de choisir librement parmi ces modèles.

Orq.ai permet de définir le modèle d’un agent et de modifier cette configuration via son API.

Plusieurs approches sont envisageables.

Option A — Mise à jour dynamique avec PATCH

Lorsqu’un utilisateur sélectionne un modèle, Engineering Companion modifie la configuration de son agent via :

PATCH /v2/agents/{agent_key}

Avantages :

* Exploite une fonctionnalité native d’Orq.ai.
* Évite de créer systématiquement plusieurs agents par modèle.
* Réduit le nombre de configurations à maintenir.

Inconvénients :

* La modification est persistante.
* Risques de concurrence entre conversations utilisant différents modèles.
* Nécessité de gérer la cohérence des mises à jour de l’orchestrateur et des sous-agents.
* Risque d’échecs partiels lors des modifications.

Le versioning Orq.ai pourrait permettre de conserver et d’invoquer des configurations précises. Cette stratégie nécessite toutefois une validation, notamment pour les sous-agents.

Option B — Agents préconfigurés par modèle

Chaque modèle disponible correspond à une configuration d’agent.

Lorsqu’un utilisateur sélectionne un modèle, Engineering Companion invoque l’agent correspondant.

Avantages :

* Aucun changement de configuration pendant l’utilisation.
* Comportement plus prévisible en cas de conversations simultanées.
* Gestion explicite des modèles et des versions.
* Risques de concurrence réduits.

Inconvénients :

* Multiplication des configurations.
* Provisioning plus important.
* Maintenance de plusieurs variantes d’agents.

Recommandation

Privilégier les agents préconfigurés par modèle lorsque la fiabilité et la concurrence sont prioritaires.

L’approche PATCH reste une alternative pertinente pour les agents personnels, sous réserve de valider son comportement en conditions réelles.

Un POC est nécessaire avant de retenir cette approche.

⸻

5. Modèles des sous-agents

Problématique

Engineering Companion utilise actuellement un orchestrateur principal et deux sous-agents spécialisés : Jira Specialist et GitLab Specialist.

Chaque sous-agent dispose de sa propre configuration de modèle.

Il faut donc définir l’effet du modèle sélectionné dans l’interface sur l’ensemble du workflow.

Option A — Même modèle pour tous les agents

Le modèle sélectionné par l’utilisateur est appliqué à l’orchestrateur et à tous les sous-agents.

Avantages :

* Comportement cohérent et facilement compréhensible.
* Tous les agents respectent explicitement le choix utilisateur.

Inconvénients :

* Coût potentiellement plus élevé.
* Nécessite davantage de configurations ou de mises à jour.
* Tous les spécialistes n’ont pas nécessairement besoin d’un modèle aussi puissant.

Option B — Modèle sélectionné pour l’orchestrateur, modèles spécifiques pour les spécialistes

L’orchestrateur utilise le modèle choisi par l’utilisateur.

Les spécialistes utilisent des modèles prédéfinis selon leurs tâches.

Avantages :

* Possibilité d’optimiser les coûts.
* Configuration des spécialistes plus stable.
* Maintenance et mutualisation facilitées.

Inconvénients :

* Le modèle sélectionné ne correspond pas à tous les modèles réellement exécutés.
* Les modèles des spécialistes doivent rester conformes aux permissions définies dans LMC.

Recommandation

Étudier prioritairement l’option B pour optimiser les coûts et simplifier la gestion des spécialistes.

Cependant, elle nécessite une validation fonctionnelle : les droits LMC doivent-ils s’appliquer au modèle principal uniquement ou à l’ensemble des modèles exécutés ?

Les modèles de fallback doivent également respecter la politique retenue.

⸻

6. Provisioning des ressources

Problématique

La création d’un projet LMC doit entraîner le provisioning des ressources nécessaires dans Orq.ai.

Il faut définir à quel moment créer les projets, agents et configurations.

Option A — Provisioning immédiat

Les ressources sont créées dès la création d’un projet ou l’ajout d’un utilisateur dans LMC.

Avantages :

* Ressources disponibles avant la première utilisation.
* Expérience utilisateur sans attente de provisioning initial.
* Possibilité de détecter les erreurs en amont.

Inconvénients :

* Création potentielle de ressources inutilisées.
* Nombre d’opérations de provisioning plus important.
* Gestion nécessaire des échecs partiels.

Option B — Provisioning à la demande

Les ressources personnelles sont créées lorsqu’un utilisateur accède pour la première fois à Engineering Companion dans un projet.

Avantages :

* Évite de créer des agents pour des utilisateurs inactifs.
* Réduit le nombre de configurations personnelles à administrer.
* Limite les opérations initiales.

Inconvénients :

* Latence potentielle lors de la première utilisation.
* Nécessité de gérer les créations concurrentes et les erreurs.
* Dépendance à la disponibilité des API Orq.ai.

Recommandation

Privilégier une approche hybride :

* Provisioning du projet Orq.ai et des ressources communes dès la création du projet LMC.
* Provisioning des agents personnels à la demande, si l’architecture retenue en nécessite.

Les opérations devront être idempotentes et disposer d’une stratégie de réconciliation.

⸻

7. Monitoring et suivi des coûts

Problématique

Le système doit permettre de mesurer les coûts et l’utilisation des ressources agentiques selon deux dimensions principales :

* Par projet LMC : consommation totale du projet.
* Par utilisateur : consommation individuelle, y compris sur plusieurs projets.

Un suivi complémentaire par agent et par modèle est également nécessaire.

Option A — Monitoring fondé principalement sur la structure des ressources

L’analyse repose sur les projets et agents Orq.ai provisionnés.

Avantages :

* Organisation explicite.
* Suivi relativement naturel des coûts par projet.
* Granularité individuelle avec des agents personnels.

Inconvénients :

* L’analyse utilisateur est moins directe avec des agents partagés.
* Nécessite une consolidation lorsque les utilisateurs appartiennent à plusieurs projets.

Option B — Monitoring via Projects, Identities et traces

Chaque requête est associée à une Identity utilisateur.

Les ressources restent associées au projet Orq.ai correspondant au projet LMC.

Les traces et métriques permettent de compléter l’analyse par agent et par modèle.

Avantages :

* Compatible avec les agents personnels et partagés.
* Suivi des coûts par utilisateur indépendamment du nombre d’agents.
* Agrégation possible par projet, modèle et agent.
* Architecture de monitoring moins dépendante du provisioning.

Inconvénients :

* Nécessite une attribution fiable de l’Identity et du contexte projet.
* Il faut valider la propagation des informations aux sous-agents.
* Une stratégie de corrélation est nécessaire pour reconstruire les coûts des workflows multi-agents.

Recommandation

Privilégier l’option B, en utilisant les capacités natives d’observabilité d’Orq.ai.

Le modèle cible serait :

Project Orq.ai + Identity utilisateur + Traces/Métriques d’exécution.

Un identifiant de corrélation Engineering Companion permettra également de relier les appels frontend, backend, Orq.ai et MCP.

Il faudra vérifier l’attribution des coûts des sous-agents afin d’éviter toute perte ou double comptabilisation.

⸻

8. Synthèse des décisions

Problématique	Recommandation préliminaire	Statut
Organisation des projets	Un projet Orq.ai par projet LMC	À confirmer
Organisation des folders	Folders utilisateurs si agents personnels	Dépend de l’architecture
Isolation	Contrôles backend/MCP + séparation native Orq.ai	Recommandé
Changement de modèle	Agents préconfigurés, PATCH en alternative	POC nécessaire
Modèles des sous-agents	Modèles spécialisés autorisés, potentiellement distincts	Décision métier nécessaire
Provisioning	Immédiat pour les projets, à la demande pour les agents personnels	À confirmer
Monitoring	Projects + Identities + Traces/Métriques	Recommandé

⸻

9. Points ouverts avant l’ADR

Les décisions suivantes doivent encore être validées :

1. Isolation : les utilisateurs finaux auront-ils uniquement accès à Engineering Companion ou également à Orq Studio ?

2. Modèles : le modèle choisi doit-il s’appliquer à toute la chaîne multi-agents ou uniquement à l’orchestrateur ?

3. PATCH : le versioning permet-il de garantir le modèle utilisé dans plusieurs conversations simultanées et des délégations vers les sous-agents ?

4. Provisioning : quels délais de création sont acceptables lors de la première utilisation ?

5. Monitoring : les coûts des sous-agents sont-ils correctement attribués à l’utilisateur et au projet dans les traces Orq.ai ?

6. Scalabilité : quelles sont les limites contractuelles de votre environnement Orq.ai concernant le nombre de projets, d’agents et les opérations de provisioning ?

Ces validations permettront de finaliser les sous-décisions techniques qui accompagneront le choix principal entre Shared Agents et Personal Agents.

⸻

10. Conclusion

L’architecture cible ne dépend pas uniquement du choix entre agents personnels et partagés.

Plusieurs décisions transverses doivent être prises concernant l’organisation des projets, l’isolation des ressources, la sélection des modèles, le cycle de vie des agents et l’observabilité.

L’orientation actuellement recommandée consiste à aligner les projets Orq.ai sur les projets LMC, à appliquer les permissions individuelles côté Engineering Companion et MCP, et à utiliser les fonctionnalités natives d’Orq.ai pour le monitoring par utilisateur et par projet.

Le choix définitif du mécanisme de sélection des modèles reste le principal point technique à valider.

Cette analyse pourra servir de référence complémentaire à l’ADR principal, sans imposer prématurément une architecture d’agents particulière.