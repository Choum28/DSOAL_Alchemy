<# 
.SYNOPSIS
    This script is a test to recreate the Creative Alchemy application in powershell for the usage with DSOAL.

.DESCRIPTION
    What different from creative alchemy :
        Registry path are check in both X86 and X86-64 path.
		dsoal.dll and dsoal-aldrv.dll should be present in the script folder.
		
.EXAMPLE
    .\Dsoal-Alchemy.ps1
        Launch the script

 -------------------------- EXEMPLE 2 --------------------------
 .\powershell.exe -WindowStyle Hidden -ep bypass -file "C:\script\Dsoal-Game-Installer.ps1"
        Launch the script and hide console

.OUTPUTS
    This script will generate an ini file NewDsoalGames.ini to store gamelist audio options and change.
    
.NOTES
    NOM:       Dsoal-Alchemy.ps1
    AUTEUR:    Choum

    HISTORIQUE VERSION:

    1.0     15.11.2020    First version
.LINK
 #>
 
function LocateAlchemy { # Locate Alchemy installation and check for necessary files, return Dsoal-Alchemy path.
	$d = Get-Location
    if (Test-Path -path "$d\alchemy.ini"){
		if (Test-Path -path "$d\dsoal-aldrv.dll"){
			if (Test-Path -path "$d\dsound.dll"){
				return $d
			} else {
				[System.Windows.MessageBox]::Show("$($txt.missfile) $d\dsound.dll","",0,	16)
			}
		}else {
				[System.Windows.MessageBox]::Show("$($txt.missfile) $d\dsoal-aldrv.dll","",0,	16)
			} 
        } else {
				[System.Windows.MessageBox]::Show("$($txt.missfile) $d\alchemy.ini","",0,	16)
			}
	exit
}

function add-Game { # Convert value into hash table.
    param([string]$Name,[string]$RegPath,[string]$Gamepath,[string]$SubDir,[string]$RootDirInstallOption,[bool]$Found,[bool]$Transmut)
    $d=@{
        Name=$Name
        RegPath=$RegPath
        Gamepath=$Gamepath
        SubDir=$SubDir
        RootDirInstallOption=$RootDirInstallOption
        Found=$Found
    }
    return $d
}

function read-file{ #read DsoalGames ini file and convert game to hash table with add-game function, default value are define here if not present in alchemy.ini.
    param([string]$file)
    $list = Get-content $file
    $liste = @()
    $test = 0
    $Number = 0
    $RootDirInstallOption="False"
    $Found=$false
    $Transmut=$false

    foreach ($line in $list) {
        $Number = $Number + 1
        if($line -notlike ';*') {

            if($line -like '`[*') {
            if ($test -gt 0) {
                    $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -Found $Found -Transmut $Transmut
                    $RegPath=""
                    $Gamepath=""
                    $SubDir=""
                    $RootDirInstallOption="False"
                    $Found=$false
                    $Transmut=$false
                }
                $test = $test+1
                $Name = $line -replace '[][]'
            }
            if($line -like "RegPath=*") {
                $RegPath = $line.replace("RegPath=","")
            }
            if($line -like "GamePath=*") {
                $Gamepath = $line.replace("GamePath=","")
            }
            if($line -like "SubDir=*") {
                $SubDir = $line.replace("SubDir=","")
            }
            if($line -like "RootDirInstallOption=*") {
                $RootDirInstallOption = $line.replace("RootDirInstallOption=","")
            }
        }
    }
    if ($Number -ne $test){
        $liste += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -Buffers $Buffers -Duration $Duration -DisableDirectMusic $DisableDirectMusic -MaxVoiceCount $MaxVoiceCount -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -DisableNativeAL $DisableNativeAL -Transmut $Transmut -LogDirectSound $LogDirectSound -LogDirectSound2D $LogDirectSound2D -LogDirectSound2DStreaming $LogDirectSound2DStreaming -LogDirectSound3D $LogDirectSound3D -LogDirectSoundListener $LogDirectSoundListener -LogDirectSoundEAX $LogDirectSoundEAX -LogDirectSoundTimingInfo $LogDirectSoundTimingInfo -LogStarvation $LogStarvation
    }
    return $liste
}

