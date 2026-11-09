Mission : POC isolé — Routing Rules et changement dynamique de modèle dans les Managed Agents Orq.ai

1. Contexte

Nous développons Engineering Companion, une application utilisant des Managed Agents Orq.ai.

Notre architecture actuelle repose sur :

* Un projet Orq.ai par projet LMC.
* Des utilisateurs possédant chacun leur orchestrateur personnel Engineering Companion.
* Deux sous-agents personnels : Jira Specialist et GitLab Specialist.
* Des outils MCP associés aux spécialistes.
* Des modèles autorisés et configurés depuis le Mock LMC.
* Un provisioning persistant et idempotent des ressources Orq.ai.
* Des identités et budgets déjà provisionnés.

Engineering Companion fonctionne actuellement en local, communique avec Mock LMC et exécute correctement les orchestrateurs personnels.

Nous voulons maintenant étudier une architecture permettant de changer dynamiquement le modèle d’inférence d’un orchestrateur sans créer un agent distinct pour chaque modèle.

La solution envisagée utilise les Routing Rules Orq.ai.

Cependant, une première expérimentation n’a pas permis de démontrer sa faisabilité.

2. État du précédent POC

Un précédent POC existe dans :

LEA_Workspace/routing-rules-poc

Fichiers à examiner :

* README.md
* REPORT.md
* report.json
* poc.py

Il contient les résultats d’une première investigation.

Principales observations :

1. Une exécution baseline du Managed Agent a fonctionné.
2. Le prompt, les outils et les deux spécialistes étaient opérationnels.
3. Les expressions CEL ont pu être validées syntaxiquement.
4. L’utilisation d’une API Key limitée au projet a entraîné une erreur 403 lors de la création d’une Routing Rule.
5. La Management Key a permis une création de règle, mais le project_id renvoyé était vide.
6. La règle créée était donc potentiellement globale au workspace.
7. Aucun changement effectif du modèle interne du Managed Agent n’a été démontré.
8. Le projet POC précédent n’a pas pu être supprimé à cause de traces existantes.
9. Les ressources temporaires de routage ont été nettoyées.

Important : ne pas recommencer inutilement les étapes déjà validées.

Commence par lire les rapports, examiner le code et identifier précisément les blocages restants.

3. Objectif technique principal

Répondre expérimentalement à cette question :

Une Routing Rule Orq.ai peut-elle changer le modèle d’inférence interne d’un Managed Agent, tout en conservant son identité, ses instructions, ses outils et son équipe de sous-agents ?

Nous voulons tester le scénario suivant :

Baseline

Un orchestrateur utilise le modèle A.

Il possède :

* Un system prompt identifiable.
* Un outil simple et vérifiable.
* Deux sous-agents de test : Jira Specialist et GitLab Specialist.
* Une configuration stable et identifiable par son Agent Key.

Avec Routing Rule

Le backend appelle toujours exactement le même orchestrateur :

model: agent/<same-functional-key>

Cependant, une Routing Rule doit sélectionner le modèle B pour l’inférence interne de cet orchestrateur.

Résultat attendu :

* Même Agent Key.
* Même system prompt.
* Même équipe de sous-agents.
* Mêmes outils.
* Modèle interne de l’orchestrateur réellement changé.
* Aucun remplacement du Managed Agent par une simple requête LLM.
* Aucune modification persistante du manifest de l’agent.

Il faut impérativement vérifier ces propriétés dans les traces Orq.ai, et pas uniquement dans les réponses textuelles.

4. Contraintes de sécurité non négociables

Ce POC doit rester complètement indépendant d’Engineering Companion et du Mock LMC opérationnels.

Ressources protégées

Ne modifie pas :

* LEA_Workspace/use-case-engineering-companion
* LEA_Workspace/mock-lmc-orq-poc
* Les projets Orq utilisés par Engineering Companion.
* Les agents personnels existants.
* Les modèles et prompts opérationnels.
* Les Routing Rules préexistantes.
* Les clés ou credentials utilisés par les applications existantes.

