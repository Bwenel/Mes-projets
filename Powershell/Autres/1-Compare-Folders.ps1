########################################## Script de comparaison d'arborescence de dossiers #####################################################

#Déclaration des variables:
$Folder1 = Read-Host "Nom du premier dossier"
$Folder2 = Read-Host "Nom du second dossier"
$outpath = Read-Host "indiquer le dossier du fichier de sortie(sans guillemet)"
$outfile= $outpath+ "\compare.csv"
$sortie=New-Object System.Collections.ArrayList ($null)

#Traitements:
$DossierSource = Get-ChildItem -Path $Folder1 -Recurse -File
$DossierCible = Get-ChildItem -Path $Folder2 -Recurse -File
$ComparaisonResultat = Compare-Object -ReferenceObject $DossierSource -DifferenceObject $DossierCible -Property Name,LastWriteTime  -IncludeEqual

foreach ($file in $ComparaisonResultat) {
	
    $Name= $file.name
    $Date= $file.lastwritetime 

    Write-Host $file.name $file.lastwritetime -NoNewLine
  
	if ($file.SideIndicator -eq "=="){
		Write-Host " : Présent dans les deux répertoires" -ForeGroundColor Green
        $lignesortie= [PSCustomObject]@{}
        $lignesortie | Add-Member -NotePropertyMembers @{Name=$Name;Date=$Date;Presence='Present dans les deux repertoires'} -Force
	}
	elseif($file.SideIndicator -eq "=>"){
		Write-Host " : Présent dans le répertoire $Folder1" -ForeGroundColor Cyan
        $lignesortie= [PSCustomObject]@{}
        $lignesortie | Add-Member -NotePropertyMembers @{Name=$Name;Date=$Date;Presence='Present dans le repertoire '+$Folder1} -Force
      
	}
	elseif($file.SideIndicator -eq "<=") {
		Write-Host " : Présent dans le répertoire $Folder2" -ForeGroundColor Yellow
        $lignesortie= [PSCustomObject]@{}
        $lignesortie | Add-Member -NotePropertyMembers @{Name=$Name;Date=$Date;Presence='Present dans le repertoire '+$Folder2} -Force
	}
$sortie+=$lignesortie
}
$sortie | Export-Csv -Path $outfile -NoTypeInformation -Delimiter ","
Write-Host "Données exportées vers le fichier" $outfile