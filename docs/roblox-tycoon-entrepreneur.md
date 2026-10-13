# Roblox Tycoon Entrepreneur : Document de concept

> Du garage à ta propre tour : crée ta marque et conquiers la ville.

Version consolidée du 13 octobre 2026. Overhaul validé : première réussite guidée, transformations architecturales, vacanciers, collections et événements. Cette roadmap remplace les anciennes priorités. Les fonctionnalités prévues ne sont pas présentées comme déjà réalisées ; durées et valeurs restent à tester.

Cible de travail : jeunes adolescents, environ 10–14 ans (fourchette proposée, pas encore confirmée précisément). Promesse : « Je commence dans un garage, je monte mon équipe, puis je deviens le patron le plus stylé du quartier. »

## 1. Vision et principes

Le joueur démarre dans un garage, choisit des produits, trouve des fournisseurs sur une plateforme fictive, négocie, produit et vend. Il fait grandir son entreprise dans une ville partagée où chacun voit les bâtiments et boutiques des autres.

Deux plaisirs structurent le jeu : prendre de bonnes décisions commerciales et vivre des situations amusantes avec les autres joueurs. La réussite est visible : enseigne, file de clients, livraisons et changements complets d'architecture, jusqu'au gratte-ciel new-yorkais. Il ne s'agit pas seulement d'empiler des étages identiques.

- Le progrès durable reste acquis : marque, bâtiments et déblocages.
- Le joueur trouve toujours une action intéressante ; les longues attentes ne bloquent pas le jeu.
- Les décisions sont compréhensibles sur mobile.
- Les risques sont annoncés par des indices et leurs résultats sont expliqués.
- Les joueurs gratuits et les petites entreprises conservent une place utile dans la ville.
- Utiliser une plateforme fictive, par exemple « MarketBridge », sans reprendre le nom ni le logo d'Alibaba.
- L'originalité du concept reste à vérifier par une étude des jeux existants ; ne pas affirmer qu'aucun concurrent n'existe.

## 2. Boucle principale

1. Choisir une famille de produits parmi trois cartes illustrées.
2. Commander, porter le colis et remplir les rayons.
3. Voir un client choisir son produit, rejoindre la caisse et l'encaisser.
4. Réinvestir dans les employés, les collections et le bâtiment.
5. Participer aux événements et accueillir les vacanciers.

Fournisseurs, remises et prix restent dans les réglages avancés, sans être obligatoires pour la première vente. Les employés travaillent dès leur recrutement ; responsable commandes et gérant peuvent être mis en pause. Les réserves d'argent pour les prochains produits restent protégées.

### Premières dix minutes : cible à tester

| Moment | Expérience |
|---|---|
| 0–30 secondes | Découvrir le garage et choisir parmi trois cartes produits |
| Environ 2 minutes au plus | Premier lot offert, carton à porter, rayons remplis puis premier encaissement |
| 2–3 minutes | Première amélioration visible |
| 3–5 minutes | Découvrir un vacancier ou un événement |
| 5–10 minutes | Recruter, personnaliser et voir le prochain objectif architectural |

Une indication à la fois sur l'objet concerné. Animation, son et retour visuel courts célèbrent la vente. Pas de négociation obligatoire ni de demande d'achat en Robux pendant l'introduction.

Le premier lot offert et le guidage dans le monde sont **à implémenter**. Les trois produits et le guide textuel contextuel existent. Sauvegarder l'attribution unique du lot offert pour éviter de le récupérer à chaque connexion. Deux minutes est une cible de conception, pas un résultat mesuré.

## 3. Fournisseurs, produits et risque stratégique

La fiabilité se découvre par des échantillons, des avis, des indices et l'historique des commandes. Les premières décisions restent simples ; les quantités minimales, garanties et contrôles qualité arrivent progressivement.

Aléas possibles : retard de livraison, lot défectueux, demande qui diminue ou concurrent proposant un produit similaire. Le contrôle qualité et l'assurance s'achètent avec la monnaie du jeu et réduisent certains risques clairement indiqués.

Un flop fournit une explication courte et une solution active : liquidation du stock, recyclage ou modification du produit. Il ne détruit pas le bâtiment ou les acquis du joueur.

