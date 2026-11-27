Je valide globalement ton analyse, avec les arbitrages suivants :

* Éligibilité : tout utilisateur actif disposant effectivement du Product Access Engineering Companion dans le projet, indépendamment de son rôle administratif ou de ses droits sur les autres produits. Réutilise strictement le mécanisme LMC/SpiceDB existant.
* Identity globale par utilisateur, réutilisable entre projets.
* Renseigne les trois champs Orq : external_id stable basé sur Keycloak, display name et email provenant du modèle utilisateur existant. Vérifie les champs sources exacts. Une modification d’email ne doit pas créer une nouvelle Identity.
* Adoption uniquement après vérification exacte de l’identité et de son rattachement légitime.
* HTTPX et configuration TLS déjà qualifiée.
* Clés temporaires : scopes minimaux, TTL court, nettoyage automatique des orphelins, aucun token persisté.
* Permission explicite de provisioning, réutilisant les rôles et périmètres existants, distincte du Product Access qui détermine l’éligibilité.
* Aucun rollback des succès partiels ni suppression d’Identity lors du retrait d’un projet.

Concernant PLAN/APPLY, je souhaite concevoir dès maintenant une logique de décision commune aux deux modes. PLAN doit rester strictement non mutatif ; APPLY doit revalider l’état avant exécution. Propose une intégration progressive sans dupliquer la logique métier. Le PLAN global dans l’interface pourra être ajouté ultérieurement.

Je valide le Workflow Identity versionné séparément, avec mutualisation maximale des fondations C5/C6 et possibilité d’orchestration globale future via un seul bouton.

Commence uniquement ID-CRED-1 : contrats, Protocols et fakes, depuis la dernière référence cumulative qualifiée.

Adapte le découpage si mes arbitrages le nécessitent. Signale les garanties fournisseur non démontrées.

Toutes nos contraintes permanentes restent applicables. Aucun appel distant ni migration à cette étape. Teste, documente et actualise la mémoire projet avant ID-CRED-2.