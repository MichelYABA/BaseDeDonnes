-- ===============================================================================
-- ===============================================================================
-- +++++ **** Elimination des doubles exacts  et des similaires ******************
-- +++++ **** Algorithmes de calcul de distance de similarité ********************
-- +++++ **** Algorithme : Data Deduplication + (DD+) (DDplus) *******************
-- ===============================================================================
-- =============================================================================== 

-- =============================================================================== 
DROP TABLE S;
CREATE TABLE S (COL VARCHAR(10));
INSERT INTO S VALUES (NULL);
COMMIT;
-- =============================================================================== 

-- ---->>>>>>> Première solution
--CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR2, LISTEATTRIBUTS VARCHAR2, SEUIL1 NUMBER, SEUIL2 NUMBER ... ) IS

-- Exemple : LISTEATTRIBUTS : NUMETUD, NOMETUD, PRENOMETUD, DATENAISETUD, VILLEETUD, PAYSETUD
-- LISTEATTRIBUTS transformée : NOMETUD || ' ' || PRENOMETUD || ' ' || DATENAISETUD || ' ' || VILLEETUD || ' ' || PAYSETUD,

CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR,  LISTEATTRIBUTS VARCHAR, ATTR_CLE VARCHAR, SEUIL1 pls_integer, SEUIL2 pls_integer) IS
  --Query VARCHAR(5000);
BEGIN 
  --Etape 0
  EXECUTE IMMEDIATE 'DROP TABLE S';
  EXECUTE IMMEDIATE 'CREATE TABLE S AS SELECT  * FROM ' || NOMTAB;
  --EXECUTE IMMEDIATE 'SELECT  * FROM S';
  -- Etape 1
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V( NEWKEY, '|| LISTEATTRIBUTS || ') AS SELECT '|| ATTR_CLE || ', '|| LISTEATTRIBUTS || ' FROM S';
  -- Etape 2
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V1(K1, K2, EDS, JWS)  AS SELECT N1.NEWKEY, N2.NEWKEY, UTL_MATCH.edit_distance_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)) EDS, UTL_MATCH.jaro_winkler_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)) JWS FROM V N1, V N2 WHERE N1.NEWKEY < N2.NEWKEY';
  -- Etape 3
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V2(K) AS( SELECT K1 FROM V1 WHERE EDS > ' || SEUIL1 || ' AND JWS > ' || SEUIL2 || 'UNION ALL SELECT K2 FROM V1 WHERE EDS > ' || SEUIL1 || ' AND JWS > ' || SEUIL2 || ')';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V2(K) AS( SELECT K1 FROM V1 WHERE EDS > ' || SEUIL1 || ' AND JWS > ' || SEUIL2 || 'UNION SELECT K2 FROM V1 WHERE EDS > ' || SEUIL1 || ' AND JWS > ' || SEUIL2 || ')';
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V2(K) AS ( SELECT K1 FROM V1 WHERE EDS > ' || SEUIL1 || 'AND JWS > '|| SEUIL2 || ')';
  -- Etape Final
  EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW V3 AS  (SELECT * FROM S WHERE ' || ATTR_CLE || ' NOT IN (SELECT * FROM V2))';
  --EXECUTE IMMEDIATE 'SELECT * FROM V3';
  --FOR curseur IN (SELECT * FROM X3) 
  --        LOOP
  --          DBMS_OUTPUT.PUT_LINE(curseur.NUMETUD || ' ' || curseur.NOMETUD || ' ' || curseur.PRENOMETUD || ' ' || curseur.DATENAISETUD || ' ' || curseur.VILLEETUD || ' ' || curseur.PAYSETUD);
  --        END LOOP;
END;
/

-- =============================================================================== 

-- Tests !
EXEC ELIMINEDOUBSIMIL('TOUSLESETUD');

SELECT * FROM S;

-- =============================================================================== 

-- ---->>>>>>> Deuxième solution

-- ---->>>>>>> Troisième solution avec DDPlus !


-- =============================================================================== 
-- Etudier le comportement des algorithmes de calcul de distance de similarité 
-- entre les valeurs dans une BD selon leurs catégories (leurs sémantiques) !

-- === MFB1 ======================================================================

-- =============================================================================== 
-- Création de la table des différentes valeurs à comparer
-- =============================================================================== 
DROP TABLE matchval;

CREATE TABLE matchval 
(
  Idval		VARCHAR2(10), categorieval	VARCHAR2(30),
  valeur1	VARCHAR2(30), valeur2	VARCHAR2(30),
  CONSTRAINT matchval_pk PRIMARY KEY (Idval)
);

