<# 
.SYNOPSIS
    This script is a test to recreate the Creative Alchemy application in powershell for the usage with DSOAL.

.DESCRIPTION
    What different from creative alchemy :
        Registry path are check in both X86 and X86-64 path.
        dsoal.dll and dsoal-aldrv.dll should be present in the script folder.
        the Creative alchemy.ini file should be present in the script folder to 
        generate the initial gamelist (if not Dsoal_alchemy.ini file is found). 

.EXAMPLE
    .\Dsoal-Alchemy.ps1
        Launch the script

 -------------------------- EXEMPLE 2 --------------------------
 .\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\script\Dsoal_alchemy.ps1"
        Launch the script and hide console

.OUTPUTS
    This script will generate an ini file Dsoal_alchemy.ini to store gamelist audio options and change.
    
.NOTES
    NAME:       Dsoal_Alchemy.ps1
    AUTHOR:    Choum

    VERSION HISTORY:
    1.5     22.08.2024    Add WPF Background colors, remove useless GridViewColumn
    1.4     17.08.2024    Add SHA 256 CRC check on soft_oal.dll & dsound.dll (32&64bits)
                          games that will not have same dlls as one in dsoal_alchemy folder will not appears in "Enabled list".
                          this will make dll version upgrades easier.
    1.3     15.08.2024    Add doubleclick support to transmut/Untransmut, possibility to edit from both Listview.
    1.22    04.08.2024    Test subdir path (if filled) before adding game to the detected list on startup.
    1.21    25.07.2024    Considerably improves launch loading time by improving CheckPresent function.
    1.2     24.07.2024    Add openalsoft configuration (ini) support.
    1.1     22.07.2024    Add 64bits game support (specific dlls needed)
                          Alchemy.ini is optionnal on first launch for gamelist creation
                          If Creative alchemy is installed, the script will use the alchemy.ini file to 
                          create the gamelist instead of default one.
    1.0     20.07.2024    First version
.LINK
    https://github.com/Choum28/DSOAL_Alchemy
 #>

# Check if all required dlls are present and if Creative Alchemy is installed (optionnal)
function LocateAlchemy { 
    if ( -Not ([System.IO.File]::Exists("$PSScriptRoot\Games.template")) ) {
        [System.Windows.MessageBox]::Show("$($txt.missfile) $PSScriptRoot\Games.template","",0,16)
        exit
    }
    if ( -Not ([System.IO.File]::Exists("$PSScriptRoot\x86-64\soft_oal.dll")) ) {
        [System.Windows.MessageBox]::Show("$($txt.missfile) $PSScriptRoot\86-64\soft_oal.dll","",0,16)
        exit
    }
    if ( -Not ([System.IO.File]::Exists("$PSScriptRoot\x86-64\dsound.dll")) ) {
        [System.Windows.MessageBox]::Show("$($txt.missfile) $PSScriptRoot\86-64\dsound.dll","",0,16)
        exit
    }
    if ( -Not ([System.IO.File]::Exists("$PSScriptRoot\x86\soft_oal.dll")) ) {
        [System.Windows.MessageBox]::Show("$($txt.missfile) $PSScriptRoot\x86\soft_oal.dll","",0,16)
        exit
    }
    if ( -Not ([System.IO.File]::Exists("$PSScriptRoot\x86\dsound.dll")) ) {
        [System.Windows.MessageBox]::Show("$($txt.missfile) $PSScriptRoot\x86\dsound.dll","",0,16)
        exit
    }
    if ( [Environment]::Is64BitOperatingSystem -eq $true ) {
        $key = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}"
    } else { $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{12321490-F573-4815-B6CC-7ABEF18C9AC4}" }
    $regkey = "InstallLocation"
    if (test-path $key) {
        try { $d = Get-ItemPropertyvalue -Path $key -name $regkey }
        catch {
            [System.Windows.MessageBox]::Show($txt.Badlocation,"",0,16)
            exit
        }
        if ( [System.IO.File]::Exists("$d\alchemy.ini") ) {
                return $d
        } else { [System.Windows.MessageBox]::Show("$($txt.missfile) $d\alchemy.ini","",0,16) }
    } else {
        $d = "False"
        return $d
    } 
    exit
}

#Convert value into hash table.
function Add-Game {
    param (
        [string]$Name,
        [string]$RegPath,
        [string]$Gamepath,
        [string]$SubDir,
        [string]$RootDirInstallOption,
        [string]$x64,
        [string]$Conf,
        [bool]$Found,
        [bool]$Transmut
    )
    
    $d = @{
        Name = $Name
        RegPath = $RegPath
        Gamepath = $Gamepath
        SubDir = $SubDir
        x64 = $x64
        RootDirInstallOption = $RootDirInstallOption
        Found = $Found
        Conf = $Conf
    }
    return $d
}

#read Dsoal_alchemy ini file and convert game to hash table with Add-Game function, default value are defined here if not found in dsoal_alchemy.ini.
function Read-File {
    param ( [string]$file )

    $list = Get-content $file
    $liste = @()
    $test = 0
    $Number = 0
    $RootDirInstallOption = "False"
    $x64 = "False"
    $Found = $false
    $Transmut = $false

    foreach ( $line in $list ) {
        $Number = $Number + 1
        if ( $line -notlike ';*' ) {
            Switch -wildcard ($line) {
                '`[*' {
                        if ( $test -gt 0 ) {
                                $liste += Add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -x64 $x64 -Conf $Conf -Found $Found -Transmut $Transmut
                                $RegPath = ""
                                $Gamepath = ""
                                $SubDir = ""
                                $RootDirInstallOption = "False"
                                $x64 = "False"
                                $Conf = ""
                                $Found = $false
                                $Transmut = $false
                        }
                            $test = $test+1
                            $Name = $line -replace '[][]'
                   }
                "RegPath=*" { $RegPath = $line.replace("RegPath=","") }
                "GamePath=*" { $Gamepath = $line.replace("GamePath=","") }
                "SubDir=*" { $SubDir = $line.replace("SubDir=","") }
                "RootDirInstallOption=*" { $RootDirInstallOption = $line.replace("RootDirInstallOption=","") }
                "x64=*" { $x64 = $line.replace("x64=","") }
                "Conf=*" { $Conf = $line.replace("Conf=","") }
            }
        }
    }
    if ( $Number -ne $test ) {
        $liste += Add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -x64 $x64 -Conf $Conf -Transmut $Transmut
    }
    return $liste
}

