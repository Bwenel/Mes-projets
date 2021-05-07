# Projet SAMO

Pour ce projet nous étions une équipes de 4 personne dont l'objectif était de faire la refonte de l'infrastructure informatique d'un client fictif.

J'ai été chargé de la partie Active Directory, pour me faciliter la tâche dans mon travail j'ai donc créeé quelques scripts d'automatisation pour l'infrastructure de SAMO.


# Active Directory

Pour la partie Active Directory 5 scripts ont été crées

1-Deploy-SAMO-WSRV01.ps1 : Ce script permet d'automatiser l'installation des rôles Active Directory, DNS et DHCP du serveur PAR-AD01

2-Etendues_DHCP.ps1 : Ce script permet d'automatiser la création des étendues DHCP du serveur PAR-AD01 à l'aide d'un fichier CSV

3-New-SAMOOrganizationUnit.ps1 : Ce script permet d'automatiser la création des Unités d'organisations de SAMO sur le serveur PAR-AD01 à l'aide d'un fichier CSV

4-New-SAMO Users.ps1 : Ce script permet d'automatiser la création des utilisateurs de SAMO sur le serveur PAR-AD01 à l'aide d'un fichier CSV

5-Deploy-SAMO-WSRV02.ps1 : Ce script permet d'automatiser l'installation des rôles Active Directory, DNS et DHCP du serveur PAR-AD02
