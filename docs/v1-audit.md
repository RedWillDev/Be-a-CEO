# Audit V1 — 11 octobre 2026

Cet audit distingue présence du code et validation réelle. La V1 n'est pas encore certifiée prête à publier.

## Correction clients et caisse — 12 octobre 2026

### Réceptionnaire actif — essais joueur à venir

Le rangement temporisé 12/8/4 secondes est remplacé par un trajet réel. Le réceptionnaire attend à droite de l'entrée, part après 3/2/1 secondes selon son rang, atteint le colis, le prend avec `Carry`, puis revient au point de rangement intérieur. Sa vitesse est de 8/10/12 studs par seconde. Le stock n'est crédité qu'après arrivée vérifiée, via la fonction unique `Receive`. L'interface décrit désormais ce comportement et un indicateur affiche sa tâche.

Un joueur peut prendre le colis tant que l'employé ne l'a pas saisi ; cela annule le trajet. Pendant le retour de l'employé, le prompt est désactivé et les interactions sont refusées côté serveur. Trajet échoué, profil indisponible, employé détruit/remplacé ou délai de 45 secondes : annulation, détachement et remise du colis au point de livraison, sans crédit de stock. Les tâches ne sont pas persistées ; le colis en attente reste enregistré comme auparavant. Le caissier reste fixe à son poste. Construction locale seulement, aucun essai en jeu effectué par l'assistant.

### File d'attente — implémentée, essais joueur à venir

`Customers.luau` remplace la place unique par trois places FIFO devant la caisse. Les clients sont toujours des passants existants ; leurs places sont réservées pendant l'approche pour éviter la surcapacité. Seul le premier client arrivé à son emplacement peut être encaissé, manuellement ou par le caissier. Chaque suivant marche jusqu'à sa nouvelle place avant d'être servi ; son délai de service commence à son arrivée. Aucun prélèvement de stock ni paiement n'a lieu à l'entrée dans la file. Le nombre de réservations ne dépasse pas le stock au moment de l'admission.

Indicateurs au-dessus des clients et compteur File 0/3 dans l'interface. Sortie par le côté du comptoir. La file est libérée en rupture de stock et au départ du propriétaire ; un trajet échoué ou un PNJ détruit ne conserve pas sa place. Les clients portés rejoignent la même file sans priorité et restent portés si elle est pleine. Construction locale et lecture du code uniquement : aucun test en jeu lancé par l'assistant.

### Vacanciers et portage (à valider par le joueur)

Refonte : `Carry.luau` centralise `new`, `Attach`, `Detach` et `Release`, avec profils `Parcel` et `Person` (vacanciers/VIP). Chaque profil définit son décalage, son orientation et ses cibles de mains. Colis, vacanciers et VIP utilisent tous un Motor6D vers le personnage, sans boucle de repositionnement de l'entité portée. La classe gère masse, collisions, état du passager, vitesse, transition de prise et nettoyage à la mort/destruction. Les bras R15 utilisent des cibles de mains et de coudes ; les bras R6 rigides suivent les cibles sans coude articulé. L'animation du PNJ ne peut plus ancrer sa racine pendant le portage. Le rangement reste validé côté serveur. Construction locale contrôlée ; rendu et interactions laissés au joueur.

Dernier ajustement colis : réception vérifiée à chaque Heartbeat serveur dans l'emprise intérieure de la boutique du porteur (pas sur le trottoir ni dans une autre boutique). La réception manuelle ne dépend plus de la boucle économique à une seconde. Les contrôles de profil, produit, capacité et crédit unique restent centralisés dans `Receive`. Les mains R15 suivent deux cibles sur les côtés du carton par IKControl ; les bras R6 sont orientés vers les points de prise. Contrôles retirés à chaque interruption/rangement. Ces changements sont à valider visuellement par le joueur, sans essai lancé par l'assistant.

