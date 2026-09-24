CREATE TABLE _image (
	id_image INTEGER PRIMARY KEY AUTO_INCREMENT,
	url_image VARCHAR(80) DEFAULT "../images/default.png",
	titre VARCHAR(100) NOT NULL,
	alt VARCHAR(100) NOT NULL
);

CREATE TABLE _adresse (
	id_adresse INTEGER PRIMARY KEY AUTO_INCREMENT,
	ville VARCHAR(60) NOT NULL,
	adresse VARCHAR(120) NOT NULL,
	code_postal VARCHAR(7) NOT NULL,
	complement_adresse VARCHAR(200),
	lon FLOAT,
	lat FLOAT
);

#-- Question de sécurité
CREATE TABLE _question_secu (
	mot_clef VARCHAR(80) PRIMARY KEY,
	question VARCHAR(200)
);


CREATE TABLE _compte (
	id_compte INTEGER PRIMARY KEY AUTO_INCREMENT,
	email VARCHAR(80) NOT NULL,
	mdp VARCHAR(200) NOT NULL,
	supprime BOOL DEFAULT FALSE,
	id_image_profil INTEGER,
	date_creation timestamp NOT NULL DEFAULT NOW(),
	clef VARCHAR(103),
	
	CONSTRAINT compte_fk_image FOREIGN KEY (id_image_profil)
	REFERENCES _image(id_image),
	
	CONSTRAINT uc_compte UNIQUE (email)
);

CREATE TABLE _client (
	id_compte INTEGER PRIMARY KEY,
	pseudo VARCHAR(40) NOT NULL,
	nom VARCHAR(40) NOT NULL,
	prenom VARCHAR(40) NOT NULL,
	date_naissance Date NOT NULL,
	date_derniere_modif_panier Date,
	id_adresse_fac INTEGER,
	question VARCHAR(80),
	reponse VARCHAR(200),
	
	CONSTRAINT client_fk_compte FOREIGN KEY (id_compte)
	REFERENCES _compte(id_compte),
	
	CONSTRAINT client_fk_adresse FOREIGN KEY (id_adresse_fac)
	REFERENCES _adresse(id_adresse),
	
	CONSTRAINT client_fk_question FOREIGN KEY (question)
	REFERENCES _question_secu(mot_clef)
);

CREATE TABLE _vendeur (
	id_compte INTEGER PRIMARY KEY,
	raison_sociale VARCHAR(60) NOT NULL,
	num_siret BIGINT NOT NULL,
	id_adresse INTEGER NOT NULL,
	description VARCHAR(200),
	
	CONSTRAINT vendeur_fk_compte FOREIGN KEY (id_compte)
	REFERENCES _compte(id_compte),
	
	CONSTRAINT vendeur_fk_adresse FOREIGN KEY (id_adresse)
	REFERENCES _adresse(id_adresse)
);

CREATE TABLE _categorie (
	nom_categorie VARCHAR(40) PRIMARY KEY,
	nom_categorie_sup VARCHAR(40),
	
	CONSTRAINT categorie_fk_sup FOREIGN KEY (nom_categorie_sup)
	REFERENCES _categorie(nom_categorie)
);


CREATE TABLE _produit (
	id_produit INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_vendeur INTEGER NOT NULL,
	nom_stock VARCHAR(100) NOT NULL,
	nom_public VARCHAR(100) NOT NULL,
	description VARCHAR(200),
	description_detaillee VARCHAR(2000),
	categorie VARCHAR(40) NOT NULL,
	code_barre BIGINT,
	quantite INTEGER DEFAULT 0,
	prix FLOAT NOT NULL,
	tva FLOAT DEFAULT 20,
	en_ligne BOOL DEFAULT TRUE,
	seuil_alerte INTEGER DEFAULT 0,
	est_supprime BOOL DEFAULT FALSE,
	poids FLOAT NOT NULL,
	volume FLOAT NOT NULL,
	plus_18 BOOL DEFAULT FALSE,
	date_creation Date DEFAULT (CURRENT_DATE),
	quantite_unite VARCHAR(10),
	
	CONSTRAINT produit_fk_vendeur FOREIGN KEY (id_vendeur)
	REFERENCES _vendeur(id_compte),
	
	CONSTRAINT produit_fk_categorie FOREIGN KEY (categorie)
	REFERENCES _categorie(nom_categorie)
);