-- =============================================================================== 
-- Insertion dans la table des différentes valeurs à comparer
-- =============================================================================== 
-- Catégorie sémantique des données : FIRSTNAME
INSERT INTO matchval VALUES ('A00-001', 'FIRSTNAME', 'Adam', 'ADAM');
INSERT INTO matchval VALUES ('A00-002', 'FIRSTNAME', 'Adam', 'Adem');
INSERT INTO matchval VALUES ('A00-003', 'FIRSTNAME', 'Adam', 'Adams');
INSERT INTO matchval VALUES ('A00-004', 'FIRSTNAME', 'Rahma', 'Rama');
INSERT INTO matchval VALUES ('A00-005', 'FIRSTNAME', 'Marie-Noel', 'Marie Noel');
INSERT INTO matchval VALUES ('A00-006', 'FIRSTNAME', 'Franc', 'Frank');
INSERT INTO matchval VALUES ('A00-007', 'FIRSTNAME', 'Mbarak', 'Moubarak');
INSERT INTO matchval VALUES ('A00-008', 'FIRSTNAME', 'Inès', 'Ines');
INSERT INTO matchval VALUES ('A00-009', 'FIRSTNAME', 'Inès', 'Iness');
INSERT INTO matchval VALUES ('A00-010', 'FIRSTNAME', 'Inès', 'Yneès');
INSERT INTO matchval VALUES ('A00-011', 'FIRSTNAME', 'Inès', 'Agnès');
INSERT INTO matchval VALUES ('A00-021', 'FIRSTLASTNAME', 'Peter Parker', 'Pete Parker');
INSERT INTO matchval VALUES ('A00-022', 'FIRSTLASTNAME', 'Peter Parker', 'peter parker');
INSERT INTO matchval VALUES ('A00-023', 'FIRSTLASTNAME', 'Clark Kent', 'Claire Kent');
INSERT INTO matchval VALUES ('A00-024', 'FIRSTLASTNAME', 'Wonder Woman', 'Ponder Woman');
INSERT INTO matchval VALUES ('A00-025', 'FIRSTLASTNAME', 'Superman', 'Superman');
INSERT INTO matchval VALUES ('A00-026', 'FIRSTLASTNAME', 'The Hulk', 'Iron Man');
INSERT INTO matchval VALUES ('A00-027', 'FIRSTLASTNAME', 'Harissa FORD', 'Harisson Ford');
INSERT INTO matchval VALUES ('A00-028', 'FIRSTLASTNAME', 'Bus WILLY', 'Bruce Willy');
INSERT INTO matchval VALUES ('A00-029', 'FIRSTLASTNAME', 'Brigitte Bardo', 'Brigitte Fardo');
INSERT INTO matchval VALUES ('A00-030', 'FIRSTLASTNAME', 'Hedi Mufti', 'Eddy Murfi');
INSERT INTO matchval VALUES ('A00-031', 'FIRSTLASTNAME', 'Alain DE LOiN', 'Alain DELON');
INSERT INTO matchval VALUES ('A00-032', 'FIRSTLASTNAME', 'De par de', '2 par 2');
INSERT INTO matchval VALUES ('A00-041', 'CITY', 'Paris', 'PArisss');
INSERT INTO matchval VALUES ('A00-042', 'CITY', 'Paris', 'Pari');
INSERT INTO matchval VALUES ('A00-043', 'CITY', 'Pékin', 'Beijing');
INSERT INTO matchval VALUES ('A00-044', 'CITY', 'Londres', 'Londre');
INSERT INTO matchval VALUES ('A00-045', 'CITY', 'Londres', 'London');
INSERT INTO matchval VALUES ('A00-061', 'EMAIL', 'fb@lipn.univ-paris13.fr', 'fb@lipn.univ-paris13.fr');
INSERT INTO matchval VALUES ('A00-062', 'EMAIL', 'fb@lipn.univ-paris13.fr', 'yb@lipn.univ-paris13.fr');
INSERT INTO matchval VALUES ('A00-063', 'EMAIL', 'fb@lipn.univ-paris13.fr', 'fb@iutv.univ-paris13.fr');
COMMIT;
-- =============================================================================== 
-- Préparation (mise en forme) de l'affichage (taille des lignes et des pages)
SET LINES 1000
SET PAGES 1000
COLUMN Idval 		FORMAT A10
COLUMN categorieval FORMAT A20
COLUMN valeur1		FORMAT A25
COLUMN valeur2		FORMAT A25
SELECT * FROM matchval;
-- =============================================================================== 
-- =============================================================================== 
-- Calcul des distances de similarités :
-- Edit_Distance ; Edit_Distance_Similarity
-- Jaro_Winkler ;  Jaro_Winkler_Similarity
-- Q_Gram -->>> ????????????? A Compléter
-- Soundex
-- Metaphone -->>> ????????????? A Compléter
-- =============================================================================== 
-- ===============================================================================
SELECT Idval,
       categorieval,
       valeur1,
       valeur2,
       UTL_MATCH.edit_distance(UPPER(valeur1), UPPER(valeur2)) ED,
	   UTL_MATCH.edit_distance_similarity(UPPER(valeur1), UPPER(valeur2)) EDS,
	   UTL_MATCH.jaro_winkler(UPPER(valeur1), UPPER(valeur2)) JW,
	   UTL_MATCH.jaro_winkler_similarity(UPPER(valeur1), UPPER(valeur2)) JWS,
	   'Q-GRAM ???',
	   SOUNDEX(UPPER(valeur1)) SON1, SOUNDEX(UPPER(valeur2)) SON2,
	   UTL_MATCH.jaro_winkler_similarity(SOUNDEX(UPPER(valeur1)), SOUNDEX(UPPER(valeur2))) S1S2,
	   'METAPHONE ???'
FROM   matchval
ORDER BY Idval;
/*
IDVAL      CATEGORIEVAL         VALEUR1                   VALEUR2                           ED        EDS         JW        JWS 'Q-GRAM??? SON1 SON2 'METAPHONE???
---------- -------------------- ------------------------- ------------------------- ---------- ---------- ---------- ---------- ---------- ---- ---- -------------
A00-001    FIRSTNAME            Adam                      ADAM                               0        100     1E+000        100 Q-GRAM ??? A350 A350 METAPHONE ???
A00-002    FIRSTNAME            Adam                      Adem                               1         75 8,667E-001         86 Q-GRAM ??? A350 A350 METAPHONE ???
A00-003    FIRSTNAME            Adam                      Adams                              1         80   9,6E-001         96 Q-GRAM ??? A350 A352 METAPHONE ???
A00-004    FIRSTNAME            Rahma                     Rama                               1         80 9,467E-001         94 Q-GRAM ??? R500 R500 METAPHONE ???
A00-005    FIRSTNAME            Marie-Noel                Marie Noel                         1         90   9,6E-001         96 Q-GRAM ??? M654 M654 METAPHONE ???
A00-006    FIRSTNAME            Franc                     Frank                              1         80   9,2E-001         92 Q-GRAM ??? F652 F652 METAPHONE ???
A00-007    FIRSTNAME            Mbarak                    Moubarak                           2         75  9,25E-001         92 Q-GRAM ??? M162 M162 METAPHONE ???
A00-008    FIRSTNAME            Inès                      Ines                               1         75 8,667E-001         86 Q-GRAM ??? I520 I520 METAPHONE ???
A00-009    FIRSTNAME            Inès                      Iness                              2         60 8,267E-001         82 Q-GRAM ??? I520 I520 METAPHONE ???
A00-010    FIRSTNAME            Inès                      Yneès                              2         60 7,833E-001         78 Q-GRAM ??? I520 Y520 METAPHONE ???
A00-011    FIRSTNAME            Inès                      Agnès                              2         60 7,833E-001         78 Q-GRAM ??? I520 A252 METAPHONE ???
A00-021    FIRSTLASTNAME        Peter Parker              Pete Parker                        1         92 9,288E-001         92 Q-GRAM ??? P361 P316 METAPHONE ???
A00-022    FIRSTLASTNAME        Peter Parker              peter parker                       0        100     1E+000        100 Q-GRAM ??? P361 P361 METAPHONE ???
A00-023    FIRSTLASTNAME        Clark Kent                Claire Kent                        2         82 9,083E-001         90 Q-GRAM ??? C462 C462 METAPHONE ???
A00-024    FIRSTLASTNAME        Wonder Woman              Ponder Woman                       1         92 9,444E-001         94 Q-GRAM ??? W536 P536 METAPHONE ???
A00-025    FIRSTLASTNAME        Superman                  Superman                           0        100     1E+000        100 Q-GRAM ??? S165 S165 METAPHONE ???
A00-026    FIRSTLASTNAME        The Hulk                  Iron Man                           8          0 4,167E-001         41 Q-GRAM ??? T420 I655 METAPHONE ???
A00-027    FIRSTLASTNAME        Harissa FORD              Harisson Ford                      2         85 9,344E-001         93 Q-GRAM ??? H621 H625 METAPHONE ???
A00-028    FIRSTLASTNAME        Bus WILLY                 Bruce Willy                        3         73 8,848E-001         88 Q-GRAM ??? B240 B624 METAPHONE ???
A00-029    FIRSTLASTNAME        Brigitte Bardo            Brigitte Fardo                     1         93 9,714E-001         97 Q-GRAM ??? B623 B623 METAPHONE ???
A00-030    FIRSTLASTNAME        Hedi Mufti                Eddy Murfi                         5         50     8E-001         80 Q-GRAM ??? H351 E356 METAPHONE ???
A00-031    FIRSTLASTNAME        Alain DE LOiN             Alain DELON                        2         85 9,692E-001         96 Q-GRAM ??? A453 A453 METAPHONE ???
A00-032    FIRSTLASTNAME        De par de                 2 par 2                            4         56 7,566E-001         75 Q-GRAM ??? D163 P600 METAPHONE ???
A00-041    CITY                 Paris                     PArisss                            2         72 9,429E-001         94 Q-GRAM ??? P620 P620 METAPHONE ???
A00-042    CITY                 Paris                     Pari                               1         80   9,6E-001         96 Q-GRAM ??? P620 P600 METAPHONE ???
A00-043    CITY                 Pékin                     Beijing                            5         29 5,619E-001         56 Q-GRAM ??? P250 B252 METAPHONE ???
A00-044    CITY                 Londres                   Londre                             1         86 9,714E-001         97 Q-GRAM ??? L536 L536 METAPHONE ???
A00-045    CITY                 Londres                   London                             3         58 8,476E-001         84 Q-GRAM ??? L536 L535 METAPHONE ???
A00-061    EMAIL                fb@lipn.univ-paris13.fr   fb@lipn.univ-paris13.fr            0        100     1E+000        100 Q-GRAM ??? F415 F415 METAPHONE ???
A00-062    EMAIL                fb@lipn.univ-paris13.fr   yb@lipn.univ-paris13.fr            1         96  9,71E-001         97 Q-GRAM ??? F415 Y141 METAPHONE ???
A00-063    EMAIL                fb@lipn.univ-paris13.fr   fb@iutv.univ-paris13.fr            4         83 9,158E-001         91 Q-GRAM ??? F415 F315 METAPHONE ???

 31 lignes sélectionnées 
*/