Les risques et systèmes commerciaux avancés ci-dessus restent secondaires : ne pas les ajouter au démarrage de cet overhaul.

### Produits et marque

- Personnaliser les couleurs, les emballages et le nom d'une gamme.
- Commencer avec des modèles et motifs prédéfinis ; filtrer les textes personnalisés avant affichage.
- Montrer les produits en vitrine et dans les mains des clients.
- Mettre en scène les lancements : camion, cartons et arrivée de clients.

### Collections validées pour l'overhaul

Les trois produits deviennent des familles : sneakers (classiques, sport, lumineuses), audio (casques, enceintes, installation DJ), jouets (robots, figurines, voitures miniatures). Ces variantes sont des exemples à produire.

Déblocages par objectifs annoncés, par exemple « Vends 20 sneakers pour obtenir ce modèle », sans tirage payant. Un exemplaire peut être exposé en vitrine de collection ; distinguer déblocages, exposition et stock vendable pour éviter toute duplication. Les collections et cette vitrine sont **à développer** ; seuls les trois produits de base existent actuellement.

## 4. Ville partagée et bâtiments visibles

### Première ville

Prototype avec 8 parcelles autour d'une place centrale, à ajuster après tests de performance et de lisibilité. Chaque joueur reçoit une parcelle disponible. La ville reste compacte, avec des trajets courts et des boutiques visitables.

### Transformations architecturales — direction validée

Le bâtiment change réellement de modèle, de façade et de silhouette sur la parcelle : garage → boutique → immeuble → siège → tour. Les styles intermédiaires restent à définir. La cible finale demandée est un **gratte-ciel d'inspiration new-yorkaise**, avec :

- une silhouette verticale distinctive et des façades travaillées ;
- un véritable hall d'accueil visitable ;
- des arbres et un aménagement paysager autour ;
- des dragons au sommet comme signature visuelle.

Les dragons sont inscrits comme ornements architecturaux ; leur donner vie ou créer du combat n'est pas validé. Tous les étages n'ont pas besoin d'être visitables : privilégier un accueil utile, les postes d'employés et les espaces pertinents.

**Meshy est prévu pour les assets 3D adaptés**, notamment dragons, ornements et éléments architecturaux personnalisés. Valider un premier bâtiment ou ensemble modulaire avant une production complète. La génération ne dispense pas du travail d'échelle, de collisions et d'optimisation mobile. Aucune génération Meshy n'est lancée par cette mise à jour documentaire.

Séparer l'apparence des points de gameplay : entrée, caisse, rayons, réception, bureaux, cheminements et véhicule. Une transformation doit préserver stock, employés, file, livraisons et sauvegarde. Contrôler l'emprise des huit parcelles, les accès voisins et la caméra au pied des tours.

Prévoir des collisions simples, une enveloppe extérieure optimisée et des textures partagées lorsque possible. Arbres et dragons doivent rester lisibles sans surcharger les appareils modestes. Campus et hélipad restent hors de cet overhaul.

Les niveaux peuvent être mélangés pour montrer les objectifs de progression. La compétition directe reste encadrée selon la progression des participants.

### Ce que les voisins voient

- Enseigne et identité de marque.
- Produits en vitrine, décorations et apparences d'employés.
- Files de clients, livraisons et animation de la boutique.
- Nouveaux étages et transformations du bâtiment.

La taille exprime les étapes acquises ; l'activité actuelle exprime la performance du moment. Aucun bâtiment n'est rétrogradé en cas d'absence ou de baisse des ventes.

### Parcelles et présence

- À la connexion : attribuer une parcelle libre et reconstruire l'entreprise sauvegardée.
- À la déconnexion : sauvegarder puis libérer la parcelle.
- Au retour : conserver l'entreprise, sans garantir la même adresse ni le même serveur.
- Rejoindre un ami et demander une parcelle proche si la capacité le permet.
- Les gains hors ligne sont calculés séparément ; une entreprise absente ne subit pas d'attaque.

Les quartiers spécialisés et les tours fantômes hors ligne restent des pistes ultérieures, hors du prototype.

## 5. Concurrence commerciale

### Deux catégories de clients

