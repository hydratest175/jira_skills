Mission — Découverte de la codebase et lancement local d’Engineering Companion

Contexte

Nous avons développé un Mock LMC capable de provisionner des ressources Orq.ai : projets, Identities, budgets, modèles, prompts et agents.

Le Mock LMC fonctionne désormais correctement en local avec Docker Compose.

Nous souhaitons prochainement intégrer ce Mock LMC à Engineering Companion.

Cependant, avant toute intégration, je veux que tu comprennes parfaitement la codebase d’Engineering Companion et que tu sois capable de lancer l’application en local.

Cette mission est exclusivement consacrée à la découverte et à l’exécution locale.

Ne commence aucune intégration entre les deux applications.

1. Analyser la codebase d’Engineering Companion

Commence par retrouver le dépôt Engineering Companion dans le workspace existant.

Explore sa structure et comprends son architecture.

Je souhaite notamment que tu identifies :

* Le fonctionnement général d’Engineering Companion.
* Les fonctionnalités déjà implémentées.
* L’architecture frontend.
* L’architecture backend.
* Les principaux composants React.
* Les endpoints FastAPI.
* Les mécanismes d’authentification.
* Les dépendances techniques.
* Les configurations d’environnement.
* Les interactions avec Orq.ai.
* La manière dont les agents sont actuellement sélectionnés et exécutés.
* Le fonctionnement de l’orchestrateur et des spécialistes Jira/GitLab.
* Les mécanismes d’intégration MCP.
* Les éventuelles dépendances avec LMC.

Examine également la configuration Docker existante, les Dockerfiles, les fichiers Compose, les éventuels devcontainers et les scripts de lancement.

Je veux que tu comprennes comment l’application a été conçue et comment elle est censée démarrer.

Ne réécris aucun composant à ce stade.

2. Identifier la procédure de lancement local

Après cette analyse, identifie la meilleure manière de lancer Engineering Companion dans notre environnement actuel.

Nous travaillons dans un VS Code Dev Container, avec Docker disponible.

Le Mock LMC utilise déjà Docker Compose.

Privilégie donc une exécution Docker pour Engineering Companion si le dépôt contient une configuration adaptée.

Tu peux également utiliser une autre méthode si elle est plus simple et mieux adaptée au projet existant.

L’objectif est de disposer d’une procédure de lancement fiable et reproductible.

Avant de lancer quoi que ce soit :

* Vérifie les services nécessaires.
* Vérifie les ports utilisés.
* Vérifie les images Docker disponibles.
* Vérifie les fichiers de configuration.
* Identifie les éventuelles dépendances externes.
* Vérifie si le frontend et le backend peuvent fonctionner indépendamment.

Attention aux conflits de ports avec le Mock LMC, qui utilise déjà les ports 5173 et 8000 dans son environnement local.

Ne modifie pas la configuration du Mock LMC pour résoudre un conflit de ports.

3. Lancer Engineering Companion

Une fois la procédure identifiée, essaie réellement de lancer l’application.

Je souhaite que tu puisses démarrer :

Le backend FastAPI

Il doit démarrer correctement et être accessible localement.

Le frontend React

Il doit être accessible depuis le navigateur de mon PC, via les ports exposés ou transférés par VS Code.

Les services complémentaires

Si Engineering Companion dépend d’autres composants, détermine lesquels sont indispensables à son démarrage.

Ne lance pas automatiquement toute une infrastructure complexe si elle n’est pas nécessaire.

Si certaines dépendances sont déjà accessibles dans notre environnement, privilégie leur réutilisation.

N’utilise pas de services externes supplémentaires sans nécessité.

4. Gérer les éventuels blocages

Il est possible que tu rencontres des difficultés liées :

* Aux dépendances Python ou Node.
* Aux certificats internes.
* Aux registres Artifactory.
* Aux variables d’environnement.
* Aux connexions réseau.
* À l’authentification Keycloak.
* Aux services backend.
* Aux accès Orq.ai.
* Aux conflits de ports.

Je souhaite que tu résolves les problèmes simples directement, sans transformer cette mission en refonte de l’infrastructure.

Réutilise autant que possible les images, dépendances, certificats et configurations déjà disponibles.

Ne désactive pas les contrôles de sécurité TLS.

Ne contourne pas l’authentification de production pour faciliter le lancement.

Ne modifie pas de credentials et ne les affiche jamais dans les logs.

Si une authentification nécessite mon intervention dans le navigateur, indique-moi simplement la procédure.

Si une dépendance externe empêche certaines fonctionnalités, distingue clairement :

* Ce qui peut démarrer localement.
* Ce qui fonctionne réellement.
* Ce qui nécessite un accès supplémentaire.
* Ce qui est actuellement bloqué.

Ne prétends pas qu’une fonctionnalité fonctionne si tu n’as pas pu la vérifier.

5. Vérifier le démarrage

Une fois l’application lancée, effectue uniquement les vérifications locales nécessaires.

Par exemple :

* Conteneurs Docker démarrés.
* Backend accessible.
* Frontend accessible.
* Réponses HTTP cohérentes.
* Absence d’erreurs bloquantes dans les logs.

Ne lance pas de tests complexes nécessitant des services externes.

Ne déclenche pas d’opérations de provisioning Orq.ai.

Ne modifie ni les agents ni les ressources existantes.

Je réaliserai moi-même les vérifications fonctionnelles dans le navigateur.

6. Contraintes importantes

Cette mission ne doit pas modifier le comportement métier d’Engineering Companion.

Ne développe pas de nouvelles fonctionnalités.

Ne commence pas l’intégration avec Mock LMC.

Ne modifie pas les autorisations, les agents ou les Routing Rules.

Ne modifie pas les autres dépôts.

Ne supprime aucun conteneur, volume ou fichier de configuration existant sans nécessité et sans m’en avertir.

Si une modification minimale est indispensable pour démarrer Engineering Companion, limite-la à cet objectif et explique-la.

Ne réorganise pas inutilement la codebase.

7. Résultat attendu

À la fin de cette mission, je veux :

1. Une présentation synthétique de l’architecture

Explique-moi comment Engineering Companion fonctionne, avec les principales responsabilités du frontend, du backend et des intégrations externes.

2. Une application démarrée localement

Je veux pouvoir ouvrir Engineering Companion dans le navigateur de mon PC.

Indique-moi les URL locales exactes.

3. Une procédure de lancement reproductible

Donne-moi les commandes nécessaires pour relancer Engineering Companion après un redémarrage.

4. Une liste des éventuelles limitations

Indique ce qui fonctionne et ce qui ne fonctionne pas encore, sans chercher à tout corriger si cela dépasse le lancement local.

5. Un récapitulatif des modifications

Liste les fichiers que tu as éventuellement dû modifier et explique pourquoi.

8. Point d’arrêt obligatoire

Une fois Engineering Companion lancé et accessible localement, arrête-toi.

Ne commence aucune modification liée à Mock LMC.

Ne commence aucune nouvelle fonctionnalité.

Je souhaite d’abord ouvrir personnellement l’application dans mon navigateur, vérifier qu’elle fonctionne et comprendre son fonctionnement actuel.

Attends ma validation explicite avant de poursuivre.

L’objectif de cette étape est simple : connaître Engineering Companion et être capable de le lancer de manière autonome et reproductible.