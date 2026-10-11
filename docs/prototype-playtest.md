# Prototype jouable — 11 octobre 2026

## Jouer

1. Lancer `scripts/serve.ps1`, connecter le plugin Rojo à `localhost:34872`.
2. Dans le lieu Be-a-CEO, lancer **Jouer / F5**. La ville est générée au démarrage du serveur ; elle n'apparaît pas encore en mode édition.
3. Le joueur reçoit un garage et 500 dollars fictifs. Dans **Marché**, commander 10 unités (ou comparer les trois produits et les trois fournisseurs).
4. Attendre la livraison de 7 à 15 secondes. Prendre le colis devant la porte et le porter au comptoir. Utiliser **Encaisser** à la caisse lorsqu'un client local attend ; un caissier recruté automatise ensuite ce service. Les ventes spéciales restent des bonus directs.
5. Réapprovisionner, adapter le prix et acheter une amélioration dans **Entreprise**. Les paliers exigent du cash et des ventes cumulées.
6. Dans **Lifestyle**, acheter une voiture ou un objet personnel avec la même caisse. Le jeu conserve le prix d'un prochain lot en réserve.
7. Monter sur le siège de sa voiture pour conduire avec les contrôles Roblox ; sauter pour descendre. Les véhicules sont réservés à leur propriétaire.
8. Sur la place au nord, accompagner le VIP jusqu'à son entreprise avec du stock : une vente x3. Le porteur ralentit ; la mort, le départ ou la conduite annulent le transport.
9. Dans **Objectifs**, récupérer les récompenses du parcours, le cadeau du calendrier et les trois missions quotidiennes. La progression des objectifs est sauvegardée hors Studio.
10. Participer aux événements : bus (+20 % sur ses achats), commande collective (jusqu'à 5 unités par contribution, payées x1,5), tendance surprise (+30 % sur les ventes locales du produit demandé).
11. Dans **Entreprise**, recruter et former les employés. Dès la boutique, recruter un responsable commandes puis activer si souhaité le réapprovisionnement automatique. Il dépense la caisse au prix du lot sélectionné, seuil de stock de 3 à 5 selon son niveau.
12. Pendant le bus, porter un vacancier jusqu'à son comptoir pour une vente x2. Un seul colis ou client peut être porté à la fois.

Voir [l'audit détaillé de la V1](v1-audit.md) : états de validation, employés, réception et restrictions du vol expérimental.

## Contenu implémenté

- Ville générée avec 8 parcelles, route, éclairage, place et végétation.
- Trois produits et trois fournisseurs, remise négociée de 10 %, livraison, stock et prix de vente.
- Cinq paliers visibles : garage, boutique, immeuble, siège, tour.
- Cinq véhicules débloqués selon le niveau de l'entreprise, vitesse de 30 à 68 studs/s.
- Montre portée par l'avatar, salon et sculpture visibles dans l'entreprise.
- Palettes de marque gratuites, clients animés, tendance tournante, VIP.
- Économie contrôlée par le serveur, validation des paramètres et limitation de fréquence.
- Sauvegarde hors Studio avec bail de session, tentatives de réécriture et blocage des achats après retard prolongé de sauvegarde.
- Cinq objectifs permanents, trois missions quotidiennes et calendrier de sept cadeaux sans perte après un jour manqué.
- Accords fournisseur : volume −10 %, fidélité −15 % après trois commandes, ou contrôle qualité +0,2 sans remise.
- Réputation, publicité limitée à deux minutes, préférences des clients disputés et tableau de session sans récompense compétitive.
- Événements de 90 secondes, bus et touristes visibles, camionnette de livraison, modèles de produits différenciés.
- Gains hors ligne : stock existant uniquement, une unité toutes les deux minutes à moitié prix, fenêtre maximale de quatre heures. Aucun réapprovisionnement hors ligne.

## Vérifications et limites

Les tests Studio de l'économie sont exécutés automatiquement par `EconomyChecks` sur des données isolées, sans toucher aux joueurs. Ils couvrent les débits, doublons, stocks, déblocages, réserve de caisse et rentabilité initiale.

`ProgressionChecks` ajoute les tests des objectifs, du calendrier, des missions quotidiennes, des accords fournisseurs, des ventes hors ligne et de l'initialisation des nouveaux champs. Les 69 assertions des deux suites ont réussi dans Studio le 11 octobre 2026. Le cadeau quotidien a également été encaissé par l'interface : 500 → 575 dollars.

La commande, la livraison, les ventes, l'achat et le déplacement d'une voiture ont été essayés dans Studio. Les graphismes utilisent des primitives Roblox créées pour le projet : aucune ressource externe ni crédit Meshy consommé.

**La progression Studio est temporaire.** Le mode publié utilise `BeACEO_Profiles_v1`. La reconnexion sur un vrai serveur, les erreurs DataStore réelles, les parties à huit joueurs et les appareils tactiles restent à valider avant une publication commerciale. La compilation Rojo seule n'est pas un test d'exécution Luau.

La conduite est cinématique sur terrain plat, avec contrôle d'obstacles ; ce n'est pas une simulation automobile. Les accords de négociation sont déterministes et leurs effets annoncés. Les alliances, le prestige, l'espionnage, les rivalités consenties avec agents de sécurité, la fidélité individuelle des clients et la monétisation ne sont pas encore implémentés. Le jeu n'est pas présenté comme une version commerciale terminée.

## Scénarios restant à valider

- Deux puis huit joueurs : parcelles distinctes, concurrence, contributions simultanées plafonnées à 30, départ du porteur VIP, impossibilité de conduire le véhicule d'autrui.
- Sur serveur privé publié : sauvegarde, reconnexion, gains hors ligne consommés une seule fois, verrou de profil entre deux serveurs et simulation d'échec DataStore.
- Téléphone portrait/paysage : lisibilité, défilement, achats, sortie de véhicule, joystick et VIP.
- Équilibrage de longue durée jusqu'à la tour ; coûts des voitures et intérêt réel de la publicité. Aucun revenu garanti par une campagne.

Les scripts gérés par Rojo se modifient dans `src`. La liaison actuelle est **fichiers → Studio** ; les modifications faites directement dans Studio ne sont pas automatiquement récupérées dans Git. Sauvegarder le lieu et versionner les sources sont deux actions distinctes.