| Catégorie | Rôle |
|---|---|
| Clients locaux | Garantir une activité de base que les concurrents ne peuvent pas supprimer |
| Clients disputés | Choisir entre les boutiques depuis la place et lors des événements |

Les clients disputés ont des préférences lisibles : économe (prix), exigeant (qualité), impatient (disponibilité) et amateur de tendances (produit à la mode). Une petite boutique peut gagner sur une spécialité.

Le choix tient compte du stock, du prix, de la qualité, de la réputation, de la fidélité et du marketing. Le stock est une condition d'achat ; les pondérations des autres critères seront ajustées en test. La fortune totale ne doit pas décider seule du résultat.

Des bulles expliquent les choix : « Trop cher ! », « Enfin en stock ! », « J'adore cette marque ! ». La part de marché affichée précise sa portée : clients disputés du serveur ou de l'événement, pas toute l'économie du joueur.

### Actions commerciales

Adapter les prix, changer la vitrine, améliorer la qualité, lancer une publicité, offrir une garantie et fidéliser les clients. Les campagnes ciblées et les abonnements de fidélité seront développés après validation de la boucle simple.

## 6. Portage de clients et sécurité

### Vacanciers — mécanique signature validée

1. Le bus dépose des vacanciers qui se promènent dans la ville.
2. Une bulle illustrée montre le produit recherché.
3. Le joueur peut les accompagner ou les porter avec une animation amusante.
4. Plusieurs boutiques peuvent intéresser un vacancier encore libre.
5. Une fois accueilli dans une boutique, il est protégé contre une reprise par un rival.
6. Il choisit un produit, rejoint la file et rapporte son bonus **au paiement**, pas en franchissant la porte.

Personnalités proposées : touriste chargé de sacs, collectionneur de sneakers, célébrité incognito. Bulles et personnalités sont à créer ; marche, portage et parcours rayon → caisse existent déjà.

Un seul objet ou client porté à la fois, déplacement ralenti. Le serveur valide réservations, distances, interruptions et paiements. Départ, mort et abandon doivent nettoyer le portage correctement.

### Rivalité de colis

Commencer par des **colis bonus disputés**, clairement distincts des commandes payées. Le vol expérimental des commandes ordinaires reste désactivé en serveur publié ; l'ouvrir n'est pas un objectif de l'overhaul.

Les anciennes propositions de reprise de clients devant une boutique, d'agents d'attaque et de salaires de sécurité ne font pas partie de la direction retenue. Aucun salaire récurrent ajouté.

### Garde-fous

- Pas de vol d'argent déjà gagné, de bâtiment ou de déblocage.
- Limites de fréquence et délai avant de cibler à nouveau le même joueur ou client.
- Plafond des ventes disputées pouvant être détournées.
- Protection des débutants et historique clair des événements.
- Aucun besoin de monter la garde en permanence.
- Jouer sans rivalité conserve les revenus normaux de base ; participer apporte des bonus propres aux défis.
- Pas d'offre payante de protection déclenchée juste après une attaque.

## 7. Événements et classements

### Trois événements prioritaires — nouvel ordre validé

- **Bus de vacanciers** : arrivée visible, demandes illustrées, accueil et portage.
- **Fête du quartier** : plusieurs boutiques contribuent ; faire évoluer la commande collective existante en événement visible et coopératif.
- **Livraison express** : transporter une commande sur un petit parcours lisible, réalisable seul.

Événements courts, facultatifs et expliqués visuellement ; durées et récompenses à équilibrer. Ils reviennent régulièrement, sans perte d'acquis si le joueur les manque. Les colis bonus disputés sont une variante à prototyper ensuite.

La tendance surprise déjà présente reste une variété secondaire, pas une priorité de production. La livraison express peut utiliser les véhicules nécessaires à son parcours ; elle ne valide pas une refonte générale des voitures.

### Distinctions

| Distinction | Mesure |
|---|---|
| Meilleur vendeur de l'événement | Performance sur une fenêtre courte |
| Clients les plus satisfaits | Qualité et service, avec un minimum de ventes pour être classé |
| Plus forte progression | Progression sur une fenêtre comparable et par tranche de niveau |
| Plus grande entreprise | Progression durable |