Tu peux examiner ces codebases en lecture seule pour comprendre leur fonctionnement.

Environnement de test

Utilise un projet Orq.ai exclusivement dédié au POC.

Ne réutilise pas les projets test_auto ou test_autoauto.

Ne supprime aucune ressource qui n’a pas été créée explicitement par ce POC.

N’utilise pas les véritables outils Jira/GitLab sur des données professionnelles. Crée des sous-agents de test avec des outils simulés déterministes.

Utilise des modèles de test avec des limites de consommation raisonnables.

Secrets

* Aucun token dans les logs ou rapports.
* Aucun credential dans les fichiers versionnés.
* Aucune Management Key dans les requêtes d’inférence.
* Aucun secret transmis au frontend.
* Ne désactive aucune vérification TLS.
* N’imprime pas les valeurs des variables d’environnement sensibles.

Point de contrôle obligatoire

Si l’expérimentation nécessite d’activer une Routing Rule globale au workspace, arrête-toi avant l’activation et demande-moi une autorisation explicite.

Tu peux préparer les scripts, les ressources de test et les règles désactivées.

Mais ne déclenche pas de modification potentiellement globale sans cette validation.

5. Phase 1 — Analyse technique préalable

Examine le POC existant et les capacités réellement disponibles dans notre instance Orq.ai.

Vérifie notamment :

Routing Rules

* Création.
* Lecture.
* Modification.
* Activation/désactivation.
* Suppression.
* Champ project_id.
* Conditions CEL.
* Priorité.
* Configuration du modèle cible.

Détermine pourquoi le project_id est ignoré ou renvoyé vide dans notre environnement.

Compare :

1. Le contrat du SDK installé.
2. La documentation officielle.
3. Les payloads réellement envoyés.
4. Les réponses réellement reçues.
5. Le comportement de l’interface Orq Studio.

Ne suppose pas qu’un champ accepté par le SDK est réellement appliqué par le backend Orq.

Vérifie également si notre version SDK peut être à l’origine d’une différence de comportement.

Livrable : expliquer précisément ce qui est confirmé, ce qui reste hypothétique et ce qui bloque.

6. Phase 2 — Préparation d’un environnement de test isolé

Prépare un projet POC dédié avec :

* Un orchestrateur de test.
* Un Jira Specialist simulé.
* Un GitLab Specialist simulé.
* Deux modèles réellement distincts.
* Des prompts contenant des marqueurs vérifiables.
* Des outils simples dont les résultats sont déterministes.

Par exemple, les spécialistes peuvent renvoyer des réponses simulées contenant un marqueur spécifique à leur rôle.

Chaque agent doit avoir une clé stable et identifiable.

Le provisioning doit être idempotent.

Enregistre les IDs des ressources créées afin de pouvoir les nettoyer ensuite.

Avant chaque création, vérifie qu’une ressource équivalente appartenant au POC n’existe pas déjà.

Ne recrée pas inutilement des ressources.

7. Phase 3 — Exécution baseline

Sans Routing Rule active :

1. Exécute l’orchestrateur.
2. Vérifie l’utilisation du modèle A.
3. Vérifie l’application du system prompt.
4. Vérifie l’exécution de l’outil simple.
5. Vérifie les appels aux deux sous-agents.
6. Vérifie le modèle effectivement utilisé par chaque spécialiste.
7. Enregistre les traces et identifiants de corrélation.

Conserve également une empreinte de la configuration de chaque agent.

Cette baseline servira de référence pour détecter toute modification du comportement agentique.

8. Phase 4 — Création et vérification de la Routing Rule

Prépare une règle initialement désactivée.

Privilégie une règle nativement limitée au projet Orq.

Si cela ne fonctionne pas, examine la possibilité d’une règle globale utilisant des conditions CEL restrictives.

Les conditions devront idéalement vérifier :

