/*
================================================================================
  DESCRIPTION :
  Ce script contient la correction intégrale de l'exercice donné par le professeur
  sur le tableau lors de la dernière séance. Il couvre les concepts avancés :
  - Clés Primaires Composées
  - Jointures Multiples (4 tables)
  - Agrégations complexes (HAVING)
  - La fameuse Division Relationnelle par les VUES (View).
================================================================================
*/

-- =============================================================================
-- 0. DICTIONNAIRE DE DONNÉES (RAPPEL DU SCHÉMA)
-- =============================================================================
/*
  1. Clients   (Cod_cli, Nom_cli, Pre_cli, Vil_cli)
  2. Articles  (Cod_Art, Nom_Art, PU_Art, Poid_UT)
  3. Vehicules (Imma_Veh, Nom_chauf, Poid_Veh_Max)
  4. Livraisons(Cod_cli, Cod_Art, Date_liv, Qte_liv, Imma_Veh, Km_Dep, Km_Arr)
     -> Table centrale qui relie les 3 autres.
*/

-- =============================================================================
-- 1. MODIFICATIONS DE STRUCTURE (DDL)
-- =============================================================================

/* -----------------------------------------------------------------------------
   QUESTION 1 : Ajouter la colonne "Ville" à la table Clients
   -----------------------------------------------------------------------------
   CONTEXTE : Au départ, la table Clients n'a pas de ville. On doit l'ajouter.
*/

ALTER TABLE Clients 
ADD COLUMN Vil_cli VARCHAR(50);

/* 💡 REMARQUE PRO :
   Si on voulait ajouter une contrainte (ex: Ville par défaut 'Tanger'), on écrirait :
   ADD COLUMN Vil_cli VARCHAR(50) DEFAULT 'Tanger';
*/


/* -----------------------------------------------------------------------------
   QUESTION 2 : Créer la table Livraisons
   -----------------------------------------------------------------------------
   ⚠️ PIÈGE CLASSIC (Exam) : La Clé Primaire !
   Un client peut commander le même article plusieurs fois, mais à des dates différentes.
   La clé primaire ne peut pas être juste (Cod_cli, Cod_Art).
   Elle DOIT être (Cod_cli, Cod_Art, Date_liv).
*/

CREATE TABLE Livraisons (
    Cod_cli VARCHAR(20),
    Cod_Art VARCHAR(20),
    Date_liv DATETIME,     -- On utilise DATETIME pour être précis
    Qte_liv INT,           -- Quantité livrée
    Imma_Veh VARCHAR(20),  -- Le véhicule qui a fait la livraison
    Km_Dep INT,            -- Compteur Km au départ
    Km_Arr INT,            -- Compteur Km à l'arrivée

    -- 1. DÉFINITION DE LA CLÉ PRIMAIRE COMPOSÉE
    CONSTRAINT PK_Livraisons PRIMARY KEY (Cod_cli, Cod_Art, Date_liv),

    -- 2. DÉFINITION DES CLÉS ÉTRANGÈRES (Liens vers les tables mères)
    CONSTRAINT FK_Liv_Client FOREIGN KEY (Cod_cli) REFERENCES Clients(Cod_cli),
    CONSTRAINT FK_Liv_Article FOREIGN KEY (Cod_Art) REFERENCES Articles(Cod_Art),
    CONSTRAINT FK_Liv_Vehicule FOREIGN KEY (Imma_Veh) REFERENCES Vehicules(Imma_Veh)
    
    -- 💡 REMARQUE : On pourrait ajouter "ON DELETE CASCADE" si le prof le demande,
    -- mais par sécurité, on évite de le mettre par défaut.
);


-- =============================================================================
-- 2. INTERROGATION DES DONNÉES (DML - SELECT)
-- =============================================================================

/* -----------------------------------------------------------------------------
   QUESTION 3 : Lister les clients n'ayant reçu AUCUNE livraison
   -----------------------------------------------------------------------------
   OBJECTIF : Trouver la différence entre "Tous les clients" et "Ceux dans Livraisons".
*/

-- MÉTHODE A : NOT IN (La plus simple à écrire)
SELECT * FROM Clients 
WHERE Cod_cli NOT IN (
    SELECT DISTINCT Cod_cli 
    FROM Livraisons
);

/* ⚠️ PIÈGE DU "NOT IN" :
   Si la sous-requête renvoie une valeur NULL, le "NOT IN" ne renvoie RIEN du tout.
   C'est pour ça que les profs préfèrent souvent la méthode B ci-dessous.
*/

-- MÉTHODE B : NOT EXISTS (La méthode "Robuste" du Prof)
SELECT * FROM Clients C
WHERE NOT EXISTS (
    SELECT 1              -- On s'en fiche de ce qu'on select, on veut juste savoir si ça existe
    FROM Livraisons L 
    WHERE L.Cod_cli = C.Cod_cli
);


/* -----------------------------------------------------------------------------
   QUESTION 4 : LA REQUÊTE "MONSTRE" (Surcharge & Distance)
   -----------------------------------------------------------------------------
   ENONCÉ : Afficher les livraisons des clients de 'Tanger' dont :
            1. Le poids total > Capacité du véhicule + 10%
            2. La distance parcourue > 3000 Km
   
   ANALYSE :
   - Besoin de la table CLIENTS (pour 'Tanger')
   - Besoin de la table LIVRAISONS (pour Qte, Km)
   - Besoin de la table ARTICLES (pour Poids Unitaire)
   - Besoin de la table VEHICULES (pour Capacité Max)
   => C'est une quadruple jointure !
*/