function GenerateNewAlchemy{ #Create New DsoalGames.ini file with new options, that will be used by the script
    param([string]$file) 
    @"
;Creative ALchemy titles
;Format/Options:
;  [TITLE]
;  RegPath <-- registry path containing string to executable or executable's directory (use this when available; alternative is GamePath)
;  GamePath <-- Directory to look for app (if RegPath can't be used) 
;  SubDir <-- subdirectory offset off of path pointed to by RegPath for library support (default is empty string)
;  RootDirInstallOption <-- option to install translator support in both RegPath and SubDir directories (default is False)

"@ | Out-File -Append DsoalGames.ini -encoding ascii
    $liste = read-file $file
    foreach ($line in $liste){
        $a = $line.Name
        $b = $line.RegPath
        $c = $line.Gamepath
        $h = $line.SubDir
        $i = $line.RootDirInstallOption
        "[$a]`rRegPath=$b`rGamePath=$c`rSubDir=$h`rRootDirInstallOption=$i`r`n" | Out-File -Append DsoalGames.ini -encoding ascii
    }
}

function checkpresent{ # Check if game is present (registry in priority then gamepath)
    param($a)
    $b = $a.RegPath
    if (![string]::IsNullOrEmpty($b)) {
        if ($b -like "HKEY_LOCAL_MACHINE*") {
            $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
        } else {
                if($b -like "HKEY_CURRENT_USER*") {
                    $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                }
            }        
        # recover registry key
        $regkey = $b|split-path -leaf
        # delete key from registry link
        $b = $b.replace("\$regkey","")
        if (!(test-path $b)){
            $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
            $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
        }
        if (test-path $b){
            try { $a.GamePath = Get-ItemPropertyvalue -Path $b -name $regkey
            }
            catch {}
        }
    }
    if (![string]::IsNullOrEmpty($a.gamePath)){
        if (test-path $a.GamePath){
            $a.Found = $true
        }
        else {$a.Found = $false}
    }
    return $a
}

function checkinstall{ # Check if the game list is installed with check present function.
    param($liste)
    $test = 0
    foreach ($game in $liste){ 
        $liste[$test] = checkpresent $game
        $test = $test +1
    }
    return $liste
}

function checkTransmut{ # Check if game is transmuted (dsoal-aldrv.dll present)
    param($liste)
    $test = 0
    foreach ($game in $liste){
        $gamepath=$game.Gamepath
        $Subdir=$game.SubDir
        if ([string]::IsNullOrEmpty($Subdir)){
            if (test-path ("$gamepath\dsoal-aldrv.dll")){
                $game.Transmut = $true
            }
            else {
                $game.Transmut = $false
            }
        } else {
            if (test-path ("$gamepath\$Subdir\dsoal-aldrv.dll")){
                $game.Transmut = $true
            }
            else {
                $game.Transmut = $false
            }
        }
        $liste[$test] = $game
        $test = $test +1 
    }
    return $liste
}

function Sortlistview{
    param($listview)
    $items = $listview.items | Sort-Object
    $listview.Items.Clear()
    foreach ($item in $items){
        $listview.Items.Add($item)
    }
    return $listview
}

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

#load translation if exist, if not found will load en-US one.
Import-LocalizedData -BindingVariable txt

# check if inside alchemy folder and if DsoalGames.ini is present or generate a new one
$PathALchemy=LocateAlchemy
if (!(Test-Path -path ".\DsoalGames.ini")) {
    GenerateNewAlchemy "$PathALchemy\Alchemy.ini"
}

$script:listejeux = read-file ".\DsoalGames.ini"
checkinstall $script:listejeux | Out-Null
$script:jeutrouve = $script:listejeux | where-object Found -eq $true
#$jeutrouve | Out-GridView
checktransmut $script:jeutrouve | Out-Null
$jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
$jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}

