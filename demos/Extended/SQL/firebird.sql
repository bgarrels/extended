/********************* ROLES **********************/
/********************* UDFS ***********************/
/****************** GENERATORS ********************/
CREATE GENERATOR GEN_T1_ID;
CREATE GENERATOR GEN_T2_ID;
/******************** DOMAINS *********************/
/******************* PROCEDURES ******************/
/******************** TABLES **********************/
CREATE TABLE DEPARTEMENT
(
  CLEP integer NOT NULL,
  NOM varchar(100),
  PRIMARY KEY (CLEP)
);
CREATE TABLE UTILISATEUR
(
  CLEP integer NOT NULL,
  NOM varchar(100),
  PRENOM varchar(100),
  IDDEPARTEMENT integer,
  PHOTO blob sub_type 0,
  ENTIER integer,
  PRIMARY KEY (CLEP)
);
/********************* VIEWS **********************/
/******************* EXCEPTIONS *******************/
/******************** TRIGGERS ********************/
SET TERM ^ ;
CREATE TRIGGER DELETE_DEPARTEMENT_UTILISATEUR FOR DEPARTEMENT ACTIVE
BEFORE DELETE POSITION 0
AS
BEGIN
UPDATE UTILISATEUR SET UTILISATEUR.IDDEPARTEMENT = NULL WHERE IDDEPARTEMENT = OLD.CLEP;
END^
SET TERM ; ^
SET TERM ^ ;
CREATE TRIGGER DEPARTEMENT_GEN FOR DEPARTEMENT ACTIVE
BEFORE INSERT POSITION 0
AS
BEGIN
if (NEW.CLEP is NULL) then NEW.CLEP =GEN_ID(GEN_T2_ID, 1);
END^
SET TERM ; ^
SET TERM ^ ;
CREATE TRIGGER UPDATE_DEPARTEMENT_UTILISATEUR FOR DEPARTEMENT ACTIVE
BEFORE UPDATE POSITION 0
AS
BEGIN
IF (NEW.CLEP <> OLD.CLEP) THEN
BEGIN
UPDATE UTILISATEUR SET UTILISATEUR.IDDEPARTEMENT = NEW.CLEP WHERE IDDEPARTEMENT = OLD.CLEP;
END
END^
SET TERM ; ^
SET TERM ^ ;
CREATE TRIGGER UTILISATEUR_GEN FOR UTILISATEUR ACTIVE
BEFORE INSERT POSITION 0
AS
BEGIN
if (NEW.CLEP is NULL) then NEW.CLEP =GEN_ID(GEN_T1_ID, 1);
END^
SET TERM ; ^
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON DEPARTEMENT TO  SYSDBA WITH GRANT OPTION;
GRANT DELETE, INSERT, REFERENCES, SELECT, UPDATE
 ON UTILISATEUR TO  SYSDBA WITH GRANT OPTION;