* Le projet Orq.
* L’application appelante.
* L’orchestrateur ciblé.
* Le modèle demandé.
* Une version de politique.
* Un marqueur opaque de POC.

Le marqueur ne constitue pas un mécanisme d’authentification. Il sert uniquement à limiter les correspondances accidentelles.

Les métadonnées utilisées pour cette règle doivent être construites côté serveur.

Ne les accepte jamais directement depuis une requête frontend non validée.

Teste les expressions CEL avec différents cas :

* Projet correct.
* Mauvais projet.
* Mauvais orchestrateur.
* Mauvais modèle.
* Marqueur absent.
* Marqueur incorrect.
* Métadonnées absentes.

La règle doit uniquement correspondre au cas explicitement prévu.

Une expression CEL valide syntaxiquement ne constitue pas une preuve que la règle sera correctement évaluée lors de l’exécution d’un Managed Agent.

Vérifie séparément ce comportement.

Si la règle est globale, présente-moi son périmètre exact, ses conditions et son plan de rollback avant toute activation.

9. Phase 5 — Test principal : changement du modèle interne

Après validation de l’activation :

Exécute deux requêtes en conservant exactement la même Agent Key.

Première requête

Routing Rule désactivée.

Résultat attendu :

* Orchestrateur exécuté avec le modèle A.
* Prompt conservé.
* Outils opérationnels.
* Sous-agents opérationnels.

Deuxième requête

Routing Rule activée.

Résultat attendu :

* Même Agent Key.
* Orchestrateur exécuté avec le modèle B.
* Prompt conservé.
* Outils opérationnels.
* Sous-agents opérationnels.
* Aucun remplacement du Managed Agent.
* Aucune modification persistante de sa configuration.

Vérifie le modèle réellement exécuté, pas seulement le modèle demandé ou affiché.

Examine les spans d’inférence, les traces Agent, les tool calls et les handoffs.

Critère d’échec majeur

Si la règle transforme l’appel Managed Agent en simple réponse LLM sans exécuter les outils ou les sous-agents, considère le scénario comme non validé.

N’essaie pas de masquer ce comportement avec des modifications applicatives.

10. Phase 6 — Vérification des sous-agents

C’est un critère essentiel.

Configure si possible :

* Orchestrateur : modèle A.
* Jira Specialist : modèle B.
* GitLab Specialist : modèle A ou modèle C.

Active ensuite le routage destiné à l’orchestrateur.

Il faut déterminer :

1. Si la règle s’applique uniquement à l’inférence de l’orchestrateur.
2. Si elle affecte également Jira Specialist.
3. Si elle affecte également GitLab Specialist.
4. Si les métadonnées du parent sont propagées aux sous-agents.
5. Si une condition CEL peut cibler uniquement l’orchestrateur réellement exécuté.

Ne considère pas que les spécialistes conservent leur modèle simplement parce que le prompt ou la réponse semble correct.

Il faut vérifier les modèles effectifs dans leurs propres spans.

Si la plateforme ne permet pas de distinguer les appels internes des sous-agents, documente explicitement cette limitation.

11. Phase 7 — Isolation et concurrence

Si une activation de règle a été autorisée, réalise également des tests négatifs.

Isolation

Prépare un second projet de test, servant de canari.

Il ne doit pas partager les ressources du projet POC principal.

Pendant l’activation de la règle :

* Exécute une requête depuis le projet canari.
* Vérifie qu’elle conserve son modèle attendu.
* Vérifie qu’aucune ressource ne change.
* Vérifie que ses traces ne correspondent pas à la règle POC.

Concurrence

Lance deux exécutions simultanées :

* Requête A demandant le modèle A.
* Requête B demandant le modèle B.

Vérifie que les modèles réellement utilisés correspondent aux modèles attendus.

La règle ne doit pas nécessiter une modification globale entre les deux requêtes.

Il faut démontrer que le routage peut fonctionner simultanément pour plusieurs conversations.

Priorités

