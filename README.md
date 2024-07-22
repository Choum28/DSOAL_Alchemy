# DSOAL_Alchemy
Recreate in powershell the creative alchemy application but for usage with DSOAL (https://github.com/kcat/dsoal).
French and English version avalaible.

   What is different from creative alchemy ?
   
       *  Registry path are checked in both X86 and X86-64 path.
       *  Install dsoal.dll and dsoal-aldrv.dll to game folder detected.
       *  Support for x64 Wrapper and drivers
       
    
## Prerequesites
OpenAlsoft (https://github.com/kcat/openal-soft) binary.
DSOAL : https://github.com/kcat/dsoal) binary.

Note 32 & 64 bits binary of DSOAL could be found in https://ci.appveyor.com/project/ChrisRobinson/dsoal
Click on the correct job (x86 'Win32' or x64 'Win64') -> artefact -> Click on dsoal.zip to download it

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
    | 
    |-- en-US                   and/Or any other language culture (fr-Fr)
    |    |--dsoal_alchemy.psd1  Containt all texts related to the script
    |
    |-- x86-64
    |    |--soft_oal.dll        64 bits version of openal soft driver
    |    |--dsound.dll          64 bits version of dsoal
    |
    |-- x86
         |--soft_oal.dll        32 bits version of openal soft driver
         |--dsound.dll          32 bits version of dsoal
```


Note : Creative alchemy and DSOAL Alchemy
If you already have creative alchemy installed, the script will automatically use your alchemy.ini to create the Dsoal_alchemy.ini gamelist.
If you don't have creative alchemy, the script will use the Games.template file to generate one.
If the games.template file is deleted, the Dsoal_alchemy.ini will be empty.  

## launch the script  
Launch the script and hide console

***.\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\script\Dsoal_alchemy.ps1"***

The script will create and use Dsoal_alchemy.ini to store games and options in the script folder.

## Options

* When launched, Dsoal ALchemy application will search the system for supported
DirectSound3D enabled games. All the games found will be listed in the left pane (titled
"Installed Games"). The right pane (titled "DSOAL-enabled Games”) will show any
games which have already been converted to use DSOAL.

* To enable DSOAL support for a particular game, select it from the left panel, and press
the “>>” button. 
* To undo DSOAL support, select the game from the right panel and
press the “<<” button. You can select multiple games at once and then use the directional
arrow buttons to update them all.


<img src="https://i.imgur.com/3ZXPCkO.png">
<img src="https://i.imgur.com/lBo1CYW.png">
<img src="https://i.imgur.com/VcC2clx.png">