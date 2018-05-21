#!/bin/bash
############################################################
############################################################
# 					Compatibilité système		 		   #
############################################################
############################################################

# ----------------------------------------------------------
# [Pour Comparer votre version d'OS à
#  celles mentionnées ci-dessous]
# 
# ¤ distributions Ubuntu:
#		lsb_release -a
#
# ¤ distributions CentOS:
# 		cat /etc/redhat-release
# 
# 
# ----------------------------------------------------------

# ----------------------------------------------------------
# testé pour:
# 
# 
# 
# 
# ----------------------------------------------------------
# (Ubuntu)
# ----------------------------------------------------------
# 
# ¤ [TEST-OK]
#
# 	[Distribution ID: 	Ubuntu]
# 	[Description: 		Ubuntu 16.04 LTS]
# 	[Release: 			16.04]
# 	[codename:			xenial]
# 
# 
# 
# 
# 
# 
# ----------------------------------------------------------
# (CentOS)
# ----------------------------------------------------------
# 
# 
# 
# ...
# ----------------------------------------------------------

############################################################
############################################################
#			Variables d'environnement globales		 	   #
############################################################
############################################################
MAISON=`pwd`

NOM_CONTENEUR_TOMCAT=ciblededeploiement-composant-srv-jee
NOM_CONTENEUR_SGBDR=ciblededeploiement-composant-sgbdr

ADRESSE_IP_SRV_JEE=192.168.1.63
NUMERO_PORT_SRV_JEE=8888

ADRESSE_IP_SGBDR=192.168.1.63
NUMERO_PORT_SGBDR=3308

DB_MGMT_USER_NAME=lauriane
DB_MGMT_USER_PWD=lauriane

DB_APP_USER_NAME=appli-de-lauriane
DB_APP_USER_PWD=mdp@ppli-l@urian3


############################################################
# l'utilisateur linux qui fera office d'opérateur
# pour le compte du plugin maven "deployeur-maven-plugin"
# cet utilisateur devrait être différent de celui utilisé
# pour construire la cible de déploiement. Il devrait de 
# plus être inexistant avant, et créé pour le
# comissionning de la cible de déploiement.
MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME=lauriane
MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD=lauriane
# le repo git qui assistera le
# plugin maven "deployeur-maven-plugin"
NOM_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN=lauriane-deploiement
URL_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN=https://github.com/Jean-Baptiste-Lasselle/lauriane-deploiement.git



############################################################
############################################################
#				déclarations des fonctions				   #
############################################################
############################################################


# ---------------------------------------------------------
# [description]
# ---------------------------------------------------------
# Cette fonction permet de demander à l'utilisateur de
# saisir un nom et un mot de passe pour l'utilisateur linux
# opérateur du plugin "deployeur-maven-plugin"
# 
# ---------------------------------------------------------
# [signature]
# ---------------------------------------------------------
#
# 	Cette fonction s'invoque sans aucun argument
#
# ---------------------------------------------------------

demander_infos_creation_operateur_mvnplugin () {
	
	clear
	# TODO: demander à l'utilisateur de choisir un nom d'utilisateur, et un mot de passe à saisir deux fois
	echo " ----------------------------------------------------------------------------------------- "
	echo " -- CREATION UTILISATEUR POUR DEPLOYEUR-MAVEN-PLUGIN ------------------------------------- "
	echo " -- Nous allons devoir créer un utilisateur Linux dans"
	echo " -- la cible de déploiement, utilisateur qui aura la possibilité d'opérer avec docker"
	echo " ----------------------------------------------------------------------------------------- "
	
	echo "Quel sera le nom d'utilisateur de ce user linux?"
	echo " "
	read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
	# read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD
	

	echo "Saisissez un mot de passe pour ce user linux?"
	echo " "
	# read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
	read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD1
	
	echo "Confirmez le mot de passe de ce user linux en le saisissant de nouveau:"
	echo " "
	# read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
	read VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD2
	# peut-être amélioré: avec vérification égalité des deux mots de passes, sinon affichage d'un message d'erreur, et sortie exit avec code d'erreur 1.
	VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME=$VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD2
	clear
	echo " ----------------------------------------------------------------------------------------- "
	echo " -- L' UTILISATEUR LINUX :							------------------------------------ "
	echo " -- 		$VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME"
	echo " -- Sera créé."
	echo " ----------------------------------------------------------------------------------------- "
	echo " "
	read
}

# demander_infos_creation_operateur_mvnplugin () { # TODO: demander à l'utilisateur de choisir un nom d'utilisateur, et un mot de passe à saisir deux fois


demanderAdresseIPserveurJee () {

	echo "Quelle adresse IP souhaitez-vous que le serveur Jee utilise?"
	echo "Voici les adresses disponibles sur cette machine:"
	echo " "
	ip addr|grep "inet"|grep -v "inet6"|grep "enp\|wlan"
	echo " "
	read ADRESSE_IP_DE_CETTE_MACHINE
	ADRESSE_IP_SRV_JEE=$ADRESSE_IP_DE_CETTE_MACHINE
}




