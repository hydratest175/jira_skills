Je valide ID-CRED-3. Passe à CRED-4 dans un nouveau workspace cumulatif isolé.

Implémente les gateways Identity et API-key ainsi que le cycle de vie des clés temporaires, en réutilisant le Mock LMC, les contrats ID-CRED-1, la persistance ID-CRED-3 et notre configuration HTTPX/TLS qualifiée.

Points de vigilance :

* Création, récupération et mise à jour des Identities avec external_id, display name et email.
* Vérification des véritables contrats Orq : endpoints, scopes, TTL, unicité et ownership.
* Clés temporaires conservées uniquement en mémoire, jamais dans PostgreSQL, Temporal ou les logs.
* Nettoyage sécurisé des clés, y compris après interruption, uniquement lorsque leur ownership est démontré.
* Aucun retry mutatif aveugle ni suppression d’Identity.
* PLAN non mutatif et logique de décision commune avec APPLY.

Toute garantie fournisseur non démontrée doit rester explicitement identifiée et bloquer les mutations concernées.

Qualifie avec des transports simulés et PostgreSQL réel. Réutilise les procédures documentées et limite les explorations redondantes.

Toutes nos règles permanentes restent applicables. Actualise les preuves, la documentation et la mémoire projet.

Aucun appel distant. Ne commence pas ID-5.