SELECT 
    C.Cod_cli, 
    C.Nom_cli, 
    L.Date_liv, 
    V.Imma_Veh,
    (L.Qte_liv * A.Poid_UT) AS Poids_Reel_Estime, -- Juste pour vérifier visuellement
    (V.Poid_Veh_Max * 1.10) AS Seuil_Surcharge      -- Juste pour vérifier visuellement
FROM Clients C
JOIN Livraisons L ON C.Cod_cli = L.Cod_cli
JOIN Articles A   ON L.Cod_Art = A.Cod_Art
JOIN Vehicules V  ON L.Imma_Veh = V.Imma_Veh
WHERE 
    C.Vil_cli = 'Tanger'
    
    -- Condition 1 : Surcharge > 10%
    -- (Quantité * Poids Unitaire) > (Capacité Max * 1.10)
    AND (L.Qte_liv * A.Poid_UT) > (V.Poid_Veh_Max * 1.10)
    
    -- Condition 2 : Distance > 3000
    -- (Arrivée - Départ) > 3000
    AND (L.Km_Arr - L.Km_Dep) > 3000;

/* 💡 REMARQUE MATHÉMATIQUE :
   "Dépasser de 10%" revient à multiplier par 1.10.
   "Dépasser de 20%" reviendrait à multiplier par 1.20.
*/


/* -----------------------------------------------------------------------------
   QUESTION 5 : Agrégation avec filtre conditionnel
   -----------------------------------------------------------------------------
   ENONCÉ : Nombre de commandes pour les clients de Tanger, si > 100 commandes.
*/

SELECT 
    C.Cod_cli, 
    C.Nom_cli, 
    COUNT(*) AS Nbr_Commandes
FROM Clients C
JOIN Livraisons L ON C.Cod_cli = L.Cod_cli
WHERE C.Vil_cli = 'Tanger'  -- Filtre AVANT le groupage (Sur les lignes brutes)
GROUP BY C.Cod_cli, C.Nom_cli
HAVING COUNT(*) > 100;      -- Filtre APRÈS le groupage (Sur le résultat du calcul)

/* ⚠️ PIÈGE FREQUENT :
   Ne jamais mettre "COUNT(*)" dans le WHERE. 
   Le WHERE sert à filtrer les lignes (ex: Ville).
   Le HAVING sert à filtrer les groupes (ex: Nombre total).
*/


/* -----------------------------------------------------------------------------
   QUESTION 6 : Somme par groupe
   -----------------------------------------------------------------------------
   ENONCÉ : Total des kilomètres parcourus par chaque chauffeur.
*/

SELECT 
    V.Nom_chauf, 
    SUM(L.Km_Arr - L.Km_Dep) AS Total_Km_Parcourus
FROM Vehicules V
JOIN Livraisons L ON V.Imma_Veh = L.Imma_Veh
GROUP BY V.Nom_chauf;

/* 💡 REMARQUE :
   Si un chauffeur n'a fait aucune livraison, il n'apparaîtra pas ici (Jointure interne).
   Pour afficher aussi ceux qui ont fait 0 km, il faudrait un LEFT JOIN 
   et utiliser COALESCE(SUM(...), 0). Mais restons simple pour l'examen.
*/


-- =============================================================================
-- 3. LA DIVISION RELATIONNELLE (MÉTHODE DU PROF AVEC VUES)
-- =============================================================================

/* -----------------------------------------------------------------------------
   QUESTION 7 : Le "TOUS" (Division)
   -----------------------------------------------------------------------------
   ENONCÉ : Lister les chauffeurs qui ont conduit TOUS les véhicules de l'entreprise.
   
   MÉTHODE DU PROF (Décomposition en 3 étapes R1, R2, R3) :
   Cette méthode est excellente car elle permet de ne pas s'embrouiller avec
   des "NOT EXISTS" imbriqués.
*/

-- ÉTAPE 1 (Vue R1) : L'OBJECTIF À ATTEINDRE
-- On compte combien il y a de véhicules au total dans la table Vehicules.
-- Imaginons que le résultat soit 50.
CREATE VIEW R1 AS 
SELECT COUNT(*) AS Nbr_Total_Veh 
FROM Vehicules;


-- ÉTAPE 2 (Vue R2) : LE SCORE DE CHAQUE CHAUFFEUR
-- On compte combien de véhicules DIFFÉRENTS chaque chauffeur a conduit.
-- ⚠️ PIÈGE : Il faut absolument mettre DISTINCT.
-- Si Ahmed conduit le véhicule V1 dix fois, ça compte pour 1 véhicule, pas 10.
CREATE VIEW R2 AS
SELECT 
    V.Nom_chauf, 
    COUNT(DISTINCT L.Imma_Veh) AS Nbr_Veh_Conduits
FROM Livraisons L
JOIN Vehicules V ON L.Imma_Veh = V.Imma_Veh
GROUP BY V.Nom_chauf;


-- ÉTAPE 3 (Vue R3) : LA COMPARAISON FINALE
-- On sélectionne les chauffeurs dont le score (R2) est égal à l'objectif (R1).
CREATE VIEW R3 AS 
SELECT R2.Nom_chauf 
FROM R2, R1
WHERE R2.Nbr_Veh_Conduits = R1.Nbr_Total_Veh;


-- POUR VOIR LE RÉSULTAT FINAL :
SELECT * FROM R3;


/*
   💡 REMARQUE DE FIN :
   Une fois l'exercice terminé, c'est bien de nettoyer les vues pour ne pas
   polluer la base de données.
*/

-- DROP VIEW R3;
-- DROP VIEW R2;
-- DROP VIEW R1;

-- =============================================================================
-- FIN DU FICHIER
-- =============================================================================
