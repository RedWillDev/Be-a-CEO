# Prototype jouable — 11 octobre 2026

## Jouer

1. Lancer `scripts/serve.ps1`, connecter le plugin Rojo à `localhost:34872`.
2. Dans le lieu Be-a-CEO, lancer **Jouer / F5**. La ville est générée au démarrage du serveur ; elle n'apparaît pas encore en mode édition.
3. Le joueur reçoit un garage et 500 dollars fictifs. Dans **Marché**, commander 10 unités (ou comparer les trois produits et les trois fournisseurs).
4. Attendre la livraison de 7 à 15 secondes. Les clients locaux achètent automatiquement ; un client disputé du serveur compare qualité, prix et tendance toutes les 9 secondes.
5. Réapprovisionner, adapter le prix et acheter une amélioration dans **Entreprise**. Les paliers exigent du cash et des ventes cumulées.
6. Dans **Lifestyle**, acheter une voiture ou un objet personnel avec la même caisse. Le jeu conserve le prix d'un prochain lot en réserve.
7. Monter sur le siège de sa voiture pour conduire avec les contrôles Roblox ; sauter pour descendre. Les véhicules sont réservés à leur propriétaire.
8. Sur la place au nord, accompagner le VIP jusqu'à son entreprise avec du stock : une vente x3. Le porteur ralentit ; la mort, le départ ou la conduite annulent le transport.

## Contenu implémenté

- Ville générée avec 8 parcelles, route, éclairage, place et végétation.
- Trois produits et trois fournisseurs, remise négociée de 10 %, livraison, stock et prix de vente.
- Cinq paliers visibles : garage, boutique, immeuble, siège, tour.
- Cinq véhicules débloqués selon le niveau de l'entreprise, vitesse de 30 à 68 studs/s.
- Montre portée par l'avatar, salon et sculpture visibles dans l'entreprise.
- Palettes de marque gratuites, clients animés, tendance tournante, VIP.
- Économie contrôlée par le serveur, validation des paramètres et limitation de fréquence.
- Sauvegarde hors Studio avec bail de session, tentatives de réécriture et blocage des achats après retard prolongé de sauvegarde.

## Vérifications et limites

Les tests Studio de l'économie sont exécutés automatiquement par `EconomyChecks` sur des données isolées, sans toucher aux joueurs. Ils couvrent les débits, doublons, stocks, déblocages, réserve de caisse et rentabilité initiale.

La commande, la livraison, les ventes, l'achat et le déplacement d'une voiture ont été essayés dans Studio. Les graphismes utilisent des primitives Roblox créées pour le projet : aucune ressource externe ni crédit Meshy consommé.

**La progression Studio est temporaire.** Le mode publié utilise `BeACEO_Profiles_v1`. La reconnexion sur un vrai serveur, les erreurs DataStore réelles, les parties à huit joueurs et les appareils tactiles restent à valider avant une publication commerciale. La compilation Rojo seule n'est pas un test d'exécution Luau.

La conduite est un prototype cinématique sur terrain plat, avec contrôle d'obstacles ; ce n'est pas une simulation automobile. La négociation est pour l'instant un accord déterministe sur le volume. La réputation persistante, les bus de touristes, les ventes hors ligne, la fidélisation, les missions quotidiennes, les alliances, le prestige et la monétisation restent des étapes futures du document de conception.

Les scripts gérés par Rojo se modifient dans `src`. La liaison actuelle est **fichiers → Studio** ; les modifications faites directement dans Studio ne sont pas automatiquement récupérées dans Git. Sauvegarder le lieu et versionner les sources sont deux actions distinctes.