# Main windows
[xml]$inputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Dsoal Alchemy" Height="417" Width="810" ResizeMode="NoResize">
    <Grid>
        <ListView Name="MenuGauche" HorizontalAlignment="Left" Height="280" Margin="20,75,0,0" VerticalAlignment="Top" Width="310">
            <ListView.View>
                <GridView>
                    <GridViewColumn Width="300"/>
                </GridView>
            </ListView.View>
        </ListView>
        <ListView Name="MenuDroite" HorizontalAlignment="Left" Height="280" Margin="472,75,0,0" VerticalAlignment="Top" Width="310">
            <ListView.View>
                <GridView>
                    <GridViewColumn Width="300"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Button Name="BoutonTransmut" Content="&gt;&gt;" HorizontalAlignment="Left" Height="45" Margin="350,100,0,0" VerticalAlignment="Top" Width="100"/>
        <Button Name="BoutonUnTransmut" Content="&lt;&lt;" HorizontalAlignment="Left" Height="45  " Margin="350,163,0,0" VerticalAlignment="Top" Width="100"/>
        <Button Name="BoutonEdition" HorizontalAlignment="Left" Height="25" Margin="350,256,0,0" VerticalAlignment="Top" Width="100"/>
        <Button Name="BoutonAjouter" HorizontalAlignment="Left" Height="25" Margin="350,293,0,0" VerticalAlignment="Top" Width="100"/>
        <Button Name="BoutonParDefaut" HorizontalAlignment="Left" Height="25" Margin="350,330,0,0" VerticalAlignment="Top" Width="100"/>
        <TextBlock Name="Text_main" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,10,0,0" Width="762" Height="34"/>
        <TextBlock Name="Text_jeuInstall" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="20,54,0,0" Width="238"/>
        <TextBlock Name="Text_JeuTransmut" HorizontalAlignment="Left" TextWrapping="Wrap" VerticalAlignment="Top" Margin="472,54,0,0" Width="173"/>
        <TextBlock Name="T_URL" HorizontalAlignment="Left" TextWrapping="Wrap" Text="https://github.com/Choum28/NewAlchemy" VerticalAlignment="Top" Margin="20,361,0,0" FontSize="8"/>
        <TextBlock Name="T_version" HorizontalAlignment="Left" TextWrapping="Wrap" Text="Version 1.0" VerticalAlignment="Top" Margin="733,359,0,0" FontSize="8"/>
    </Grid>
</Window>

"@
$reader=(New-Object System.Xml.XmlNodeReader $inputXML)
$Window =[Windows.Markup.XamlReader]::Load( $reader )
$inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)}

$BoutonEdition.Content="<< $($txt.BoutonEditionContent)"
$BoutonAjouter.Content=$txt.BoutonAjouterContent
$BoutonParDefaut.Content=$txt.BoutonDefaultContent
$Text_main.Text=$txt.Text_main
$Text_jeuInstall.Text=$txt.Text_jeuInstall
$Text_JeuTransmut.Text=$txt.Text_JeuTransmut

# populate each listview, disable counter output in terminal
$MenuGauche.Items.Clear()
foreach ($jeu in $jeunontransmut){
    $MenuGauche.Items.Add($jeu.name) | Out-Null
}

$MenuDroite.Items.Clear()
foreach ($jeu in $jeutransmut){
    $MenuDroite.Items.Add($jeu.name) | Out-Null
}
 
#Transmut Button Copy needed file to gamepath and refresh listview (sort by name)
$BoutonTransmut.add_Click({
    $x = $Menugauche.SelectedItem
        foreach($game in $script:jeutrouve){
            if ($x -eq $game.Name){
                $gamepath = $game.Gamepath
                $SubDir = $game.SubDir
                $RootDirInstallOption = $game.RootDirInstallOption
 
                if ([string]::IsNullOrEmpty($Subdir)){
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
					Copy-Item -Path "$PathAlchemy\dsoal-aldrv.dll" -Destination $gamepath
                } elseif ($RootDirInstallOption -eq "True"){
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath
					Copy-Item -Path "$PathAlchemy\dsoal-aldrv.dll" -Destination $gamepath
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir
					Copy-Item -Path "$PathAlchemy\dsoal-aldrv.dll" -Destination $gamepath\$Subdir

                }  else { 
                    Copy-Item -Path "$PathAlchemy\dsound.dll" -Destination $gamepath\$Subdir
                }
                $MenuGauche.Items.Remove($x)
                $MenuDroite.Items.Add($x)
                Sortlistview $MenuDroite
            }
    }
 })

#Button Untransmut, remove Dsound files and refresh each listview (sort by name)
$BoutonUnTransmut.add_Click({
    $x = $Menudroite.SelectedItem
    foreach ($game in $script:jeutrouve){
        if ($x -eq $game.Name){
            $gamepath = $game.Gamepath
            $SubDir = $game.SubDir
            $RootDirInstallOption = $game.RootDirInstallOption
            if ([string]::IsNullOrEmpty($Subdir)){
				Remove-Item "$gamepath\dsoal-aldrv.dll"
				if (test-path "$gamepath\dsound.dll") { Remove-Item "$gamepath\dsound.dll" }			
            } elseif ($RootDirInstallOption -eq "True"){
				Remove-Item "$gamepath\dsoal-aldrv.dll"	
				if (test-path "$gamepath\dsound.dll") { Remove-Item "$gamepath\dsound.dll" }
				Remove-Item "$gamepath\$Subdir\dsoal-aldrv.dll"
				if (test-path "$gamepath\$Subdir\dsound.dll") { Remove-Item "$gamepath\$Subdir\dsound.dll" }
            } else {
				Remove-Item "$gamepath\$Subdir\dsoal-aldrv.dll"
				if (test-path "$gamepath\$Subdir\dsound.dll") { Remove-Item "$gamepath\$Subdir\dsound.dll" }
            }
            $MenuDroite.Items.Remove($x)
            $MenuGauche.Items.Add($x)
            Sortlistview $MenuGauche
        }
    }
})