CREATE TABLE _promotion (
	id_promo INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_produit INTEGER NOT NULL,
	date_debut Date NOT NULL,
	date_fin Date NOT NULL,
	reduction INTEGER, #-- en %
	id_image_banniere INTEGER,
	
	CONSTRAINT promotion_fk_produit FOREIGN KEY (id_produit)
	REFERENCES _produit(id_produit),
	
	CONSTRAINT promotion_fk_image FOREIGN KEY (id_image_banniere)
	REFERENCES _image(id_image),
	
	CONSTRAINT promotion_chk_fin_apres_debut CHECK (date_fin >= date_debut),
	
	CONSTRAINT reduction_chk_entre_0_et_100 CHECK (reduction IS NULL OR 0 <= reduction OR reduction < 100)
);

CREATE TABLE _commande (
	id_commande INTEGER PRIMARY KEY AUTO_INCREMENT,
	date_commande TIMESTAMP NOT NULL DEFAULT (CURRENT_TIMESTAMP),
	id_client INTEGER NOT NULL,
	bordereau_colis VARCHAR(12),
	
	CONSTRAINT commande_fk_client FOREIGN KEY (id_client)
	REFERENCES _client(id_compte)
);

CREATE TABLE _elt_commande (
	id_commande INTEGER,
	id_produit INTEGER,
	quantite INTEGER NOT NULL DEFAULT 1,
	prix FLOAT NOT NULL,
	nom_produit VARCHAR(100) NOT NULL,
	id_vendeur INT NOT NULL,
	
	CONSTRAINT _elt_commande_pk PRIMARY KEY (id_commande, id_produit),
	
	CONSTRAINT _elt_commande_fk_commande FOREIGN KEY (id_commande)
	REFERENCES _commande(id_commande),
	
	CONSTRAINT _elt_commande_fk_produit FOREIGN KEY (id_produit)
	REFERENCES _produit(id_produit),
	
	CONSTRAINT _elt_commande_fk_vendeur FOREIGN KEY (id_vendeur)
	REFERENCES _vendeur(id_compte)
);



CREATE TABLE _avis (
	id_avis INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_client INTEGER NOT NULL,
	id_produit INTEGER NOT NULL,
	note INTEGER DEFAULT 1,
	titre VARCHAR(100),
	commentaire VARCHAR(1000),
	date_avis Date NOT NULL DEFAULT (CURRENT_DATE),
	id_image INTEGER,

	CONSTRAINT avis_fk_client FOREIGN KEY (id_client)
	REFERENCES _client(id_compte),
	
	CONSTRAINT avis_fk_produit FOREIGN KEY (id_produit)
	REFERENCES _produit(id_produit),
	
	CONSTRAINT avis_fk_image FOREIGN KEY (id_image)
	REFERENCES _image(id_image)
);

CREATE TRIGGER `delete_image_avis` BEFORE DELETE ON `_image` FOR EACH ROW UPDATE _avis SET id_image = NULL WHERE id_image = OLD.id_image

CREATE TABLE _reponse (
	id_reponse INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_avis INTEGER,
	reponse VARCHAR(1000) NOT NULL,
	date_reponse Date NOT NULL,
	date_modification Date NOT NULL,

	CONSTRAINT reponse_fk_avis FOREIGN KEY (id_avis)
	REFERENCES _avis(id_avis)
);


