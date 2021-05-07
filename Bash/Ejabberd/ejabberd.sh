#!/bin/bash

###################################################################
#												                  #
#	AUTEUR										                  #
#		Nicolas BISSIERES						                  #
#												                  #
#	DESCRIPTION									                  #
#         Menu Ejabberd							                  #
# - 1 Installation de Ejabberd                                    #
# - 2 Désinstallation de Ejabberd                                 #
# - 3 Créer des utilisateurs à partir du fichier /etc/passwd      #
# - 4 Créer aux choix des utilisateurs                            #
# - 5 Supprimer des utilisateurs à partir du fichier /etc/passwd  #
# - 6 Supprimer aux choix des utilisateurs                        #
# - 7 Faire une sauvegarde de Ejabberd                            #
# - 8 Faire une restauration de Ejabberd                          #
#								             	                  #
#	ENVIRONNEMENT VALIDE						                  #
#		- Debian Jessie	(8)						                  #
#												                  #
#	EXEMPLE LANCEMENT							                  #
#		chmod +x ejabberd.sh                                      #
#		.\ejabberd.sh							                  #
#												                  #
###################################################################

### On fait une boucle pour le menu Ejabberd

while true
	do
	clear
	echo -e "
	##################################################
	##  ________       _     _                  _   ##
	## |  ____(_)     | |   | |                | |  ##
	## | |__   _  __ _| |__ | |__   ___ _ __ __| |  ##
	## |  __| | |/ _  |  _ \|  _ \ / _ \  __/ _  |  ##
	## | |____| | (_| | |_) | |_) |  __/ | | (_| |  ##
	## |______| |\____|____/|____/ \___|_|  \____|  ##
	##      _/ |                                    ##
	##     |__/                                     ##
	##                                              ##
	##################################################
	
	Veuillez choisir une option et confirmer avec entrer
	Assurez-vous de bien être utilisateur root avant d'exécuter ce script

	1 - Installation de Ejabberd
	2 - Désinstallation de Ejabberd
	3 - Créer des utilisateurs à partir du fichier /etc/passwd
	4 - Créer aux choix des utilisateurs
	5 - Supprimer des utilisateurs à partir du fichier /etc/passwd
	6 - Supprimer aux choix des utilisateurs
	7 - Faire une sauvegarde de Ejabberd
	8 - Faire une restauration de Ejabberd

	Q - Quitter"

read answer
	clear
case $answer in

[1]) # Permet d'installer Ejabberd

### On vérifie la présence de Ejabberd afin de savoir s’il n'est pas déjà installé

	if [ -d "/etc/ejabberd/" ]; then
		echo "#############################################"
		echo "######### EJABBERD EST DÉJÀ INSTALLÉ ########"
		echo "#############################################"
	break
	
## Si celui-ci n'est pas installé on procède à son installation après confirmation de l'utilisateur
	
	else
	read -sn1 -p "L'installation d'Ejabberd va commencer, souhaitez-vous continuer ? [O/n] " ;echo 
	[ "$REPLY" = "o" ] || { echo "Caramba ! Installation annulé !";exit 0; }

		echo "#############################################"
		echo "########## MISES A JOUR DES DEPOTS ##########"
		echo "#############################################"
		
			apt-get update -y && apt-get upgrade -y
			clear	
				
		echo "#############################################"
		echo "#########  INSTALLATION EN COURS.... ########"
		echo "#############################################"
		
			apt-get install -y ejabberd
			clear
														
		echo "######################################################"
		echo "########  CONFIGURATION D'EJABBERD EN COURS... #######"
		echo "######################################################"
	
			cp /etc/ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml.orig
			ejabberdctl register admin localhost admin	
			sed -i '378i- "": "admin@localhost"' /etc/ejabberd/ejabberd.yml
			sed -i "s/loglevel\: 4/loglevel\: 3/g" /etc/ejabberd/ejabberd.yml
			sed -i "s/ip_access\: trusted_network/ip_access\: all/g" /etc/ejabberd/ejabberd.yml
			clear				
		echo "######## CONFIGURATION DU CERTIFICAT #######"
		
			mv /etc/ejabberd/ejabberd.pem /etc/ejabberd/ejabberd.pem.orig
			openssl req -new -x509 -newkey rsa:1024 -days 3650 -keyout privkey.pem -out server.pem 
			openssl rsa -in privkey.pem -out privkey.pem 
			cat privkey.pem >> server.pem 
			rm privkey.pem 
			mv server.pem /etc/ejabberd/ejabberd.pem 
			chown root:ejabberd /etc/ejabberd/ejabberd.pem 
			chmod 640 /etc/ejabberd/ejabberd.pem
			
		echo "######################################################"
		echo "######### CONFIGURATION D'EJABBERD TERMINÉE ! ########"	
		echo "IDENTIFIANT ADMIN"                            ########"
		echo "Utilisateur   : admin@localhost               ########"
		echo "Mot de passe  : admin                         ########"
		echo "######################################################"
	break	
	fi	;;
		
[2]) # Permet de supprimer Ejabberd
	read -sn1 -p "Souhaitez-vous vraiment procéder à la suppression de Ejabberd ? (tous sera perdu) [O/n] " ;echo 
	[ "$REPLY" = "o" ] || { echo "Caramba ! On a évité le pire !";exit 0; }
	
		echo "######################################################"
		echo "######### SUPPRESSION D'EJABBERD EN COURS... #########"
		echo "######################################################"

			apt-get remove -y ejabberd && aptitude purge -y ejabberd
			find /etc/ejabberd/ -delete
			clear	
			
		echo "######################################################"
		echo "##########  SUPRESSION D'EJABBERD TERMINÉE ! #########"
		echo "######################################################"						
	break ;;