Correction colis : suppression du repositionnement une fois par seconde. Le colis est attaché au personnage par un joint, sans collision et sans masse ajoutée, avec transition de prise en main de 0,3 seconde. Dimensions adaptées aux bras ; pose des bras activée pour colis et vacanciers, avec retour progressif à l'animation normale. Le joint et la pose sont retirés au dépôt, au rangement ou à l'interruption. Le retour du colis à son emplacement de livraison lors d'une interruption reste le comportement de sécurité existant. Construction locale uniquement ; rendu en jeu à vérifier par le joueur.

Tenue distincte : chapeau, lunettes, chemise à motifs, short, sandales et sac. Les vacanciers parcourent désormais le trottoir entier à une vitesse proche des passants. Seuls les vacanciers disposent du prompt de portage parmi ces piétons ; le VIP garde son interaction spéciale existante.

La documentation Roblox des animations par défaut ne fournit pas de portage à deux personnages. Une pose procédurale spécifique a donc été ajoutée (bras du porteur relevés, jambes du vacancier repliées), sans animation tierce ni achat. Le suivi du vacancier passe de la boucle économique à une mise à jour à chaque image serveur. La marche Roblox reste inchangée. Relâcher le vacancier le remet en promenade au lieu de le supprimer ; une limite de durée nettoie les vacanciers sortis du groupe de leur événement.

Contrôles limités au code et à la construction locale : **aucun essai en jeu lancé par l'assistant pour cette passe**, à la demande du joueur. Le rendu de la pose, les proportions R6/R15 et les interruptions sont à vérifier par lui.

Cette passe remplace les déplacements visuels et ventes immédiates décrits plus bas :

- 36 passants (au lieu de 10), modèles Roblox R6 standards avec couleurs variées, animations Roblox de marche et d'attente chargées par le serveur. Déplacement physique par Humanoid, sans interpolation du modèle pour marcher.
- Le magasin attire un passant déjà présent sur son côté du boulevard. Il suit le trottoir, entre par la façade ouverte, rejoint le comptoir, attend son paiement puis retourne dans la ville. Une place de service par magasin pour cette version, pas encore de file de plusieurs clients.
- Aucun encaissement de client automatique sans caissier, y compris clients disputés, bonus touristes et clients transportés. Les ventes hors ligne exigent également un caissier. Les contributions collectives restent une action explicite du joueur.
- Le caissier sert seulement un client réellement arrivé au comptoir, après son délai de service. Stock épuisé ou trajet échoué : pas de vente.
- Validation Studio : **350 assertions réussies** ; 36 PNJ standards présents ; animation de marche chargée et jouée, déplacement mesuré. Client au comptoir observé. Pendant 20 secondes loin de la caisse et sans caissier : 6 ventes, 4 produits et 501 dollars inchangés. Une interaction manuelle isolée vend ensuite un produit. Après recrutement du caissier, une vente supplémentaire se réalise sans interaction.
- Ancienne animation procédurale cliente retirée car remplacée par les pistes Roblox. Pas d'achat d'assets ni utilisation de Meshy.

Restent à tester : file multi-client, obstacles dynamiques, charge mobile, concurrence à huit joueurs et parcours complets de portage après cette modification. La navigation utilise des étapes prédéfinies, pas un calcul de chemin autour des véhicules.

Dernière exécution Studio : **87 assertions réussies** (économie 40, progression 29, opérations 18). Vérification par l'interface : commande 180 $, colis visible sans créditer le stock, recrutement du réceptionnaire 150 $, disparition du colis et marchandises disponibles pour les ventes. Le portage manuel complet, les vacanciers et les transferts entre deux vrais joueurs restent à tester de bout en bout.

