#  Recherche les groupes universels utilisateurs (GU_U_prenom.nom) vide et ajoute les utilisateurs correspondants si ils existent
$GroupeUniverselleVide=( Get-ADGroup -Filter * -Properties members -SearchBase "OU=Groupes universels,OU=Utilisateurs,DC=Domaine,DC=gouv,DC=fr" | where { $_.members.count -eq 0}).name
 
foreach ($LigneGroupeUtilisateur in $GroupeUtilisateurVide) { #Pour chaque groupe de la liste des GU_U faire les action suivantes
    $CompteActiveDirectory =""                                                                    # Déclaration d'une variable vide $CompteActiveDirectory
    $samAccountName = ""                                                                          # Déclaration d'une variable vide $samAccountName
    $CompteGroupesUniversels = $LigneGroupeUtilisateur.split("_")[2]                              # Déclaration d'une variable $CompteGroupesUniversels récupérant le prenom.nom du GU_U
    $CompteActiveDirectory = Get-ADUser -Filter {CN -eq $CompteGroupesUniversels}                 # Déclaration d'une variable $CompteActiveDirectory rechercher les comptes AD correspondant au GU_U
    if ($CompteActiveDirectory.Name -ne $null){                                                   # Si le nom du compte AD n'est pas égale à 0
        $samAccountName = $CompteActiveDirectory.SAMAccountName                                   # On récupère le SAMAccountName des comptes AD que l'on stocke dans la variable samAccountName
       #Add-ADGroupMember -identity $LigneGroupeUtilisateur -members $samAccountName              # On ajoute à chauqe groupe le SAMAccountName correspondant
        Add-Content -Path $PSScriptRoot"\GU_U_membres_rajouté.txt" -Value $LigneGroupeUtilisateur # On exporte le rséultat dans un fichier texte appelé GU_U_membres_rajouté.txt
        Write-Host "L'utilisateur $samAccountName correspondant au $LigneGroupeUtilisateur a été rajouté avec succès" -ForegroundColor Green # On affiche sur l'écran le bon succès de l'opération
    }
    else{ # Si l'utilisateur associès au groupe n'existe plus alors on affiche les comptes concernès à l'écran et on l'exporte dans un fichier texte appelé GU_U_pas_de_comptes_AD_correspondant
        Write-Host "L'utilisateur du groupe $LigneGroupeUtilisateur n'existe pas ou plus"
        Add-Content -Path $PSScriptRoot"\GU_U_pas_de_comptes_AD_correspondant.txt" -Value $LigneGroupeUtilisateur
        }
}