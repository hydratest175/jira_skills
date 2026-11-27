Nous reprenons cette session après avoir temporairement poursuivi le développement dans l’ancienne.

Depuis ta dernière intervention, C8 a été revue et corrigée, le lancement standard sécurisé a été qualifié et le premier provisioning réel d’un projet Orq depuis le LMC a réussi : Temporal COMPLETED, Saga/UI SUCCEEDED, mapping exact, un seul POST.

La mémoire projet a été actualisée.

Relis les instructions, l’état courant et le handoff dans /workspace/LEA_Workspace/project-memory/. Consulte uniquement les documents nécessaires pour comprendre les changements intervenus depuis ta dernière mission.

Identifie la dernière référence applicative cumulative, incluant les correctifs C8, sécurité et TLS. Vérifie également l’état du nettoyage de la qualification réelle précédente.

Nous passons maintenant à l’intégration des Identities Orq et des clés API temporaires.

Analyse le Mock LMC conjointement avec les mécanismes existants du véritable LMC.

Exigences structurantes :

* Le LMC reste la source de vérité pour les utilisateurs, rôles, permissions et appartenances aux projets.
* Chaque Identity Orq repose sur un utilisateur LMC existant, avec un mapping stable et une réutilisation entre projets.
* Le retrait d’un utilisateur d’un projet ne doit pas affecter ses autres projets.
* Aucun système parallèle de gestion des utilisateurs ou des permissions.
* Les clés API temporaires doivent respecter le cycle de vie du Mock, sans persistance de secrets bruts.

Étudie les mappings nécessaires, l’idempotence, la concurrence, la récupération après interruption et l’intégration dans notre architecture Temporal existante.

Propose un découpage minimal en micro-MR avec les critères d’acceptation. Capitalise sur les fondations existantes sans les reconstruire.

Toutes nos règles permanentes restent applicables. C9 reste ouvert.

Évite les explorations redondantes et la multiplication inutile des sous-agents.

Présente-moi ta compréhension des changements récents, ton plan technique et les éventuelles décisions à arbitrer. Attends ma validation avant toute implémentation ou mutation distante.