-- =============================================================================== 
-- ??? TRAVAIL A FAIRE (Minuscule, Majuscule, Espace, caractères spéciaux...) : 
-- Etudier les algorithmes : Edit_distance, Jaro_winkler, Q_Gram, Soundex, Métaphone

-- =============================================================================== 
-- =============================================================================== 
-- === MFB2 ============= UNIV PARIS 13 - SORBONNE PARIS NORD   ==================

ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY' ;

DROP TABLE ETUDIUTV;
CREATE TABLE ETUDIUTV (NUMETUD VARCHAR2(10), NOMETUD VARCHAR2(20), PRENOMETUD VARCHAR2(20), 
DATENAISETUD DATE, VILLEETUD VARCHAR2(20), PAYSETUD VARCHAR2(20));

INSERT INTO ETUDIUTV VALUES ('iutv1', 'LE BON', 'Adam', '19-06-2001', 'EPINAY SUR SEINE', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv2', 'LE BON', 'Adam', '19-06-2001', 'EPINAY SUR SEINE', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv3', 'BELLE', 'Clemence', '16-10-1996', 'NICE', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv4', 'UNIQUE', 'Alexandre', '19-06-2001', 'PARIS', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv5', 'TRAIFORT', 'Eve', '19-06-2001', 'EPINAY-SUR-SEINE', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv6', 'TRAIFORT', 'Nadia', '17-09-2000', 'EPINAY-SUR-SEINE', 'FRANCE');
INSERT INTO ETUDIUTV VALUES ('iutv7', 'CHEVALIER', 'Ines', '17-09-2000', 'EPINAY-SUR-SEINE', NULL);

DROP TABLE ETUDIG;
CREATE TABLE ETUDIG (NUME VARCHAR2(10), NOME VARCHAR2(20), PRENE VARCHAR2(20),
DNE DATE, VILLEE VARCHAR2(20), PAYSE VARCHAR2(20));

INSERT INTO ETUDIG VALUES ('ig1', 'LE BON', 'Adem', '19-06-2001', 'EPINAY-SUR-SEINE', 'FRANCE');
INSERT INTO ETUDIG VALUES ('ig2', 'BELLE', 'C.', '16-10-1996', 'NICE', 'FRANCE');
INSERT INTO ETUDIG VALUES ('ig3', 'LEBON', 'Adams', NULL, 'PARIS', 'FRANCE');
INSERT INTO ETUDIG VALUES ('ig4', 'CHEVALIER', 'Inès', '17-09-2000', 'EPINAY-SUR-SEINE', 'FRANCE');
INSERT INTO ETUDIG VALUES ('ig5', 'CHEVALIER', 'Jean', '17-09-2001', 'ORLY-VILLE', 'FRANCE');

COMMIT;

DROP TABLE TOUSLESETUD;
CREATE TABLE TOUSLESETUD AS (SELECT * FROM ETUDIUTV UNION SELECT * FROM ETUDIG);

--===========================================================================
--->>> Détection et élimination des SIMILAIRES
--===========================================================================
-- Création d'une nouvelle table ETUDIANT_E_S sans les doubles ou similaires ...
-- Règles de similarités t1 = t2 ?
--                       Quelles sont les colonnes
--                       Quelles sont les algorithmes (S'écrit comme [L=ED, J, JW, QG], se prononce comme[S, M])
--                       Quels sont les seuils

-- Etape 0 : Sauvedarde des données de la source dans la dable S
DROP TABLE S;
CREATE TABLE S AS SELECT  * FROM TOUSLESETUD;
----- Détection des doubles et/ou similaires
-- Etape 1 : Créer la vue avec la clé de blockage
CREATE OR REPLACE VIEW V (NEWKEY, NUMEROE, NOME, PRENOME, DNE, VILE, PAYE) AS
-- NEWKEY est la concaténation de tous les attributs sauf la clé primaire
-- NEWKEY = NOMETUD || PRENOMETUD || DATENAISETUD || VILLEETUD || PAYSETUD
SELECT 
NOMETUD || ' ' || PRENOMETUD || ' ' || DATENAISETUD || ' ' || VILLEETUD || ' ' || PAYSETUD,
NUMETUD, NOMETUD, PRENOMETUD, DATENAISETUD, VILLEETUD, PAYSETUD
FROM S;
-- Etape 2 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V1(K1, K2, EDS, JWS) AS
SELECT N1.NEWKEY, N2.NEWKEY,
       UTL_MATCH.edit_distance_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)),
       UTL_MATCH.jaro_winkler_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY))
FROM V N1, V N2
WHERE N1.NEWKEY < N2.NEWKEY ;
-- Etape 3 : Calcul des distances de similarités (EDS+JWS)
-- SELECT 'Les tuples/lignes assez proches (similaires à 80%) sont : ' FROM DUAL;
CREATE OR REPLACE VIEW V2(K) AS
( SELECT K1 FROM V1 WHERE EDS > 80 AND JWS > 80 
UNION
SELECT K2 FROM V1 WHERE EDS > 80 AND JWS > 80 );