### EDIT BUTTON, Check each mandatory info, add then to global var and edit newalchemy file entry.
$BoutonEdition.add_Click({
    $x = $MenuGauche.SelectedItem
    if (!($x -eq $null)) {
        [xml]$InputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Height="350" Width="552" VerticalAlignment="Bottom" ResizeMode="NoResize">
    <Grid>
        <TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="439,284,0,0" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="331,284,0,0" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
    </Grid>
</Window>
"@
        $reader=(New-Object System.Xml.XmlNodeReader $inputXML)
        $Window_edit =[Windows.Markup.XamlReader]::Load( $reader )
        $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_edit.FindName($_.Name)}

        $T_Titrejeu.IsReadOnly=$true
        $T_Titrejeu.Background = '#e5e5e5'

        $Window_edit.Title=$txt.MainTitle2    
        $C_Gamepath.Content = $txt.C_GamepathContent
        $C_registre.Content=$txt.C_registreContent
        $T_registre.ToolTip = $txt.T_registreToolTip
        $T_Gamepath.ToolTip= $txt.T_GamepathToolTip
        $C_SubDir.Content = $txt.C_SubDirContent
        $T_Subdir.ToolTip = $txt.T_SubdirToolTip
        $C_Rootdir.Content=$txt.C_RootdirContent
        $L_GameTitle.Content=$txt.L_GameTitleContent
        $B_Cancel.Content=$txt.B_CancelContent
        $B_ok.Content=$txt.B_OkContent

        $C_Registre.Add_Checked({
            $T_Registre.IsReadOnly=$False
            $T_Registre.Background = '#ffffff'
            $B_GamePath.IsEnabled=$False
            $T_Gamepath.IsReadOnly=$true
            $T_Gamepath.Background = '#e5e5e5'
        })
        $C_Gamepath.Add_Checked({
            $T_Registre.IsReadOnly=$true
            $T_Registre.Background = '#e5e5e5'
            $T_Gamepath.IsReadOnly=$False
            $T_Gamepath.Background = '#ffffff'
            $B_GamePath.IsEnabled=$True
        })
        $C_SubDir.Add_Checked({
            $T_SubDir.IsReadOnly=$False
            $T_SubDir.Background = '#ffffff'
            $C_Rootdir.Background = '#ffffff'
            $C_Rootdir.IsEnabled=$true
            $B_SubDir.IsEnabled=$True
        })
        $C_SubDir.Add_UnChecked({
            $T_SubDir.IsReadOnly=$True
            $T_SubDir.Background = '#e5e5e5'
            $C_Rootdir.Background = '#e5e5e5'
            $C_Rootdir.IsChecked=$False
            $B_SubDir.IsEnabled=$False
            $C_Rootdir.IsEnabled=$False
        })

    ## RETREIVE EDIT FORM VALUES
        $count = 0
        $found = 0
        foreach ($game in $script:jeutrouve){
            if ($x -eq $game.Name){
                $found = 1
                $T_titrejeu.text = $game.Name
                $T_Subdir.text = $game.Subdir
                $RootDirInstallOption = $game.RootDirInstallOption

                if ([string]::IsNullOrEmpty($game.RegPath)){
                    $T_Gamepath.text = $game.Gamepath
                    $T_Registre.IsReadOnly=$true
                    $T_Registre.Background = '#e5e5e5'
                    $C_GamePath.IsChecked=$true
                } else{
                    $T_registre.text = $game.RegPath
                    $T_Gamepath.IsReadOnly=$true
                    $T_Gamepath.Background = '#e5e5e5'
                    $B_GamePath.IsEnabled=$False
                    $C_Registre.IsChecked=$True
                }
                if ([string]::IsNullOrEmpty($T_Subdir.text)){
                    $T_SubDir.IsReadOnly=$True
                    $T_SubDir.Background = '#e5e5e5'
                    $C_Rootdir.IsEnabled=$False
                    $C_Rootdir.Background = '#e5e5e5'
                    $B_SubDir.IsEnabled=$False
                    $C_SubDir.IsChecked=$False
                    $C_Rootdir.IsChecked=$False
                }else{
                    $C_SubDir.Ischecked= $true
                    $C_Rootdir.IsEnabled=$true
                    if ($RootDirInstallOption -eq "True"){
                        $C_Rootdir.IsChecked=$True
                    } else {
                        $C_Rootdir.IsChecked=$False
                    }
                }
            } else {
                if ($found -ne 1){
                    $count = $count +1
                }
            }
        }

    ## CLICK ON ICON GAMEPATH (EDIT FORM)
        $B_GamePath.add_Click({
            $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
            $foldername.Description = $txt.FolderChoice
            $foldername.rootfolder = "MyComputer"
            if ($C_Gamepath.IsChecked) {
                $foldername.SelectedPath = $T_Gamepath.text
            }
            if($foldername.ShowDialog() -eq "OK")
            {
                $T_Gamepath.text = $foldername.SelectedPath
            }
        })

    ## CLICK ON SUBDIR BUTTON (EDIT FORM)
        $B_SubDir.add_Click({
            $fail=$False
            if ($C_registre.IsChecked) {
                    $b = $T_Registre.Text
                    if (![string]::IsNullOrEmpty($b)){
                        if ($b -like "HKEY_LOCAL_MACHINE*") {
                            $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                        } else {
                            if($b -like "HKEY_CURRENT_USER*") {
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
                    if ($fail -eq $False){            
                        #retreive registry key
                        $regkey = $b|split-path -leaf
                        #remove registry key from registry link"
                        $b = $b.replace("\$regkey","")
                        if (!(test-path $b)){
                            $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                            $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                        }
                        if (test-path $b){
                            try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                            }
                            catch {
                                [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                                $fail = $true
                            }
                            if ($fail -eq $False) {
                                if (!(test-path $Gamepath)){
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
                    if ([string]::IsNullOrEmpty($Gamepath)){
                        $fail = $True
                        [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ($fail -eq $False) {
                if (!(test-path $Gamepath)){
                    [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    $fail = $true
                }
                if ($fail -eq $False) {
                    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                    $foldername.Description = $txt.SubFolderChoice
                    $foldername.SelectedPath = $Gamepath
                    if($foldername.ShowDialog() -eq "OK"){
                        $Subdir = $foldername.SelectedPath
                        $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                        $Subdir = $Subdir.Trimstart("\")
                        if (test-path $Gamepath\$Subdir){
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
            $Window_edit.Close()
        })

    
    ### OK BUTTON (EDIT FORM), Check if everything is ok, then EDIT GAME FILE and Hash table
        $B_Ok.add_Click({
            $fail = $false
            $regprio = $false
            if ($C_registre.IsChecked) {
                $b = $T_Registre.Text
                if (![string]::IsNullOrEmpty($b)) {    
                    if ($b -like "HKEY_LOCAL_MACHINE*") {
                        $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                    } else {
                            if($b -like "HKEY_CURRENT_USER*") {
                                $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                            }
                        }        
                    #Recover Reg Key
                    $regkey = $b|split-path -leaf
                    #"supprimer clef du lien registre"
                    $b = $b.replace("\$regkey","")
                    if (!(test-path $b)){
                    $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                    }
                    if (test-path $b){
                        try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                        }
                        catch {
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                        }
                        if ($fail -eq $False) {
                            if (!(test-path $Gamepath)){
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
                if ([string]::IsNullOrEmpty($Gamepath)){ 
                            $fail = $true
                            [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
                    }
            }
            if ($fail -eq $False) {
                $Gamepath = $Gamepath.TrimEnd("\")
                if (![string]::IsNullOrEmpty($Gamepath)){
                    if (!(test-path $Gamepath)){
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                    } 
                }
            }
            if ($C_SubDir.IsChecked -and $fail -eq $false){
                $Subdir = $T_Subdir.text
                if (!(test-path $Gamepath\$Subdir)){
                    $fail = $true
                    [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
                } 
            }
            # Test if no error
            if ($fail -eq $False){

                # Prepare Game value to write
                $Name = $T_titrejeu.text
                if ($C_Rootdir.IsChecked){
                    $RootDirInstallOption="True"
                } else {
                    $RootDirInstallOption="False"
                }
                if ($C_SubDir.IsUnChecked){
                    $SubDir=""
                    $RootDirInstallOption="False"
                }
                
                # Update list game to reflect change    
                $script:jeutrouve[$count].RegPath=$RegPath
                $script:jeutrouve[$count].Gamepath=$Gamepath
                $script:jeutrouve[$count].MaxVoiceCount=$Voice
                $script:jeutrouve[$count].SubDir=$Subdir
                $script:jeutrouve[$count].RootDirInstallOption=$RootDirInstallOption
                
                # Write change in file
                $file = Get-content ".\DsoalGames.ini"
                $LineNumber = Select-String -pattern ([regex]::Escape("[$Name]")) DsoalGames.ini| Select-Object -ExpandProperty LineNumber
                if ($regprio -eq $true) {
                    $file[$LineNumber] = "RegPath=$RegPath"
                    $file[$LineNumber +1]="GamePath="
                }else{
                    $file[$LineNumber] = "RegPath="
                    $file[$LineNumber +1]="GamePath=$Gamepath" 
                }
                $file[$LineNumber +2] = "SubDir=$Subdir" 
                $file[$LineNumber +3] = "RootDirInstallOption=$RootDirInstallOption"
                $file | Set-Content DsoalGames.ini -encoding ascii
                
                $Window_edit.Close()
                }
        })
        $Window_edit.ShowDialog() | out-null
    }
})

### ADD BUTTON (MAIN FORM)
$BoutonAjouter.add_Click({
    [xml]$InputXML =@"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Height="350" Width="552" VerticalAlignment="Bottom" ResizeMode="NoResize">
    <Grid>
        <TextBox Name="T_titrejeu" HorizontalAlignment="Left" Height="22" Margin="28,44,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="485"/>
        <RadioButton Name="C_registre" HorizontalAlignment="Left" Margin="67,85,0,0" VerticalAlignment="Top" Width="252"/>
        <RadioButton Name="C_Gamepath" HorizontalAlignment="Left" Margin="67,136,0,0" VerticalAlignment="Top" Width="252"/>
        <TextBox Name="T_registre" HorizontalAlignment="Left" Height="22" Margin="67,105,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <TextBox Name="T_Gamepath" HorizontalAlignment="Left" Height="22" Margin="67,156,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410" />
        <CheckBox Name="C_SubDir" HorizontalAlignment="Left" Height="18" Margin="67,188,0,0" VerticalAlignment="Top" Width="192"/>
        <TextBox Name="T_Subdir" HorizontalAlignment="Left" Height="22" Margin="67,211,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="410"/>
        <CheckBox Name="C_Rootdir" HorizontalAlignment="Left" Margin="67,243,0,0" VerticalAlignment="Top"/>
        <Label Name ="L_GameTitle" HorizontalAlignment="Left" Margin="67,13,0,0" VerticalAlignment="Top" RenderTransformOrigin="0.526,0"/>
        <Button Name="B_Cancel" HorizontalAlignment="Left" Height="25" Margin="439,284,0,0" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_ok" HorizontalAlignment="Left" Height="25" Margin="331,284,0,0" VerticalAlignment="Top" Width="90"/>
        <Button Name="B_GamePath" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,156,0,0" VerticalAlignment="Top" Width="22"/>
        <Button Name="B_SubDir" Content="..." HorizontalAlignment="Left" Height="22" Margin="491,211,0,0" VerticalAlignment="Top" Width="22"/>
    </Grid>
</Window>
"@
    $reader=(New-Object System.Xml.XmlNodeReader $inputXML)
    $Window_add =[Windows.Markup.XamlReader]::Load( $reader )
    $inputXML.SelectNodes("//*[@Name]") | Foreach-Object { Set-Variable -Name ($_.Name) -Value $Window_add.FindName($_.Name)}
    
    # WPF Content, tooltip values
    $Window_add.Title=$txt.MainTitle2    
    $C_Gamepath.Content = $txt.C_GamepathContent
    $C_registre.Content=$txt.C_registreContent
    $T_registre.ToolTip = $txt.T_registreToolTip
    $T_Gamepath.ToolTip= $txt.T_GamepathToolTip
    $C_SubDir.Content = $txt.C_SubDirContent
    $T_Subdir.ToolTip = $txt.T_SubdirToolTip
    $C_Rootdir.Content=$txt.C_RootdirContent
    $L_GameTitle.Content=$txt.L_GameTitleContent
    $B_Cancel.Content=$txt.B_CancelContent
    $B_ok.Content=$txt.B_OkContent

    # Default value
    $T_Gamepath.MaxLines=1
    $T_registre.MaxLines=1
    $C_registre.IsChecked=$true
    $C_SubDir.IsChecked=$False
    $T_SubDir.IsReadOnly=$True
    $T_SubDir.Background='#e5e5e5'
    $C_Rootdir.IsChecked=$false
    $C_Rootdir.IsEnabled=$False
    $C_Rootdir.Background = '#e5e5e5'
    $B_SubDir.IsEnabled=$False
    $T_Registre.IsReadOnly=$False
    $T_Registre.Background = '#ffffff'
    $B_GamePath.IsEnabled=$False
    $T_Gamepath.IsReadOnly=$true
    $T_Gamepath.Background = '#e5e5e5'
 
    $C_Registre.Add_Checked({
        $T_Registre.IsReadOnly=$False
        $T_Registre.Background = '#ffffff'
        $B_GamePath.IsEnabled=$False
        $T_Gamepath.IsReadOnly=$true
        $T_Gamepath.Background = '#e5e5e5'
    })

    $C_Gamepath.Add_Checked({
        $T_Registre.IsReadOnly=$true
        $T_Registre.Background = '#e5e5e5'
        $T_Gamepath.IsReadOnly=$False
        $T_Gamepath.Background = '#ffffff'
        $B_GamePath.IsEnabled=$True
    })

    $C_SubDir.Add_Checked({
        $T_SubDir.IsReadOnly=$False
        $T_SubDir.Background = '#ffffff'
        $C_Rootdir.IsEnabled=$True
        $C_Rootdir.Background = '#ffffff'
        $B_SubDir.IsEnabled=$True
        $C_Rootdir.IsEnabled=$true
    })

    $C_SubDir.Add_UnChecked({
        $T_SubDir.IsReadOnly=$True
        $T_SubDir.Background = '#e5e5e5'
        $C_Rootdir.IsEnabled=$False
        $C_Rootdir.Background = '#e5e5e5'
        $B_SubDir.IsEnabled=$False
        $C_Rootdir.IsEnabled=$False
        $C_Rootdir.IsChecked=$False
    })

## CLICK ON GAMEPATH BUTTON (ADD FORM)
    $B_GamePath.add_Click({
        $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
        $foldername.Description = $txt.FolderChoice
        $foldername.rootfolder = "MyComputer"
        #$initialDirectory
        if ($C_Gamepath.IsChecked) {
            $foldername.SelectedPath = $T_Gamepath.text
        }
        if($foldername.ShowDialog() -eq "OK")
        {
            $T_Gamepath.text = $foldername.SelectedPath
        }
    })

## CLICK ON SUBDIR BUTTON (ADD FORM), chek registry path first or gamepath is not present, then test subdir+gamepath path
    $B_SubDir.add_Click({
        $fail = $false
        if ($C_registre.IsChecked) {
            $b = $T_Registre.Text
            if (![string]::IsNullOrEmpty($b)){
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
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
            if ($fail -eq $False) {                
                #retreive registry key
                $regkey = $b|split-path -leaf
                #remove registry key from registry path
                $b = $b.replace("\$regkey","")
                if (!(test-path $b)){
                $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if (test-path $b){
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ($fail -eq $False) {
                        if (!(test-path $Gamepath)){
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
            if ([string]::IsNullOrEmpty($Gamepath)){ 
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
        }
        if ($fail -eq $False) {
            if (!(test-path $Gamepath)){
                [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
            } else {        
                $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
                $foldername.Description = $txt.SubFolderChoice
                $foldername.SelectedPath = $Gamepath
                if($foldername.ShowDialog() -eq "OK"){
                    $Subdir = $foldername.SelectedPath
                    $Subdir = $Subdir -ireplace[regex]::Escape("$Gamepath"),""
                    $Subdir = $Subdir.Trimstart("\")
                    if (test-path $Gamepath\$Subdir){
                        $T_Subdir.text = $Subdir
                    } else { 
                        [System.Windows.MessageBox]::Show($txt.BadPathOrSub,"",0,48)
                    }
                }
            }
        }
    })
    $B_Cancel.add_Click({
        $Window_add.Close()
    })
   
### OK BUTTON (ADD FORM), test if every value are correct, then add game to ini file and inside hashtable
    $B_Ok.add_Click({
        $fail = $false
        $regprio = $false
        $b = $T_Registre.Text
        $x = $T_titrejeu.Text

        foreach ($game in $script:listejeux){
            if ($x -eq $game.name){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.TitleExist,"",0,64)
            }
        }
        if ([string]::IsNullOrEmpty($x)){
            $fail = $true
            [System.Windows.MessageBox]::Show($txt.TitleMiss,"",0,64)
        }
        if ($C_registre.IsChecked) {
            if (![string]::IsNullOrEmpty($b)) {
                if ($b -like "HKEY_LOCAL_MACHINE*") {
                    $b = $b.replace("HKEY_LOCAL_MACHINE","HKLM:")
                } else {
                        if($b -like "HKEY_CURRENT_USER*") {
                            $b = $b.replace("HKEY_CURRENT_USER","HKCU:")
                        }
                    } 
                $regkey = $b|split-path -leaf
                $b = $b.replace("\$regkey","")
                if (!(test-path $b)){
                    $b=$b.replace("HKLM:\SOFTWARE","HKLM:\SOFTWARE\WOW6432Node")
                    $b=$b.replace("HKCU:\SOFTWARE","HKCU:\SOFTWARE\WOW6432Node")
                }
                if (test-path $b){
                    try { $Gamepath = Get-ItemPropertyvalue -Path $b -name $regkey
                    }
                    catch {
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.RegKeyInc,"",0,48)
                    }
                    if ($fail -eq $false){
                        if (!(test-path $Gamepath)){
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
        } else {
            $Gamepath = $T_Gamepath.text
        }    
        if ($fail -eq $False) {
            if ([string]::IsNullOrEmpty($Gamepath)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.PathEmpty,"",0,64)
            }
            else {
                if (!(test-path $Gamepath)){
                        $fail = $true
                        [System.Windows.MessageBox]::Show($txt.BadPath,"",0,48)
                }
            }
        }
        if ($B_SubDir.IsEnabled -and $fail -eq $false){
            $Subdir = $T_Subdir.text
            if (!(test-path $Gamepath\$Subdir)){
                $fail = $true
                [System.Windows.MessageBox]::Show($txt.SubNotFound,"",0,48)
            } 
        }
        # test if no error
        if ($fail -eq $False){
            # Value to write
            $Name = $T_titrejeu.text
            if ($C_Rootdir.IsChecked){
                $RootDirInstallOption="True"
            } else {
                $RootDirInstallOption="False"
            }
            if ($C_SubDir.IsUnchecked){
                $SubDir=""
                $RootDirInstallOption="False"
            }

            # Write change in file, Registry first, Gamepath second choice
            if ($regprio -eq $true) {
                $RegPath = $T_Registre.Text
                $Gamepath=""
            }else{
                $RegPath=""
                $Gamepath=$T_Gamepath.text
            }
            "[$Name]`rRegPath=$RegPath`rGamePath=$Gamepath`rSubDir=$SubDir`rRootDirInstallOption=$RootDirInstallOption`r`n"| Out-File -Append DsoalGames.ini -encoding ascii

            # Update list game to reflect change, Order listview by name
            $script:listejeux += add-Game -Name $Name -RegPath $RegPath -Gamepath $Gamepath -SubDir $SubDir -RootDirInstallOption $RootDirInstallOption -Found $True -Transmut $False      
            $script:jeutrouve = $script:listejeux | where-object Found -eq $True
            checktransmut $script:jeutrouve | Out-Null
            $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
            $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
            $MenuGauche.Items.Clear()
            foreach ($jeu in $jeunontransmut){
                $MenuGauche.Items.Add($jeu.name) | Out-Null
            }
            $MenuDroite.Items.Clear()
            foreach ($jeu in $jeutransmut){
                $MenuDroite.Items.Add($jeu.name) | Out-Null
            }
            Sortlistview $MenuGauche
            Sortlistview $MenuDroite
            $Window_add.Close()
        }
    })
    $Window_add.ShowDialog() | out-null
})

### Default Button (MAIN FORM)
$BoutonParDefaut.add_Click({
    $choice = [System.Windows.MessageBox]::Show("$($txt.Defaultmsgbox)`r$($txt.Defaultmsgbox2)`r$(Get-Location)\DsoalGames.bak`r`r$($txt.Defaultmsgbox3)" , "NewAlchemy" , 4,64)
    if ($choice -eq 'Yes') {
        move-Item ".\DsoalGames.ini" ".\DsoalGames.Bak" -force
        GenerateNewAlchemy "$PathAlchemy\Alchemy.ini"	
        $script:listejeux = read-file ".\DsoalGames.ini"
        checkinstall $script:listejeux | Out-Null
        $script:jeutrouve = $script:listejeux | where-object Found -eq $true
        checktransmut $script:jeutrouve | Out-Null
        $jeutransmut = $script:jeutrouve | where-object Transmut -eq $true
        $jeunontransmut = $script:jeutrouve | where-object {$_.Found -eq $true -and $_.Transmut -eq $False}
        $MenuGauche.Items.Clear()
        foreach ($jeu in $jeunontransmut){
            $MenuGauche.Items.Add($jeu.name) | Out-Null
        }
        $MenuDroite.Items.Clear()
        foreach ($jeu in $jeutransmut){
            $MenuDroite.Items.Add($jeu.name) | Out-Null
        }
    }
})

$Window.ShowDialog() | out-null
