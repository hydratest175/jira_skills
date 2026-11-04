Nous avons terminé la première étape du Mock LMC.

L’application React + FastAPI + SQLite fonctionne maintenant avec Docker Compose.

J’ai créé un projet, ajouté des utilisateurs, configuré les modèles et les budgets.

Nous allons maintenant commencer l’intégration réelle avec Orq.ai, progressivement.

OBJECTIF

Implémenter uniquement la création automatique d’un projet Orq.ai à partir d’un projet existant dans le Mock LMC.

Le workflow attendu est :

Mock LMC → Bouton Provisionner → FastAPI → SDK Orq.ai → Création du projet.

IMPLÉMENTATION

Travaille uniquement dans mock-lmc-orq-poc.

Réutilise les patterns du SDK Orq.ai déjà présents dans :

use-case-engineering-companion/thales-orq-provisioning

Le SDK disponible est orq-ai-sdk 4.13.14.

Utilise une Management Key avec les permissions nécessaires pour créer les projets.

La clé doit rester exclusivement côté backend, sans être enregistrée dans SQLite ni exposée au frontend.

Implémente la création du projet Orq.ai en utilisant son nom et sa description définis dans le Mock LMC.

Enregistre dans SQLite le mapping entre l’identifiant du projet Mock LMC et l’identifiant du projet Orq.ai.

Le provisioning doit être idempotent : cliquer plusieurs fois sur Provisionner ne doit pas créer plusieurs projets Orq.ai identiques.

Prévois un mode dry-run et une gestion simple des erreurs.

Le frontend doit afficher le résultat du provisioning, notamment son statut et l’identifiant du projet Orq.ai créé.

IMPORTANT

Pour cette étape, ne provisionne aucune autre ressource.

Ne crée pas encore :

* Les modèles.
* Les Identities.
* Les budgets.
* Les agents.
* Les folders.
* Les Routing Rules.

Ne modifie pas les repositories existants.

Ne développe pas de tests d’intégration automatisés inutiles.

Ne lance pas d’opération réelle contre Orq.ai sans mon accord.

Je vérifierai moi-même dans l’interface Orq.ai que le projet a bien été créé.

RÉSULTAT ATTENDU

Je veux pouvoir ouvrir le Mock LMC, sélectionner mon projet test_auto, cliquer sur Provisionner et retrouver automatiquement le projet correspondant dans Orq.ai.

Explique-moi les éventuelles variables d’environnement nécessaires, sans afficher de secrets.

Indique-moi comment reconstruire et relancer le POC avec Docker Compose.

Ne passe pas à l’étape suivante avant ma validation.

Réponds en français.