SET LINES 1000
SET PAGES 1000
COLUMN K1 FORMAT A50
COLUMN K2 FORMAT A50
SELECT * FROM V2 ORDER BY 1;
/*
Les tuples/lignes assez proches (similaires à 80%) sont : 
View V2 créé(e).
K                                                                                            
----------------------------------------------------------------------------------------------
BELLE C. 16-10-1996 NICE FRANCE                                                               
BELLE Clemence 16-10-1996 NICE FRANCE                                                         
CHEVALIER Ines 17-09-2000 EPINAY-SUR-SEINE                                                    
CHEVALIER Inès 17-09-2000 EPINAY-SUR-SEINE FRANCE                                             
LE BON Adam 19-06-2001 EPINAY SUR SEINE FRANCE                                                
LE BON Adem 19-06-2001 EPINAY-SUR-SEINE FRANCE                                                
TRAIFORT Eve 19-06-2001 EPINAY-SUR-SEINE FRANCE                                               
TRAIFORT Nadia 17-09-2000 EPINAY-SUR-SEINE FRANCE                                             
 8 lignes sélectionnées 
*/

CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR2) IS
BEGIN 
-- TRAVAIL A FAIRE : Transformer les étapes pour éliminer les doubles/similaires dans une procédure
END;
/

/*Exécution de la procédure pour éliminer les doublons dans la table TOUSLESETUD*/
set SERVEROUTPUT ON;
declare
 v_nomtab varchar(50) := 'TOUSLESETUD';
 v_listeAttributs varchar(200) := 'NUMETUD, NOMETUD, PRENOMETUD, DATENAISETUD, VILLEETUD, PAYSETUD';
 v_attcle varchar(300) := 'NOMETUD || CHR(39) || PRENOMETUD || CHR(39) || DATENAISETUD || CHR(39) || VILLEETUD || CHR(39) || PAYSETUD';
 v_seuil1 pls_integer := 80;
 v_seuil2 pls_integer := 80;
begin
    ELIMINEDOUBSIMIL (v_nomtab, v_listeAttributs, v_attcle, v_seuil1, v_seuil2);
end;
/

/*La nouvelle table sans doublons*/
SELECT * FROM V3 ORDER BY 2;

/*

NUMETUD    NOMETUD              PRENOMETUD           DATENAIS VILLEETUD            PAYSETUD            
---------- -------------------- -------------------- -------- -------------------- --------------------
iutv3      BELLE                Clemence             16/10/96 NICE                 FRANCE              
ig2        BELLE                C.                   16/10/96 NICE                 FRANCE              
ig4        CHEVALIER            Inès                 17/09/00 EPINAY-SUR-SEINE     FRANCE              
ig5        CHEVALIER            Jean                 17/09/01 ORLY-VILLE           FRANCE              
ig1        LE BON               Adem                 19/06/01 EPINAY-SUR-SEINE     FRANCE              
ig3        LEBON                Adams                         PARIS                FRANCE              
iutv6      TRAIFORT             Nadia                17/09/00 EPINAY-SUR-SEINE     FRANCE              
iutv4      UNIQUE               Alexandre            19/06/01 PARIS                FRANCE              

8 lignes sélectionnées. 
*/


-- =============================================================================== 
-- =============================================================================== 
-- === MFB3 ============= BIBLIOGRAPHIE BD-ACM BD-DBLP ===========================

--===========================================================================
--->>> Détection et élimination des SIMILAIRES
--===========================================================================DROP TABLE BDACM;
CREATE TABLE BDACM (
ID      VARCHAR2(50) PRIMARY KEY,
Title   VARCHAR2(500), 
Authors VARCHAR2(500), 
Venue   VARCHAR2(500), 
Year    NUMBER
);

INSERT INTO BDACM VALUES
('564753', 'A compact B-TREE', 'Peter Bumbulis, Ivan T. Bowman', 'International Conference on Management of Data', 2002);
INSERT INTO BDACM VALUES
('872806', 'A theory of redo recovery', 'David Lomet, Mark Tuttle', 'International Conference on Management of Data',2003);

COMMIT;

DROP TABLE BDDBLP;
CREATE TABLE BDDBLP (
ID      VARCHAR2(50) PRIMARY KEY,
Title   VARCHAR2(500), 
Authors VARCHAR2(500), 
Venue   VARCHAR2(500), 
Year    NUMBER
);

INSERT INTO BDDBLP VALUES
('conf/sigmod/BumbulisB02', 'A compact B-tree', 'Ivan T. Bowman, Peter Bumbulis', 'SIGMOD Conference', 2002);
INSERT INTO BDDBLP VALUES
('conf/sigmod/LometT03', 'A Theory of Redo-Recovery', 'Mark R. Tuttle, David B. Lomet', 'SIGMOD Conference', 2003);
INSERT INTO BDDBLP VALUES
('conf/sigmod/DraperHW01', 'The Nimble Integration Engine', 'Daniel S. Weld, Alon Y. Halevy, Denise Draper', 'SIGMOD Conference', 2001);
COMMIT;

DROP TABLE BIBLIOGRAPHIE;
CREATE TABLE BIBLIOGRAPHIE AS (SELECT * FROM BDACM UNION SELECT * FROM BDDBLP);

-- Etape 0 : Sauvedarde des données de la source dans la dable S
DROP TABLE S;
CREATE TABLE S AS SELECT  * FROM BIBLIOGRAPHIE;
----- Détection des doubles et/ou similaires
--  Etape 1 : Créer la vue avec la clé de blockage
CREATE OR REPLACE VIEW V (NEWKEY, ID, Title, Authors, Venue, Year) AS
SELECT 
Title || ' ' || Authors || ' ' || Venue || ' ' || Year,
ID, Title, Authors, Venue, Year
FROM S;
-- Etape 2 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V1(K1, K2, EDS, JWS) AS
SELECT N1.NEWKEY, N2.NEWKEY,
       UTL_MATCH.edit_distance_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)),
       UTL_MATCH.jaro_winkler_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY))
FROM V N1, V N2
WHERE N1.NEWKEY < N2.NEWKEY ;
-- Etape 3 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V2(K) AS
( SELECT K1 FROM V1 WHERE JWS > 80 
UNION
SELECT K2 FROM V1 WHERE JWS > 80 );

SET LINES 1000
SET PAGES 1000
COLUMN K1 FORMAT A50
COLUMN K2 FORMAT A50
SELECT * FROM V2 ORDER BY 1;

/*
K                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
A compact B-tree Ivan T. Bowman, Peter Bumbulis SIGMOD Conference 2002                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
A compact B-TREE Peter Bumbulis, Ivan T. Bowman International Conference on Management of Data 2002                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
A theory of redo recovery David Lomet, Mark Tuttle International Conference on Management of Data 2003                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
A Theory of Redo-Recovery Mark R. Tuttle, David B. Lomet SIGMOD Conference 2003                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
*/

CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR2) IS
BEGIN 
-- TRAVAIL A FAIRE : Transformer les étapes pour éliminer les doubles/similaires dans une procédure
END;
/

/*Exécution de la procédure pour éliminer les doublons dans la table BIBLIOGRAPHIE*/
set SERVEROUTPUT ON;
declare
 v_nomtab varchar(50) := 'BIBLIOGRAPHIE';
 v_listeAttributs varchar(200) := 'ID, Title, Authors, Venue, Year';
 v_attcle varchar(300) := 'Title || CHR(39) || Authors || CHR(39) || Venue || CHR(39) || Year';
 v_seuil1 pls_integer := 0;
 v_seuil2 pls_integer := 80;
begin
    ELIMINEDOUBSIMIL (v_nomtab, v_listeAttributs, v_attcle, v_seuil1, v_seuil2);
end;
/

/*La nouvelle table sans doublons*/
SELECT * FROM V3 ORDER BY 2;

/*
ID                                                 TITLE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                AUTHORS                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              VENUE                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      YEAR
-------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------
conf/sigmod/BumbulisB02                            A compact B-tree                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     Ivan T. Bowman, Peter Bumbulis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       SIGMOD Conference                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          2002
872806                                             A theory of redo recovery                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            David Lomet, Mark Tuttle                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             International Conference on Management of Data                                                                                                                                                                                                                                                                                                                                                                                                                                                                             2003
conf/sigmod/DraperHW01                             The Nimble Integration Engine                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        Daniel S. Weld, Alon Y. Halevy, Denise Draper                                                                                                                                                                                                                                                                                                                                                                                                                                                                        SIGMOD Conference                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          2001

*/

-- =============================================================================== 
-- =============================================================================== 
-- === MFB4 ============= TABLE CLIENTSBis DE GESCOM BB BoBo =====================
DROP TABLE CLIENTSBis;
CREATE TABLE CLIENTSBis
(
	CODCLI		VARCHAR2(10), 
	CIVCLI		VARCHAR2(12),
	NOMCLI		VARCHAR2(20),
	PRENCLI		VARCHAR2(20),
	CATCLI		NUMBER(1),
	ADNCLI		VARCHAR2(10),
	ADRCLI		VARCHAR2(50),
	CPCLI		VARCHAR2(10),
	VILCLI		VARCHAR2(50),
	PAYSCLI		VARCHAR2(30),
	MAILCLI		VARCHAR2(30),
	TELCLI		VARCHAR2(20),
	CONSTRAINT PK_CLIENTSBis			PRIMARY KEY(CODCLI),
	CONSTRAINT CK_CLIENTSBis_CIVCLI		CHECK(CIVCLI   IN ('Mademoiselle', 'Madame', 'Monsieur')),
	CONSTRAINT CK_CLIENTSBis_CATCLI		CHECK(CATCLI   BETWEEN 1 and 7),
	CONSTRAINT NN_CLIENTSBis_NOMCLI		CHECK(NOMCLI   IS NOT NULL),
	CONSTRAINT NN_CLIENTSBis_PRENCLI	CHECK(PRENCLI  IS NOT NULL),
	CONSTRAINT NN_CLIENTSBis_CATCLI		CHECK(CATCLI   IS NOT NULL),
	CONSTRAINT CK_CLIENTSBis_PAYSCLI	CHECK(PAYSCLI  = UPPER(PAYSCLI))
);

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C001', 'Madame', 'CLEM@ENT', 'EVE', 1, '18', 'BOULEVARD FOCH', '91000', 'EPINAY-SUR-ORGE', 'FRANCE','eve.clement@gmail.com', '+33777889911');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C002', 'Madame', 'LESEUL', 'M@RIE', 1, '17', 'AVENUE D ITALIE', '75013', 'PARIS', 'FRANCE','marieleseul@yahoo.fr', '0617586565');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C003', 'Madame', 'UNIQUE', 'Marine', 2, '77', 'RUE DE LA LIBERTE', '13001', 'MARCHEILLE', 'FRANCE','munique@gmail.com', '+33717889922');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C004', 'Madame', 'CLEMENCE', 'EVELYNE', 3, '8 BIS', 'BOULEVARD FOCH', '93800', 'EPINAY-SUR-SEINE', 'FRANCE','clemence evelyne@gmail.com', '+33777889933');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C005', 'Madame', 'FORT', 'Jeanne', 3, '55', 'RUE DU JAPON', '94310', 'ORLY-VILLE', 'FRANCE','jfort\@hotmail.fr', '+33777889944');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C006', 'Mademoiselle', 'LE BON', 'Clémence', 1, '18', 'BOULEVARD FOCH', '93800', 'EPINAY-SUR-SEINE', 'FRANCE','clemence.le bon@cfo.fr', '0033777889955');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C007', 'Mademoiselle', 'TRAIFOR', 'Alice', 2, '6', 'RUE DE LA ROSIERE', '75015', 'PARIS', 'FRANCE','alice.traifor@yahoo.fr', '+33777889966');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C008', 'Monsieur', 'VIVANT', 'JEAN-BAPTISTE', 1, '13', 'RUE DE LA PAIX', '93800', 'EPINAY-SUR-SEINE', 'FRANCE','jeanbaptiste@', '0607');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C009', 'Monsieur', 'CLEMENCE', 'Alexandre', 1, '5', 'RUE DE BELLEVILLE', '75019', 'PaRiS', NULL,'alexandre.clemence@up13.fr', '+33149404071');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C010', 'Monsieur', 'TRAIFOR', 'Alexandre', 1, '17', 'AVENUE FOCH', '75016', 'PARIS', 'FRA','alexandre.traifor@up13.fr', '06070809');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C011', 'Monsieur', 'PREMIER', 'JOS//EPH', 2, '77//', 'RUE DE LA LIBERTE', '13001', 'MARCHEILLE', 'FRANCE','josef@premier', '+33777889977');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C012', 'Monsieur', 'CLEMENT', 'Adam', 2, '13', 'AVENUE JEAN BAPTISTE CLEMENT', '9430', 'VILLETANEUSE', 'FRANCE','adam.clement@gmail.com', '+33149404072');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C013', 'Monsieur', 'FORT', 'Gabriel', 5, '1', 'AVENUE DE CARTAGE', '99000', 'TUNIS', 'TUNISIE','gabriel.fort@yahoo.fr', '+21624801777');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C014', 'Monsieur', 'ADAM', 'DAVID', 5, '1', 'AVENUE DE ROME', '99001', 'ROME', 'ITALIE','david.adamé@gmail com', '');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C015', 'Monsieur', 'Labsent', 'pala', 7, '1', 'rue des absents', '000', 'BAGDAD', 'IRAQ','pala-labsent@paici', '');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C016', 'Madame', 'obsolete', 'kadym', 7, '1', 'rue des anciens', '000', 'CARTHAGE', 'IFRIQIA','inexistant', 'inexistant');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C017', 'Madame', 'RAHYM', 'Karym', 1, '1', 'RUE DES GENTILS', '1000', 'CARTHAGE', 'TUNISIE','karym.rahym@gmail.com', '+21624808444');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C018', 'Madame', 'GENIE', 'ADAM', 3, '8', 'BOULEVARD FOCH', '93800', 'EPINAY SUR SEINE', 'FRANCE','adam.génie@gmail.com', '+33777889911');
COMMIT;
--
INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C118', 'Madame', 'GENIE', 'Adam', 3, '8', 'BOULEVARD FOCH', '93800', '     EPINAY    SUR     SEINE', 'FRANCE','adam.génie@gmail.com', '+33777889911');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C119', 'Madame', 'UNE', 'Marie', 1, '17', 'AVENUE D ITALIE', '75013', 'PARIS', 'FRANCE','marieune@gmail.com', '0617586575');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C120', 'Madame', '1', 'MARIE', 1, '17', 'AVENUE D ITALIE', '75013', 'PARIS', 'FRANCE','MARIEUNE@GMAIL.COM', '0617586575');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C121', 'Monsieur', '2 PAR 2', 'Girard', 1, '27', 'AVENUE D ITALIE', '75013', 'PARIS', 'FRANCE','2PAR2@GMAIL.COM', '0617586577');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C122', 'Monsieur', 'DE PAR DE', 'GIRARD', 1, '27', 'AVENUE D-ITALIE', '75013', '     PARIS     ', 'FRANCE','2PAR2@GMAIL.COM', '0617586577');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C123', 'Monsieur', 'DE PAR DE', 'GIRARD', 1, '27', 'AVENUE D''ITALIE', '75013', '     PARIS     ', 'FRANCE','2PAR2@GMAIL.COM', '0617586577');