[3]) # Créer des utilisateurs à partir du fichier /etc/passwd
	for lineuser in $(cat /etc/passwd | cut -d: -f1,3); do
		user=`echo "$lineuser" | cut -d: -f1`
		id=`echo "$lineuser" | cut -d: -f2`
		
	if [[ $id -ge 1000 || $id -eq 0 ]]; then
	read -p "Indiquer le domaine et le mot de passe de $user ? Exemple : localhost azerty123 : " domain password
			ejabberdctl register $user $domain $password
		echo "##########  Création de l'utilisateur $user effectué ! #########"	
	fi
	done;;
	
[4]) # Créer aux choix des utilisateurs
	read -p "Combien d'utilisateurs voulez-vous créer ? " users_create
	for i in $(seq 1 $users_create); do
	read -p "Veuillez saisir le domaine Ejabberd (localhost par défaut) " domain
	read -p "Veuillez saisir l'utilisateur a créer " user
		
		i=`ejabberdctl registered-users $domain | grep "$user" | wc -l`

	if  [ $i = 1 ]; then
		echo "Caramba ! L'utilisateur $user existe déjà !"
	else
	read -p "Indiquez un mot de passe pour $user " password
			ejabberdctl register $user $domain $password
		echo "##########  Création de l'utilisateur $user effectué ! #########"
	fi
	done
	break;;
	
[5]) # Supprimer des utilisateurs à partir du fichier /etc/passwd
	for lineuser in $(cat /etc/passwd | cut -d: -f1,3); do
		user=`echo "$lineuser" | cut -d: -f1`
		id=`echo "$lineuser" | cut -d: -f2`
		
	if [[ $id -ge 1000 || $id -eq 0 ]]; then
	read -p "Pour supprimer l'utilisateur $user merci d'indiquer son domaine (localhost par defaut) " domain
		
			ejabberdctl unregister $user $domain 
			
		echo "##########  Supression de l'utilisateur $user effectué ! #########"	
	fi
	done;;	
	
[6]) # Supprimer aux choix des utilisateurs

	read -p "Indiquez le nombre d'utilisateurs à supprimer : " users_delete
	for nb_users in $(seq 1 $users_delete); do
	read -p "Indiquez le domaine Ejabberd (localhost par défaut) : " domain
	read -p "Indiquez l'utilisateurs à supprimer : " user
	
		i=`ejabberdctl registered-users $domain | grep "$user" | wc -l`
	
	if  [ $i = 0 ]; then
		echo "Caramba ! L'utilisateur $user n'existe pas !"
	else	
			ejabberdctl unregister $user $domain
		echo "##########  Supression de l'utilisateur $user effectué ! #########"
	fi
	done
	break;;
	
[7]) # Sauvegarde Ejabberd dans le fichier ejabberd.backup

	if [ -f "/var/lib/ejabberd/ejabberd.backup" ]; then
	read -sn1 -p "Une sauvegarde d'Ejabberd existe déjà, souhaitez-vous quand même continuer ? [O/n] " ;echo 
	[ "$REPLY" = "o" ] || { exit 0; }
			ejabberdctl backup ejabberd.backup
			cp /etc/ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml.bak
		echo "####  SAUVEGARDE EFFECTUÉ ! ###"
		echo "Le fichier ejabberd.backup est situé dans le répertoire :/var/lib/ejabberd"
		echo "Le fichier de configuration ejabberd.yml.bak est situé dans le répertoire :/etc/ejabberd"
	else 
	read -sn1 -p "Caramba ! Aucune sauvegarde trouvée ! Souhaitez-vous en créer une ? [O/n] " ;echo 
	[ "$REPLY" = "o" ] || { exit 0; }
			ejabberdctl backup ejabberd.backup
			cp /etc/ejabberd/ejabberd.yml /etc/ejabberd/ejabberd.yml.bak
		echo "####  SAUVEGARDE EFFECTUÉ ! ####"
		echo "Le fichier ejabberd.backup est situé dans le répertoire : /var/lib/ejabberd"
		echo "Le fichier de configuration ejabberd.yml.bak est situé dans le répertoire :/etc/ejabberd"
	fi	
	break;;	
	
[8]) # Restaure Ejabberd à partir du fichier ejabberd.backup

	if [ -f "/var/lib/ejabberd/ejabberd.backup" ]; then
		echo "#############################################"
	read -sn1 -p "Une sauvegarde d'Ejabberd a été trouvé, souhaitez-vous la réstaurer ? [O/n] " ;echo 
	[ "$REPLY" = "o" ] || { exit 0; }
			ejabberdctl restore ejabberd.backup
			cp /etc/ejabberd/ejabberd.yml.bak /etc/ejabberd/ejabberd.yml
		echo "####  RESTAURATION EFFECTUÉ ! ###"
	else 
		echo "Caramba ! Il n'y a pas de fichier de sauvegarde ! Pas de fichier de sauvegarde, pas de restauration !"
	fi	
	break;;
	
[Qq]) # Permet de quitter le menu définitivement
   echo "Ce Menu vous a été présenté par Nicolas BISSIERES . A une prochaine fois !" ; exit 0 ;;
	
*) # En cas de mauvais choix envoi une erreur

		echo "Caramba l'option est invalide !" ;;
esac
		echo ""
		echo "Tapez ENTRÉE pour retouner au menu Ejabberd"
read dummy
done