/* -----------------------------------------------------------------------------------
   RÉVISION SQL - TD 5 : GESTION DE STOCK
   Source : Série N°5 (Requêtes) & Série N°1 (Données/Règles)
   Contexte : Une société veut gérer son stock, ses clients et ses fournisseurs.
-----------------------------------------------------------------------------------
*/

-- ==============================================================================
-- 1. CRÉATION DE LA STRUCTURE (Tes tables)
-- ==============================================================================

-- Q1 : Créer une base de données pour la gestion de stock de la société.
CREATE DATABASE GestionStock;
USE GestionStock;

-- Création des tables principales

CREATE TABLE Client(
    Code_Cl VARCHAR(10) PRIMARY KEY,
    Nom_Cl VARCHAR(50),
    Prenom_Cl VARCHAR(50),
    Adresse_Cl VARCHAR(255),
    Ville_Cl VARCHAR(25),
    Tel_Cl VARCHAR(15)
);

CREATE TABLE Article (
    Code_Art VARCHAR(10) PRIMARY KEY,
    Nom_Art VARCHAR(50),
    Qte_Stock INT,
    PU_Art DECIMAL(6,2)
);

CREATE TABLE Fournisseur(
    Code_Four VARCHAR(10) PRIMARY KEY,
    Nom_Four VARCHAR(50)
);

-- Création des tables avec Clés Étrangères (Relations)

-- Table Société (Liée à Fournisseur)
CREATE TABLE Societe(
    Code_Soc VARCHAR(20) PRIMARY KEY,
    Nom_Soc VARCHAR(30),
    Ville_Soc VARCHAR(25),
    Code_Four VARCHAR(10),
    FOREIGN KEY (Code_Four) REFERENCES Fournisseur(Code_Four)
);

-- Table Commande (Liée à Client)
CREATE TABLE Commande (
    Num_Com INT PRIMARY KEY,
    Date_Com DATE, 
    Code_Cl VARCHAR(10),
    FOREIGN KEY (Code_Cl) REFERENCES Client(Code_Cl)
);

-- Tables d'association (Clés Primaires Composées)

-- Détail de la commande (Liaison Commande <-> Article)
CREATE TABLE Ligne_Commande(
    Num_Com INT,
    Code_Art VARCHAR(10),
    Qte_Commande INT, -- Note: Attention à l'orthographe (souvent Qte_Commandee dans les sujets)
    PRIMARY KEY (Num_Com, Code_Art),
    FOREIGN KEY (Num_Com) REFERENCES Commande(Num_Com),
    FOREIGN KEY (Code_Art) REFERENCES Article(Code_Art)
);

-- Liaison Article <-> Société (Livraison)
CREATE TABLE Livraison (
    Code_Art VARCHAR(10),
    Code_Soc VARCHAR(20),
    PRIMARY KEY(Code_Art, Code_Soc),
    FOREIGN KEY (Code_Art) REFERENCES Article(Code_Art),
    FOREIGN KEY (Code_Soc) REFERENCES Societe(Code_Soc)
);

-- ==============================================================================
-- 1.1 INSERTION DES DONNÉES DE TEST (DATA SEEDING)
-- ==============================================================================

-- 1. Remplissage des CLIENTS
-- On met des gens de Tanger (pour tester Q2) et d'ailleurs.
INSERT INTO Client VALUES ('CL01', 'Alami', 'Ahmed', '12 Rue de la Paix', 'Tanger', '0611223344');
INSERT INTO Client VALUES ('CL02', 'Benali', 'Fatima', '45 Av. Hassan II', 'Casablanca', '0622334455');
INSERT INTO Client VALUES ('CL03', 'Charafi', 'Karim', '8 Bloc A', 'Tanger', '0633445566');
INSERT INTO Client VALUES ('CL04', 'Daoudi', 'Sanae', 'Res. Fal', 'Rabat', '0644556677');
INSERT INTO Client VALUES ('CL05', 'El Fassi', 'Omar', 'Bv Med V', 'Tanger', '0655667788'); -- Lui n'aura pas de commande (Piège)

-- 2. Remplissage des ARTICLES
-- Note bien les stocks : PC (5 en stock), Souris (50 en stock).
INSERT INTO Article VALUES ('A01', 'PC Portable Dell', 5, 4500.00);
INSERT INTO Article VALUES ('A02', 'Souris Sans Fil', 50, 80.00);
INSERT INTO Article VALUES ('A03', 'Clavier Mécanique', 10, 600.00);
INSERT INTO Article VALUES ('A04', 'Ecran 27 pouces', 2, 2500.00);
INSERT INTO Article VALUES ('A05', 'Imprimante Laser', 8, 1200.00);

