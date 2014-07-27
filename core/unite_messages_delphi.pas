unit unite_messages_delphi;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

{$I ..\dlcompilers.inc}
{$I ..\extends.inc}


uses fonctions_string
{$IFDEF VERSIONS}
     ,fonctions_version ;

const
  gVer_unite_messages : T_Version= ( Component : 'Constantes messages' ; FileUnit : 'unite_messages' ;
                        	     Owner : 'Matthieu Giroux' ;
                        	     Comment : 'Constantes et variables messages.' ;
                        	     BugsStory : 'Version 1.0.6.0 : db messages.' + CST_ENDOFLINE
                                               + 'Version 1.0.5.0 : NetUpdate messages.' + CST_ENDOFLINE
                                               + 'Version 1.0.4.1 : Menu Toolbar messages.' + CST_ENDOFLINE
                                               + 'Version 1.0.4.0 : Message d''erreur de sauvegarde ini.' + CST_ENDOFLINE
                                               + 'Version 1.0.3.3 : Message GS_MC_ERREUR_CONNEXION.' + CST_ENDOFLINE
                                               + 'Version 1.0.3.2 : Modifs GS_MC_VALEUR_UTILISEE et GS_MC_VALEURS_UTILISEES, ajout de GS_MC_DETAILS_TECHNIQUES.' + CST_ENDOFLINE
                                               + 'Version 1.0.3.1 : Constante message Form Dico.' + CST_ENDOFLINE
                                               + 'Version 1.0.3.0 : Constantes INI.' + CST_ENDOFLINE
                                               + 'Version 1.0.2.0 : Plus de messages dans l''unit�.' + CST_ENDOFLINE
                                               + 'Version 1.0.1.0 : Plus de messages dans l''unit�.' + CST_ENDOFLINE
                                               + 'Version 1.0.0.0 : Gestion des messages des fen�tres.';
                        	     UnitType : 1 ;
                        	     Major : 1 ; Minor : 0 ; Release : 6 ; Build : 0 )

{$ENDIF};

// COmposants
const
  CST_RESSOURCENAV = 'EXTNAV' ;
  CST_RESSOURCENAVMOVE = 'MOVE' ;
  CST_RESSOURCENAVBOOKMARK = 'BOOKMARK' ;
  CST_HC_SUPPRIMER        = 0 ;
  CST_PALETTE_COMPOSANTS_INVISIBLE = 'ExtInvisible' ;
  CST_PALETTE_COMPOSANTS_DB = 'ExtDB' ;
  CST_PALETTE_COMPOSANTS    = 'ExtCtrls' ;
  CST_PALETTE_BOUTONS    = 'FWButtons' ;
  CST_Avant_Fichier = 'MG_';
  CST_ARG           = '@ARG' ;
  CST_ASYNCHRONE_TIMEOUT_DEFAUT = 30 ;
  CST_CONNECTION_TIMEOUT_DEFAUT : Integer = 15 ;
  CST_ASYNCHRONE_NB_ENREGISTREMENTS : Integer = 300 ;
  CST_CONNECTION_TIMEOUT = 'Connection TimeOut' ;
  CST_FORM_ONCLOSE = 'OnClose' ;
 {$IFDEF EADO}
  CST_Set_KEYSET = 'Set Keyset' ;
  CST_MODE_ASYNCHRONE = 'Mode Asynchrone' ;
  CST_ACCES_DIRECT_SERVEUR = 'Acc�s directs Serveur' ;
  CST_MODE_CONNEXION_ASYNCHRONE = 'Connection Asynchrone' ;
  CST_MODE_ASYNCHRONE_NB_ENREGISTREMENTS = 'Mode Asynchrone Enregistrements' ;
  CST_MODE_ASYNCHRONE_TIMEOUT = 'Mode Asynchrone TimeOut' ;
{$ENDIF}