INSERT INTO CLIENTSBis (CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI)
VALUES ('C124', 'Monsieur', 'DE    PAR       DE', 'Girard', 1, '27', 'AVENUE D_ITALIE', '75013', '     PARIS     ', 'FRANCE','2PAR2@GMAIL.COM', '0617586577');

COMMIT;

--===========================================================================
--->>> Détection et élimination des SIMILAIRES
--===========================================================================
-- Etape 0 : Sauvedarde des données de la source dans la dable S
DROP TABLE S;
CREATE TABLE S AS SELECT  * FROM CLIENTSBis;
----- Détection des doubles et/ou similaires
--  Etape 1 : Créer la vue avec la clé de blockage
CREATE OR REPLACE VIEW V 
(NEWKEY, CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI) AS
SELECT 
 CODCLI  || ' ' ||  --<<< Attention la clé est prise en considération !
 CIVCLI  || ' ' ||
 NOMCLI  || ' ' ||
 PRENCLI || ' ' ||
 CATCLI  || ' ' ||
 ADNCLI  || ' ' ||
 ADRCLI  || ' ' ||
 CPCLI   || ' ' ||
 VILCLI  || ' ' ||
 PAYSCLI || ' ' ||
 MAILCLI || ' ' ||
 TELCLI, 
 CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI
FROM S;
-- Etape 2 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V1(K1, K2, EDS, JWS) AS
SELECT N1.NEWKEY, N2.NEWKEY,
       UTL_MATCH.edit_distance_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)),
       UTL_MATCH.jaro_winkler_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY))
FROM V N1, V N2
WHERE N1.NEWKEY < N2.NEWKEY ;
-- Etape 3 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V2(K) AS
( SELECT K1 FROM V1 WHERE EDS > 75 AND JWS > 75 
UNION
SELECT K2 FROM V1 WHERE EDS > 75 AND JWS > 75 );

SET LINES 1000
SET PAGES 1000
COLUMN K1 FORMAT A50
COLUMN K2 FORMAT A50
SELECT * FROM V2 ORDER BY 1;

/*
K                                                                                                                                                                                                                                                                                                                       
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
C002 Madame LESEUL M@RIE 1 17 AVENUE D ITALIE 75013 PARIS FRANCE marieleseul@yahoo.fr 0617586565                                                                                                                                                                                                                         
C018 Madame GENIE ADAM 3 8 BOULEVARD FOCH 93800 EPINAY SUR SEINE FRANCE adam.génie@gmail.com +33777889911                                                                                                                                                                                                                
C118 Madame GENIE Adam 3 8 BOULEVARD FOCH 93800      EPINAY    SUR     SEINE FRANCE adam.génie@gmail.com +33777889911                                                                                                                                                                                                    
C119 Madame UNE Marie 1 17 AVENUE D ITALIE 75013 PARIS FRANCE marieune@gmail.com 0617586575                                                                                                                                                                                                                              
C120 Madame 1 MARIE 1 17 AVENUE D ITALIE 75013 PARIS FRANCE MARIEUNE@GMAIL.COM 0617586575                                                                                                                                                                                                                                
C121 Monsieur 2 PAR 2 Girard 1 27 AVENUE D ITALIE 75013 PARIS FRANCE 2PAR2@GMAIL.COM 0617586577                                                                                                                                                                                                                          
C122 Monsieur DE PAR DE GIRARD 1 27 AVENUE D-ITALIE 75013      PARIS      FRANCE 2PAR2@GMAIL.COM 0617586577                                                                                                                                                                                                              
C123 Monsieur DE PAR DE GIRARD 1 27 AVENUE D'ITALIE 75013      PARIS      FRANCE 2PAR2@GMAIL.COM 0617586577                                                                                                                                                                                                              
C124 Monsieur DE    PAR       DE Girard 1 27 AVENUE D_ITALIE 75013      PARIS      FRANCE 2PAR2@GMAIL.COM 0617586577                                                                                                                                                                                                     
 9 lignes sélectionnées 
*/

CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR2) IS
BEGIN 
-- TRAVAIL A FAIRE : Transformer les étapes pour éliminer les doubles/similaires dans une procédure
END;
/

/*Exécution de la procédure pour éliminer les doublons dans la table CLIENTSBis*/
set SERVEROUTPUT ON;
declare
 v_nomtab varchar(50) := 'CLIENTSBis';
 v_listeAttributs varchar(200) := ' CODCLI, CIVCLI, NOMCLI, PRENCLI, CATCLI, ADNCLI, ADRCLI, CPCLI, VILCLI, PAYSCLI, MAILCLI, TELCLI';
 v_attcle varchar(300) := 'CODCLI || CHR(39) || CIVCLI || CHR(39) || NOMCLI || CHR(39) || PRENCLI || CHR(39) || CATCLI || CHR(39) || 
 ADNCLI || CHR(39) || ADRCLI || CHR(39) || CPCLI || CHR(39) || VILCLI || CHR(39) || PAYSCLI || CHR(39) || MAILCLI || CHR(39) || TELCLI';
 v_seuil1 pls_integer := 75;
 v_seuil2 pls_integer := 75;