-- 3. Remplissage des FOURNISSEURS
INSERT INTO Fournisseur VALUES ('F01', 'TechImport');
INSERT INTO Fournisseur VALUES ('F02', 'ElectroMaroc');

-- 4. Remplissage des SOCIETES (Distributeurs)
INSERT INTO Societe VALUES ('S01', 'InfoDist', 'Casablanca', 'F01');
INSERT INTO Societe VALUES ('S02', 'NordTech', 'Tanger', 'F02');

-- 5. Remplissage des LIVRAISONS (Qui livre quoi)
INSERT INTO Livraison VALUES ('A01', 'S01');
INSERT INTO Livraison VALUES ('A02', 'S01');
INSERT INTO Livraison VALUES ('A01', 'S02'); -- Le PC est livré par deux sociétés

-- 6. Remplissage des COMMANDES
-- Attention aux dates et aux clients
INSERT INTO Commande VALUES (101, '2024-01-10', 'CL01'); -- Ahmed de Tanger
INSERT INTO Commande VALUES (102, '2024-01-12', 'CL02'); -- Fatima de Casa
INSERT INTO Commande VALUES (103, '2024-01-15', 'CL01'); -- Ahmed (2ème commande)
INSERT INTO Commande VALUES (104, '2024-01-20', 'CL03'); -- Karim de Tanger
INSERT INTO Commande VALUES (105, '2024-02-01', 'CL04'); -- Sanae de Rabat

-- 7. Remplissage des LIGNES_COMMANDE (Le détail)
-- C'est ici qu'on crée les scénarios de test !

-- Commande 101 (Ahmed) : Achète 2 PC.
-- Montant = 2 * 4500 = 9000 DH. Stock OK (2 < 5).
INSERT INTO Ligne_Commande VALUES (101, 'A01', 2); 

-- Commande 102 (Fatima) : Achète 10 Souris.
-- Montant = 10 * 80 = 800 DH. Stock OK (10 < 50).
INSERT INTO Ligne_Commande VALUES (102, 'A02', 10);

-- Commande 103 (Ahmed encore) : Achète 3 Ecrans. 
-- PIÈGE : Stock article A04 = 2, mais il commande 3 ! -> Doit sortir à la Q3 et Q5.
-- Montant = 3 * 2500 = 7500 DH.
INSERT INTO Ligne_Commande VALUES (103, 'A04', 3);

-- Commande 104 (Karim) : Achète 6 PC ! 
-- PIÈGE : Stock = 5, Commande = 6 -> Problème de stock.
-- Montant = 6 * 4500 = 27.000 DH -> Supérieur à 10.000 DH (Pour Q6).
INSERT INTO Ligne_Commande VALUES (104, 'A01', 6);

-- Commande 105 (Sanae) : Petit achat
INSERT INTO Ligne_Commande VALUES (105, 'A02', 1);

-- ==============================================================================
-- 2. REQUÊTES DE SÉLECTION (Exercices du TD)
-- ==============================================================================

-- Q2 : Lister tous les clients qui ont passé au moins une commande et qui habitent Tanger.
-- Analyse :
-- 1. On a besoin des tables Client (pour le nom/ville) et Commande (pour vérifier l'acte d'achat).
-- 2. On utilise INNER JOIN : cela ne garde que les clients qui ont une correspondance dans la table Commande.
--    Ceux qui n'ont jamais commandé sont automatiquement exclus.
-- 3. On utilise DISTINCT : car un client peut avoir plusieurs commandes, on ne veut pas répéter son nom.

SELECT DISTINCT cl.Nom_Cl, cl.Prenom_Cl
FROM Client AS cl
INNER JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
WHERE cl.Ville_Cl = 'Tanger';

-- Q3 : Lister tous les articles dont la quantité commandée est supérieure à celle dans le stock.
-- Analyse :
-- 1. Tables : Article (pour Qte_Stock) et Ligne_Commande (pour Qte_Commande).
-- 2. Jointure : INNER JOIN sur Code_Art (la clé commune).
-- 3. Condition : Simple comparaison mathématique (>) entre les deux colonnes de quantité.

