######################  CREATION USERS  ##########################
Import-Module ActiveDirectory
Import-Module NTFSSecurity

#import du fichier CSV

$Import-CsvFile = Read-Host "Glisser ici ou préciser le chemin du fichier csv"
$Import-Csv = Import-Csv $Import-CsvFile -Delimiter ';'

#Récupération de l'OU où seront créés les utilisateurs
$OURead = Read-Host "Ou voulez vous créer les utilisateurs ? "
$OUSAMO = 'AD:\OU='+$OURead+',DC=interne.samo,DC=com'
  
  if ((Test-Path "$OUSAMO") -eq $True )
 {
 Write-host OK
 $OU = "OU="+$OURead+",DC=interne.samo,DC=com"
 }
 else
 {
 $OU = "OU="+$OURead+",DC=interne.samo,DC=com"
 New-ADOrganizationalUnit -Name $OURead -Path "DC=interne.samo,DC=com"
 }


foreach ($user in $Import-Csv)
{
$DisplayName = $user.prenom+" "+($user.nom)
$PersoUser = "D:\Repertoire_Perso\"+$user.login

#Création des utilisateurs
New-ADUser -Name $DisplayName `    -DisplayName $DisplayName `    -Surname $user.nom ``    -GivenName $user.prenom `    -SamAccountName $user.login `    -UserPrincipalName $user.login `    -Description $user.fonction `    -Path $OU `    -enable $True `    -AccountPassword(ConvertTo-SecureString -AsPlainText "SAMO75000" -Force)

#Creation du dossier personnel
New-Item -Name $user.login -ItemType directory -path D:\Repertoire_Perso

#Ajout des droits pour l'utilisateur sur son perso et retrait de l'héritage et du groupe utilisateur
Disable-NTFSAccessInheritance $PersoUser
Add-NTFSAccess $PersoUser -Account $user.login -AccessRights FullControl
Get-NTFSAccess $PersoUser -Account Utilisateurs | Remove-NTFSAccess
}