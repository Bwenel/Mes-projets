
$IPAddress = '192.168.1.60'
$CIDR = '24'
$DefaultGateway  = '192.168.1.62'
$DNS = '192.168.1.61'
$ServerName = 'SAMO-WSRV02'

if ($BestPractices -eq $True) {
    if ($env:computerName -ne $ServerName) {
        Write-Warning "Le nom d'hôte est incorrect. Il va être renomé en $ServerName"
        Write-Warning 'VEUILLEZ RE-EXECUTER LE SCRIPT APRES LE RE-DEMARRAGE DU SERVEUR'
        Rename-Computer -NewName $ServerName
        Start-Sleep 10
        #Restart-Computer
    }

    #Avertie l'utilsateur qu'il ne respect pas les Best Practices
    if ($PathAD -like "$env:HOMEDRIVE*") {
        Write-Warning "Vous allez installer l'Active Directory sur votre partition principal. Il est recommandé de l'installé sur une parition secondaire"
        $Continue = Read-Host 'Voulez-vous continuer ? (y/n)'

        while("y","n" -notcontains $Continue) {$Continue =  Read-Host "Voulez-vous continer ? (y/n)"}

        if ($Continue -eq "n") {
            Write-Output 'Veuillez executer le script avec le paramètre -Path'
            Write-Output "Exemple d'utilisation : .\Deploy-SAMO-WSRV01.ps1 -PathAD D:\ActiveDirectory"
            exit
        }
    }
}

Write-Output "#########################################################"
Write-Output "############## PARAMETRAGE DE LA CARTE RESEAU ###########"
Write-Output "#########################################################"

Write-Output "Rennomage de la carte $NetAdapter en LAN"
Rename-NetAdapter -Name $NetAdapter -NewName LAN
Write-Output "Configuration de la carte LAN"
New-NetIPAddress -InterfaceIndex (Get-NetAdapter LAN).ifIndex -IPAddress $IPAddress -PrefixLength $CIDR -DefaultGateway $DefaultGateway
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter LAN).ifIndex -ServerAddresses ("$DNS","127.0.0.1")
Write-Output "Les paramétres de la carte LAN ont été configurés"

Write-Output "#########################################################"
Write-Output "############### INSTALLATION DU ROLE DNS ################"
Write-Output "#########################################################"

if (!(Get-WindowsFeature -Name DNS).Installed) {Install-WindowsFeature DNS –IncludeManagementTools} else {Write-Output "Le rôle DNS est déjà installé"}

$PathCsv = "E:\SAMO\Powershell\Scripts\SAMO\Configuration_DHCP.csv"

Write-Output "#########################################################"
Write-Output "############### INSTALLATION DU ROLE DHCP ###############"
Write-Output "#########################################################"

#Vérification si le chemin du fichier CSV est correct
if (!(Test-Path $PathCsv)) {
    Write-Warning "Le chemin du fichier CSV pour la configuration DHCP n'est pas correct" 
    exit
}

if (!((Get-WindowsFeature -Name DHCP).Installed)) {
    Write-Output "########## INSTALLATION DU ROLE ##########"
    Install-WindowsFeature -Name DHCP -IncludeManagementTools
    Add-DhcpServerSecurityGroup
    Restart-service dhcpserver
    Set-ItemProperty –Path registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\ServerManager\Roles\12 –Name ConfigurationState –Value 2
    Start-Sleep 15
} else {Write-Output 'Le rôle DHCP est déjà installé'}


Write-Output "########## CONFIGURATION DHCP ##########"
if ((Get-WindowsFeature -Name DHCP).Installed) {

    $DNS = "192.168.1.60"

    #Configuration des options DHCP
    Set-DHCPServerv4OptionValue -DnsServer $DNS
    Set-DHCPServerv4OptionValue -DnsDomain $DomainName

    #Boucle pour chaque ligne du fichier CSV
    foreach ($i in Import-CSV -Path $PathCsv -Delimiter (';')) {
        $Scope = $i.Scope
        if (-not (Get-DhcpServerv4Scope | Where-Object { $_.ScopeId -eq $Scope })) {

            #Création de l'étendu
            Add-DHCPServerv4Scope -Name $i.Name -StartRange $i.Start -EndRange $i.End -SubnetMask $i.Mask
            Set-DHCPServerv4OptionValue -ScopeId $Scope -Router $i.Router
            Write-Output "SUCCES : L'étendue $Scope a été créé"

        } else {
            Write-Warning "L'étendue $Scope existe déjà"
        }
    }

} else {Write-Warning "Annulation de la configuration car le role DHCP n'est pas installé"}























Write-Output '######################################################################'
Write-Output '############### INSTALLATION DU ROLE ACTIVE DIRECTORY ################'
Write-Output '######################################################################'

if (!(Get-WindowsFeature -Name AD-Domain-Services).Installed){

    Install-WindowsFeature AD-Domain-Services –IncludeManagementTools
    Import-Module ADDSDeployment

    #Ajout du controleur de domaine au domaine samo.lan
    Install-ADDSDomainController -DomainName "samo.lan" -InstallDns:$true -Credential (Get-Credential "SAMO\Administrateur") -SafeModeAdministratorPassword (ConvertTo-SecureString -AsPlainText "Samoè(ààà" -Force )
} else {
    Write-Output "Le rôle Active Directory est déjà installé"
}





