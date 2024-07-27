# DSOAL_Alchemy
Recreate in powershell the creative alchemy application but for usage with DSOAL (https://github.com/kcat/dsoal).
French and English version avalaible.

   What is different from creative alchemy ?
   
       *  Registry path are checked in both X86 and X86-64 path.
       *  Install dsoal.dll and dsoal-aldrv.dll to game folder detected.
       *  Support for x64 Wrapper and drivers
       
    
## Prerequesites
OpenAlsoft : https://github.com/kcat/openal-soft binaries.<br>
DSOAL : https://github.com/kcat/dsoal binaries.

<p>Note 32 & 64 bits binaries of DSOAL could be found at https://ci.appveyor.com/project/ChrisRobinson/dsoal<br>
Click on the correct job (x86 'Win32' or x64) -> artefact -> Click on dsoal.zip to download it</p>

## Installation

* Copy the script dsoal_alchemy.ps1 and language (culture) folder into a folder of your choise.
* Download dsoal.dll (https://github.com/kcat/dsoal)  and OpenAlsoft (https://github.com/kcat/openal-soft)
* Copy the dsound.dll 64bits version of the DSOAL wrapper into the X86-64 folder
* Copy the dsound.dll 32bits version of theDSOAL wrapper into the X86 folder
* Copy the soft_oal.dll 64bits version of openal-soft drivers into the X86-64 folder
* Copy the soft_oal.dll 32bits version of openal-soft drivers into the X86 folder

A Correct installation should look like this

```
DSOAL_Alchemy-main
    |
    |--dsoal_alchemy.ps1        the script itself
    |--Games.template           Default gamelist use to generate the dsoal_alchemy.ini gamelist, not used if you have creative alchemy installed.
    |--dsoal_alchemy.ico        Icon file used by Gui.
    | 
    |-- en-US                   and/or any other language culture folder (fr-FR)
    |    |--dsoal_alchemy.psd1  Containt all texts related to the script
    | 
    |-- configs                 Folder where you put specific openalsoft (ini file) configuration you want to use
    |
    |-- x86-64
    |    |--soft_oal.dll        64 bits version of openal soft driver
    |    |--dsound.dll          64 bits version of dsoal
    |
    |-- x86
         |--soft_oal.dll        32 bits version of openal soft driver
         |--dsound.dll          32 bits version of dsoal
```


Note : 

**Creative alchemy and DSOAL Alchemy**<br>
If you already have creative alchemy installed, the script will automatically use your alchemy.ini to create the Dsoal_alchemy.ini gamelist.<br>
If you don't have creative alchemy, the script will use the Games.template file to generate one.<br>
If the games.template file is deleted, the Dsoal_alchemy.ini will be empty.

**Openalsoft configurations**<br>
You can copy openalsoft configurations you want to use into the configs folder, it should be a .ini file<br>
When the setting is selected in Dsoal_alchemy, the script will automatically copy the selected configuration as alsoft.ini into game folder(s).

## launch the script  
Launch the script and hide console

***.\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\script\Dsoal_alchemy.ps1"***

The script will create and use Dsoal_alchemy.ini to store games and options in the script folder.

## How to use

<p>When launched, Dsoal ALchemy application will search the system for supported<br>
DirectSound3D enabled games. All the games found will be listed in the left panel (titled
"Installed Games").<br>The right pane (titled "DSOAL-enabled Games”) will show any
games which have already been converted to use DSOAL.</p>

* To enable DSOAL support for a particular game, select it from the left panel, and press
the “>>” button. 
* To undo DSOAL support, select the game from the right panel and
press the “<<” button. You can select multiple games at once and then use the directional
arrow buttons to update them all.

Buttons and checkbox have tooltip when you place your mouse cursor on them.


<img src="https://i.imgur.com/3ZXPCkO.png">
<img src="https://i.imgur.com/HZrG3Qv.png">
<img src="https://i.imgur.com/EUPhc4S.png">