#Create New Dsoal_alchemy.ini file with new settings
function GenerateNewAlchemy {
    param ( [string]$file )

    @"
;DSOAL ALchemy titles
;Format/Options:
;  [TITLE]
;  RegPath <-- registry path containing string to executable or executable's directory (use this when available; alternative is GamePath)
;  GamePath <-- Directory to look for app (if RegPath can't be used) 
;  SubDir <-- subdirectory offset off of path pointed to by RegPath for library support (default is empty string)
;  RootDirInstallOption <-- option to install translator support in both RegPath and SubDir directories (default is False)
;  x64 <-- If true it will copy the 64bits wrapper and driver to game folder instead of 32bits one, only usefull for very rare 64bits Directsound 3D games. 
;  Conf <-- Openalsoft configuration file to use if defined.

"@ | Out-File -Append $PSScriptRoot\Dsoal_alchemy.ini -encoding ascii
    $liste = Read-File $file
    foreach ( $line in $liste ) {
        $a = $line.Name
        $b = $line.RegPath
        $c = $line.Gamepath
        $h = $line.SubDir
        $i = $line.RootDirInstallOption
        $j = $Line.x64
        $k = $Line.Conf
        "[$a]`r`nRegPath=$b`r`nGamePath=$c`r`nSubDir=$h`r`nRootDirInstallOption=$i`r`nx64=$j`r`nConf=$k`r`n" | Out-File -Append $PSScriptRoot\Dsoal_alchemy.ini -encoding ascii
    }
}

# Check if game is installed (registry in priority then gamepath), use of .net for performance.
function CheckPresent{
    param ( $a )
    $b = $a.RegPath
    if ( ![string]::IsNullOrEmpty($b) ) {
        # recup chemin et clef séparé
        $RegKey = $b|split-path -leaf
        $KeyPath = $b.replace("\$regkey","")
        
        Switch -wildcard ($b) {
            "HKEY_LOCAL_MACHINE*" {
                $KeyPath = $KeyPath.replace("HKEY_LOCAL_MACHINE\","")
                $RegTest = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($KeyPath)
                if ( $Null -eq $RegTest ) {
                    $KeyPath = $Keypath.replace("SOFTWARE","SOFTWARE\WOW6432Node")
                }
                $RegTest = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($KeyPath)
                if ( $Null -ne $RegTest ) {
                    $a.GamePath = $Regtest.GetValue($RegKey)
                }
            }
            "HKEY_CURRENT_USER*"{
                $KeyPath = $KeyPath.replace("HKEY_CURRENT_USER\","")
                $RegTest = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($KeyPath)
                if ( $Null -eq $RegTest ) {
                    $KeyPath = $Keypath.replace("SOFTWARE","SOFTWARE\WOW6432Node")
                }
                $RegTest = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($KeyPath)
                if ( $Null -ne $RegTest ) {
                    $a.GamePath = $Regtest.GetValue($RegKey)
                }
            }
        }
    }
    if ( ![string]::IsNullOrEmpty($a.gamePath) ) {
        if ( [System.IO.Directory]::Exists($a.GamePath) ) {
            if ( ![string]::IsNullOrEmpty($a.SubDir) ) {
                if ( [System.IO.Directory]::Exists("$($a.GamePath)\$($a.SubDir)") ) {
                    $a.Found = $true
                } else { $a.Found = $false }
            } else { $a.Found = $true }
        } else { $a.Found = $false }
    } else { $a.Found = $false }
    return $a
}

# Check if the game list is installed with check present function.
function CheckInstall {
    param ( $liste )

    $test = 0
    foreach ($game in $liste) { 
        $liste[$test] = CheckPresent $game
        $test = $test +1
    }
    return $liste
}

# Check if game is transmuted (dsoal-aldrv.dll + dsound present with correct Hash)
function checkTransmut {
    param( $liste )
    
    $test = 0
    foreach ( $game in $liste) {
        $gamepath = $game.Gamepath
        $Subdir = $game.SubDir
        $x64 = $game.x64
        $RootDirInstallOption = $game.RootDirInstallOption
        if ( $x64 -eq "False" ) {
            if ( [string]::IsNullOrEmpty($Subdir) ) {
                if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
                    if ( CheckHash $gamepath\dsoal-aldrv.dll $script:OalHash ) {
                        if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                            $game.Transmut = CheckHash $gamepath\dsound.dll $script:dsoundHash
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
                } else { $game.Transmut = $false }
            } elseif ( $RootDirInstallOption -eq $False ) {
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsoal-aldrv.dll") ) {
                    if ( CheckHash $gamepath\$Subdir\dsoal-aldrv.dll $script:OalHash ) {
                        if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                            $game.Transmut = CheckHash $gamepath\$Subdir\dsound.dll $script:dsoundHash
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
                } else { $game.Transmut = $false }
            } else { 
                    if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
                        if ( CheckHash $gamepath\dsoal-aldrv.dll $script:OalHash ) {
                            if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                                if ( CheckHash $gamepath\dsound.dll $script:dsoundHash ) {
                                    if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsoal-aldrv.dll") ) {
                                        if ( CheckHash $gamepath\$Subdir\dsoal-aldrv.dll $script:OalHash ) {
                                            if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                                                $game.Transmut = CheckHash $gamepath\$Subdir\dsound.dll $script:dsoundHash
                                            } else { $game.Transmut = $false }
                                        } else { $game.Transmut = $false }
                                    } else { $game.Transmut = $false }
                                } else { $game.Transmut = $false }
                            } else { $game.Transmut = $false}
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
              }
        } else {
            #x64
            if ( [string]::IsNullOrEmpty($Subdir) ) {
                if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
                    if ( CheckHash $gamepath\dsoal-aldrv.dll $script:OalHashx64 ) {
                        if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                            $game.Transmut = CheckHash $gamepath\dsound.dll $script:dsoundHashx64
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
                } else { $game.Transmut = $false }
            } elseif ( $RootDirInstallOption -eq $False ) {
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsoal-aldrv.dll") ) {
                    if (CheckHash $gamepath\$Subdir\dsoal-aldrv.dll $script:OalHashx64) {
                        if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                            $game.Transmut = CheckHash $gamepath\$Subdir\dsound.dll $script:dsoundHashx64
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
                } else { $game.Transmut = $false }
            } else { 
                    if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
                        if ( CheckHash $gamepath\dsoal-aldrv.dll $script:OalHashx64 ) {
                            if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
                                if ( CheckHash $gamepath\dsound.dll $script:dsoundHashx64 ) {
                                    if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsoal-aldrv.dll" ) ) {
                                        if ( CheckHash $gamepath\$Subdir\dsoal-aldrv.dll $script:OalHashx64 ) {
                                            if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) {
                                                $game.Transmut = CheckHash $gamepath\$Subdir\dsound.dll $script:dsoundHashx64
                                            } else { $game.Transmut = $false }
                                        } else { $game.Transmut = $false }
                                    } else { $game.Transmut = $false }
                                } else { $game.Transmut = $false }
                            } else { $game.Transmut = $false }
                        } else { $game.Transmut = $false }
                    } else { $game.Transmut = $false }
              }
        }
        $liste[$test] = $game
        $test = $test +1 
    }
    return $liste
}

function CheckHash {
    param(
        $filepath,
        $sourcehash
    )
    
    $destHash = (Get-FileHash -Path $filepath -Algorithm SHA256).Hash
    if ( $sourcehash -ne $destHash ) {
       $correcthash = $False
    } else { $correcthash = $True }
    return $correcthash
}

