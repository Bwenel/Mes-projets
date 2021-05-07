param(
    [string]$DomainName = "interne.samo.com",
	[string]$DnsServer = "192.168.4.4",
    [string]$PathCsv  = "C:\Configuration_DHCP.csv"
)
    
Write-Output "#########################################################"
Write-Output "################## CONFIGURATION DHCP ###################"
Write-Output "#########################################################"

#Vérification pour voir si le chemin du fichier CSV est correct
if (!(Test-Path $PathCsv)) {
    Write-Warning "Le chemin du fichier CSV pour la configuration DHCP n'est pas correct" 
    exit
}

if ((Get-WindowsFeature -Name DHCP).Installed) {
	
    #Configuration des options DHCP
	#DNS et Domaine
    Set-DHCPServerv4OptionValue -DnsServer $DnsServer -DnsDomain $DomainName
	
	#Sert pour le serveur de Teledistribution du Technicien Kevin
	Set-DHCPServerv4OptionValue -OptionId 66 -Value "192.168.4.15"
	Set-DHCPServerv4OptionValue -OptionId 67 -Value "undionly.kpxe"

    #Boucle pour chaque ligne du fichier CSV
    foreach ($i in Import-CSV -Path $PathCsv -Delimiter (';')) {
        $Scope = $i.Scope
        if (-not (Get-DhcpServerv4Scope | Where-Object { $_.ScopeId -eq $Scope })) {

            #Création de l'étendu
            Add-DHCPServerv4Scope -Name $i.Name -StartRange $i.Start -EndRange $i.End -SubnetMask $i.Mask -LeaseDuration 12:00:00 # Un bail de 12 heures
            Set-DHCPServerv4OptionValue -ScopeId $Scope -Router $i.Router
            Write-Output "SUCCES : L'étendue $Scope a été créé"

        } else {
            Write-Warning "L'étendue Scope existe déjà"
        }
    }
} else {Write-Warning "Annulation de la configuration car le role DHCP n'est pas installé"}
