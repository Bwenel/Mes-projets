
param(
    [string]$NamePrincipalOU        = 'PARIS',
    [array]$Utilisateurs            = @('Administrateurs','Direction / Ressources Humaines','Employés','VIP'),
    [array]$Ordinateurs            = @('Ordinateurs Fixe','Ordinateurs Portable','Clients léger')
)

$PrincipalOU = "OU=$NamePrincipalOU,DC=interne.samo,DC=com"

if (!(Get-ADOrganizationalUnit -Filter {ou -eq 'interne.samo'})) {

    New-ADOrganizationalUnit -Name $NamePrincipalOU -Path "DC=interne.samo,DC=com" -ProtectedFromAccidentalDeletion $false
    New-ADOrganizationalUnit -Name 'Ordinateurs' -Path $PrincipalOU 
    New-ADOrganizationalUnit -Name 'Utilisateurs' -Path $PrincipalOU
    New-ADOrganizationalUnit -Name 'Groupes' -Path $PrincipalOU

}

# Création de l'arborescence Utilisateurs
if ($Utilisateurs.Count -ne 0) {
    foreach ($i in $Utilisateurs) {
        if (Get-ADOrganizationalUnit -Filter {ou -eq $i}) {
            Write-Warning "L'unité d'organisation $NamePrincipalOU $i existe déjà"
        } else {
            Write-Output "Création de l'unité d'organisation $i"
            New-ADOrganizationalUnit -Name $i -Path "OU=Utilisateurs,$PrincipalOU"
        }
    }
}

# Création de l'arborescence Ordinateurs
if ($Ordinateurs.Count -ne 0) {
    foreach ($i in $Ordinateurs) {

        if (Get-ADOrganizationalUnit -Filter {ou -eq $i}) {
            Write-Warning "L'unité d'organisation $i existe déjà"
        } else {
            Write-Output "Création de l'unité d'organisation $i"
            New-ADOrganizationalUnit -Name $i -Path "OU=Ordinateurs,$PrincipalOU"
        }
    }
}