resourcestring
  gs_TestOk  = 'Test OK' ;
  gs_TestBad  = 'Error' ;

  // Paquet extcore

  GS_ECRITURE_IMPOSSIBLE_AVEC_ATTR = 'Impossible d''�crire sur le fichier @ARG avec l''attribut de fichier @ARG.' ;
  GS_ECRITURE_IMPOSSIBLE = 'Impossible d''�crire sur le fichier @ARG.' ;
  GS_DETAILS_TECHNIQUES = 'D�tails techniques : ' ;
  GS_TOOLBARMENU_Personnaliser = 'Personnaliser' ;

  GS_OF_DATASET = 'du Dataset ';

  GS_SOFT_IMAGE_NOT_FOUND   ='Image @ARG non tnouv�e'+CST_ENDOFLINE +
                             'Veuillez copier le r�pertoire ''Images'' dans le r�pertoire de votre ex�cutable.';
  GS_GROUPE_INCLURE         = 'Inclure' ;
  GS_GROUPE_EXCLURE         = 'Exclure' ;
  GS_GROUPE_TOUT_INCLURE    = 'Tout inclure' ;
  GS_STRING_MUST_BE_HEXA    = 'La chaine doit repr�senter des hexad�cimaux' ;
  GS_GROUPE_TOUT_EXCLURE    = 'Tout exclure' ;
  GS_GROUPE_RETOUR_ORIGINE  = 'Restaurer les donn�es initiales' ;
  GS_GROUPE_MAUVAIS_BOUTONS = 'Les boutons de transfert doivent s''inverser dans les deux listes. ' + CST_ENDOFLINE
                        	+ 'Les boutons de transfert sont identifi�s par rapport � leur liste,' + CST_ENDOFLINE
                        	+ ' � l''inverse des num�ros d''images identifi�s par rapport � la table. ' ;
      // Doit-on enregistrer ou abandonner
  GS_GROUPE_ABANDON = 'Veuillez enregistrer ou abandonner avant de continuer.' ;
      // Vidage du panier : oui ou non
  GS_GROUPE_VIDER   = 'Le panier utilis� pour les r�affectations n''est pas vide.' + CST_ENDOFLINE
                         + 'Voulez-vous abandonner ces r�affectations ?' ;
  GS_PAS_GROUPES    = 'DatasourceOwnerTable ou DatasourceOwnerKey non trouv�s.' ;
  GS_GROUP_INCLUDE_LIST = 'Liste d''inclusion';
  GS_GROUP_EXCLUDE_LIST = 'Liste d''exclusion';

  GS_IMAGE_MAUVAISE_TAILLE = 'La taille de l''image doit �tre au moins de 32 sur 32.' ;
  GS_IMAGE_DEFORMATION = 'L''image sera d�form�e, continuer ?' ;
  GS_IMAGE_MAUVAISE_IMAGE = 'Mauvais format d''image.' ;