Le classement de session est distinct du classement global. Les règles empêchent les reconnexions répétées de réinitialiser avantageusement les scores. Les récompenses compétitives peuvent être temporaires ; les bâtiments restent acquis.

## 8. Rétention et progression

### Revenir avec un objectif

- Prochain bâtiment ou amélioration visible.
- Nouvelle gamme à lancer et réputation fournisseur à développer.
- Tendances quotidiennes et nouvelles missions.
- Commandes longues facultatives en parallèle d'activités immédiates.
- Ventes hors ligne plafonnées, avec durée et calcul expliqués.
- Informations de retour centrées sur les opportunités et résultats, sans attaque hors ligne.

### Récompenses de session

Remplacer les tirages à chance croissante et leur remise à zéro par des objectifs garantis. La progression est sauvegardée à la déconnexion. Récompenses : monnaie, matières premières, échantillons et petits boosts.

Une jauge affiche l'objectif et sa récompense. Valoriser les actions utiles ; se déplacer sans but ne suffit pas à obtenir des gains illimités.

### Récompenses quotidiennes

Calendrier de 7 jours, éventuellement étendu ensuite. Une journée ratée n'efface pas les acquis et aucun rattrapage payant n'est proposé. Afficher le prochain renouvellement clairement. Un cadeau de PNJ et trois missions courtes peuvent compléter le calendrier.

### Long terme

Spécialisations tech, mode, maison et jouets ; arbres de compétences ; réputation fournisseur ; marque internationale. Un prestige pourra permettre une revente volontaire avec un titre et des avantages maîtrisés. Expliquer précisément les éléments réinitialisés avant confirmation.

## 9. Social et contenu futur

- Visites de boutiques et entreprises voisines entre amis.
- Contrats coopératifs : production et transport répartis, progression solo toujours possible.
- Commandes groupées pour négocier un meilleur prix.
- Plus tard : marché de stocks, échanges de contacts et alliances, avec protections contre duplication et abus.
- Espionnage ultérieur : informations partielles ou incertaines sur fournisseurs et produits ; contre-espionnage et réputation. Ne pas présenter une estimation comme un fait certain.
- Saisons de 4 à 6 semaines seulement lorsque la production de contenu peut suivre.
- Guerres de marché facultatives et défis à conditions identiques.
- Mises à jour thématiques soutenables : produits, fournisseurs, décorations et missions.
- Promotions saisonnières et pénuries simulées peuvent devenir des événements, sans bloquer toute l'activité.

## 10. Monétisation et tunnel d'achat

### Nouvelle orientation

Priorité au style, au confort et à l'expression personnelle. Le cumul initial x5 revenus, fournisseurs à moitié prix et sécurité supérieure n'est pas retenu pour le lancement. Les avantages économiques éventuels doivent être plafonnés, testés et exclus des défis à conditions identiques.

### Trois offres au maximum au lancement commercial

1. Petit pack permanent de personnalisation.
2. Pass de confort, par exemple configurations de boutique sauvegardées supplémentaires.
3. Collection premium : devanture, emballages et apparences d'employés.

Prix à déterminer après tests ; aucun prix optimal n'est supposé. Les éléments visuels premium n'améliorent pas la performance des agents.

### Parcours d'achat

| Étape | Expérience |
|---|---|
| Réussite initiale | Premières ventes et amélioration de la boutique |
| Envie comprise | Découverte de la personnalisation et aperçu d'une devanture |
| Offre pertinente | Contenu, prix et caractère permanent ou temporaire clairement affichés |
| Choix | Achat volontaire ou fermeture facile, sans relances répétées |
| Valeur immédiate | Objet obtenu et visible dans la ville |
| Retour | Nouvelles collections ; pass de saison ultérieur avec voie gratuite |

Ne pas interrompre le tutoriel avec une demande d'achat. Ne pas utiliser de fausse promotion, de rareté inventée ou de compte à rebours trompeur. Aucun achat aléatoire payant prévu.

Si des boosts de jeu actif sont introduits, leur temps se consomme en jouant, avec activation et durée explicites. Pas de cumul sans limite. Ne pas vendre la suppression d'une attente artificiellement bloquante.