function Sortlistview {
    param ( $listview )

    $items = $listview.items | Sort-Object
    $listview.Items.Clear()
    foreach ( $item in $items ) {
        $listview.Items.Add($item)
    }
    return $listview
}

# Check dll filehash and copy if corrupt or missing, used by Transmut function.
function CheckFiles {
    param (
    [String]$gamepath,
    [String]$Arch
    )

    if ( $Arch -eq "x86" ) {
        if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
            $destHash = (Get-FileHash -Path "$gamepath\dsound.dll" -Algorithm SHA256).Hash
            if ( $script:dsoundHash -ne $destHash ) {
                Copy-Item -Path "$PSScriptRoot\x86\dsound.dll" -Destination $gamepath
            }
        } else { Copy-Item -Path "$PSScriptRoot\x86\dsound.dll" -Destination $gamepath }
        if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
            $destHash = (Get-FileHash -Path "$gamepath\dsoal-aldrv.dll" -Algorithm SHA256).Hash
            if ( $script:OalHash -ne $destHash ) {
                Copy-Item -Path "$PSScriptRoot\x86\soft_oal.dll" -Destination $gamepath\dsoal-aldrv.dll
            }
        } else { Copy-Item -Path "$PSScriptRoot\x86\soft_oal.dll" -Destination $gamepath\dsoal-aldrv.dll }
    } else {
        if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) {
            $destHash = (Get-FileHash -Path "$gamepath\dsound.dll" -Algorithm SHA256).Hash
            if ( $script:dsoundHashx64 -ne $destHash ) {
                Copy-Item -Path "$PSScriptRoot\x86-64\dsound.dll" -Destination $gamepath
            }
        } else { Copy-Item -Path "$PSScriptRoot\x86-64\dsound.dll" -Destination $gamepath }
        if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) {
            $destHash = (Get-FileHash -Path "$gamepath\dsoal-aldrv.dll" -Algorithm SHA256).Hash
            if ( $script:OalHashx64 -ne $destHash ) {
                Copy-Item -Path "$PSScriptRoot\x86-64\soft_oal.dll" -Destination $gamepath\dsoal-aldrv.dll
            }
        } else { Copy-Item -Path "$PSScriptRoot\x86-64\soft_oal.dll" -Destination $gamepath\dsoal-aldrv.dll }
    }
}

#popuplate config combobox.
function Update-Conf {
    $C_ListConf.Items.Clear()
    $list = Get-ChildItem $PSScriptRoot\Configs\*.ini
        if ( $list ) { 
            foreach ( $entry in $list.name ) {
                $C_ListConf.Items.add($entry)
            }
        }
    $C_ListConf.SelectedIndex = $C_ListConf.Items.Count - 1
}

function Transmut {
    param ($x) 
    
    #$x = $Menugauche.SelectedItem
        foreach( $game in $script:jeutrouve ) {
            if ( $x -eq $game.Name ) {
                $gamepath = $game.Gamepath
                $SubDir = $game.SubDir
                $RootDirInstallOption = $game.RootDirInstallOption
                $x64 = $game.x64
                $Conf = $game.conf
                if ( $x64-eq "true" ) {
                    if ( [string]::IsNullOrEmpty($Subdir) ) {
                        # 64bits Gamepath only
                        CheckFiles $gamepath x86-64
                        if ( $conf ) {
                            Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\alsoft.ini
                        } else {
                            if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
                        }
                    # 64 bits subdir + root install
                    } elseif ( $RootDirInstallOption -eq "True" ) {
                        CheckFiles $gamepath x86-64
                        CheckFiles $gamepath\$Subdir x86-64
                        if ( $conf ) {
                            Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\$Subdir\alsoft.ini
                            Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\alsoft.ini
                        } else {
                            if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
                            if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) { Remove-Item "$gamepath\$Subdir\alsoft.ini" }
                        }
                    # 64 bits subdir only
                    } else {
                        CheckFiles $gamepath\$Subdir x86-64
                        if ( $conf ) {
                            Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\$Subdir\alsoft.ini
                        } else {
                            if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) { Remove-Item "$gamepath\$Subdir\alsoft.ini" }
                        }
                    }
                } 
                # 32 bits
                else {
                            if ( [string]::IsNullOrEmpty($Subdir) ) {
                                CheckFiles $gamepath x86
                                if ( $conf ) {
                                    Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\alsoft.ini
                                } else {
                                    if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
                                }
                            } elseif ( $RootDirInstallOption -eq "True" ) {
                                CheckFiles $gamepath x86
                                CheckFiles $gamepath\$Subdir x86
                                if ( $conf ) {
                                    Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\$Subdir\alsoft.ini
                                    Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\alsoft.ini
                                } else {
                                    if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
                                    if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) { Remove-Item "$gamepath\$Subdir\alsoft.ini" }
                                }
                            } else {
                                # 32bits Subdir Only
                                if ( [System.IO.File]::Exists("$gamepath\dsoal-aldrv.dll") ) { Remove-Item -Path "$gamepath\dsoal-aldrv.dll" -force }
                                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) { Remove-Item -Path "$gamepath\dsound.dll" -force }
                                if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item -Path "$gamepath\alsoft.ini" -force }
                                CheckFiles $gamepath\$Subdir x86
                                    if ( $conf ) {
                                        Copy-Item -Path "$PSScriptRoot\Configs\$conf" -Destination $gamepath\$Subdir\alsoft.ini
                                    } else {
                                        if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) {
                                            Remove-Item -Path "$gamepath\$Subdir\alsoft.ini" -force
                                        }
                                    }
                            }
                    }
                $MenuGauche.Items.Remove($x)
                $MenuDroite.Items.Add($x)
                Sortlistview $MenuDroite
            }
    }
}

function UnTransmut {
    param ( $x ) 

    foreach ($game in $script:jeutrouve) {
        if ( $x -eq $game.Name ) {
            $gamepath = $game.Gamepath
            $SubDir = $game.SubDir
            $RootDirInstallOption = $game.RootDirInstallOption
            if ( [string]::IsNullOrEmpty($Subdir) ) {
                Remove-Item "$gamepath\dsoal-aldrv.dll"
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) { Remove-Item "$gamepath\dsound.dll" }
                if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
            } elseif ( $RootDirInstallOption -eq "True" ) {
                Remove-Item "$gamepath\dsoal-aldrv.dll"	
                if ( [System.IO.File]::Exists("$gamepath\dsound.dll") ) { Remove-Item "$gamepath\dsound.dll" }
                if ( [System.IO.File]::Exists("$gamepath\alsoft.ini") ) { Remove-Item "$gamepath\alsoft.ini" }
                Remove-Item "$gamepath\$Subdir\dsoal-aldrv.dll"
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) { Remove-Item "$gamepath\$Subdir\dsound.dll" }
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) { Remove-Item "$gamepath\$Subdir\alsoft.ini" }
            } else {
                Remove-Item "$gamepath\$Subdir\dsoal-aldrv.dll"
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\dsound.dll") ) { Remove-Item "$gamepath\$Subdir\dsound.dll" }
                if ( [System.IO.File]::Exists("$gamepath\$Subdir\alsoft.ini") ) { Remove-Item "$gamepath\$Subdir\alsoft.ini" }
            }
            $MenuDroite.Items.Remove($x)
            $MenuGauche.Items.Add($x)
            Sortlistview $MenuGauche
        }
    }
}


Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#load translation if exist, if not will use en-US.
Import-LocalizedData -BindingVariable txt

