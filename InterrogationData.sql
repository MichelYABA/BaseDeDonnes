PROMPT =========================================================
PROMPT FB-A : Requetes sur la bd EN SQL 2  du type : A, B, C, D, E, F, I, J...
PROMPT =========================================================
PROMPT

PROMPT =========================================================
PROMPT >> Requete A
PROMPT =========================================================
PROMPT
-- A01. Les Noms des clients (Avec éventuellement des doublons)
SELECT NOMCLI FROM Clients ;

-- A02. Les Noms des clients (Sans les doublons)
SELECT DISTINCT NOMCLI FROM Clients ;

-- A03. Les articles dont le prix de vente est supérieur ou égal au double du prix d’achat et dont la quantité en stock >= 100
SELECT * FROM Articles WHERE PvArt >= 2*(PaArt) AND QSART >= 100;

-- A04. Les articles dont le prix de vente est soit 4 soit 27 soit 35
SELECT * FROM Articles WHERE PvArt=4 OR PvArt=27 OR PvArt=35;
SELECT * FROM Articles WHERE PvArt IN (4, 27, 35);

-- A05. Les articles dont le prix de vente est compris entre 40 et 45
SELECT * FROM Articles WHERE PvArt BETWEEN 40 AND 45;

-- A06. Les Commandes du mois de septembre 2018
SELECT * FROM Commandes WHERE TO_CHAR(datcom,'MM')='09' AND TO_CHAR(datcom,'YYYY')='2018';

-- A07. Les détails des Commandes d’une année donnée (2018)
SELECT * FROM DETAILCOM WHERE NUMCOM LIKE '2018%';

-- A08. Les clients de « Paris » (Civilité Nom Prénom, Ville), le nom de la ville s’écrit comme « Paris »
SELECT civcli || ' ' || NOMCLI || ' ' || PRENCLI AS CLIENT_P, VILCLI AS VILLE FROM Clients WHERE UPPER(VilCli) LIKE '%PARIS%';

-- A09. Les clients dont le nom commence par « C »
SELECT * FROM Clients WHERE UPPER(Nomcli) LIKE 'C%';

-- A10. Les articles dont le nom commence par « Barrière de »
SELECT * FROM Articles WHERE NomArt LIKE 'BARRIERE DE%';

-- A11. Les articles du fournisseur « WD »
SELECT * FROM Articles WHERE REFART LIKE'WD%';

-- A12. Les clients pour lesquels on n''a pas de téléphone
SELECT CODCLI, UPPER(NOMCLI), MAILCLI, TELCLI FROM Clients WHERE TELCLI IS NULL OR  TELCLI LIKE 'inexistant';

-- A13. Les clients dont le nom de la ville se prononce comme « pari » ou « bariz » ou « pary »
SELECT * FROM Clients WHERE SOUNDEX(VilCli)=SOUNDEX('PARI') OR SOUNDEX(VilCli)=SOUNDEX('bariz') OR SOUNDEX(VilCli)=SOUNDEX('pary');

-- A14. Les clients dont le nom est similaire à « traifor » ou « tresfor » ou « tresfaur »
SELECT * FROM Clients WHERE UPPER(Nomcli) LIKE '%traifor%' OR UPPER(Nomcli) LIKE '%tresfor%' OR UPPER(Nomcli) LIKE '%tresfaur%';

-- A15. Décodification de la catégorie des clients : Transformez la catégorie comme suit : 
-- 1 ? Grossiste, 2 ? Demi-Gros, ? Détaillant
SELECT 
Nomcli, catcli,
CASE catcli WHEN 1 THEN 'Grossiste' WHEN 2 THEN 'Demi-Gros' ELSE 'detaillant' END AS Categorie 
FROM Clients;

-- Avec DECODE !
SELECT Nomcli, catcli, DECODE(catcli, 1, 'Grossiste', 2, 'Demi-Gros', 'Detaillant') AS Categorie FROM Clients;

-- A16. Les clients pour lesquels le nom et/ou le prénom sont invalides (Code, Nom, et Prénom)
SELECT NomCli,prencli FROM clients WHERE REGEXP_LIKE(NOMCLI,'[^[:alpha:] ]') OR REGEXP_LIKE(PRENCLI,'[^[:alpha:] ]');

-- A17. Les clients pour lesquels les mails sont invalides (Code, Nom, et Mail)
SELECT CODCli,nomcli,mailcli FROM clients WHERE NOT REGEXP_LIKE (MAILCLI,'^[A-Za-z]+[A-Za-z0-9.]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$');

