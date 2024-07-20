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
	C_DisableDirectMusicContent=Disable Direct Music 
	C_DisableDirectMusicToolTip=is used to disable DirectMusic support. Default is false (0 or 1 in dsound.ini).
	C_DisableNativeAlContent=Disable Native OpenAL drivers 
	C_DisableNativeAlToolTip=For X-Fi and Audigy card only, disable the use of hardware openAL driver (CT_oal.dll) by ALchemy, the Creative Software 3D Library will be used instead.
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
