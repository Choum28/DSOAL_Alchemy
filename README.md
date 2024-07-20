# DSOAL_Alchemy
Recreate in powershell the creative alchemy application but for usage with DSOAL dll.
French and English version avalaible.

   What is different from creative alchemy ?
   
       *  Registry path are checked in both X86 and X86-64 path.
       *  Install dsoal.dll and dsoal-aldrv.dll to detected game folder.
       
    
## Install
Creative ALchemy must be installed on your pc.  
Copy the script and your language (culture) folder into a folder of your choise.
dsoal.dll and dsoal-aldrv.dll should be present in the script folder.
the Creative alchemy.ini file should be present in the script folder to generate
the initial gamelist (if not Dsoal_alchemy.ini file is found). 
Launch the script
   
The script will use for text translation in priority the culture folder of your language, or will load the en-us one if it's not present (ex: de-DE).   
if you do not copy at least the en-US culture folder, you will have no text.   

## launch the script  
Launch the script and hide console
.\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\script\Dsoal_alchemy.ps1"

The scripts will create and use a new Dsoal_alchemy.ini in the script folder to store games and options.

## Options

*When launched, the Creative ALchemy application will search the system for supported
DirectSound3D enabled games. All the games found will be listed in the left pane (titled
"Installed Games"). The right pane (titled "DSOAL-enabled Games”) will show any
games which have already been converted to use ALchemy.
To enable ALchemy support for a particular game, select it from the left panel, and press
the “>>” button. To undo ALchemy support, select the game from the right panel and
press the “<<” button. You can select multiple games at once and then use the directional
arrow buttons to update them all. 