-- A18. Les clients pour lesquels les téléphones sont invalides (Code, Nom, et Mail)
SELECT CODCli,nomcli,telcli FROM clients WHERE NOT REGEXP_LIKE (TELCLI,'(+[1-9]{2,3}|00[1-9]{2,3}|0)[1-9][0-9]{8}');




PROMPT =========================================================
PROMPT >> Requete B
PROMPT =========================================================
PROMPT

-- B01. Classez les clients par ville, par ordre croissant / décroissant
SELECT * FROM Clients ORDER BY VilCli ASC;
SELECT * FROM Clients ORDER BY VilCli;
SELECT * FROM CLIENTS ORDER BY 9;
SELECT * FROM CLIENTS ORDER BY 9 DESC;

-- B02. Classez les articles de PV < 20, dans l’ordre décroissant du stock
SELECT NomArt,QsArt,Pvart FROM Articles WHERE PvArt< 20 ORDER BY QsArt DESC;

--B03. Calculez la marge pour chaque article (marge = PV – PA !), présentez le résultat par ordre décroissant de la marge
SELECT REFART,(PvArt-PaArt) AS Marge FROM Articles order by Marge DESC;

-- B04. Calculez la marge pour tous les sièges, présentez le résultat par ordre croissant de la marge
SELECT REFART,NOMART,PVART-PAART AS MARGE FROM ARTICLES WHERE UPPER(NOMART) like 'SIEGE%' ORDER BY MARGE;

PROMPT =========================================================
PROMPT >> Requete C
PROMPT =========================================================
PROMPT

-- C01. Nombre de clients (Femme + Homme)
SELECT COUNT(*) AS NB_CLIENTS_Fem_Hom FROM Clients;

-- C02. Nombre de clientes (Femme)
SELECT COUNT(*) AS NB_CLIENTES FROM CLIENTS WHERE UPPER(CIVCLI)='MADAME' OR UPPER(CIVCLI)='MADEMOISELLE';

-- C03. Nombre de clients (Homme)
SELECT COUNT(*) AS NB_CLIENTS_Homme FROM CLIENTS WHERE UPPER(CIVCLI)='MONSIEUR';

-- C04. Le prix de vente le plus élevé
SELECT MAX(PVART) AS PRIX_MAX FROM ARTICLES; 

-- C05. Moyenne des prix de vente des articles chers (PV>100)
SELECT AVG(PVART) AS MOYENNE_PV FROM ARTICLES where PVART>100; 

-- C06. Le chiffre d’affaires global
SELECT SUM((puart*qtcom)-remise) AS chiffre_affaire from detailcom;

-- C07. Les articles dont le prix de vente est supérieur à la moyenne des prix de vente
SELECT * FROM Articles WHERE PvArt >= (SELECT AVG(PvArt) FROM Articles);

-- C08. Calculez le nombre de téléphones inconnus (valeurs nulles)
SELECT COUNT(*) AS NbrValManq FROM Clients WHERE TELCLI IS NULL;

PROMPT =========================================================
PROMPT >> Requete D
PROMPT =========================================================
PROMPT

-- D01. Nombre de clients par catégorie
SELECT CatCli, COUNT(*) AS nb_clients FROM Clients GROUP BY CatCli;

-- D02. Nombre de clients parisiens par catégorie
SELECT CatCli, COUNT(*) AS nb_clients_parisiens FROM Clients WHERE UPPER(vilcli) LIKE '%PARIS%' GROUP BY CatCli;

-- D03. Montant de chaque commANDe
SELECT numcom, SUM(qtcom*puart) AS montant FROM detailcom GROUP BY numcom;

-- D04. Nombre de clients parisiens par catégorie, nombre > 2
SELECT COUNT(*) AS nb_clients_parisiens, catcli FROM clients WHERE UPPER(vilcli) LIKE '%PARIS%' GROUP BY catcli HAVING COUNT(*)>2;

-- D05. Total des quantités commandées par article
SELECT refart, SUM(qtcom) AS Quantite_Commandes FROM detailcom GROUP BY refart;

-- D06. Total des quantités commandées par catégorie d’article
SELECT substr(refart, 1, 2) AS Categorie_article, SUM(qtcom) AS Quantite_Commandes FROM detailcom
GROUP BY substr(refart, 1, 2);

