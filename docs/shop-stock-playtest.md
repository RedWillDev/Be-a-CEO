# Rayons et postes des employés

Ajout : boutique prolongée de 12 studs vers l'arrière, bureaux Commandes et Direction fixes, zone de réception conservée à droite. Caisse et livraison gardent leurs positions.

Stock : 50 / 75 / 100 / 125 / 150 unités selon le niveau. Chaque amélioration ajoute un rayon de 25 places. Une unité affichée correspond à une unité en stock ; elle disparaît à la vente, pas pendant le choix en rayon. Les commandes et réceptions utilisent la même limite que le HUD.

Clients : arrivée depuis la ville, arrêt de 1,5 seconde devant un rayon approvisionné, puis file et encaissement. Les vacanciers portés suivent aussi le parcours d'achat. Sans caissier, le joueur encaisse toujours lui-même. Pas de nouvel achat en Robux ni de modification du format des sauvegardes.

## Essais à effectuer par le joueur après synchronisation Rojo et Stop → Play

1. Démarrer sans stock : rayons vides, capacité 50, bureaux identifiés.
2. Commander et rapporter un lot : dix produits visibles immédiatement.
3. Suivre un passant : entrée, rayon, file, attente. Encaisser : neuf produits et paiement unique.
4. Porter un vacancier : rayon puis file, bonus x2 lors du paiement.
5. Recruter commandes et gérant aux niveaux requis : employés fixes derrière leur bureau ; panneau reflétant activation ou pause.
6. Recruter réception et commander : trajet aller-retour inchangé, rayons remplis au retour.
7. Améliorer : un rayon et 25 places de plus, stock conservé ; vérifier aussi les boutiques des deux côtés du boulevard.
8. Vider/liquider le stock pendant un choix en rayon : aucun paiement sans produit, clients libérés.
9. Vérifier une amélioration ou un changement de couleur pendant une livraison et une file active.

Des assertions isolées de capacité et d'affichage sont ajoutées aux scripts Studio. Elles n'ont pas été exécutées par l'assistant ; les essais en jeu restent à la charge du joueur.
