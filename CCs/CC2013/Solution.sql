/* Q1 : Créer la table Missions.
   Analyse : La clé primaire est composée de 4 attributs (soulignés dans l'énoncé).
   Il y a 3 clés étrangères vers les tables Chauffeurs, Véhicules et Lignes.
*/

CREATE TABLE Missions (
    CIN_Chauffeur VARCHAR(20), 
    Imm_Vehicule VARCHAR(20), 
    Num_Ligne INT,            -- Souvent INT pour un numéro, ou VARCHAR
    Date_Depart DATE, 
    Heure_Depart TIME,
    Date_Arrivee DATE, 
    Heure_Arrivee TIME,

    -- Clé Primaire Composée (L'unicité est définie par la combinaison de ces 4 champs)
    PRIMARY KEY (CIN_Chauffeur, Imm_Vehicule, Num_Ligne, Date_Depart),

    -- Clés Étrangères (Liens vers les tables parentes)
    FOREIGN KEY (CIN_Chauffeur) REFERENCES Chauffeurs(CIN_Chauffeur),
    FOREIGN KEY (Imm_Vehicule) REFERENCES Vehicules(Imm_Vehicule),
    FOREIGN KEY (Num_Ligne) REFERENCES Lignes(Num_Ligne)
);


/* Q2 : Lister les chauffeurs qui n'ont conduit aucun véhicule.
   Analyse : On cherche la différence entre "Tous les chauffeurs" et "Ceux qui ont des missions".
*/

-- Méthode 1 : Avec sous-requête (NOT IN)
-- "Donne-moi les chauffeurs dont le CIN n'est PAS DANS la liste des CIN de la table Missions"
SELECT *
FROM Chauffeurs
WHERE CIN_Chauffeur NOT IN (
    SELECT DISTINCT CIN_Chauffeur 
    FROM Missions
);

-- Méthode 2 : Avec Jointure Externe (LEFT JOIN ... IS NULL)
-- "Prends tous les chauffeurs, essaie de coller leurs missions. Garde ceux où la mission est vide (NULL)."
SELECT C.CIN_Chauffeur, C.Nom_Chauffeur, C.Prenom_Chauffeur
FROM Chauffeurs AS C
LEFT JOIN Missions AS M ON C.CIN_Chauffeur = M.CIN_Chauffeur
WHERE M.CIN_Chauffeur IS NULL;


/* Q3 : Lister les chauffeurs qui ont conduit TOUS les véhicules.
   Difficulté : C'est une Division Relationnelle (Le "TOUS").
*/

-- MÉTHODE 1 : L'approche "Comptable" (La tienne, corrigée)
-- Logique : Si l'entreprise a 10 voitures, je cherche les chauffeurs qui ont conduit 10 voitures distinctes.

SELECT ch.Nom_Chauffeur, ch.Prenom_Chauffeur
FROM Chauffeurs AS ch
JOIN Missions AS ms ON ch.CIN_Chauffeur = ms.CIN_Chauffeur
GROUP BY ch.CIN_Chauffeur, ch.Nom_Chauffeur, ch.Prenom_Chauffeur
HAVING COUNT(DISTINCT ms.Imm_Vehicule) = (SELECT COUNT(*) FROM Vehicules);

-- Note bien le sous-requête (SELECT COUNT(*) FROM Vehicules) : 
-- Elle compte le total théorique de voitures (ex: 50) indépendamment des missions.


-- MÉTHODE 2 : L'approche "Logique Pure" (Double Négation)
-- Logique : On cherche un chauffeur pour lequel IL N'EXISTE PAS de véhicule qu'il N'AIT PAS conduit.
-- C'est la méthode préférée des professeurs théoriques.

SELECT * FROM Chauffeurs C
WHERE NOT EXISTS (
    SELECT * FROM Vehicules V
    WHERE NOT EXISTS (
        SELECT * FROM Missions M
        WHERE M.CIN_Chauffeur = C.CIN_Chauffeur
        AND M.Imm_Vehicule = V.Imm_Vehicule
    )
);


/* Q4 : Afficher le nombre de kilomètres parcourus pour chaque chauffeur durant l'année 2007.
   Analyse : Il faut faire la somme des Km des lignes, filtrées par l'année de la mission.
*/

SELECT 
    C.Nom_Chauffeur, 
    C.Prenom_Chauffeur, 
    SUM(L.Km_ligne) AS Total_Km
FROM Chauffeurs C
JOIN Missions M ON C.CIN_Chauffeur = M.CIN_Chauffeur
JOIN Lignes L ON M.Num_Ligne = L.Num_Ligne
WHERE YEAR(M.Date_Depart) = 2007
GROUP BY C.CIN_Chauffeur, C.Nom_Chauffeur, C.Prenom_Chauffeur;


/* Q5 : Lister les véhicules qui ont dépassé 50.000 Km.
   Calcul : (Somme des trajets des missions) + (Kilométrage initial) > 50000
*/

SELECT v.Imm_Vehicule, v.Type_Vehicule
FROM Vehicules AS v
JOIN Missions AS m ON v.Imm_Vehicule = m.Imm_Vehicule
JOIN Lignes AS l ON m.Num_Ligne = l.Num_Ligne
GROUP BY v.Imm_Vehicule, v.Km_Depart, v.Type_Vehicule -- On ajoute Km_Depart ici pour éviter les erreurs
HAVING SUM(l.Km_ligne) + v.Km_Depart > 50000;


/* Q6 : Le Boss Final 👹
   Lister les chauffeurs de l'année en cours (ex: 2013) ayant fait PLUS de missions 
   que le MEILLEUR chauffeur de l'année précédente (ex: 2012).
*/

SELECT 
    C.CIN_Chauffeur, 
    C.Nom_Chauffeur, 
    C.Prenom_Chauffeur,
    COUNT(*) AS Nbr_Missions_Current
FROM Chauffeurs C
JOIN Missions M ON C.CIN_Chauffeur = M.CIN_Chauffeur
-- 1. On filtre d'abord pour ne garder que l'année en cours
WHERE YEAR(M.Date_Depart) = YEAR(CURDATE()) 
GROUP BY C.CIN_Chauffeur, C.Nom_Chauffeur, C.Prenom_Chauffeur

-- 2. La comparaison difficile : "Mon score > Le meilleur score de l'année d'avant"
-- Astuce Mathématique : Être supérieur au MAX, c'est être supérieur à TOUS (ALL) les scores.
HAVING COUNT(*) > ALL (
    SELECT COUNT(*)
    FROM Missions M2
    WHERE YEAR(M2.Date_Depart) = YEAR(CURDATE()) - 1 -- Année précédente
    GROUP BY M2.CIN_Chauffeur
);