// Messages box
  gs_OK = 'OK';
  gs_Yes = 'Oui';
  gs_YesToAll = 'Oui � tout';
  gs_NoToAll = 'Non � tout';
  gs_No  = 'Non';
  gs_Cancel = 'Annuler';
  gs_Close = 'Fermer';
  gs_Ignore = 'Ignorer';
  gs_Warning = 'Attention';
  gs_Information = 'Informations';
  gs_Confirmation = 'Confirmation';
  gs_Error = 'Erreur';
  gs_Please_Wait = 'Veuillez patienter�';
  gs_Press_ctrl_c_to_copy_text = 'Appuyez sur Ctrl+C pour copier ce texte.';
  gs_Downloading_in_progress = 'T�l�chargement de @ARG en cours�';
  gs_Download_update = 'T�l�charger mise � jour';
  gs_Download_finished = 'T�l�chargement termin�.';
  GS_mot_passe_invalide = 'Mot de passe invalide.' + CST_ENDOFLINE
	 + 'Veuillez resaisir votre mot de passe.' ;
  GS_EXE_DO_NOT_EXISTS_EXITING   = 'L''ex�cutable suivant n''a pas �t� trouv�. L''application va s''arr?ter.'+#10+'@ARG' ;
  GS_IMAGING_FILTER = 'Graphic (*.bmp;*.BMP;*.xpm;*.XPM;*.pbm;*.PBM;*.pgm;*.PGM;*.ppm;*.PPM;*.ico;*.ICO;*.icns;*.ICNS;*.cur;*.CUR;*.jpeg;*.JPEG;*.jpg;*.JPG;'
          +'*.jfif;*.JFIF;*.tif;*.TIF;*.tiff;*.TIFF;*.gif*.GIF;*.dagsky;*.dat;*.dagtexture;*.img;*.cif;*.rci;*.bsi;'
          +'*.xpm;*.XPM;*.pcx;*.psd;*.pdd;*.jp2;*.j2k;*.j2c;*.jpx;*.jpc;*.pfm;*.pam;*.ppm;*.PPM;*.pgm;*.PGM;*.pbm;*.PBM;'
          +'*.tga;*.dds;*.gif;*.GIF;*.jng;*.JNG;*.mng;*.dib;*.DIB;*.tga;*.TGA;'
          +'*.dds;*.jng;*.JNG;*.mng;*.png;*.PNG;*.jfif;*.JFIF;*.jpe;*.jif;*.bmp;*.BMP;*.dib;*.DIB)|*.bmp;*.BMP;*.xpm;*.XPM;'
          +'*.pbm;*.PBM;*.pgm;*.PGM;*.ppm;*.PPM;*.ico;*.ICO;*.icns;*.ICNS;*.cur;*.CUR;*.jpeg;*.JPEG;*.jpg;*.JPG;*.jpe;*.jfif;*.JFIF;*.tif;*.TIF;*.tiff;*.TIFF;*.gif;*.GIF;*.gif;*.GIF;'
          +'*.dagsky;*.dat;*.dagtexture;*.img;*.cif;*.rci;*.bsi;*.xpm;*.XPM;*.pcx;*.psd;*.pdd;*.jp2;*.j2k;'
          +'*.j2c;*.jpx;*.jpc;*.pfm;*.pam;*.ppm;*.PPM;*.pgm;*.PGM;*.pbm;*.PBM;*.tga;*.TGA;*.dds;*.gif;*.GIF;*.jng;*.JNG;*.mng;*.png;*.PNG;*.jpg;*.JPG;'
          +'*.jpeg;*.JPEG;*.jfif;*.JFIF;*.jpe;*.jif;*.bmp;*.BMP;*.dib;*.DIB;*.tga;*.TGA;*.dds;*.jng;*.JNG;*.mng;*.gif;*.GIF;*.png;*.PNG;*.jpg;*.JPG;*.jpeg;*.JPEG;'
          +'*.jfif;*.JFIF;*.jpe;*.jif;*.bmp;*.BMP;*.dib;*.DIB|Bitmaps (*.bmp;*.BMP)|*.bmp;*.BMP|Pixmap (*.xpm;*.XPM)|*.xpm;*.XPM|Portable PixMap'
          +' (*.pbm;*.PBM;*.pgm;*.PGM;*.ppm;*.PPM)|*.pbm;*.PBM;*.pgm;*.PGM;*.ppm;*.PPM|Icon (*.ico;*.ICO)|*.ico;*.ICO|Mac OS X Icon (*.icns;*.ICNS)|*.icns;*.ICNS|Cursor'
          +' (*.cur;*.CUR)|*.cur;*.CUR|Joint Picture Expert Group (*.jpeg;*.JPEG;*.jpg;*.JPG;*.jpe;*.jfif;*.JFIF)|*.jpeg;*.JPEG;*.jpg;*.JPG;*.jpe;*.jfif;*.JFIF|'
          +'Tagged Image File Format (*.tif;*.TIF;*.tiff;*.TIFF)|*.tif;*.TIF;*.tiff;*.TIFF|Graphics Interchange Format (*.gif;*.GIF)|*.gif;*.GIF|'
          +'Animated GIF (*.gif;*.GIF)|*.gif;*.GIF|Imaging Graphic AllInOne (*.dagsky)|*.dagsky|Imaging Graphic AllInOne'
          +' (*.dat)|*.dat|Imaging Graphic AllInOne (*.dagtexture)|*.dagtexture|Imaging Graphic AllInOne (*.img)'
          +'|*.img|Imaging Graphic AllInOne (*.cif)|*.cif|Imaging Graphic AllInOne (*.rci)|*.rci|Imaging Graphic '
          +'AllInOne (*.bsi)|*.bsi|Imaging Graphic AllInOne (*.xpm;*.XPM)|*.xpm;*.XPM|Imaging Graphic AllInOne (*.pcx)|*.pcx|'
          +'Imaging Graphic AllInOne (*.psd)|*.psd|Imaging Graphic AllInOne (*.pdd)|*.pdd|Imaging Graphic AllInOne'
          +' (*.jp2)|*.jp2|Imaging Graphic AllInOne (*.j2k)|*.j2k|Imaging Graphic AllInOne (*.j2c)|*.j2c|'
          +'Imaging Graphic AllInOne (*.jpx)|*.jpx|Imaging Graphic AllInOne (*.jpc)|*.jpc|Imaging Graphic AllInOne '
          +'(*.pfm)|*.pfm|Imaging Graphic AllInOne (*.pam)|*.pam|Imaging Graphic AllInOne (*.ppm;*.PPM)|*.ppm;*.PPM|'
          +'Imaging Graphic AllInOne (*.pgm;*.PGM)|*.pgm;*.PGM|Imaging Graphic AllInOne (*.pbm;*.PBM)|*.pbm;*.PBM|Imaging Graphic'
          +' AllInOne (*.tga;*.TGA)|*.tga;*.TGA|Imaging Graphic AllInOne (*.dds)|*.dds|Imaging Graphic AllInOne (*.gif;*.GIF)|'
          +'*.gif;*.GIF|Imaging Graphic AllInOne (*.jng;*.JNG)|*.jng;*.JNG|Imaging Graphic AllInOne (*.mng)|*.mng|'
          +'Imaging Graphic AllInOne (*.png;*.PNG)|*.png;*.PNG|Imaging Graphic AllInOne (*.jpg;*.JPG)|*.jpg;*.JPG|'
          +'Imaging Graphic AllInOne (*.jpeg;*.JPEG)|*.jpeg;*.JPEG|Imaging Graphic AllInOne (*.jfif;*.JFIF)|*.jfif;*.JFIF|'
          +'Imaging Graphic AllInOne (*.jpe)|*.jpe|Imaging Graphic AllInOne (*.jif)|*.jif|'
          +'Imaging Graphic AllInOne (*.bmp;*.BMP)|*.bmp;*.BMP|Imaging Graphic AllInOne (*.dib;*.DIB)|*.dib;*.DIB|'
          +'Truevision Targa Image (*.tga;*.TGA)|*.tga;*.TGA|DirectDraw Surface (*.dds)|*.dds|JPEG Network Graphics (*.jng;*.JNG)|'
          +'*.jng;*.JNG|Multiple Network Graphics (*.mng)|*.mng|Graphics Interchange Format (*.gif;*.GIF)|*.gif;*.GIF|'
          +'Portable Network Graphics (*.png;*.PNG)|*.png;*.PNG|Joint Photographic Experts Group Image (*.jpg;*.JPG)|*.jpg;*.JPG|'
          +'Joint Photographic Experts Group Image (*.jpeg;*.JPEG)|*.jpeg;*.JPEG|Joint Photographic Experts Group Image '
          +'(*.jfif;*.JFIF)|*.jfif;*.JFIF|Joint Photographic Experts Group Image (*.jpe)|*.jpe|Joint Photographic Experts Group Image (*.jif)|'
          +'*.jif|Windows Bitmap Image (*.bmp;*.BMP)|*.bmp;*.BMP|Windows Bitmap Image (*.dib;*.DIB)|*.dib;*.DIB|Tous les fichiers (*)|*|' ;

  // dbcomponents
  gs_Caption_Save_in = 'Sauvegarde dans @ARG.';
  gs_Caption_Restore_database = 'Restauration base @ARG.';
  gs_Error_Restore_Directory_does_not_exists =
          'Op�ration impossible, le r�pertoire de sauvegarde'+CST_ENDOFLINE
        +'@ARG'+CST_ENDOFLINE+'n''existe pas et ne peut �tre cr��.';
  gs_Optimising_database_is_a_success = 'L''optimisation de la base s''est bien pass�e.';

 // Composants
  GS_SUPPRIMER_QUESTION = 'Confirmez-vous l''effacement de l''enregistrement ?' ;
  GS_CHARGEMENT_IMPOSSIBLE_FIELD_IMAGE  = 'Il est impossible de charger l''enregistrement de l''image.' ;
  GS_CHARGEMENT_IMPOSSIBLE_STREAM_IMAGE = 'Il est impossible de charger le flux image.' ;
  GS_CHARGEMENT_IMPOSSIBLE_STREAM_FIELD = 'Il est impossible de charger le flux image dans le champ.' ;
  GS_CHARGEMENT_IMPOSSIBLE_FILE_IMAGE   = 'Il est impossible de charger le fichier image.' ;
  GS_ERREUR_OUVERTURE = 'Erreur � l''ouverture @ARG.' ;
  GS_FORM_ABANDON_OUVERTURE = 'Abandon de l''ouverture de la fiche @ARG...' ;
  GS_FirstRecord = 'Premier enregistrement';
  Gs_GROUPVIEW_Basket = 'Retour origine';
  Gs_GROUPVIEW_Record = 'Enregistrer';
  Gs_GROUPVIEW_Abort  = 'Abandonner';

  GS_PriorRecord = 'Enregistrement pr�c�dent';
  GS_NextRecord = 'Enregistrement suivant';
  GS_LastRecord = 'Dernier enregistrement';
  GS_InsertRecord = 'Ins�rer enregistrement';
  GS_DeleteRecord = 'Supprimer l''enregistrement';
  GS_EditRecord = 'Modifier l''enregistrement';
  GS_PostEdit = 'Valider modifications';
  GS_CancelEdit = 'Annuler les modifications';
  GS_ConfirmCaption = 'Confirmation';
  GS_RefreshRecord = 'Rafra�chir les donn�es';
  GS_SearchRecord = 'Rechercher' ;
  GS_MoveNextRecord = 'D�placer l''enregistrement au suivant' ;
  GS_MovePreviousRecord = 'D�placer l''enregistrement au pr�c�dent' ;
  GS_SetBookmarkRecord = 'Marquer L''enregistrement' ;
  GS_GotoBookmarkRecord = 'Aller � l''enregistrement Marqu�' ;

  // SGBD
 
 {$IFDEF FPC}
  SCloseButton = '&Fermer' ;
 {$ENDIF}

  // Erreurs
  gs_Error_Forbidden_Access = 'Acc�s interdit';
  gs_Error_Bad_URL = 'Mauvaise URL : @ARG';
  gs_Error_Bad_request = 'Mauvaise requ�te';
  gs_Error_Bad_Gateway = 'Mauvaise passerelle';
  gs_Error_Bad_Web_Connection='Probl�me de connexion internet.';
  gs_Error_Bad_Connection='Probl�me de connexion � @ARG.';
  gs_Error_Cannot_load_not_downloaded_file = 'Impossible de lire le fichier. Il n''a pas �t� t�l�charg�.';
  gs_Error_Cannot_Write_on = '�criture impossible de @ARG.';
  gs_Error_File_is_not_on_the_web_site = 'Le fichier que vous essayez de t�l�charger est absent du site.';
  gs_Error_timeout_problem = 'Probl�me de timeOut';
  GS_ERREUR_NOMBRE_GRAND = 'Probl�me � la validation du nombre :' + CST_ENDOFLINE
                   + 'Un nombre saisi est trop grand.' + CST_ENDOFLINE
                   + 'Modifier la saisie ou annuler.' ;
  GS_METTRE_A_JOUR_FICHE = 'L''enregistrement a �t� effac� ou modifi� par un autre utilisateur.' + #13 + #10
                        			+ 'La fiche va �tre mise � jour.' ;
  GS_VALEUR_UTILISEE   = 'La valeur @ARG est d�j� utilis�e.' + #13 + #10
                        		+ 'Saisir une valeur diff�rente, annuler ou r�effectuer la validation si une valeur n''est pas modifiable.' ;
  GS_VALEURS_UTILISEES = 'Les valeurs @ARG sont d�j� utilis�es.' + #13 + #10
                        		+ 'Saisir des valeurs diff�rentes, annuler ou r�effectuer la validation si une valeur n''est pas modifiable.' ;
  GS_ERREUR_RESEAU = 'Erreur r�seau.' + CST_ENDOFLINE
                        + 'V�rifier la connexion r�seau.' ;
  GS_ERREUR_MODIFICATION_MAJ = 'Impossible de supprimer cet enregistrement.' + CST_ENDOFLINE
               + 'Il est utilis� dans une autre fonction.';
  GS_ERREUR_CONNEXION = 'Un probl�me est survenu pour la connexion aux donn�es.' + CST_ENDOFLINE
                        	 + 'R�essayez d''ouvrir la fiche.' ;
                        //GS_CHANGEMENTS_SAUVER = 'Des changements ont �t� effectu�s.' + CST_ENDOFLINE +' Le trie n�cessite alors une sauvegarde.'  + CST_ENDOFLINE + 'Voulez-vous enregistrer les changements effectu�s ?' ;

 // Messages pour les images
  GS_IMAGE_MULTIPLE_5 = 'L''image doit avoir une largeur multiple de ' ;
  GS_IMAGE_DOIT_ETRE = 'La taille de l''image doit �tre de ' ;
  GS_IMAGE_HAUTEUR = 'L''image doit avoir une hauteur de ' ;
  GS_IMAGE_TROP_PETITE = 'L''image est trop petite.' ;
  GS_IMAGE_TROP_GRANDE = 'L''image est trop grande.' ;
  GS_FICHIER_NON_TROUVE = 'Fichier @ARG non trouv�.' ;

  // confirmation demand�e
  GS_INI_FILE_CANT_WRITE = 'Chemin @ARG inaccessible.' + CST_ENDOFLINE + 'D�marrer l''application en tant qu''administrateur' ;
  gs_Confirm_File_is_unavailable_Do_i_erase_it_to_update_it = 'Le fichier est innaccessible.'+CST_ENDOFLINE+'L''effacer pour le mettre � jour ?';

 // Messages pour le navigateur
  GS_INSERER_ENREGISTREMENT = 'Ins�rer un enregistrement' ;
  GS_VALIDER_MODIFICATIONS  = 'Valider les modifications' ;

  GS_NAVIGATEUR_VERS_LE_BAS  = 'D�placer la ligne vers le bas' ;
  GS_NAVIGATEUR_VERS_LE_HAUT = 'D�placer la ligne vers le haut' ;

  GS_PB_CONNEXION = 'La connexion a �chou�e.' + #13 + #10
                      + 'Veuillez contacter votre administrateur.';
  GS_DECONNECTER_ANNULE = 'Annulation de la d�connexion';
  GS_PLEASE_SET_PROPERTY = 'Veuillez renseigner cette propri�t� : ';
  GS_Files_seems_to_be_the_same_reuse = 'Il y a un fichier de m�me taille et nom d�j� sauvegard�. Le r�utilise-t-on ?';

  GS_MODE_ASYNCHRONE = 'Mode Asynchrone' ;
  GS_ACCES_DIRECT_SERVEUR = 'Acc�s directs Serveur' ;
  GS_MODE_CONNEXION_ASYNCHRONE = 'Connection Asynchrone' ;
  GS_MODE_ASYNCHRONE_NB_ENREGISTREMENTS = 'Mode Asynchrone Enregistrements' ;
  GS_MODE_ASYNCHRONE_TIMEOUT = 'Mode Asynchrone TimeOut' ;
  GS_CONNECTION_TIMEOUT = 'Connection TimeOut' ;
  GS_Set_KEYSET         = 'Set Keyset'; 

var
  gb_MainFormIniOneUserOnServer : Boolean = False ;
{$IFDEF EADO}
  GB_ASYNCHRONE_PAR_DEFAUT : Boolean = False ;
{$ENDIF}
implementation

initialization
{$IFDEF VERSIONS}
  p_ConcatVersion ( gVer_unite_messages );
{$ENDIF}
end.