-- D07. Total du chiffre d’affaires par catégorie d’article
SELECT substr(refart, 1, 2) AS Categorie_article, SUM((qtcom*puart)-remise) AS chiffre_affaire FROM detailcom
GROUP BY substr(refart, 1, 2);

-- D08. Total, moyenne, min et max du chiffre d’affaires par catégorie d’article
SELECT substr(refart, 1, 2) AS Categorie_article, SUM((qtcom*puart)-remise) AS Total_chiffre_affaire, 
AVG((qtcom*puart)-remise) AS Moyenne_chiffre_affaire, MIN((qtcom*puart)-remise) AS Min_chiffre_affaire,
MAX((qtcom*puart)-remise) AS Max_chiffre_affaire
FROM detailcom
GROUP BY substr(refart, 1, 2);

-- D09. Le chiffre d’affaires par année
SELECT EXTRACT(YEAR FROM commandes.datcom) AS Annee, SUM((detailcom.qtcom*detailcom.puart)-detailcom.remise) AS chiffre_affaire
FROM detailcom, commandes
WHERE detailcom.numcom = commandes.numcom
GROUP BY EXTRACT(YEAR FROM commandes.datcom);

-- D10. Le nombre de valeurs différentes par colonne 
SELECT COUNT(DISTINCT(numcom)) AS NB_NUMCOMS, COUNT(DISTINCT(datcom)) AS NB_DATCOMS, COUNT(DISTINCT(codcli)) AS NB_CLIENTS
FROM commandes;

PROMPT =========================================================
PROMPT >> Requete E
PROMPT =========================================================
PROMPT

-- E01. Différents types de produit-cartésien, jointures (équi-jointure)
PROMPT =========================================================
PROMPT >> produit-cartésien clientsXcommandes
PROMPT =========================================================
SELECT * FROM Clients, Commandes ;
PROMPT =========================================================
PROMPT >> produit-cartésien commandesXclients
PROMPT =========================================================
SELECT * FROM Commandes, Clients ;
PROMPT =========================================================
PROMPT >> Equijointure clientsXcommandes
PROMPT =========================================================
SELECT * FROM Clients, Commandes WHERE Clients.CODCLI = Commandes.codcli;
PROMPT =========================================================
PROMPT >> Equijointure commandesXclients
PROMPT =========================================================
SELECT * FROM Commandes,Clients  WHERE Clients.CODCLI = Commandes.codcli;

-- E02. Les clients ayant commandé et leurs Commandes
SELECT Clients.codcli, Commandes.datcom FROM Clients, Commandes WHERE Clients.codcli=Commandes.codcli;

create or replace view v as (SELECT Clients.codcli, Commandes.datcom FROM Clients, Commandes WHERE Clients.codcli=Commandes.codcli);
select * from v;
SELECT * FROM Clients, Commandes WHERE Clients.codcli=Commandes.codcli;

-- E03. Les clients ayant commandé et leurs Commandes -->>> Full outer join
SELECT * FROM Clients FULL OUTER JOIN Commandes ON Clients.codcli = Commandes.codcli;

-- E04. Les clients ayant commandé et leurs Commandes -->>> Left outer join
SELECT * FROM Clients LEFT OUTER JOIN Commandes ON Clients.codcli = Commandes.codcli;

-- E05. Les clients ayant commandé et leurs Commandes -->>> Right outer join 
SELECT * FROM Clients RIGHT OUTER JOIN Commandes ON Clients.codcli = Commandes.codcli;

-- E06. Les dates des Commandes des clients de PARIS
--SELECT C.codcli, K.datcom FROM Clients C, Commandes K WHERE C.codcli = K.codcli AND LOWER(C.vilcli) = 'paris';
SELECT C.codcli, K.datcom FROM Clients C, Commandes K WHERE C.codcli = K.codcli AND UPPER(C.vilcli) = 'PARIS';

-- E07. Les clients (Codes & Noms des clients) de Paris ayant commandé
SELECT C.codcli Code, Nomcli Nom FROM Clients C, Commandes K WHERE UPPER(C.vilcli) LIKE '%PARIS%' AND C.codcli = K.codcli ;

-- E08. Les clients (Code des clients et Dates des Commandes) de Paris ayant commandé
SELECT t.codcli, t.nomcli, Commandes.datcom 
FROM (SELECT * FROM Clients WHERE UPPER(vilcli)='PARIS') t, Commandes
WHERE t.codcli= Commandes.codcli;