Des emplacements de produits supplémentaires influencent l'économie : les traiter comme un avantage à équilibrer, et non comme un simple cosmétique. Les favoris fournisseurs et configurations sauvegardées constituent des pistes de confort.

## 11. Acquisition et mesures

Parcours à optimiser : voir le jeu → cliquer → comprendre → s'amuser → revenir → inviter → acheter éventuellement.

### Présentation et promotion

Tester trois angles fidèles au jeu réel : transformation garage-tour, boutique débordée de clients, course pour un client si cette mécanique est disponible. Les premières minutes doivent tenir la promesse des visuels.

Commencer par un petit groupe de testeurs, observer les abandons, puis diffuser de courtes vidéos de vraies situations. Investir progressivement dans la publicité après validation de la rétention et de l'engagement. Aucun volume de joueurs n'est garanti.

### Indicateurs

- Arrivée → choix du produit → première commande → première vente → première amélioration.
- Temps nécessaire pour atteindre chaque étape et points de sortie.
- Retour le lendemain (J1) et après une semaine (J7), par cohorte et appareil.
- Participation aux événements, jeu entre amis et satisfaction après une rivalité.
- Affichage d'offre → achat, puis rétention des acheteurs et des non-acheteurs.
- Acquisition par source, performance mobile, erreurs et échecs de sauvegarde.

Comparer les versions et cohortes plutôt que d'inventer des objectifs universels. Une hausse de conversion ne suffit pas si elle dégrade fortement l'expérience ou les retours.

## 12. Architecture et développement

### Organisation proposée

Code Luau versionné dans GitHub ; projet Rojo pour synchroniser les fichiers locaux avec Roblox Studio. GitHub conserve le code et les versions ; Roblox héberge l'expérience. Studio reste nécessaire pour les tests de jeu et la validation visuelle.

Répartition prévue : logique serveur (économie, clients, parcelles, commandes, sauvegarde), interface et contrôles côté client, définitions partagées pour produits et équilibrage.

- Autorité serveur sur argent, inventaire, commandes, récompenses et achats.
- Validation des requêtes client, distances, délais et propriété des actions.
- Sauvegarde versionnée, gestion des erreurs et protection contre les sessions concurrentes.
- Calcul hors ligne basé sur un temps serveur et plafonné ; pas de versement dupliqué.
- Attribution d'achat résistante aux reçus répétés.
- Tests multijoueurs, mobile et reconnexion avant publication.
- Éviter les modifications concurrentes d'un script dans Studio et dans sa source Rojo.

### Connexion de l'assistant

Deux voies complémentaires : accès autorisé au dépôt GitHub pour modifier les sources ; client IA local compatible avec le serveur MCP de Roblox Studio pour agir dans une session Studio ouverte et tester. Une connexion GitHub seule ne donne pas le contrôle de Studio.

Le dépôt Be-a-CEO et le workflow local Rojo existent désormais. Vérifier l'état actif des connexions lors des interventions. Les essais en jeu sont effectués par le joueur : l'assistant ne lance pas de session Play. Les clés et mots de passe ne doivent pas être placés dans le document ou le dépôt.

## 13. Feuille de route — overhaul validé le 13 octobre 2026

Remplace l'ancien découpage V1/V2/V3. **Implémenté** signifie présent dans le code, pas validé pour publication. Les propositions 1, 2 (avec correction architecturale), 4, 5 et 7 sont retenues. Les refontes générales des activités après automatisation (3) et des véhicules (6) ne sont pas validées comme chantiers distincts ; les fonctionnalités existantes sont conservées.

### Socle existant — conserver et stabiliser

- [x] Ville de huit parcelles, clients marchant depuis la ville.
- [x] Livraisons physiques, portage, caisse manuelle et employés automatiques.
- [x] Stock visible en rayon, capacité par niveau et bureaux dédiés.
- [x] Vacanciers portables, parcours d'achat et événements de base.
- [x] HUD simplifié, réglages avancés et guide contextuel.
- [x] GitHub et workflow Rojo configurés.
- [ ] Validation multijoueur, mobile, sauvegarde réelle et reconnexions.

### O1 — Première réussite guidée

- [x] Boost de vitesse initial +50 % pendant 3 minutes, avec timer ; compatible portage et non renouvelé à la reconnexion en profil publié.

