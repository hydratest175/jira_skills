Je valide ton plan.

Je t’autorise à arrêter la pile temporaire C8 sans supprimer ses volumes, à préparer une nouvelle pile locale isolée PostgreSQL 18.4/SpiceDB, à qualifier le pont Alembic, à installer le SDK Temporal verrouillé et à adapter le harness fake-Orq.

Avant d’exécuter les scripts habituels, vérifie qu’ils ne ciblent aucune base, aucun volume ni aucun service existant. En cas de conflit, arrête-toi.

Conserve notre procédure habituelle de lancement et toutes les contraintes de project-memory.

Pour le premier provisioning intégré :

* Utilise exclusivement un projet synthétique et un gateway Orq factice, sans possibilité de fallback réel.
* Vérifie l’absence d’anciennes opérations réclamables.
* Crée l’opération depuis l’interface, Dispatcher arrêté.
* Avant son activation, vérifie qu’une seule opération approuvée est réclamable et qu’aucune autre soumission ne peut intervenir pendant le test.
* Critères de réussite : UI SUCCEEDED, Saga SUCCEEDED, outbox STARTED, mapping cohérent, Temporal COMPLETED, exactement un POST Orq simulé et zéro DELETE.

Avance directement sur les préparatifs locaux. Lorsque mon intervention est nécessaire pour le tunnel Temporal, donne-moi les commandes exactes.

Attends mon autorisation avant la qualification distante.

Documente les résultats et actualise la mémoire projet. Ne commence pas C9.