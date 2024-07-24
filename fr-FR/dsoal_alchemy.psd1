#culture="fr_FR"
ConvertFrom-StringData @'
	#main form
	BoutonAjouterContent=Ajouter
	BoutonEditionContent=Édition
	BoutonDefaultContent=Par défaut
	Defaultmsgbox=La liste de jeux et les paramètres par défaut vont être rétablis.
	Defaultmsgbox2=Ces informations vont être sauvegardée dans : 
	Defaultmsgbox3=Etes vous sur de vouloir continuer ?
	Text_main=DSOAL restaure le son de sorte que vous puissez profiter des effets EAX et du son Audio 3D lorsque vous utilisez des jeux DirectSound3D dans windows version Vista et supérieures.
	Text_jeuInstall=Jeux installés
	Text_JeuTransmut=Jeux activés par DSOAL
	#Edit / add Form
	MainTitle2=Paramètres du jeu
	C_ConfContent=Copier configuration openalsoft
	C_ConfTooltip=Si coché, la configuration openalsoft sélectioné sera aussi copié (en tant que alsoft.ini), utile si vous souhaitez une configuration openalsoft particulère pour un jeu.
	C_registreContent=Utiliser le chemin d'accès au registre
	C_GamepathContent=Utiliser le chemin d'accès au jeu
	T_registreToolTip=Chemin du registre contenant la chaîne de l'exécutable ou le répertoire de l'exécutable (à privilégier, l'alternative est le chemin d'accès)
	T_GamepathToolTip=Chemin vers le dossier de l'application (si le chemin d'accès au registre ne peut être utilisé)
	B_OkContent=Ok
	B_CancelContent=Annuler
	L_GameTitleContent=Titre du jeu
	T_SubdirToolTip=Permet de définir un sous-dossier par rapport au chemin remonté par le chemin d'accès
	C_SubDirContent=Installer dans un sous-dossier
	C_RootdirContent=Installer dans le dossier racine et un sous-dossier
	C_x64Content=Jeu 64-bit
	C_x64ToolTip=Si coché installe le wrapper et le pilote 64 bit (x86-64) dans le dossier du jeu, utile uniquement pour très rares jeux directsound 3D 64bits.
	FolderChoice=Sélectionnez un dossier
	SubFolderChoice=Sélectionnez un sous-dossier
	# Error message
	MissFile=Fichier nécéssaire manquant dans le dossier du gestionnaire de jeu DSOAL
	RegKeyInc=Valeur de la clef registre incorrect
	RegKeyValInc=La clef registre ne renvoie pas un chemin
	RegKeyBad=La clef registre est invalide
	RegKeyEmpty=Le chemin d'accès au registre est vide
	PathEmpty=Le chemin d'accès au jeu est vide
	BadPath=Le chemin d'accès est invalide
	BadPathOrSub=Le chemin n'existe pas ou n'est pas un sous-dossier.
	SubNotFound=Le sous-dossier est introuvable
	TitleExist=Titre de jeu déja existant
	TitleMiss=Titre de jeu obligatoire
'@