# check if Dsoal_alchemy.ini already exist, if not check for Creative alchemy file or use template to generate new dsoal_alchemy.
$PathALchemy = LocateAlchemy
if ( !(Test-Path -path "$PSScriptRoot\Dsoal_alchemy.ini") ) {
    if ( $PathALchemy -ne "False" ) {
        GenerateNewAlchemy "$PathALchemy\Alchemy.ini"
    } else { Copy-item $PSScriptRoot\Games.template $PSScriptRoot\Dsoal_alchemy.ini }
}

$script:OalHash = (Get-FileHash -Path "$PSScriptRoot\x86\soft_oal.dll" -Algorithm SHA256).Hash 
$script:OalHashx64 = (Get-FileHash -Path "$PSScriptRoot\x86-64\soft_oal.dll" -Algorithm SHA256).Hash
$script:dsoundHash = (Get-FileHash -Path "$PSScriptRoot\x86\dsound.dll" -Algorithm SHA256).Hash 
$script:dsoundHashx64 = (Get-FileHash -Path "$PSScriptRoot\x86-64\dsound.dll" -Algorithm SHA256).Hash 

$script:listejeux = Read-File "$PSScriptRoot\Dsoal_alchemy.ini"
CheckInstall $script:listejeux | Out-Null
$script:jeutrouve = $script:listejeux | where-object Found -eq $true
#$jeutrouve | Out-GridView		#debug
CheckTransmut $script:jeutrouve | Out-Null
$jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
$jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}

# Main windows
[xml]$inputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Title="Dsoal Alchemy" Height="417" Width="818" MinHeight="417" MinWidth="818" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\dsoal_alchemy.ico">
    <Window.Background>
        <LinearGradientBrush StartPoint="0.5,0" EndPoint="0.5,1">
            <GradientStop Color="#83baf0" Offset="0" />
            <GradientStop Color="#5aa3eb" Offset="1" />
        </LinearGradientBrush>
    </Window.Background>
    <Viewbox Stretch="Uniform" StretchDirection="UpOnly">
        <Grid>
            <ListView Name="MenuGauche" HorizontalAlignment="Left" Height="280" Margin="20,75,0,0" VerticalAlignment="Top" Width="310"/>
            <ListView Name="MenuDroite" HorizontalAlignment="Left" Height="280" Margin="472,75,20,0" VerticalAlignment="Top" Width="310"/>
            <Button Name="BoutonTransmut" Content="&gt;&gt;" HorizontalAlignment="Left" Height="45" Margin="350,100,0,0" VerticalAlignment="Top" Width="100"/>
            <Button Name="BoutonUnTransmut" Content="&lt;&lt;" HorizontalAlignment="Left" Height="45  " Margin="350,163,0,0" VerticalAlignment="Top" Width="100"/>
            <Button Name="BoutonEdition" HorizontalAlignment="Left" Height="25" Margin="350,256,0,0" VerticalAlignment="Top" Width="100"/>
            <Button Name="BoutonAjouter" HorizontalAlignment="Left" Height="25" Margin="350,293,0,0" VerticalAlignment="Top" Width="100"/>
            <Button Name="BoutonParDefaut" HorizontalAlignment="Left" Height="25" Margin="350,330,0,0" VerticalAlignment="Top" Width="100"/>
            <TextBlock Name="Text_main" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,10,0,0" Width="762" Height="34"/>
            <TextBlock Name="Text_jeuInstall" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,54,0,0" Width="238"/>
            <TextBlock Name="Text_JeuTransmut" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="472,54,0,0" Width="173"/>
            <TextBlock Name="T_URL" HorizontalAlignment="Left" TextWrapping="Wrap" Text="https://github.com/Choum28/DSOAL_Alchemy" VerticalAlignment="Top" Margin="20,361,0,0" FontSize="8"/>
            <TextBlock Name="T_version" HorizontalAlignment="Left" TextWrapping="Wrap" Text="Version 1.5" VerticalAlignment="Top" Margin="733,359,0,0" FontSize="8"/>
        </Grid>
    </Viewbox>
</Window>

"@
$reader = (New-Object System.Xml.XmlNodeReader $inputXML)
$Window = [Windows.Markup.XamlReader]::Load( $reader )
$inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}
$Window.WindowStartupLocation = "CenterScreen"
$MenuGauche.Background = "#007ba7"
$Menudroite.Background = "#007ba7"
$Menudroite.Foreground = "White"
$MenuGauche.Foreground = "White"

$BoutonTransmut.IsEnabled = $False
$BoutonUnTransmut.IsEnabled = $False
$BoutonEdition.Content = $txt.BoutonEditionContent
$BoutonAjouter.Content = $txt.BoutonAjouterContent
$BoutonParDefaut.Content = $txt.BoutonDefaultContent
$Text_main.Text = $txt.Text_main
$Text_jeuInstall.Text = $txt.Text_jeuInstall
$Text_JeuTransmut.Text = $txt.Text_JeuTransmut
$BoutonEdition.IsEnabled = $False

# populate each listview, disable counter output in terminal
$MenuGauche.Items.Clear()
foreach ( $jeu in $jeunontransmut ) { $MenuGauche.Items.Add($jeu.name) | Out-Null }
Sortlistview $MenuGauche | Out-Null

$MenuDroite.Items.Clear()
foreach ( $jeu in $jeutransmut ) { $MenuDroite.Items.Add($jeu.name) | Out-Null }
Sortlistview $MenuDroite | Out-Null
 
#Transmut Button Copy required file to gamepath, refresh listview (sort by name)
$BoutonTransmut.add_Click({ 
    Transmut $MenuGauche.SelectedItem
    if ( $Null -eq $MenuGauche.SelectedItem) { $BoutonTransmut.IsEnabled = $False }
})

#Button Untransmut, remove files from gamepath and refresh listview (sort by name)
$BoutonUnTransmut.add_Click({ 
    UnTransmut $MenuDroite.SelectedItem
    if ( $Null -eq $MenuDroite.SelectedItem) { $BoutonUnTransmut.IsEnabled = $False }
})

$MenuGauche.Add_MouseDoubleClick({
    if ( $Null -ne $MenuGauche.SelectedItem ) {
        Transmut $MenuGauche.SelectedItem
        $BoutonTransmut.IsEnabled = $False
    }
})

$MenuDroite.Add_MouseDoubleClick({
    if ( $Null -ne $MenuDroite.SelectedItem ) {
        UnTransmut $MenuDroite.SelectedItem
        $BoutonUnTransmut.IsEnabled = $False
    }
})