CREATE TABLE _elt_panier (
	id_produit INTEGER,
	id_client INTEGER,
	quantite INTEGER DEFAULT 1,
	
	CONSTRAINT panier_pk PRIMARY KEY (id_produit, id_client),
	
	CONSTRAINT panier_fk_produit FOREIGN KEY (id_produit)
	REFERENCES _produit(id_produit),
	
	CONSTRAINT panier_fk_client FOREIGN KEY (id_client)
	REFERENCES _client(id_compte)
);

CREATE TABLE _images_produit (
	id_produit INTEGER PRIMARY KEY,
	id_image_principale INTEGER NOT NULL,
	id_image1 INTEGER NULL,
	id_image2 INTEGER NULL,
	
	CONSTRAINT images_produit_fk_produit FOREIGN KEY (id_produit)
	REFERENCES _produit(id_produit),
	
	CONSTRAINT images_produit_fk_image_p FOREIGN KEY (id_image_principale)
	REFERENCES _image(id_image),
	
	CONSTRAINT images_produit_fk_image_1 FOREIGN KEY (id_image1)
	REFERENCES _image(id_image),
	
	CONSTRAINT images_produit_fk_image_2 FOREIGN KEY (id_image2)
	REFERENCES _image(id_image)
);


CREATE TABLE _signalement (
	id_signalement INTEGER PRIMARY KEY AUTO_INCREMENT,
	id_compte INTEGER,
	id_avis INTEGER,
	id_reponse INTEGER,
	email VARCHAR(80),
	raison VARCHAR(80) NOT NULL,
	
	CONSTRAINT signalement_fk_compte FOREIGN KEY(id_compte)
	REFERENCES _compte(id_compte),
	
	CONSTRAINT signalement_fk_avis FOREIGN KEY(id_avis)
	REFERENCES _avis(id_avis),
	
	UNIQUE KEY signalement_uniq (id_signalement, id_compte, email)
);

CREATE TABLE _cle_vendeur (
	cle_cobrec VARCHAR(15)
);

CREATE TABLE _admin (
	identifiant VARCHAR(40) PRIMARY KEY,
	mdp VARCHAR(200) NOT NULL,
	nom VARCHAR(40) NOT NULL,
	prenom VARCHAR(40) NOT NULL
);





#-- FONTIONS ET TRIGGERS
DELIMITER $$

#-- Renvoie le mot de passe (crypté) lié à un email
CREATE FUNCTION recupe_mdp(email_v VARCHAR(80))
RETURNS VARCHAR(200)
NOT DETERMINISTIC READS SQL DATA
BEGIN
        RETURN (SELECT mdp FROM _compte WHERE email = email_v);
END $$


#-- Verifie si l'email est lié à un compte. Renvoie 0 s'il ne l'est pas, renvoie 1 s'il est lié à un compte Client, et renvoie 2 s'il est lié à un compte Vendeur
CREATE FUNCTION verifie_email(email_v VARCHAR(80))
RETURNS INT
NOT DETERMINISTIC READS SQL DATA
BEGIN
    IF EXISTS (SELECT * FROM _compte NATURAL JOIN _client WHERE email = email_v) THEN
        RETURN 1;
    ELSEIF EXISTS (SELECT * FROM _compte NATURAL JOIN _vendeur WHERE email = email_v) THEN
        RETURN 2;
    ELSE 
        RETURN 0;
    END IF;
END $$


#-- Renvoie true si date1 est avant date2, sinon renvoie false
CREATE FUNCTION compare_date(date1 Date, date2 Date) RETURNS BOOL DETERMINISTIC
BEGIN
	IF (date1 <= date2) THEN
		RETURN true;
	ELSE
		RETURN false;
	END IF;
END $$

#-- Renvoie true s'il y a aucune promotion avec bannière où les dates se superposent (en gros si le créneau est libre), sinon renvoie false
CREATE FUNCTION periode_banniere_libre(date1 Date, date2 Date)
RETURNS BOOL
NOT DETERMINISTIC READS SQL DATA
BEGIN
	IF (SELECT COUNT(1) FROM _promotion WHERE id_image_banniere IS NOT NULL AND (date1 < date_fin AND date2 > date_debut)) THEN
		RETURN false;
	ELSE
		RETURN true;
	END IF;
