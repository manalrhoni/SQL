Partie II (SQL) :
  
Pour la gestion des activités d'une société de transport, on considère le modèle relationnel suivant :
     Véhicules (<ins>Imm_Vehicule</ins>, Type_Vehicule, Nbr_place, Date_Achat, Km_Depart)
     Chauffeurs (<ins>CIN_Chauffeur</ins>, Nom_Chauffeur, Prenom_Chauffeur, Salaire_Chauffeur)
     Lignes (<ins>Num_Ligne</ins>, Km_ligne, Ville_Depart, Ville_Arrivee, Ville_Escale)
     Missions (<ins>CIN_Chauffeur, Imm_Vehicule, Num_Ligne, Date_Depart</ins>, Heure_Depart, Date_Arrivee, Heure_Arrivee)

  
Réaliser les requêtes suivantes en SQL :
     1. Créer la table Missions (préciser les différentes clés et les types des attributs).
     2. Lister les chauffeurs qui n'ont conduit aucun véhicule.
     3. Lister les chauffeurs qui ont conduit tous les véhicules.
     4. Afficher le nombre de kilomètres parcouru pour chaque chauffeur durant l'année 2007.
     5. Lister les véhicules qui ont dépassé 50.000 Km de circulation (prendre en considération le kilométrage de départ de chaque véhicule Km_depart).
     6. Lister les chauffeurs qui ont dépassé le nombre de missions, durant l'année en cours, du chauffeur qui a réalisé le nombre maximal des missions durant l'année précédente.

  
Indication : La fonction prédéfinie year(Date) retourne l'année d'une date donnée. Exemple : year(Date) = 2013 et year(03/09/2008) = 2008