begin
    ELIMINEDOUBSIMIL (v_nomtab, v_listeAttributs, v_attcle, v_seuil1, v_seuil2);
end;
/

/*La nouvelle table sans doublons*/
SELECT * FROM V3 ORDER BY 2;

/*
CODCLI     CIVCLI       NOMCLI               PRENCLI                  CATCLI ADNCLI     ADRCLI                                             CPCLI      VILCLI                                             PAYSCLI                        MAILCLI                        TELCLI              
---------- ------------ -------------------- -------------------- ---------- ---------- -------------------------------------------------- ---------- -------------------------------------------------- ------------------------------ ------------------------------ --------------------
C001       Madame       CLEM@ENT             EVE                           1 18         BOULEVARD FOCH                                     91000      EPINAY-SUR-ORGE                                    FRANCE                         eve.clement@gmail.com          +33777889911        
C003       Madame       UNIQUE               Marine                        2 77         RUE DE LA LIBERTE                                  13001      MARCHEILLE                                         FRANCE                         munique@gmail.com              +33717889922        
C120       Madame       1                    MARIE                         1 17         AVENUE D ITALIE                                    75013      PARIS                                              FRANCE                         MARIEUNE@GMAIL.COM             0617586575          
C118       Madame       GENIE                Adam                          3 8          BOULEVARD FOCH                                     93800           EPINAY    SUR     SEINE                       FRANCE                         adam.génie@gmail.com           +33777889911        
C017       Madame       RAHYM                Karym                         1 1          RUE DES GENTILS                                    1000       CARTHAGE                                           TUNISIE                        karym.rahym@gmail.com          +21624808444        
C016       Madame       obsolete             kadym                         7 1          rue des anciens                                    000        CARTHAGE                                           IFRIQIA                        inexistant                     inexistant          
C005       Madame       FORT                 Jeanne                        3 55         RUE DU JAPON                                       94310      ORLY-VILLE                                         FRANCE                         jfort\@hotmail.fr              +33777889944        
C004       Madame       CLEMENCE             EVELYNE                       3 8 BIS      BOULEVARD FOCH                                     93800      EPINAY-SUR-SEINE                                   FRANCE                         clemence evelyne@gmail.com     +33777889933        
C006       Mademoiselle LE BON               Clémence                      1 18         BOULEVARD FOCH                                     93800      EPINAY-SUR-SEINE                                   FRANCE                         clemence.le bon@cfo.fr         0033777889955       
C007       Mademoiselle TRAIFOR              Alice                         2 6          RUE DE LA ROSIERE                                  75015      PARIS                                              FRANCE                         alice.traifor@yahoo.fr         +33777889966        
C012       Monsieur     CLEMENT              Adam                          2 13         AVENUE JEAN BAPTISTE CLEMENT                       9430       VILLETANEUSE                                       FRANCE                         adam.clement@gmail.com         +33149404072        
C013       Monsieur     FORT                 Gabriel                       5 1          AVENUE DE CARTAGE                                  99000      TUNIS                                              TUNISIE                        gabriel.fort@yahoo.fr          +21624801777        
C009       Monsieur     CLEMENCE             Alexandre                     1 5          RUE DE BELLEVILLE                                  75019      PaRiS                                                                             alexandre.clemence@up13.fr     +33149404071        
C124       Monsieur     DE    PAR       DE   Girard                        1 27         AVENUE D_ITALIE                                    75013           PARIS                                         FRANCE                         2PAR2@GMAIL.COM                0617586577          
C015       Monsieur     Labsent              pala                          7 1          rue des absents                                    000        BAGDAD                                             IRAQ                           pala-labsent@paici                                 
C014       Monsieur     ADAM                 DAVID                         5 1          AVENUE DE ROME                                     99001      ROME                                               ITALIE                         david.adamé@gmail com                              
C011       Monsieur     PREMIER              JOS//EPH                      2 77//       RUE DE LA LIBERTE                                  13001      MARCHEILLE                                         FRANCE                         josef@premier                  +33777889977        
C010       Monsieur     TRAIFOR              Alexandre                     1 17         AVENUE FOCH                                        75016      PARIS                                              FRA                            alexandre.traifor@up13.fr      06070809            
C008       Monsieur     VIVANT               JEAN-BAPTISTE                 1 13         RUE DE LA PAIX                                     93800      EPINAY-SUR-SEINE                                   FRANCE                         jeanbaptiste@                  0607                

19 lignes sélectionnées. 
*/

-- =============================================================================== 
-- =============================================================================== 
-- === MFB5 ============= TABLE TABCLI ===========================================
/*
Entre parenthèses hihi haha FFF ! (...)
Etant donné la table TABCLI issue des tables de la BD GesComI... 
Faire les requêtes ci-dessous : Eliminer les doubles et les similaires !
*/