| Critère | État | Preuve / travail restant |
|---|---|---|
| Ville, 8 parcelles, garages visitables | Présent, démarrage solo vérifié | Construction `World.Build`, huit emplacements. Charge à huit joueurs à tester. |
| Attribution et libération | Présent | Attribution serveur ; libération après départ. Reconnexion et départs simultanés à tester. |
| Sauvegarde fiable | Implémentée, non validée en production | Verrou de session, tentatives, pause en cas d'échec. Studio utilise des profils temporaires ; tests sur serveur publié indispensables. |
| Trois fournisseurs et trois produits | Présent et testé | Tests de rentabilité des neuf combinaisons. |
| Négociation, commandes, ventes, clients | Présent | Trois accords. Nouvelle réception manuelle et caisse locale : validation interactive à compléter après ce changement. |
| Garage → boutique, personnalisation | Présent | Cinq niveaux, quatre palettes, luxe et véhicules. Parcours complet à équilibrer. |
| Clients locaux et disputés | Présent | Locaux encaissés au comptoir ou par caissier. Les ventes spéciales restent des bonus directs. Concurrence à plusieurs à tester. |
| Événement et portage | Présent | VIP, bus, commande collective, tendance ; ajout des vacanciers portables. Interruptions et concurrence à vérifier à plusieurs. |
| Mobile et tutoriel | Partiel | Interface adaptable, prompts tactiles Roblox, guide commande → colis → caisse → équipe. Pas encore vérifié sur téléphone réel. |
| Aucune perte/duplication | Non certifié | Suites de tests isolées ; indispensables mais insuffisantes pour prouver la fiabilité des sauvegardes réseau. |
| Boucle compréhensible et amusante | Premier retour positif | Retour utilisateur sur l'ancien prototype ; à réévaluer après réception manuelle et recrutement. |

## Ajouts de gestion

- Caissier : 120 / 240 / 360 dollars ; automatise les clients locaux et accélère le service.
- Réceptionnaire : 150 / 300 / 450 dollars ; range les colis après 12 / 8 / 4 secondes.
- Responsable commandes : entreprise niveau 2, 250 / 500 / 750 dollars ; seuil de stock 3 / 4 / 5, activation explicite du réapprovisionnement.
- Gérant : entreprise niveau 4, 1 200 / 2 400 / 3 600 dollars ; sur activation explicite, recrute et forme les trois autres postes jusqu'à son niveau, garde deux lots de réserve. Ne dépense pas en bâtiments ou achats personnels.
- Tous ces frais sont ponctuels dans cette version. Pas de salaires récurrents cachés. Les employés sont visibles mais leurs tâches sont actuellement temporisées, sans trajet animé.

## Colis et rivalité

Le stock n'est crédité qu'après réception du colis. Un colis non réceptionné bloque la prochaine commande et le changement de gamme. Les colis en attente restent dans le profil ; les états de portage ne sont pas sauvegardés. Déconnexion ou interruption repose le colis, sans créer une deuxième marchandise.

Le vol est **expérimental et limité à Studio** : niveau 2 des deux entreprises, consentement des deux joueurs, protection initiale de 20 secondes, même gamme chez le voleur, remboursement de 50 % du prix au propriétaire. Aucun vol d'argent ou de bâtiment. En serveur publié, le vol est bloqué tant qu'un mécanisme transactionnel durable entre deux profils et ses tests de panne ne sont pas disponibles.

## Validation à terminer avant lancement

### Passe visuelle du 11 octobre

Dernière exécution Studio : **349 assertions réussies** (87 existantes et 262 vérifications des personnages et véhicules). Démarrage et déplacement des passants observés dans Studio ; bus visible en jeu.

- PNJ articulés, visages, cheveux, accessoires par rôle, animations procédurales de marche et d'attente.
- Passants sur les trottoirs, promenades des touristes après arrivée du bus et petits déplacements des employés. Ces déplacements sont décoratifs, sur parcours prédéfinis : les tâches des employés restent temporisées, sans navigation jusqu'aux colis.
- Voitures, camionnette et bus enrichis : vitrages, roues et jantes, phares, sièges et détails de carrosserie. Arrivée animée du bus et départ de la camionnette.
- Modèles stylisés construits localement, sans Meshy ni achat d'assets. La conduite, les performances mobiles et les interactions de portage doivent encore être vérifiées après cette passe.

1. Parcours complet manuel, puis automatisé, jusqu'à la tour.
2. Deux puis huit clients : colis, vacanciers, VIP, départs, décès, véhicules, double interaction.
3. Téléphone portrait/paysage et conduite tactile.
4. Sauvegardes réelles, reconnexions, échecs réseau et verrou de profil.
5. Retours joueurs : compréhension, temps jusqu'au premier employé et envie de revenir.
