# Timers et départ rapide

## Présentation circulaire

Les anciens badges rectangulaires sont remplacés par des pastilles rondes : multiplicateur au centre, nom au-dessus et compte à rebours dessous. Argent jaune, vitesse cyan, bus orange, tendance violette, collectif vert ; préparation neutre sans faux bonus.

Le contour comporte 24 segments représentant le temps restant. Une pulsation douce de 3,5 % au maximum intervient pendant les 15 dernières secondes, sans clignotement ni changement du délai réel. Les pastilles de départ disparaissent à expiration. Le format est compact en paysage ; le détail complet des effets reste disponible dans Missions.

À vérifier par le joueur : textes centrés, couleurs, contour qui se vide, expiration, menus ouverts et téléphone dans les deux orientations. Aucune économie ni durée modifiée par cette refonte graphique.

Le HUD affiche en permanence l'événement courant, son temps restant et les bonus correspondants. Préparation affiche le temps avant le prochain événement sans inventer de bonus. Les futurs événements de la roadmap ne sont pas encore implémentés.

- Bus : clients bonus +20 % pour le produit demandé ; vacanciers portés x2.
- Tendance : ventes locales du produit concerné +30 %.
- Commande collective : contribution +50 %, compteur de produits.
- Départ rapide : vitesse du personnage +50 % pendant 180 secondes à sa première arrivée sans vente antérieure. Marche 16 → 24 ; portage 11 → 16,5. Pas de changement de vitesse des véhicules ni des employés.

Le départ rapide double aussi l'argent des ventes en jeu pendant la même échéance : caisse manuelle, caissier et contributions collectives. Il se multiplie avec le bonus du client (vacancier x2 puis départ x2 = x4). Cadeaux, récompenses de missions, remboursements et gains hors ligne ne sont pas doublés. Deux badges distincts affichent vitesse et ventes avec le temps restant. Les anciens profils dont le boost est terminé ne reçoivent pas une nouvelle durée.

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
8. Vendre une sneaker au prix normal pendant le boost : 80 $ au lieu de 40 $, une seule unité consommée ; revenir à 40 $ après expiration. Tester aussi caissier, vacancier et cadeau non doublé.
9. Vérifier « Ta boutique », le repère du colis et celui de la caisse ; les autres joueurs ne doivent pas voir ces indications personnelles. Vérifier leur reconstruction après amélioration du bâtiment.

Génération Rojo et revue du code seulement côté assistant. Les assertions Studio ajoutées et ces essais restent à exécuter par le joueur.