-- E09. Les clients (Code des clients et Dates des Commandes) de Paris ayant commandé 
SELECT /* + ordered */ Clients.codcli, Commandes.datcom FROM Commandes, Clients WHERE Clients.codcli = Commandes.codcli 
AND UPPER(Clients.vilcli)='PARIS';

SELECT /* + ordered */ Clients.codcli, Commandes.datcom FROM Clients, Commandes WHERE Clients.codcli = Commandes.codcli 
AND UPPER(Clients.vilcli)='PARIS';



PROMPT =========================================================
PROMPT >> Requete du type F
PROMPT =========================================================
PROMPT

-- F01. Clients ayant commandé en septembre 2018
SELECT C.codcli, C.Nomcli,  K.datcom FROM Clients C, Commandes K 
WHERE K.datcom LIKE '%SEPTEMBER-2018%'
AND C.codcli = K.codcli ;

-- F02. Montant total des Commandes de septembre 2018
SELECT SUM(d.qtcom*d.puart) as Montant_Total FROM commandes c, detailcom d 
WHERE c.numcom = d.numcom AND UPPER(c.datcom) LIKE '%SEPTEMBER-2018%';

-- F03. Commandes ayant des articles dont le prix vente est supérieur à 20 (Commande, Article, PV)
SELECT c.numcom Commande, a.refart Article, a.pvart PV
FROM commandes c, articles a, detailcom d
WHERE d.refart = a.refart AND d.numcom = c.numcom AND a.pvart > 20;

-- F04. Commandes ayant des articles dont le prix vente est supérieur à 20 (CommANDe, Nombre)
SELECT c.numcom Commande, sum(d.qtcom) AS Nombre
FROM commandes c, articles a, detailcom d
WHERE d.refart = a.refart AND d.numcom = c.numcom AND a.pvart > 20
GROUP BY c.numcom;

-- F05. Commandes ayant 4 articles dont le prix vente est supérieur à 20
SELECT DISTINCT(c.numcom), SUM(d.qtcom) AS NOMBRE_ARTICLE
FROM commandes c, articles a, detailcom d
WHERE c.numcom = d.numcom AND d.refart = a.refart AND a.pvart > 20
GROUP BY c.numcom
HAVING SUM(d.qtcom) > 4;


-- F06. Les clients de paris qui n’ont pas commandé en octobre 2011
SELECT * FROM clients  WHERE UPPER(vilcli) LIKE '%PARIS%'
AND codcli NOT IN (SELECT codcli FROM COMMANDES WHERE UPPER(datcom) LIKE '%OCTOBER-2011%');

-- F07. Les clients de paris ou ceux ayant commandé en octobre 2011
SELECT CODCLI FROM CLIENTS WHERE UPPER(VILCLI) LIKE '%PARIS%'
UNION
SELECT CODCLI FROM COMMANDES WHERE UPPER(datcom) LIKE '%OCTOBER-2011%';

-- G01. Les articles qui figurent sur toutes les Commandes !
SELECT REFART FROM ARTICLES WHERE REFART IN (SELECT REFART FROM DETAILCOM
GROUP BY REFART HAVING COUNT(*) = (SELECT COUNT(*) FROM COMMANDES));

-- G02. Articles commandés par tous les parisiens
TTITLE CENTER 'Requete: les articles qui sont commandés par tous les parisiens' skip 1 -
       LEFT   '=========================================================================' skip 0
SELECT	REFART, NOMART
FROM	ARTICLES
WHERE	NOT EXISTS
	(SELECT *
	 FROM	CLIENTS
	 WHERE	UPPER(VilCli) LKE '%PARIS%'
	 AND	NOT EXISTS
		(SELECT *
		 FROM	Commandes, DETAILCOM
		 WHERE	Commandes.NUMCOM = DETAILCOM.NUMCOM
		 AND	DETAILCOM.REFART = ARTICLES.REFART
		 AND	Commandes.CODCLI = CLIENTS.CODCLI));

-- G03. Les articles qui figurent sur toutes les Commandes d’une période donnée !
SELECT REFART FROM ARTICLES WHERE REFART IN(SELECT REFART FROM DETAILCOM
GROUP BY REFART HAVING COUNT(*) = (SELECT COUNT(*) FROM COMMANDES WHERE
DATCOM BETWEEN TO_DATE('10-08-1996','DD-MM-YYYY') AND TO_DATE('10-09-
2004','DD-MM-YYYY')));