SELECT a.Code_Art, a.Nom_Art, lc.Qte_Commande, a.Qte_Stock
FROM Article AS a
INNER JOIN Ligne_Commande AS lc ON a.Code_Art = lc.Code_Art
WHERE lc.Qte_Commande > a.Qte_Stock;

-- Q4 : Lister le nombre de commandes passées par chaque client.
-- Analyse :
-- 1. On utilise COUNT() pour compter les numéros de commande.
-- 2. On regroupe par Code_Cl (l'identifiant unique) pour éviter de mélanger deux personnes 
--    qui auraient le même nom (Homonymes).
-- 3. CONCAT n'est pas obligatoire mais rend le résultat plus joli.

SELECT 
    cl.Code_Cl, 
    CONCAT(cl.Nom_Cl, ' ', cl.Prenom_Cl) AS Nom_Complet, 
    COUNT(cm.Num_Com) AS Nbr_Commandes
FROM Client AS cl
INNER JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
GROUP BY cl.Code_Cl, cl.Nom_Cl, cl.Prenom_Cl; 
-- Note : En SQL strict, on répète toutes les colonnes de texte dans le GROUP BY.

-- Q5 : Lister tous les clients qui ont commandé les articles dont la quantité est supérieure à celle dans le stock.
-- Analyse :
-- 1. On doit traverser 4 tables : Client -> Commande -> Ligne_Commande -> Article.
-- 2. On utilise DISTINCT car si un client a fait 2 commandes "problématiques", on ne veut voir son nom qu'une fois.
-- 3. Attention au sens du signe : Quantité Commandée > Stock.

SELECT DISTINCT cl.Nom_Cl, cl.Prenom_Cl
FROM Client AS cl
JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl          -- Pont 1
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com    -- Pont 2
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art         -- Pont 3
WHERE lc.Qte_Commande > ar.Qte_Stock;

-- Q6 : Lister tous les clients qui ont dépassé un montant de 10.000 Dh par commande.
-- Analyse :
-- 1. On calcule le montant total par ligne (Prix * Qté) puis on fait la SOMME par commande.
-- 2. On filtre avec HAVING car "WHERE" ne peut pas voir le résultat d'un SUM().
-- 3. On ajoute Nom et Prénom dans le GROUP BY pour respecter le standard SQL strict => Si tu affiches une colonne qui n'est pas un calcul, elle doit être dans le GROUP BY.

SELECT cl.Nom_Cl, cl.Prenom_Cl, SUM(ar.PU_Art * lc.Qte_Commande) AS Montant_Total
FROM Client AS cl
JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art
GROUP BY cm.Num_Com, cl.Nom_Cl, cl.Prenom_Cl
HAVING Montant_Total > 10000;

-- Q7 : Lister tous les clients qui ont dépassé un montant de 100.000 Dh (Total cumulé de toutes leurs commandes).
-- Analyse :
-- 1. On garde la même chaine de jointures (les 4 tables).
-- 2. CHANGEMENT CLÉ : On ne groupe plus par "Num_Com", mais uniquement par Client (Code_Cl).
--    Cela force SQL à additionner TOUTES les commandes de ce client en un seul montant global.
-- 3. Attention au montant dans le HAVING (100.000 et pas 10.000).

SELECT cl.Nom_Cl, cl.Prenom_Cl, SUM(ar.PU_Art * lc.Qte_Commande) AS Montant_Global
FROM Client AS cl
JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art
GROUP BY cl.Code_Cl, cl.Nom_Cl, cl.Prenom_Cl
HAVING Montant_Global > 100000;

-- Q8 : Calculer le taux d’achat (Panier Moyen) pour chaque client.
-- Formule : Montant Total des Achats / Nombre de Commandes.
-- Analyse :
-- 1. SUM(...) calcule le chiffre d'affaires total généré par le client.
-- 2. COUNT(DISTINCT ...) compte le nombre réel de commandes, sans compter les doublons dus aux lignes d'articles.

SELECT 
    cl.Code_Cl, 
    cl.Nom_Cl, 
    cl.Prenom_Cl, 
    SUM(ar.PU_Art * lc.Qte_Commande) / COUNT(DISTINCT cm.Num_Com) AS Panier_Moyen
FROM Client AS cl
JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art
GROUP BY cl.Code_Cl, cl.Nom_Cl, cl.Prenom_Cl;


-- Q9 : Lister les clients qui ont dépassé le montant d’achat 10.000 DH par produit.
-- Analyse :
-- 1. On groupe par Client ET par Article.
-- 2. Ainsi, le SUM() calcule le total dépensé pour CE client sur CE produit spécifique.
--    (Si Ahmed a acheté des PC et des Souris, on aura deux lignes de totaux distincts).

SELECT 
    cl.Nom_Cl, 
    cl.Prenom_Cl, 
    ar.Nom_Art, 
    SUM(ar.PU_Art * lc.Qte_Commande) AS Montant_Par_Produit
FROM Client AS cl
JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art
GROUP BY cl.Code_Cl, cl.Nom_Cl, cl.Prenom_Cl, ar.Code_Art, ar.Nom_Art
HAVING Montant_Par_Produit > 10000;

-- Q10 : Idem que Q4


-- Q11 : Lister toutes les commandes dont la quantité commandée d’article est supérieure à une quantité de même article d’une commande du client « code1 ». 
-- Commandes dont la quantité est supérieure à UNE des quantités commandées par "CL01" pour le même article.

SELECT cm.Num_Com, ar.Nom_Art, lc.Qte_Commande
FROM Commande AS cm
JOIN Ligne_Commande AS lc ON cm.Num_Com = lc.Num_Com
JOIN Article AS ar ON lc.Code_Art = ar.Code_Art
WHERE lc.Qte_Commande > ANY (
    -- Sous-requête : On cherche les quantités achetées par CL01 pour CET article
    SELECT lc_ref.Qte_Commande
    FROM Ligne_Commande AS lc_ref
    JOIN Commande AS cm_ref ON lc_ref.Num_Com = cm_ref.Num_Com
    WHERE cm_ref.Code_Cl = 'CL01' 
    AND lc_ref.Code_Art = lc.Code_Art -- C'est ici qu'on fait le lien (La Corrélation) !
);

-- Q12 : Lister tous les clients de la ville de Tanger qui n’ont passé aucune commande.
-- Analyse : Utilisation de NOT IN (Ensembliste).
-- On prend les clients de Tanger et on retire ceux dont le Code est présent dans la table Commande.

SELECT cl.Nom_Cl, cl.Prenom_Cl
FROM Client AS cl
WHERE cl.Ville_Cl = 'Tanger' 
AND cl.Code_Cl NOT IN (
    SELECT cm.Code_Cl
    FROM Commande AS cm
); -- Le point virgule est ici, à la fin de tout !


-- Q12 (Méthode 2) : Avec LEFT JOIN
-- Analyse :
-- 1. LEFT JOIN : "Prends TOUS les clients, et essaie de coller les commandes en face".
-- 2. Si un client n'a pas de commande, la colonne "Num_Com" sera vide (NULL).
-- 3. WHERE ... IS NULL : On garde uniquement ces lignes vides.

SELECT cl.Nom_Cl, cl.Prenom_Cl
FROM Client AS cl
LEFT JOIN Commande AS cm ON cl.Code_Cl = cm.Code_Cl
WHERE cl.Ville_Cl = 'Tanger'
AND cm.Num_Com IS NULL;  -- C'est ici qu'on capture les "fantômes" (sans commande)

-- Q13 : Lister toutes les sociétés de distribution de Rabat qui ont livré le produit 'A01' (P1).
-- Analyse :
-- 1. On part de Societe (pour le filtre Rabat).
-- 2. On joint Livraison (pour le filtre Code_Art).
-- 3. Optimisation : Pas besoin de la table Article car on a déjà le Code dans Livraison.

SELECT DISTINCT sc.Nom_Soc
FROM Societe AS sc
JOIN Livraison AS liv ON sc.Code_Soc = liv.Code_Soc
WHERE sc.Ville_Soc = 'Rabat' 
AND liv.Code_Art = 'A01';

-- Q14 : Lister les fournisseurs du produit A1 (A01).
-- Analyse :
-- 1. On remonte la chaîne : Article -> Livraison -> Societe -> Fournisseur.
-- 2. On utilise DISTINCT pour ne pas afficher le même fournisseur plusieurs fois.

SELECT DISTINCT f.Nom_Four, ar.Nom_Art
FROM Fournisseur AS f
JOIN Societe AS sc ON f.Code_Four = sc.Code_Four
JOIN Livraison AS liv ON sc.Code_Soc = liv.Code_Soc
JOIN Article AS ar ON liv.Code_Art = ar.Code_Art
WHERE ar.Code_Art = 'A01';


-- Q15 : Afficher le produit le plus commandé (en quantité totale).
-- Analyse :
-- 1. On groupe par Article.
-- 2. On calcule la somme des quantités (SUM).
-- 3. ORDER BY ... DESC : On met le plus gros chiffre tout en haut.
-- 4. LIMIT 1 : On ne garde que la première ligne (le vainqueur).

SELECT ar.Nom_Art, SUM(lc.Qte_Commande) AS Total_Vendu
FROM Article AS ar
JOIN Ligne_Commande AS lc ON ar.Code_Art = lc.Code_Art
GROUP BY ar.Code_Art, ar.Nom_Art
ORDER BY Total_Vendu DESC
LIMIT 1; 

-- Q16 : Citer les sociétés qui livrent le produit le plus commandé.
-- Analyse :
-- 1. On cherche les sociétés (Table Societe) liées aux Livraisons.
-- 2. Condition : L'article livré doit être ÉGAL au résultat de la "Question 15".
-- 3. La sous-requête (entre parenthèses) trouve juste le CODE du produit champion.

SELECT DISTINCT sc.Nom_Soc
FROM Societe AS sc
JOIN Livraison AS liv ON sc.Code_Soc = liv.Code_Soc
WHERE liv.Code_Art = (
    -- DÉBUT DE LA SOUS-REQUÊTE (Le Champion)
    SELECT Code_Art
    FROM Ligne_Commande
    GROUP BY Code_Art
    ORDER BY SUM(Qte_Commande) DESC
    LIMIT 1
    -- FIN DE LA SOUS-REQUÊTE
);

-- ==============================================================================
-- Q16 : Citer les sociétés qui livrent le produit le plus commandé.
-- ==============================================================================

-- MÉTHODE 1 : L'approche "Directe" (Ta méthode avec jointure globale)
-- Avantage : Une seule requête, plus courte à écrire.
-- Inconvénient (Le Risque) : Si le produit est livré par 2 sociétés différentes, 
-- le "LIMIT 1" va en choisir une seule au hasard et cacher l'autre.
SELECT sc.Nom_Soc, ar.Nom_Art, SUM(lc.Qte_Commande) as Total_Vendu
FROM Article AS ar
JOIN Ligne_Commande AS lc ON lc.Code_Art = ar.Code_Art
JOIN Livraison AS liv ON liv.Code_Art = lc.Code_Art
JOIN Societe AS sc ON sc.Code_Soc = liv.Code_Soc
GROUP BY sc.Nom_Soc, ar.Code_Art, ar.Nom_Art
ORDER BY Total_Vendu DESC
LIMIT 1;

-- MÉTHODE 2 : L'approche "Cible" (Recommandée / Sous-requête)
-- Avantage : Si le produit "PC Dell" est le gagnant, cette requête affichera 
-- TOUTES les sociétés qui le livrent (même s'il y en a 10).
SELECT DISTINCT sc.Nom_Soc
FROM Societe AS sc
JOIN Livraison AS liv ON sc.Code_Soc = liv.Code_Soc
WHERE liv.Code_Art = (
    -- La Cible : On identifie d'abord l'ID du produit champion
    SELECT Code_Art
    FROM Ligne_Commande
    GROUP BY Code_Art
    ORDER BY SUM(Qte_Commande) DESC
    LIMIT 1
);

-- Q17 : Calculer le stock de chaque produit.
-- Analyse : Simple sélection des colonnes Nom et Stock.
SELECT Nom_Art, Qte_Stock 
FROM Article;

-- Q18 : Afficher le revenu de chaque produit entre deux dates, trié par revenu décroissant.
-- Analyse :
-- 1. WHERE : On filtre d'abord les commandes sur la période (AVEC des guillemets !).
-- 2. GROUP BY : On regroupe par Article pour que le SUM s'applique à chaque produit séparément.
-- 3. ORDER BY : On trie sur le montant calculé (Revenu) et pas sur le numéro de commande.

SELECT ar.Nom_Art, SUM(ar.PU_Art * lc.Qte_Commande) AS Revenu_Total
FROM Commande AS cm
JOIN Ligne_Commande AS lc ON lc.Num_Com = cm.Num_Com
JOIN Article AS ar ON ar.Code_Art = lc.Code_Art
WHERE cm.Date_Com BETWEEN '2024-01-01' AND '2024-12-31'
GROUP BY ar.Code_Art, ar.Nom_Art
ORDER BY Revenu_Total DESC;