DROP TABLE TABCLI;
CREATE TABLE TABCLI (COL1 VARCHAR(10), COL2 VARCHAR(12), COL3 VARCHAR(10), COL4 VARCHAR(10), COL5 VARCHAR(1));
-- La structure n'est pas bien définie ! (tel qu'un fichier CSV)
INSERT INTO TABCLI VALUES ('2994570', 'Madame', 'RAHMA', 'CLEMENCE', '3');
INSERT INTO TABCLI VALUES ('2996100', 'Monsieur', 'CLEMENCE', 'ALEXANDRE', '1');
INSERT INTO TABCLI VALUES ('3000107', 'MO NSIEUR', 'ONRI', 'PANDA', '2');
INSERT INTO TABCLI VALUES ('2997777', 'Mademoiselle', 'LE BON', 'CLEMENTINE', '1');
INSERT INTO TABCLI VALUES ('299PPPP', 'Mlle', 'BON', 'CLEMENTINE', '1');
INSERT INTO TABCLI VALUES ('2997007', 'Monsieur', 'TRAIFOR', 'ADAM', '2');
INSERT INTO TABCLI VALUES ('2998500', 'Monsieur', 'CHEVALIER', 'INES', '1');
INSERT INTO TABCLI VALUES ('3000106', 'Monsieur', 'HARISSA', 'FORD', '1');
INSERT INTO TABCLI VALUES ('3000106', 'Monsieur', 'HARISSA', 'FORD', '1');
INSERT INTO TABCLI VALUES ('3000108', 'Madame', 'EDITE', 'FIAT', '1');
INSERT INTO TABCLI VALUES ('3000109', 'Madame', 'TOYOTA', 'JACKSON', '3');
INSERT INTO TABCLI VALUES ('3000111', 'Madame', 'GENEREUX', 'EVE', '1');
INSERT INTO TABCLI VALUES ('3001778', 'Mr', 'COURTOIS', 'Bruno', '1');
INSERT INTO TABCLI VALUES ('3001779', 'Monsieur', 'VANDERHOTE', 'Ivan', '1');
INSERT INTO TABCLI VALUES ('3001780', 'Monsieur', 'HollANDa', 'Francis', '1');
INSERT INTO TABCLI VALUES ('3001781', 'Monsieur', 'Bernard', 'Hugues', '1');
INSERT INTO TABCLI VALUES ('3001782', 'Monsieur', 'LATIFOU', 'Ilyas', '1');
INSERT INTO TABCLI VALUES ('3001783', 'Madame', 'LALLEMAND', 'Ines', '1');
INSERT INTO TABCLI VALUES ('3001784', 'Monsieur', 'DEUTCH', 'Hans', '1');
INSERT INTO TABCLI VALUES ('3001785', 'Madame', 'ALMANI', 'Eve', '1');
INSERT INTO TABCLI VALUES ('3001786', 'Madame', 'MERQUELLE', 'Angela', '1');
INSERT INTO TABCLI VALUES ('3001', 'M.', 'LE BON', 'Adam', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Mr', 'LE BON', 'Adem', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Mr', 'LE BON', 'Adem', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Mr', 'LE BON', 'Adem', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieur', 'LE BON', 'Adam', '1');
INSERT INTO TABCLI VALUES ('2998505', 'Mademoiselle', 'TRAIFOR', 'ALICE', '2');
INSERT INTO TABCLI VALUES ('3000110', 'MADAME', 'ONRI', 'HONDA', '2');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieur', 'LE BON', 'Adam', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieur', 'LE BON', 'Adam', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieur', 'LE BON', 'Adam', '');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieur', 'LE BON', 'Adam', '1');
INSERT INTO TABCLI VALUES ('3001777', 'Monsieùr', 'LE BON', 'Adam', '1');
COMMIT; 
--===========================================================================
-- ATTENTION : Mise à jour des données
-- HOMOGENEISATION & STANDARDISATION DES DONNEES : TOUT EN MAJUSCULE sans espaces superflus
UPDATE TABCLI SET COL2 = 'Monsieur'     WHERE UPPER(COL2) IN ('M.', 'MR') OR UPPER(COL2) LIKE 'MO%';
UPDATE TABCLI SET COL2 = 'Mademoiselle' WHERE UPPER(COL2) = 'MLLE';
UPDATE TABCLI SET COL2 = INITCAP(COL2);
UPDATE TABCLI SET COL3 = UPPER(COL3);
UPDATE TABCLI SET COL4 = INITCAP(COL4);
COMMIT;
--===========================================================================
-- ATTENTION : Mise à jour des données
--===========================================================================

--===========================================================================
--->>> Détection et élimination des SIMILAIRES
--===========================================================================
-- Etape 0 : Sauvedarde des données de la source dans la dable S
DROP TABLE S;
CREATE TABLE S AS SELECT  * FROM TABCLI;
----- Détection des doubles et/ou similaires
--  Etape 1 : Créer la vue avec la clé de blockage
CREATE OR REPLACE VIEW V
(NEWKEY, COL1, COL2, COL3, COL4, COL5) AS
SELECT 
 COL1  || ' ' ||  --<<< Attention la clé est prise en considération !
 COL2  || ' ' ||
 COL3  || ' ' ||
 COL4  || ' ' ||
 COL5,
 COL1, COL2, COL3, COL4, COL5
FROM S;
-- Etape 2 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V1(K1, K2, EDS, JWS) AS
SELECT N1.NEWKEY, N2.NEWKEY,
       UTL_MATCH.edit_distance_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY)),
       UTL_MATCH.jaro_winkler_similarity(UPPER(N1.NEWKEY), UPPER(N2.NEWKEY))
FROM V N1, V N2
WHERE N1.NEWKEY < N2.NEWKEY ;
-- Etape 3 : Calcul des distances de similarités (EDS+JWS)
CREATE OR REPLACE VIEW V2(K) AS
( SELECT K1 FROM V1 WHERE EDS > 75 AND JWS > 75 
UNION
SELECT K2 FROM V1 WHERE EDS > 75 AND JWS > 75 );

SET LINES 1000
SET PAGES 1000
COLUMN K1 FORMAT A40
COLUMN K2 FORMAT A40
SELECT * FROM V2 ORDER BY 1;
/*
K                                             
-----------------------------------------------
299PPPP Mademoiselle BON Clementine 1          
2997777 Mademoiselle LE BON Clementine 1       
3001 Monsieur LE BON Adam 1                    
3001777 Monsieur LE BON Adam                   
3001777 Monsieur LE BON Adam 1                 
3001777 Monsieur LE BON Adem 1                 
 6 lignes sélectionnées 
*/

CREATE OR REPLACE PROCEDURE ELIMINEDOUBSIMIL (NOMTAB VARCHAR2) IS
BEGIN 
-- TRAVAIL A FAIRE : Transformer les étapes pour éliminer les doubles/similaires dans une procédure
END;
/

/*Exécution de la procédure pour éliminer les doublons dans la table TABCLI*/
set SERVEROUTPUT ON;
declare
 v_nomtab varchar(50) := 'TABCLI';
 v_listeAttributs varchar(200) := 'COL1, COL2, COL3, COL4, COL5';
 v_attcle varchar(300) := 'COL1 || CHR(39) || COL2 || CHR(39) || COL3 || CHR(39) || COL4 || CHR(39) || COL5';
 v_seuil1 pls_integer := 80;
 v_seuil2 pls_integer := 80;
begin
    ELIMINEDOUBSIMIL (v_nomtab, v_listeAttributs, v_attcle, v_seuil1, v_seuil2);
end;
/

/*La nouvelle table sans doublons*/
SELECT DISTINCT * FROM V3 ORDER BY 2;

/*

COL1       COL2         COL3       COL4       C
---------- ------------ ---------- ---------- -
3000109    Madame       TOYOTA     Jackson    3
2998505    Mademoiselle TRAIFOR    Alice      2
2996100    Monsieur     CLEMENCE   Alexandre  1
2998500    Monsieur     CHEVALIER  Ines       1
299PPPP    Mademoiselle BON        Clementine 1
3001786    Madame       MERQUELLE  Angela     1
3001778    Monsieur     COURTOIS   Bruno      1
3000110    Madame       ONRI       Honda      2
3000107    Monsieur     ONRI       Panda      2
3001777    Monsieur     LE BON     Adem       1
3000108    Madame       EDITE      Fiat       1
3001780    Monsieur     HOLLANDA   Francis    1
3001782    Monsieur     LATIFOU    Ilyas      1
3001785    Madame       ALMANI     Eve        1
3000111    Madame       GENEREUX   Eve        1
2994570    Madame       RAHMA      Clemence   3
3001779    Monsieur     VANDERHOTE Ivan       1
2997007    Monsieur     TRAIFOR    Adam       2
3001781    Monsieur     BERNARD    Hugues     1
3001783    Madame       LALLEMAND  Ines       1
3000106    Monsieur     HARISSA    Ford       1
3001784    Monsieur     DEUTCH     Hans       1

22 lignes sélectionnées. 
 
*/