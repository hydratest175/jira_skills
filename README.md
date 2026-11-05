Mission — Première communication entre Mock LMC et Engineering Companion

Contexte

Nous avons désormais deux applications fonctionnelles en local :

1. Mock LMC : gestion des projets, utilisateurs, autorisations et provisioning des ressources Orq.ai.
2. Engineering Companion : application React/FastAPI utilisant les agents Orq.ai.

Tu as déjà analysé la codebase d’Engineering Companion et tu es parvenu à lancer l’application localement.

Nous pouvons donc commencer progressivement leur intégration.

Cette mission concerne exclusivement la communication entre les deux backends et la récupération des configurations.

Ne modifie pas encore l’exécution des agents ni le fonctionnement du chat.

1. Objectif

Permettre au backend Engineering Companion de récupérer les configurations enregistrées dans le Mock LMC.

À partir d’un utilisateur identifié, nous souhaitons pouvoir retrouver :

* Les projets auxquels il appartient.
* Son rôle dans chaque projet.
* Les modèles disponibles dans chaque projet.
* Les modèles qui lui sont réellement autorisés.
* Son modèle par défaut.
* L’état de provisioning du projet.
* Les agents Orq.ai déjà provisionnés pour ce couple utilisateur/projet.
* La référence exacte de son orchestrateur Engineering Companion.

Les identifiants d’agents doivent provenir des mappings existants du Mock LMC.

Ne pas reconstruire approximativement les clés Orq.ai.

2. Commencer par inspecter l’existant

Avant toute modification, analyse :

Côté Mock LMC

* Les endpoints FastAPI existants.
* Les modèles SQLAlchemy.
* Les memberships.
* Les autorisations de modèles.
* Les configurations des modèles par projet.
* Les mappings des ressources Orq.ai.
* Les références des agents personnels.
* Les statuts de synchronisation.

Côté Engineering Companion

* L’identification actuelle des utilisateurs.
* L’authentification Keycloak existante.
* La gestion actuelle des projets.
* Les éventuelles intégrations LMC déjà présentes.
* Les services et clients HTTP existants.
* La manière dont les agents Orq.ai sont actuellement référencés.

Attention : Engineering Companion possède potentiellement déjà des mécanismes d’intégration LMC.

Réutilise-les lorsqu’ils sont adaptés plutôt que de créer une architecture parallèle inutile.

3. Définir un contrat de lecture

Nous souhaitons une communication REST entre les deux backends.

Le Mock LMC doit exposer les informations nécessaires à Engineering Companion.

Engineering Companion doit disposer d’un client permettant de les récupérer.

Réutilise les endpoints existants lorsque c’est possible.

Sinon, ajoute uniquement les endpoints de lecture manquants.

Privilégie un contrat simple, clair et typé.

La réponse doit permettre de connaître, pour chaque projet accessible à un utilisateur :

* L’identifiant local du projet.
* L’identifiant du projet Orq.ai, lorsqu’il existe.
* Le nom du projet.
* Le rôle de l’utilisateur.
* Les modèles autorisés.
* Le modèle par défaut.
* Les références Orq.ai de ses agents provisionnés.
* Les éventuels statuts indiquant qu’une ressource n’est pas encore synchronisée.

N’expose jamais de Management Key, de PAT, de clé fournisseur ni d’autre credential.

Les références techniques nécessaires à l’exécution des agents doivent rester côté backend.

4. Correspondance des utilisateurs

Le Mock LMC possède actuellement des utilisateurs synthétiques.

Engineering Companion utilise un véritable mécanisme d’authentification.

Je veux que tu étudies comment associer proprement un utilisateur Engineering Companion à son utilisateur Mock LMC.

Privilégie un identifiant stable, par exemple le sub Keycloak ou un external_id, selon ce que les applications utilisent réellement.

Pour cette première étape locale, une correspondance de développement explicite peut être mise en place si nécessaire.

Cependant :

* Elle doit être limitée à l’environnement de développement.
* Elle ne doit pas permettre à un utilisateur de s’attribuer arbitrairement l’identité d’un autre.
* Elle ne doit pas modifier ni affaiblir l’authentification existante.
* Elle ne doit pas être considérée comme une solution de sécurité définitive.

Si le Mock LMC ne dispose pas actuellement des informations nécessaires à une correspondance fiable, signale-le et propose la solution minimale adaptée au POC.

5. Implémentation attendue

Je souhaite une première intégration backend simple.

Le backend Engineering Companion doit être capable d’interroger le Mock LMC et de récupérer les configurations correspondant à un utilisateur.

Tu peux prévoir un endpoint de lecture ou de diagnostic permettant de vérifier le résultat de cette intégration.

Cette première étape doit nous permettre de confirmer :

1. Engineering Companion communique correctement avec Mock LMC.
2. Le Mock LMC retourne les projets correspondant à l’utilisateur identifié.
3. Les modèles autorisés sont correctement récupérés.
4. Le modèle par défaut est correctement identifié.
5. Les références des agents existants sont récupérées.
6. Les situations où les ressources sont absentes ou non synchronisées sont correctement traitées.

Attention aux communications réseau entre les conteneurs Docker.

Ne suppose pas que localhost désigne la même machine depuis tous les conteneurs.

Utilise la configuration réseau réellement disponible.

6. Contraintes

Cette étape doit rester volontairement limitée.

Ne modifie pas :

* Le provisioning Orq.ai.
* Les templates des agents.
* Les prompts.
* Les modèles des agents.
* Le fonctionnement du chat.
* Les appels MCP.
* Les Routing Rules.
* Les budgets.
* Les Identities.
* La nouvelle interface du Mock LMC.

Ne crée pas de nouveaux agents.

Ne déclenche aucune opération de provisioning.

Ne modifie aucune ressource Orq.ai existante.

La communication Mock LMC → Engineering Companion doit être utilisée uniquement en lecture pour le moment.

Ne développe pas encore de sélection dynamique des modèles.

Ne remplace pas encore les agents actuellement utilisés par Engineering Companion.

7. Vérifications

Réalise les vérifications locales nécessaires.

Privilégie les tests unitaires ou les tests de contrat avec des données simulées lorsqu’ils sont utiles.

Ne lance pas de tests complexes sur des environnements externes.

Je réaliserai les vérifications manuelles du fonctionnement des applications.

8. Résultat attendu

À la fin de cette mission, je souhaite :

1. Un backend Engineering Companion capable de communiquer avec le Mock LMC.
2. Une récupération fonctionnelle des projets et configurations d’un utilisateur.
3. Une récupération des références des agents déjà provisionnés.
4. Une gestion claire des erreurs.
5. Une explication des fichiers modifiés.
6. Une procédure simple pour vérifier manuellement que l’intégration fonctionne.

Point d’arrêt obligatoire :

Une fois la communication entre les deux backends fonctionnelle, arrête-toi.

Ne commence pas à modifier le frontend Engineering Companion.

Ne commence pas à utiliser les agents provisionnés dans le chat.

Je souhaite d’abord vérifier que les données récupérées sont correctes.

Nous poursuivrons ensuite l’intégration, étape par étape.