- [ ] Trois cartes illustrées et premier lot offert une seule fois.
- [ ] Guidage visuel carton → rayons → client → caisse.
- [ ] Célébration courte de première vente et prochaine amélioration visible.
- [ ] Tester la cible d'environ deux minutes jusqu'à la première vente.

Validation joueur : progression compréhensible sans aide, aucune double attribution à la reconnexion, interface utilisable sur téléphone.

### O2 — Garage → gratte-ciel new-yorkais

- [ ] Définir les silhouettes des cinq niveaux et l'échelle sur les huit parcelles.
- [ ] Séparer apparence et points de gameplay.
- [ ] Prototyper une transformation complète, pas des étages identiques ajoutés.
- [ ] Produire un premier essai d'assets Meshy, intégrer et optimiser.
- [ ] Ajouter hall d'accueil, arbres et aménagement extérieur.
- [ ] Créer et placer les dragons ornementaux au sommet.
- [ ] Décliner les modèles intermédiaires et mettre en scène les transformations.

Validation joueur : différences architecturales nettes, accueil accessible, PNJ et livraisons non bloqués, stock et employés conservés, caméra et performances acceptables avec huit tours.

### O3 — Vacanciers reconnaissables

- [ ] Bulles de demande illustrées et personnalités distinctes.
- [ ] Animation de portage améliorée.
- [ ] Concurrence limitée aux vacanciers encore libres dans la ville.
- [ ] Protection après accueil, bonus au paiement et interruptions propres.

Validation joueur : bonus compréhensible, aucune reprise en boutique, double réservation ou duplication de paiement.

### O4 — Collections de produits

- [ ] Premières variantes des trois familles.
- [ ] Objectifs et déblocages garantis affichés.
- [ ] Vitrine de collection séparée du stock vendable.
- [ ] Sauvegarde des déblocages compatible avec les profils existants.

Validation joueur : comprendre quoi obtenir et comment ; retrouver sa collection après reconnexion.

### O5 — Événements du quartier

- [x] Bandeau permanent avec compte à rebours et bonus pour chaque événement actuellement implémenté ; à étendre lors de l'ajout des nouveaux événements.

- [ ] Enrichir le bus avec les nouveaux vacanciers.
- [ ] Faire de la commande collective une fête visible et coopérative.
- [ ] Ajouter un parcours de livraison express.
- [ ] Prototyper les colis bonus disputés sans risque pour les commandes ordinaires.

Validation joueur : événements compréhensibles et jouables seul ou à plusieurs, récompenses uniques, débutants protégés.

### O6 — Validation avant élargissement

- [ ] Observer de nouveaux joueurs pendant les premières minutes.
- [ ] Mesurer livraison → première vente → premier recrutement.
- [ ] Tester mobile, huit joueurs, bâtiments/dragons et persistance.
- [ ] Ajuster rythme, prix et récompenses avant publication.

Alliances, espionnage, saisons, prestige et offres commerciales restent des pistes ultérieures, sans engagement de production dans cet overhaul. Aucune remise à zéro obligatoire de l'entreprise.

## 14. Prochaine étape de production

Commencer par O1 et le cadrage artistique d'O2 : parcours de première vente, silhouettes des bâtiments et référence de tour. Ne pas produire toute la bibliothèque Meshy avant validation de l'échelle et de l'intégration d'un premier essai.

Les façades intermédiaires, l'apparence précise des dragons et les espaces visitables restent à préciser avant production définitive des assets. Cela ne bloque pas la préparation du guidage.

## 15. Références techniques et produit

Documentation consultée le 11 octobre 2026 ; les interfaces et possibilités peuvent évoluer.

- Outils externes et Rojo : https://create.roblox.com/docs/projects/external-tools
- Connexion au serveur MCP Studio : https://create.roblox.com/docs/studio/mcp
- Rojo : https://rojo.space/docs/v7/
- Monétisation : https://create.roblox.com/docs/production/monetization
- Acquisition : https://create.roblox.com/docs/production/analytics/acquisition

Les choix de conception ci-dessus sont des propositions du projet à tester, pas des exigences Roblox ni des promesses de revenus.