Examine les Routing Rules préexistantes en lecture seule.

Détermine si une autre règle pourrait prendre priorité sur celle du POC.

Ne modifie jamais les priorités des règles existantes.

12. Phase 8 — Nettoyage et restauration

À la fin des tests :

1. Désactive immédiatement les Routing Rules créées.
2. Vérifie qu’elles ne correspondent plus aux requêtes.
3. Supprime uniquement les règles créées par le POC.
4. Supprime les ressources temporaires dont la suppression est sûre.
5. Vérifie qu’aucune règle POC ne reste active.
6. Compare les règles préexistantes avec leur état initial.

Prévois un nettoyage automatique finally pour les erreurs normales et un mécanisme de récupération en cas d’interruption brutale.

Si une ressource ne peut pas être supprimée parce qu’elle possède des traces, signale-le clairement. Ne tente pas de contourner les protections Orq.

13. Phase 9 — Rapport final

Je veux un rapport technique structuré, basé exclusivement sur les preuves recueillies.

Il devra contenir :

A. Résultat principal

Une des conclusions suivantes :

* VALIDÉ : une Routing Rule change réellement le modèle interne du Managed Agent tout en conservant son comportement agentique.
* INVALIDÉ : le test démontre que le comportement recherché ne fonctionne pas.
* INDÉTERMINÉ : les permissions, limitations de plateforme ou preuves disponibles ne permettent pas de conclure.

B. Résultats détaillés

Pour chaque critère :

* Test effectué.
* Résultat attendu.
* Résultat observé.
* Statut PASS / FAIL / BLOCKED.
* Trace ou élément de preuve.

C. Sous-agents

Indique précisément quels modèles ont été utilisés par l’orchestrateur, Jira Specialist et GitLab Specialist.

D. Sécurité et isolation

Documente :

* Le périmètre réellement appliqué aux règles.
* Les risques liés aux règles globales.
* Les résultats du test canari.
* Les permissions nécessaires.
* Les conséquences éventuelles sur les autres projets.

E. Impact architectural

Compare les deux solutions :

Solution A : un orchestrateur personnel avec Routing Rules

Solution B : des orchestrateurs distincts par modèle

Évalue notamment :

* Scalabilité.
* Nombre de ressources Orq.
* Provisioning.
* Maintenance.
* Comportement des spécialistes.
* Sécurité.
* Concurrence.
* Observabilité.
* Coûts.
* Continuité conversationnelle.

F. Recommandation

Dis clairement si nous pouvons envisager les Routing Rules pour Engineering Companion.

Ne recommande pas cette architecture uniquement parce qu’un routage fonctionne sur une requête LLM classique.

La validation doit concerner le Managed Agent et ses sous-agents.

14. Ce qui est hors périmètre

Ne commence aucune intégration définitive dans Engineering Companion.

Ne modifie pas :

* Le sélecteur de modèle.
* Le système de conversation.
* Le provisioning du Mock LMC.
* Les agents personnels existants.
* Les Routing Rules opérationnelles.
* La logique previous_response_id.

Nous étudierons l’intégration applicative et la continuité conversationnelle dans une étape distincte, après validation de la faisabilité du routage.

15. Mode de travail attendu

Travaille progressivement.

Commence par examiner les fichiers existants et identifier ce qui peut être réutilisé.

Prépare ensuite les tests et les ressources isolées.

Exécute automatiquement toutes les vérifications sans impact global.

Si des permissions manquent, explique exactement lesquelles et propose la procédure minimale pour les obtenir.

Si l’activation d’une Routing Rule globale devient nécessaire, présente la règle et ses risques, puis arrête-toi pour ma validation explicite.

Ne considère pas un échec de permission comme un échec de faisabilité technique.

Ne considère pas non plus une réussite de routage au niveau AI Gateway comme une preuve de compatibilité avec les Managed Agents.

Priorité absolue : obtenir une conclusion expérimentale fiable sans perturber les projets, agents et applications existants.