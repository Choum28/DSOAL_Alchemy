#culture="en-US"
ConvertFrom-StringData @'
	#main form Text
	BoutonAjouterContent=Add
	BoutonEditionContent=Edit
	BoutonDefaultContent=Default
	Defaultmsgbox=This will revert the list of games and settings to the defaults. 
	Defaultmsgbox2=A backup of this information will be saved to: 
	Defaultmsgbox3=Are you sure you want to continue?
	Text_main=DSOAL restores audio so that you can enjoy EAX effects and 3D Audio when playing Directsound 3D games in Microsoft Windows Vista and above.
	Text_jeuInstall=Installed Games
	Text_JeuTransmut=DSOAL Alchemy-enabled Games
	#Edit / add Form Text
	MainTitle2=Game Settings
	C_registreContent=Use Registry Path
	C_GamepathContent=Use Game Path
	T_registreToolTip=registry path containing string to executable or executable's directory (use this when available, alternative is GamePath)
	T_GamepathToolTip=Directory to look for app (if RegPath can't be used)
	B_OkContent=Ok
	B_CancelContent=Cancel
	L_GameTitleContent=Game Title
	T_SubdirToolTip=subdirectory offset off of path pointed to by RegPath or Gamepath for library support
	C_SubDirContent=Install into Sub Folder
	C_RootdirContent=Install into both Root and Sub Folders
	C_x64Content=64-bit game
	C_x64ToolTip=if checked, install 64 bits (x86-64) wrapper and drivers dll in the game folder, shoud be used only with very rare directsound 3d 64bits games.
	# Error message
	Badlocation=NewAlchemy required Creative Alchemy installation.
	RegKeyInc=Registry key value incorrect
	RegKeyValInc=Registry key value does not return a Path
	RegKeyBad=Registry key invalid
	RegKeyEmpty=Registry key empty
	PathEmpty=Empty Path
	BadPath=Invalid Path
	BadPathOrSub=Path do not exist or is not a Sub Folder.
	SubNotFound=Sub Folder not found
	TitleExist=Game Title already exist
	TitleMiss=Game Title mandatory
'@