END $$

CREATE TRIGGER avant_ajout_promotion
BEFORE INSERT ON _promotion
FOR EACH ROW
BEGIN
	IF NOT compare_date(NEW.date_debut, NEW.date_fin) THEN
		SIGNAL SQLSTATE '45000' 
		SET MESSAGE_TEXT = 'Insertion de promotion impossible ! La date de début doit être avant la date de fin.';
	ELSEIF (NEW.id_image_banniere != NULL) AND NOT periode_banniere_libre(NEW.date_debut, NEW.date_fin) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Insertion de promotion impossible ! La promotion ne peut pas avoir de bannière à cette date; date déjà prise.';
	END IF;
END $$



-- procedure cree compte vendeurDELIMITER $$
CREATE OR REPLACE PROCEDURE creer_vendeur_compte(IN p_email VARCHAR(80), IN p_mdp VARCHAR(200), IN p_ville VARCHAR(60), IN p_adresse VARCHAR(120), IN p_complement_adresse VARCHAR(200), IN p_code_postal VARCHAR(5), IN p_raison_sociale VARCHAR(60), IN p_num_siret VARCHAR(20), IN p_cle_cobrec VARCHAR(15), IN p_lon FLOAT(10), IN p_lat FLOAT(10))
BEGIN
    DECLARE v_id_compte INT;
    DECLARE v_id_adresse INT;

    IF EXISTS(SELECT 1 FROM _cle_vendeur WHERE cle_cobrec = p_cle_cobrec) THEN

        -- 1. Insérer dans _compte
        INSERT INTO _compte (email, mdp)
        VALUES (p_email, p_mdp);

        -- 2. Récupérer id_compte
        SELECT id_compte INTO v_id_compte
        FROM _compte
        WHERE email = p_email
        ORDER BY id_compte DESC
        LIMIT 1;

        -- 3. Insérer dans _adresse
        INSERT INTO _adresse (ville, adresse, complement_adresse, code_postal, lon, lat)
        VALUES (p_ville, p_adresse, p_complement_adresse, p_code_postal, p_lon, p_lat);

        -- 4. Récupérer id_adresse
        SELECT id_adresse INTO v_id_adresse
        FROM _adresse
        WHERE adresse = p_adresse
        ORDER BY id_adresse DESC
        LIMIT 1;

        -- 5. Insérer dans _vendeur
        INSERT INTO _vendeur (id_compte, raison_sociale, num_siret, id_adresse)
        VALUES (v_id_compte, p_raison_sociale, p_num_siret, v_id_adresse);

        -- 6. Retirer la clef cobrec
        DELETE FROM _cle_vendeur WHERE cle_cobrec = p_cle_cobrec;
    END IF;

END$$


-- procedure cree compte client
CREATE PROCEDURE creer_client_compte (
    IN p_email VARCHAR(80),
    IN p_mdp VARCHAR(200),
    IN p_pseudo VARCHAR(40),
    IN p_nom VARCHAR(40),
    IN p_prenom VARCHAR(40),
    IN p_date_naissance DATE
)
BEGIN
    DECLARE v_id_compte INT;

    -- 1. Insérer dans _compte
    INSERT INTO _compte (email, mdp)
    VALUES (p_email, p_mdp);

    -- 2. Récupérer id_compte
    SELECT id_compte INTO v_id_compte
    FROM _compte
    WHERE email = p_email
    ORDER BY id_compte DESC
    LIMIT 1;

    -- 3. Insérer dans _client
    INSERT INTO _client (id_compte, pseudo, nom, prenom, date_naissance)
    VALUES (v_id_compte, p_pseudo, p_nom, p_prenom, p_date_naissance);
END$$