$MenuDroite.Add_SelectionChanged({
    if ( $MenuDroite.SelectedIndex -ne -1 ) {
         $MenuGauche.SelectedIndex = -1
    }
    $BoutonEdition.IsEnabled = $True
    $script:lastSelectedListView = $MenuDroite
    $BoutonTransmut.IsEnabled = $False
    $BoutonUnTransmut.IsEnabled = $True
})

$MenuGauche.Add_SelectionChanged({
    if ( $MenuGauche.SelectedIndex -ne -1 ) {
        $MenuDroite.SelectedIndex = -1
    }
    $BoutonEdition.IsEnabled = $True
    $script:lastSelectedListView = $MenuGauche
    $BoutonTransmut.IsEnabled = $True
    $BoutonUnTransmut.IsEnabled = $False
})

### EDIT BUTTON, Check each mandatory info, add them to global var, and update Dsoal_alchemy file entry.
$BoutonEdition.add_Click({
    $x = $script:lastSelectedListView.SelectedItem
    if ( !($Null -eq $x) ) {
        [xml]$InputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Height="361" Width="557" MinHeight="361" MinWidth="557" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\dsoal_alchemy.ico">
    <Window.Background>
        <LinearGradientBrush StartPoint="0.5,0" EndPoint="0.5,1">
            <GradientStop Color="#83baf0" Offset="0" />
            <GradientStop Color="#5aa3eb" Offset="1" />
        </LinearGradientBrush>
    </Window.Background>
    <Viewbox Stretch="Uniform" StretchDirection="UpOnly">
    <Grid>
        <Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,28,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <CheckBox Name="C_x64" HorizontalAlignment="Left" Margin="424,13,0,0" VerticalAlignment="Top"/>
        <RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
        <CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="C_ListConf" HorizontalAlignment="Left" Margin="90,287,0,0" VerticalAlignment="Top" Width="150"/>
        <CheckBox Name="C_Conf" HorizontalAlignment="Left" Margin="67,266,0,0" VerticalAlignment="Top"/>
        <Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="423,284,0,13" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="315,284,0,13" VerticalAlignment="Top" Width="90"/>       
    </Grid>
    </Viewbox>
</Window>
"@
        $reader = (New-Object System.Xml.XmlNodeReader $inputXML)
        $Window_edit = [Windows.Markup.XamlReader]::Load( $reader )
        $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_edit.FindName($_.Name)}
        $Window_edit.WindowStartupLocation = "CenterScreen"

        $T_Titrejeu.IsReadOnly = $true
        $T_Titrejeu.Background = '#e5e5e5'
        $Window_edit.Title = $txt.MainTitle2    
        $C_Gamepath.Content = $txt.C_GamepathContent
        $C_registre.Content = $txt.C_registreContent
        $T_registre.ToolTip = $txt.T_registreToolTip
        $T_Gamepath.ToolTip = $txt.T_GamepathToolTip
        $C_SubDir.Content = $txt.C_SubDirContent
        $T_Subdir.ToolTip = $txt.T_SubdirToolTip
        $C_Rootdir.Content = $txt.C_RootdirContent
        $C_Conf.Content = $txt.C_ConfContent
        $C_Conf.Tooltip = $txt.C_ConfTooltip
        $C_x64.Content = $txt.C_x64Content
        $C_x64.ToolTip = $txt.C_x64ToolTip
        $L_GameTitle.Content = $txt.L_GameTitleContent
        $B_Cancel.Content = $txt.B_CancelContent
        $B_ok.Content = $txt.B_OkContent
        $C_ListConf.visibility = "Hidden"

        $C_Registre.Add_Checked({
            $T_Registre.IsReadOnly = $False
            $T_Registre.Background = '#ffffff'
            $B_GamePath.IsEnabled = $False
            $T_Gamepath.IsReadOnly = $true
            $T_Gamepath.Background = '#e5e5e5'
        })
        $C_Gamepath.Add_Checked({
            $T_Registre.IsReadOnly = $true
            $T_Registre.Background = '#e5e5e5'
            $T_Gamepath.IsReadOnly = $False
            $T_Gamepath.Background = '#ffffff'
            $B_GamePath.IsEnabled = $True
        })
        $C_SubDir.Add_Checked({
            $T_SubDir.IsReadOnly = $False
            $T_SubDir.Background = '#ffffff'
            $C_Rootdir.Background = '#ffffff'
            $C_Rootdir.IsEnabled = $true
            $B_SubDir.IsEnabled = $True
        })
        $C_SubDir.Add_UnChecked({
            $T_SubDir.IsReadOnly = $True
            $T_SubDir.Background = '#e5e5e5'
            $C_Rootdir.Background = '#e5e5e5'
            $C_Rootdir.IsChecked = $False
            $B_SubDir.IsEnabled = $False
            $C_Rootdir.IsEnabled = $False
        })
        $C_Conf.Add_Checked({
            $C_ListConf.visibility = "Visible"
            Update-Conf
        })
        
        $C_Conf.Add_UnChecked({
            $C_ListConf.visibility = "Hidden"
        })

    ## RETREIVE EDIT FORM VALUES
        $count = 0
        $found = 0
        foreach ( $game in $script:jeutrouve ) {
            if ( $x -eq $game.Name ) {
                $found = 1
                $T_titrejeu.text = $game.Name
                $T_Subdir.text = $game.Subdir
                $RootDirInstallOption = $game.RootDirInstallOption
                $x64 = $game.x64
                $Conf = $game.conf

                if ( [string]::IsNullOrEmpty($game.RegPath) ) {
                    $T_Gamepath.text = $game.Gamepath
                    $T_Registre.IsReadOnly = $true
                    $T_Registre.Background = '#e5e5e5'
                    $C_GamePath.IsChecked = $true
                } else {
                    $T_registre.text = $game.RegPath
                    $T_Gamepath.IsReadOnly = $true
                    $T_Gamepath.Background = '#e5e5e5'
                    $B_GamePath.IsEnabled = $False
                    $C_Registre.IsChecked = $True
                }
                if ( $x64 -eq "True" ) { $C_x64.IsChecked = $True } else { $C_x64.IsChecked = $False }
                if ( $conf ) {
                    $C_Conf.IsChecked = $True
                    $C_ListConf.SelectedItem = $game.conf
                } else { $C_Conf.IsChecked = $False }
                if ( [string]::IsNullOrEmpty($T_Subdir.text) ) {
                    $T_SubDir.IsReadOnly = $True
                    $T_SubDir.Background = '#e5e5e5'
                    $C_Rootdir.IsEnabled = $False
                    $C_Rootdir.Background = '#e5e5e5'
                    $B_SubDir.IsEnabled = $False
                    $C_SubDir.IsChecked = $False
                    $C_Rootdir.IsChecked = $False
                } else {
                    $C_SubDir.Ischecked = $true
                    $C_Rootdir.IsEnabled = $true
                    if ( $RootDirInstallOption -eq "True" ) { $C_Rootdir.IsChecked = $True } else { $C_Rootdir.IsChecked = $False }
                }
            } else {
                if ( $found -ne 1 ) {
                    $count = $count +1
                }
            }
        }

    ## CLICK ON ICON GAMEPATH (EDIT FORM)
        $B_GamePath.add_Click({
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = $txt.FolderChoice
            $foldername.rootfolder = "MyComputer"
            if ( $C_Gamepath.IsChecked ) {
                $foldername.SelectedPath = $T_Gamepath.text
            }
            if ( $foldername.ShowDialog() -eq "OK" )
            {
                $T_Gamepath.text = $foldername.SelectedPath
            }
        })

    ## CLICK ON SUBDIR BUTTON (EDIT FORM)
        $B_SubDir.add_Click({
            $fail = $False
            if ( $C_registre.IsChecked ) {
                    $b = $T_Registre.Text
                    if (![string]::IsNullOrEmpty($b)) {
                        if ( $b -like "HKEY_LOCAL_MACHINE*" ) {
                            $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                        } else {
                            if ( $b -like "HKEY_CURRENT_USER*" ) {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                            } else {
                                $fail = $True
                                [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                            }
                        }
                    } else { 
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                    }
                    if ( $fail -eq $False ) {
                        #retreive registry key
                        $regkey = $b|split-path -leaf
                        #remove registry key from registry link"
                        $b = $b.replace("\$regkey","")
                        if ( !(test-path $b) ) {
                            $b = $b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                            $b = $b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                        }
                        if ( test-path $b ) {
                            try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey }
                            catch {
                                [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                                $fail = $true
                            }
                            if ( $fail -eq $False ) {
                                if ( !(test-path $Gamepath) ) {
                                    [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                                    $fail = $true
                                }
                            }
                        } else {
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                        }
                    }
            } else {
                    $Gamepath = $T_Gamepath.text
                    if ( [string]::IsNullOrEmpty($Gamepath) ) {
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ( $fail -eq $False ) {
                if ( !(test-path $Gamepath) ) {
                    [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    $fail = $true
                }
                if ( $fail -eq $False ) {
                    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                    $foldername.Description = $txt.SubFolderChoice
                    $foldername.SelectedPath = $Gamepath
                    if ( $foldername.ShowDialog() -eq "OK" ) {
                        $Subdir = $foldername.SelectedPath
                        $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                        $Subdir = $Subdir.Trimstart("\")
                        if (test-path $Gamepath\$Subdir) {
                            $T_Subdir.text = $Subdir
                        } else { 
                            [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48)
                        }
                    }
                }
            }
        })
        # Cancel Button (EDIT FORM)
        $B_Cancel.add_Click({
            $MenuGauche.SelectedIndex = -1
            $MenuDroite.SelectedIndex = -1
            $BoutonEdition.IsEnabled = $False
            $BoutonTransmut.IsEnabled = $False
            $BoutonUnTransmut.IsEnabled = $False
            $Window_edit.Close()
        })

    
    ### OK BUTTON (EDIT FORM), Check if everything is ok, then EDIT GAME FILE and Hash table
        $B_Ok.add_Click({
            $fail = $false
            $regprio = $false
            if ( $C_registre.IsChecked ) {
                $b = $T_Registre.Text
                if (![string]::IsNullOrEmpty($b)) {
                    if ( $b -like "HKEY_LOCAL_MACHINE*" ) {
                        $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                    } else {
                            if ( $b -like "HKEY_CURRENT_USER*" ) {
                                $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                            }
                        }        
                    #Recover Reg Key
                    $regkey = $b|split-path -leaf
                    #"supprimer clef du lien registre"
                    $b = $b.replace("\$regkey","")
                    if ( !(test-path $b) ) {
                    $b = $b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b = $b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                    }
                    if (test-path $b) {
                        try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                        }
                        catch {
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                        }
                        if ( $fail -eq $False ) {
                            if ( !(test-path $Gamepath) ) {
                                [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                                $fail = $true
                            } else {
                                $regprio = $true
                                $RegPath = $T_Registre.Text
                            }
                        }
                    } else {
                     $fail = $true
                     [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                    }
                } else { 
                         $fail = $true
                         [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                }
            } else {
                $Gamepath = $T_Gamepath.text
                if ( [string]::IsNullOrEmpty($Gamepath) ) { 
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ( $fail -eq $False ) {
                $Gamepath = $Gamepath.TrimEnd("\")
                if (![string]::IsNullOrEmpty($Gamepath)) {
                    if ( !(test-path $Gamepath) ) {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    } 
                }
            }
            if ( $C_SubDir.IsChecked -and $fail -eq $false ) {
                $Subdir = $T_Subdir.text
                if ( !(test-path $Gamepath\$Subdir) ) {
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
                } 
            }
            # Test if no error
            if ( $fail -eq $False ) {

                # Prepare Game value to write
                $Name = $T_titrejeu.text
                if ( $C_x64.IsChecked ) { $x64 = "True" } else { $x64 = "False" }
                if ( $C_Rootdir.IsChecked ) { $RootDirInstallOption = "True" } else { $RootDirInstallOption = "False" }
                if ( $C_SubDir.IsUnChecked ) {
                    $SubDir = ""
                    $RootDirInstallOption = "False"
                }
                if ( $C_Conf.IsChecked ) { $Conf = $C_ListConf.SelectedItem } else { $Conf = "" }
                
                # Update list game to reflect change    
                $script:jeutrouve[$count].RegPath = $RegPath
                $script:jeutrouve[$count].Gamepath = $Gamepath
                $script:jeutrouve[$count].SubDir = $Subdir
                $script:jeutrouve[$count].RootDirInstallOption = $RootDirInstallOption
                $script:jeutrouve[$count].x64 = $x64
                $script:jeutrouve[$count].Conf = $Conf
                
                # Write change in file
                $file = Get-content "$PSScriptRoot\Dsoal_alchemy.ini"
                $LineNumber = Select-String -pattern ([regex]::Escape("[$Name]")) $PSScriptRoot\Dsoal_alchemy.ini | Select-Object -ExpandProperty LineNumber
                if ( $regprio -eq $true ) {
                    $file[$LineNumber] = "RegPath=$RegPath"
                    $file[$LineNumber +1] = "GamePath="
                } else {
                    $file[$LineNumber] = "RegPath="
                    $file[$LineNumber +1] = "GamePath=$Gamepath" 
                }
                $file[$LineNumber +2] = "SubDir=$Subdir" 
                $file[$LineNumber +3] = "RootDirInstallOption=$RootDirInstallOption"
                $file[$LineNumber +4] = "x64=$x64"
                $file[$LineNumber +5] = "Conf=$Conf"
                $file | Set-Content $PSScriptRoot\Dsoal_alchemy.ini -encoding ascii
                # Update file/conf if game is already transmuted (Re-transmut)
                if ( $script:lastSelectedListView -eq $MenuDroite ) {
                    $MenuDroite.Items.Remove($x)
                    Transmut $x
                    }
                $Window_edit.Close()
            }
        })
        $closingHandler = {
            $MenuGauche.SelectedIndex = -1
            $MenuDroite.SelectedIndex = -1
            $BoutonEdition.IsEnabled = $False
            $BoutonTransmut.IsEnabled = $False
            $BoutonUnTransmut.IsEnabled = $False
        }
        $Window_edit.Add_Closing($closingHandler)
        $Window_edit.ShowDialog() | out-null
    }
})

### ADD BUTTON (MAIN FORM)
$BoutonAjouter.add_Click({
    [xml]$InputXML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    Height="361" Width="557" MinHeight="361" MinWidth="557" VerticalAlignment="Bottom" ResizeMode="CanResizeWithGrip" Icon="$PSScriptRoot\dsoal_alchemy.ico">
    <Window.Background>
        <LinearGradientBrush StartPoint="0.5,0" EndPoint="0.5,1">
            <GradientStop Color="#83baf0" Offset="0" />
            <GradientStop Color="#5aa3eb" Offset="1" />
        </LinearGradientBrush>
    </Window.Background>
    <Viewbox Stretch="Uniform" StretchDirection="UpOnly">
    <Grid>
        <Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,28,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <CheckBox Name="C_x64" HorizontalAlignment="Left" Margin="424,13,0,0" VerticalAlignment="Top"/>
        <RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
        <CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="C_ListConf" HorizontalAlignment="Left" Margin="90,287,0,0" VerticalAlignment="Top" Width="150"/>
        <CheckBox Name="C_Conf" HorizontalAlignment="Left" Margin="67,266,0,0" VerticalAlignment="Top"/>		
        <Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="423,284,0,13" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="315,284,0,13" VerticalAlignment="Top" Width="90"/>
    </Grid>
    </Viewbox>
</Window>
"@
    $reader = (New-Object System.Xml.XmlNodeReader $inputXML)
    $Window_add = [Windows.Markup.XamlReader]::Load( $reader )
    $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_add.FindName($_.Name)}
    $Window_add.WindowStartupLocation = "CenterScreen"
    # WPF Content, tooltip values
    $Window_add.Title = $txt.MainTitle2    
    $C_Gamepath.Content = $txt.C_GamepathContent
    $C_registre.Content = $txt.C_registreContent
    $T_registre.ToolTip = $txt.T_registreToolTip
    $T_Gamepath.ToolTip = $txt.T_GamepathToolTip
    $C_SubDir.Content = $txt.C_SubDirContent
    $T_Subdir.ToolTip = $txt.T_SubdirToolTip
    $C_Rootdir.Content = $txt.C_RootdirContent
    $C_Conf.Tooltip = $txt.C_ConfTooltip
    $C_Conf.Content = $txt.C_ConfContent
    $C_x64.Content = $txt.C_x64Content
    $C_x64.ToolTip = $txt.C_x64ToolTip
    $L_GameTitle.Content = $txt.L_GameTitleContent
    $B_Cancel.Content = $txt.B_CancelContent
    $B_ok.Content = $txt.B_OkContent

    # Default value
    $T_Gamepath.MaxLines = 1
    $T_registre.MaxLines = 1
    $C_registre.IsChecked = $true
    $C_SubDir.IsChecked = $False
    $T_SubDir.IsReadOnly = $True
    $T_SubDir.Background = '#e5e5e5'
    $C_Rootdir.IsChecked = $false
    $C_Rootdir.IsEnabled = $False
    $C_Rootdir.Background = '#e5e5e5'
    $B_SubDir.IsEnabled = $False
    $C_x64.IsChecked = $False
    $T_Registre.IsReadOnly = $False
    $T_Registre.Background = '#ffffff'
    $B_GamePath.IsEnabled = $False
    $T_Gamepath.IsReadOnly = $true
    $T_Gamepath.Background = '#e5e5e5'
    $C_ListConf.visibility = "Hidden"
 
    $C_Registre.Add_Checked({
        $T_Registre.IsReadOnly = $False
        $T_Registre.Background = '#ffffff'
        $B_GamePath.IsEnabled = $False
        $T_Gamepath.IsReadOnly = $true
        $T_Gamepath.Background = '#e5e5e5'
    })

    $C_Gamepath.Add_Checked({
        $T_Registre.IsReadOnly = $true
        $T_Registre.Background = '#e5e5e5'
        $T_Gamepath.IsReadOnly = $False
        $T_Gamepath.Background = '#ffffff'
        $B_GamePath.IsEnabled = $True
    })

    $C_SubDir.Add_Checked({
        $T_SubDir.IsReadOnly = $False
        $T_SubDir.Background = '#ffffff'
        $C_Rootdir.IsEnabled = $True
        $C_Rootdir.Background = '#ffffff'
        $B_SubDir.IsEnabled = $True
        $C_Rootdir.IsEnabled = $true
    })

    $C_SubDir.Add_UnChecked({
        $T_SubDir.IsReadOnly = $True
        $T_SubDir.Background = '#e5e5e5'
        $C_Rootdir.IsEnabled = $False
        $C_Rootdir.Background = '#e5e5e5'
        $B_SubDir.IsEnabled = $False
        $C_Rootdir.IsEnabled = $False
        $C_Rootdir.IsChecked = $False
    })

    $C_Conf.Add_Checked({
        $C_ListConf.visibility = "Visible"
        Update-Conf
    })

    $C_Conf.Add_UnChecked({
        $C_ListConf.visibility = "Hidden"
    })

## CLICK ON GAMEPATH BUTTON (ADD FORM)
    $B_GamePath.add_Click({
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.Description = $txt.FolderChoice
        $foldername.rootfolder = "MyComputer"
        #$initialDirectory
        if ( $C_Gamepath.IsChecked ) {
            $foldername.SelectedPath = $T_Gamepath.text
        }
        if ( $foldername.ShowDialog() -eq "OK" )
        {
            $T_Gamepath.text = $foldername.SelectedPath
        }
    })

## CLICK ON SUBDIR BUTTON (ADD FORM), chek registry path first or gamepath is not present, then test subdir+gamepath path
    $B_SubDir.add_Click({
        $fail = $false
        if ( $C_registre.IsChecked ) {
            $b = $T_Registre.Text
            if ( ![string]::IsNullOrEmpty($b) ) {
                if ( $b -like "HKEY_LOCAL_MACHINE*" ) {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if ( $b -like "HKEY_CURRENT_USER*" ) {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        } else {
                            $fail = $True
                            [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                        }    
                    }
            } else {
                $fail = $True
                [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
            }
            if ( $fail -eq $False ) {
                #retreive registry key
                $regkey = $b|split-path -leaf
                #remove registry key from registry path
                $b = $b.replace("\$regkey","")
                if ( !(test-path $b) ) {
                $b = $b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                $b = $b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if ( test-path $b ) {
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ( $fail -eq $False ) {
                        if ( !(test-path $Gamepath) ) {
                            [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                            $fail = $True
                        }
                    }
                } else {
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                }
            }
        } else {
            $Gamepath = $T_Gamepath.text
            if ( [string]::IsNullOrEmpty($Gamepath) ) { 
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
        }
        if ( $fail -eq $False ) {
            if ( !(test-path $Gamepath) ) {
                [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
            } else {        
                $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                $foldername.Description = $txt.SubFolderChoice
                $foldername.SelectedPath = $Gamepath
                if ( $foldername.ShowDialog() -eq "OK" ) {
                    $Subdir = $foldername.SelectedPath
                    $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                    $Subdir = $Subdir.Trimstart("\")
                    if (test-path $Gamepath\$Subdir) {
                        $T_Subdir.text = $Subdir
                    } else { [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48) }
                }
            }
        }
    })
    $B_Cancel.add_Click({
        $MenuGauche.SelectedIndex = -1
        $MenuDroite.SelectedIndex = -1
        $BoutonEdition.IsEnabled = $False
        $BoutonTransmut.IsEnabled = $False
        $BoutonUnTransmut.IsEnabled = $False
        $Window_add.Close()
    })
   
### OK BUTTON (ADD FORM), test if every value are correct, then add game to ini file and inside hashtable
    $B_Ok.add_Click({
        $fail = $false
        $regprio = $false
        $b = $T_Registre.Text
        $x = $T_titrejeu.Text

        foreach ( $game in $script:listejeux ) {
            if ( $x -eq $game.name ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.TitleExist,"",0,64)
            }
        }
        if ( [string]::IsNullOrEmpty($x) ) {
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.TitleMiss,"",0,64)
        }
        if ( $C_registre.IsChecked ) {
            if (![string]::IsNullOrEmpty($b)) {
                if ( $b -like "HKEY_LOCAL_MACHINE*" ) {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if ( $b -like "HKEY_CURRENT_USER*" ) {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    } 
                $regkey = $b|split-path -leaf
                $b = $b.replace("\$regkey","")
                if ( !(test-path $b) ) {
                    $b = $b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b = $b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if (test-path $b) {
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ( $fail -eq $false ) {
                        if ( !(test-path $Gamepath) ) {
                            [System.Windows.MessageBox]::Show($txt.RegKeyValInc,"",0,48)
                            $fail = $true
                        }
                        $regprio = $true
                        $Gamepath = $Gamepath.TrimEnd("\")
                    }
                } else {
                    [System.Windows.MessageBox]::Show($txt.RegKeyBad,"",0,48)
                    $fail = $true
                }
            } else {
                [System.Windows.MessageBox]::Show($txt.RegKeyEmpty,"",0,64)
                $fail = $true
             }
        } else { $Gamepath = $T_Gamepath.text }
        
        if ( $fail -eq $False ) {
            if ( [string]::IsNullOrEmpty($Gamepath) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
            else {
                if ( !(test-path $Gamepath) ) {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                }
            }
        }
        if ( $B_SubDir.IsEnabled -and $fail -eq $false ) {
            $Subdir = $T_Subdir.text
            if ( !(test-path $Gamepath\$Subdir) ) {
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
            } 
        }
        # test if no error
        if ( $fail -eq $False ) {
            # Value to write
            $Name = $T_titrejeu.text
            if ( $C_x64.IsChecked ) {
                $x64 = "True"
            } else { $x64 = "False" }
            
            if ( $C_Rootdir.IsChecked ) {
                $RootDirInstallOption = "True"
            } else { $RootDirInstallOption = "False" }
            
            if ( $C_SubDir.IsUnchecked ) {
                $SubDir = ""
                $RootDirInstallOption = "False"
            }
            if ( $C_Conf.IsChecked ) {
                $Conf = $C_ListConf.SelectedItem
            } else { $Conf = "" }

            # Write change in file, Registry first, Gamepath second choice
            if ( $regprio -eq $true ) {
                $RegPath = $T_Registre.Text
                $Gamepath = ""
            } else {
                $RegPath = ""
                $Gamepath = $T_Gamepath.text
            }
            "[$Name]`r`nRegPath=$RegPath`r`nGamePath=$Gamepath`r`nSubDir=$SubDir`r`nRootDirInstallOption=$RootDirInstallOption`r`nx64=$x64`r`nConf=$Conf`r`n"| Out-File -Append $PSScriptRoot\Dsoal_alchemy.ini -encoding ascii

            # Update list game to reflect change, Order listview by name
            $script:listejeux += Add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -x64 $x64 -Found $True -Transmut $False      
            $script:jeutrouve = $script:listejeux | where-object Found -eq $True
            CheckTransmut $script:jeutrouve | Out-Null
            $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
            $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
            $MenuGauche.Items.Clear()
            foreach ( $jeu in $jeunontransmut ) {
                $MenuGauche.Items.Add($jeu.name) | Out-Null
            }
            $MenuDroite.Items.Clear()
            foreach ( $jeu in $jeutransmut ) {
                $MenuDroite.Items.Add($jeu.name) | Out-Null
            }
            Sortlistview $MenuGauche
            Sortlistview $MenuDroite
            $Window_add.Close()
        }
    })
    $closingHandler = {
        $MenuGauche.SelectedIndex = -1
        $MenuDroite.SelectedIndex = -1
        $BoutonEdition.IsEnabled = $False
        $BoutonTransmut.IsEnabled = $False
        $BoutonUnTransmut.IsEnabled = $False
    }
    $Window_add.Add_Closing($closingHandler)
    $Window_add.ShowDialog() | out-null
})

### Default Button (MAIN FORM)
$BoutonParDefaut.add_Click({
    $choice = [System.Windows.MessageBox]::Show("$($txt.Defaultmsgbox)`r`n$($txt.Defaultmsgbox2)`r`n$($PSScriptRoot)\Dsoal_alchemy.bak`r`n`r`n$($txt.Defaultmsgbox3)" , "Dsoal Alchemy" , 4,64)
    if ( $choice -eq 'Yes' ) {
        move-Item "$PSScriptRoot\Dsoal_alchemy.ini" "$PSScriptRoot\Dsoal_alchemy.Bak" -force
        if (Test-path -path $PathALchemy\alchemy.ini) {
            GenerateNewAlchemy "$PathALchemy\Alchemy.ini"
        } else { Copy-item $PSScriptRoot\Games.template $PSScriptRoot\Dsoal_alchemy.ini }
        $script:listejeux = Read-File "$PSScriptRoot\Dsoal_alchemy.ini"
        CheckInstall $script:listejeux | Out-Null
        $script:jeutrouve = $script:listejeux | where-object Found -eq $true
        CheckTransmut $script:jeutrouve | Out-Null
        $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
        $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
        $MenuGauche.Items.Clear()
        $MenuDroite.Items.Clear()
        $BoutonEdition.IsEnabled = $False
        $BoutonTransmut.IsEnabled = $False
        $BoutonUnTransmut.IsEnabled = $False
        foreach ( $jeu in $jeunontransmut ) { $MenuGauche.Items.Add($jeu.name) | Out-Null }
        Sortlistview $MenuGauche
        foreach ( $jeu in $jeutransmut ) { $MenuDroite.Items.Add($jeu.name) | Out-Null }
        Sortlistview $MenuDroite
    }
})

$Window.ShowDialog() | out-null
