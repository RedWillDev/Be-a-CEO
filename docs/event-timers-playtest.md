# Timers et départ rapide

Le HUD affiche en permanence l'événement courant, son temps restant et les bonus correspondants. Préparation affiche le temps avant le prochain événement sans inventer de bonus. Les futurs événements de la roadmap ne sont pas encore implémentés.

- Bus : clients bonus +20 % pour le produit demandé ; vacanciers portés x2.
- Tendance : ventes locales du produit concerné +30 %.
- Commande collective : contribution +50 %, compteur de produits.
- Départ rapide : vitesse du personnage +50 % pendant 180 secondes à sa première arrivée sans vente antérieure. Marche 16 → 24 ; portage 11 → 16,5. Pas de changement de vitesse des véhicules ni des employés.

Le délai est une échéance serveur enregistrée dès l'acquisition du profil publié. Mort et reconnexion ne le renouvellent pas ; le temps continue hors ligne. Les profils déjà avancés n'obtiennent pas le bonus. En Studio, les profils temporaires repartent à zéro à chaque Stop → Play comme le reste du prototype.

Expiration pendant un portage et dépôt après expiration recalculent la vitesse correcte. Le timer client se base sur l'heure reçue du serveur, sans utiliser l'horloge locale pour attribuer le bonus. Les bonus clients existants restent ceux réservés à leur admission.

## Essais du joueur

1. Stop → Play : voir 03:00 et marcher plus vite.
2. Porter un colis puis un vacancier : bonus conservé, mais plus lent que sans charge.
3. Attendre la fin en portant un objet, puis déposer : retour à 11 puis 16, sans ancien boost persistant.
4. Réinitialiser le personnage pendant les trois minutes : garder uniquement le temps restant.
5. Observer chaque événement : bon bonus, bon compte à rebours, pas de valeurs négatives.
6. Vérifier téléphone portrait/paysage et menus ouverts : bandeau lisible, commandes accessibles.
7. Sur serveur de test publié : quitter/rejoindre sans obtenir trois minutes supplémentaires.

Génération Rojo et revue du code seulement côté assistant. Les assertions Studio ajoutées et ces essais restent à exécuter par le joueur.