CREATE PROCEDURE avis_client_produit (
    IN p_id_produit INT
)
BEGIN
    SELECT note, _avis.titre, commentaire, date_avis, url_image, _image.titre AS titre_image, alt AS alt_image, pseudo
    FROM _avis INNER JOIN _client ON id_client = id_compte
    LEFT JOIN _image ON _avis.id_image = _image.id_image 
    WHERE id_produit = p_id_produit;
END$$


CREATE PROCEDURE creer_avis (
	IN p_id_client INTEGER,
	IN p_id_produit INTEGER,
	IN p_note INTEGER,
	IN p_titre VARCHAR(100),
	IN p_commentaire VARCHAR(1000),
	IN p_url_image VARCHAR(80),
	IN p_titre_image VARCHAR(100),
	IN p_alt_image VARCHAR(100)
)
BEGIN
	DECLARE v_id_image INTEGER;
	
	IF (NOT ISNULL(p_url_image) AND p_url_image <> '') THEN
		INSERT INTO _image (url_image, titre, alt)
		VALUES (p_url_image, p_titre_image, p_alt_image);

		SELECT id_image INTO v_id_image FROM _image WHERE url_image = p_url_image;
	ELSE
		SELECT NULL INTO v_id_image;
	END IF;
	
	INSERT INTO _avis (id_client, id_produit, note, titre, commentaire, id_image)
	VALUES (p_id_client, p_id_produit, p_note, p_titre, p_commentaire, v_id_image);
END$$


CREATE OR REPLACE FUNCTION email_actif_existe(email_input VARCHAR(80)) 
RETURNS BOOL
NOT DETERMINISTIC READS SQL DATA
BEGIN
    DECLARE existe BOOLEAN;

    SELECT EXISTS (
        SELECT 1 FROM _compte WHERE email = email_input AND supprime <> 1
    ) INTO existe;

    RETURN existe;
END$$

DELIMITER ; ;


#-- VUES

CREATE VIEW promo_jour AS (
	SELECT * FROM _promotion
	WHERE date_debut <= CURRENT_DATE
	AND date_fin >= CURRENT_DATE
);

CREATE VIEW reduc_jour AS (
	SELECT * FROM _reduction
	WHERE date_debut <= CURRENT_DATE
	AND date_fin >= CURRENT_DATE
);

CREATE VIEW produit_note AS (
	(SELECT a.id_produit, AVG(note) AS note_moy
	FROM _avis a
	INNER JOIN _produit p ON a.id_produit = p.id_produit
	GROUP BY id_produit)
	
	UNION
	
	(SELECT id_produit, NULL FROM _produit p
	WHERE id_produit NOT IN (SELECT id_produit i FROM _avis))
	
	ORDER BY id_produit
);

CREATE OR REPLACE VIEW avis_nombre AS(
    SELECT id_produit, COUNT(id_produit) AS nb_avis
    FROM _avis
    GROUP BY id_produit
);

CREATE VIEW produit AS (	
	SELECT p.id_produit, p.nom_public, p.nom_stock, p.seuil_alerte, p.description, p.description_detaillee, p.prix, p.quantite, p.id_vendeur, v.raison_sociale, n.note_moy,
	ROUND(p.prix * (100 - IFNULL(r.pourcentage, 0)) / 100, 2) AS prix_actuel, pr.id_produit IS NOT NULL AS en_promotion, p.categorie, p.en_ligne,
	p.poids, p.volume, p.plus_18, p.date_creation, p.quantite_unite, p.tva, p.code_barre,
	i.id_image_principale, i.id_image1, i.id_image2,
	nb.nb_avis
	FROM _produit p
	INNER JOIN _vendeur v ON p.id_vendeur = v.id_compte
	INNER JOIN _images_produit i ON p.id_produit = i.id_produit
	LEFT JOIN promo_jour pr ON p.id_produit = pr.id_produit
	LEFT JOIN reduc_jour r ON p.id_produit = r.id_produit
	LEFT JOIN produit_note n ON p.id_produit = n.id_produit
	LEFT JOIN avis_nombre nb ON p.id_produit = nb.id_produit
	WHERE !p.est_supprime
);
	