demander_choix_no_ports () {

	echo "Quel nuéméro de port souhaitez-vous que le serveur jee utilise?"
	read SAISIE_NUMERO_PORT_SRV_JEE
	
	echo "Quel nuéméro de port souhaitez-vous que le SGBDR utilise?"
	read SAISIE_NUMERO_PORT_SGBDR
	
	
	
}


############################################################
############################################################
#					exécution des opérations			   #
############################################################
############################################################










# Possibilité de configuration réseau IP statique
clear
echo "Cet utilitaire automatise la construction d'une infrastructure, dans laquelle il vous"
echo "est possible de déployer une application Web Java Jee, faisant usage d'une base de données SQL."
echo "Cette infrastructure comprend donc au moins:"
echo " "
echo "	¤ un serveur Jee "
echo "	¤ un serveur de gestion de base de données relationelles (SGBDR)"
echo " "
echo "La totalité de cette infrastructure est construite dans cette machine virtuelle."
echo " "
echo " - "
echo " "
echo "Vous pourrez de plus utilsier le [fullstack-maven-plugin] pour  "
echo "déployer votre application à partir de votre hôte de virutalisation. "
echo " "
echo " "
echo "	¤ https://github.com/Jean-Baptiste-Lasselle/fullstack-maven-plugin "
echo " "
echo " - "
echo " Pressez la touche entrée pour commencer. "
read
clear

echo "Avant tout, cette machine DOIT avoir accès à internet."
echo "Et vous avez besoin de connaître une adresse IP de votre VM."
echo " Pressez la touche entrée pour poursuivre. "
read
clear

demanderAdresseIPserveurJee

# echo "Souhaitez-vous configurer une adresse IP statique pour cette machine ? (oui/non)"
# car ma procédure de reconfiguration réseau s'applique sur les
# interfaces réseau linux classiques, mais pas sur les interfaces réseau linux wifi
# echo "<!!!> (À n'utliser que lorsque vous maîtriser bien le réseau dans lequel opère cette machine)"
# echo "<!!!> (Si vous êtes connecté à internet via wifi, répondez non)"
# read DOIS_JE_CONFIG_IPSTATIQUE
# case "$DOIS_JE_CONFIG_IPSTATIQUE" in
	# [oO] | [oO][uU][iI]) configurer_ip_statique ;;
	# [nN] | [nN][oO][nN]) echo "L'utilisateur $USER a répondu non: Aucune reconfiguration réseau ne sera donc faite.";;
	# *) echo "L'utilisateur [$USER] a saisi une réponse incompréhensible: Aucune reconfiguration réseau ne sera donc faite.";;
# esac
demander_choix_no_ports
# à faire lorsque 'lon aura bien implémenter le module qui créera l'utilisateur dans le script "installes-tout.sh"
# demander_infos_creation_operateur_mvnplugin
############################################################
############################################################
#	  Export des Variables d'environnement globales	 	   #
############################################################
############################################################
export MAISON
export NOM_CONTENEUR_TOMCAT
export NOM_CONTENEUR_SGBDR

export ADRESSE_IP_SRV_JEE
NUMERO_PORT_SRV_JEE=$SAISIE_NUMERO_PORT_SRV_JEE
export NUMERO_PORT_SRV_JEE

ADRESSE_IP_SGBDR=$ADRESSE_IP_SRV_JEE
export ADRESSE_IP_SGBDR
NUMERO_PORT_SGBDR=$SAISIE_NUMERO_PORT_SGBDR
export NUMERO_PORT_SGBDR

export DB_MGMT_USER_NAME
export DB_MGMT_USER_PWD

export DB_APP_USER_NAME
export DB_APP_USER_PWD


export NOM_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN
export URL_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN

# à dé-commenter pour activer la demadne des infos de user plugin maven
# MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME=$VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
# MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD=$VAL_MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD
export MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
export MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD

# clear
# echo POIN DEBUG DEBUT
# echo "verif valeur [ADRESSE_IP_SRV_JEE=$ADRESSE_IP_SRV_JEE]"
# echo "verif valeur [NUMERO_PORT_SRV_JEE=$NUMERO_PORT_SRV_JEE]"
# echo "verif valeur [NUMERO_PORT_SGBDR=$NUMERO_PORT_SGBDR]"
# read


sudo chmod +x ./*.sh

#• Non: même au niveau du fichier [monter-cible-deploiement.sh], le script [configurer-user-et-bdd-sql.sh] ne peut être exécuté
# ./sys-setup.sh && ./generer-op-std-deploiement.sh && ./installes-tout.sh && sudo ./configurer-user-et-bdd-sql.sh
./docker-BARE-METAL-SETUP.sh && ./generer-op-std-deploiement.sh && ./installes-tout.sh