CREATE VIEW produit_en_ligne AS (
	SELECT * 
	FROM produit
	WHERE en_ligne
);

CREATE VIEW client AS (
	SELECT c.id_compte, pseudo, nom, prenom, email, mdp, id_image_profil, date_creation, date_naissance, date_derniere_modif_panier, id_adresse_fac
	FROM _client c
    INNER JOIN _compte ON c.id_compte = _compte.id_compte
	WHERE supprime <> 1
);

CREATE VIEW vendeur AS (
	SELECT v.id_compte, raison_sociale, num_siret, description, id_adresse, mdp, email
	FROM _vendeur v
	INNER JOIN _compte ON v.id_compte = _compte.id_compte
	WHERE supprime <> 1
);

CREATE VIEW nb_signalements AS (
	SELECT id_avis, COUNT(*)
	FROM _signalement
	GROUP BY id_avis
);

CREATE VIEW avis_client AS (
	SELECT a.id_avis, a.id_produit, id_client, note, a.titre, commentaire, date_avis, url_image, i.titre AS titre_image, i.alt AS alt_image, pseudo, id_image_profil AS id_image_pp, produit.id_image_principale AS id_image_produit
    FROM _avis a
    LEFT JOIN _image i ON a.id_image = i.id_image
    INNER JOIN client ON a.id_client = client.id_compte
    INNER JOIN produit ON a.id_produit = produit.id_produit
);

CREATE VIEW produit_banniere_aujourd AS (
	SELECT id_produit FROM _promotion
	WHERE id_image_banniere IS NOT NULL
	AND date_debut <= (CURRENT_DATE)
	AND date_fin >= (CURRENT_DATE)
);

CREATE VIEW produit_alerte AS (
	SELECT *
	FROM produit
	WHERE quantite <= seuil_alerte
);



CREATE VIEW produit_panier AS (
    SELECT e.id_client, e.quantite AS quantite_panier, p.* 
    FROM _elt_panier e
    INNER JOIN produit p
        ON e.id_produit = p.id_produit
);

CREATE OR REPLACE VIEW avis_vendeur AS (
    SELECT     a.id_avis AS id_avis, 
             v.id_compte AS id_compte, 
            v.raison_sociale AS raison_sociale, 
            c.id_image_profil AS id_image_profil
    FROM _avis a
    INNER JOIN _produit p
        ON a.id_produit = p.id_produit
       INNER JOIN _vendeur v
        ON p.id_vendeur = v.id_compte
    INNER JOIN _compte c
        ON v.id_compte = c.id_compte
);

CREATE VIEW stats_par_produit AS
    SELECT _elt_commande.id_produit, _elt_commande.quantite, _elt_commande.prix, date_commande, categorie, nom_stock, id_vendeur
    FROM _elt_commande
    NATURAL JOIN _commande
    left JOIN _produit on _elt_commande.id_produit = _produit.id_produit
;

CREATE VIEW stats_par_produit2 AS
    SELECT _elt_commande.id_produit, _elt_commande.quantite, _elt_commande.prix, date_commande, categorie, nom_stock, id_vendeur,
DATE_FORMAT(
        CONVERT_TZ(date_commande, 'Europe/Paris', 'UTC'),
        '%Y-%m-%dT%H:%i:%s.000Z'
    ) AS date

    FROM _elt_commande
    NATURAL JOIN _commande
    left JOIN _produit on _elt_commande.id_produit = _produit.id_produit
;


CREATE VIEW promo_a_venir AS SELECT * FROM _promotion WHERE date_debut >= CURDATE();

CREATE VIEW reduction_a_venir AS SELECT * FROM _reduction WHERE date_debut >= CURDATE();
