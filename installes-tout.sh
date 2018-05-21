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




#----------------------------------------------------------#
############################################################
#					exécution des opérations			   #
############################################################
#----------------------------------------------------------#



##########################################################
##### 				INSTALLATION DOCKER			 #########
##########################################################
# installation docker
apt-get remove -y apt-transport-https ca-certificates curl software-properties-common
apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg|apt-key add -

# config repo ubuntu contenant les dépendances docker
apt-key fingerprint 0EBFCD88 >> ./VERIF-EMPREINTE-CLE-REPO.lauriane
# le fichier "./VERIF-EMPREINTE-CLE-REPO.lauriane" doit contenir:
# 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"



apt-get update -y

apt-get install -y docker-ce

usermod -aG docker $USER

systemctl enable docker
systemctl start docker


clear
##########################################################
##### MONTEE INFRASTRUCTURE CIBLE DE DEPLOIEMENT #########
##########################################################


# 
# 
# >>>> ENV. SETUP.
# NOM_CONTENEUR_TOMCAT=ciblededeploiement-composant-srv-jee
# NUMERO_PORT_SRV_JEE=8785
VERSION_TOMCAT=8.0
# MAISON=/home/lauriane
# NOM_CONTENEUR_SGBDR=ciblededeploiement-composant-sgbdr
# NUMERO_PORT_SGBDR=3308
# NUMERO_PORT_SGBDR=3355
# NOM_BDD_APPLI=bdd_appli_lauriane
NOM_BDD_APPLI=bdd_organisaction

MARIADB_MDP_ROOT_PASSWORD=peuimporte

# DB_MGMT_USER_NAME=lauriane
# DB_MGMT_USER_PWD=lauriane

# DB_APP_USER_NAME=appli-de-lauriane
# DB_APP_USER_PWD=mdp@ppli-l@urian3

# Avec cet utilisateur, on va créer la BDD $NOM_BDD_APPLI, et
# créer l'utilisateur $DB_APP_USER_NAME
MARIADB_DB_MGMT_USER_NAME=$DB_MGMT_USER_NAME
MARIADB_DB_MGMT_USER_PWD=$DB_MGMT_USER_PWD


MARIADB_DB_APP_USER_NAME=$DB_APP_USER_NAME
MARIADB_DB_APP_USER_PWD=$DB_APP_USER_PWD

# 		¤ 
VERSION_MARIADB=10.1
CONTEXTE_DU_BUILD_DOCKER=$MAISON/lauriane
export NOM_IMAGE_DOCKER_SGBDR=organis-action/sgbdr:v1
NO_PORT_EXTERIEUR_MARIADB=$NUMERO_PORT_SGBDR
NOM_CONTENEUR_MARIADB=$NOM_CONTENEUR_SGBDR
REPERTOIRE_HOTE_BCKUP_CONF_MARIADB=$MAISON/mariadb-conf/bckup
rm -rf $REPERTOIRE_HOTE_BCKUP_CONF_MARIADB
mkdir -p $REPERTOIRE_HOTE_BCKUP_CONF_MARIADB
# >>>>>>>>>>>> [$CONF_MARIADB_A_APPLIQUER] >>> DOIT EXISTER
# CONF_MARIADB_A_APPLIQUER=$MAISON/conf.mariadb
CONF_MARIADB_A_APPLIQUER=$MAISON/my.cnf

############################################################
############################################################
#					déclarations fonctions				   #
############################################################
############################################################
# ----------------------------------------------------------
# ces fichiers générés sont des dépendaces du
# build de l'image mariadb.
generer_fichiers () {
	# > script sql pour créer la bdd
	rm -f $CONTEXTE_DU_BUILD_DOCKER/creer-bdd-application.sql
	echo "CREATE DATABASE $NOM_BDD_APPLI; " >> $CONTEXTE_DU_BUILD_DOCKER/creer-bdd-application.sql
	# > script shell pour créer la bdd
	rm -f $CONTEXTE_DU_BUILD_DOCKER/creer-bdd-application.sh
	echo "mysql -u root -p$MARIADB_MDP_ROOT_PASSWORD < ./creer-bdd-application.sql" > $CONTEXTE_DU_BUILD_DOCKER/creer-bdd-application.sh
	# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================
	# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================
	# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================
	# docker cp ./creer-bdd-application.sql $NOM_CONTENEUR_SGBDR:. 
	# docker cp ./creer-bdd-application.sh $NOM_CONTENEUR_SGBDR:. 
	# docker exec -it $NOM_CONTENEUR_SGBDR /bin/bash < ./creer-bdd-application.sh
	# ou alors:
	# docker exec -it $NOM_CONTENEUR_SGBDR /bin/bash < ./creer-bdd-application.sh


	# > scripts sql/sh pour créer l'utilisateur applicatif
	rm -f $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sql
	echo "use mysql; " >> $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sql
	# echo "select @mdp:= PASSWORD('$MARIADB_DB_APP_USER_PWD');" >> $CONTEXTE_DU_BUILD_DOCKER./creer-utilisateur-applicatif.sql
	echo "CREATE USER '$MARIADB_DB_APP_USER_NAME'@'%' IDENTIFIED BY '$MARIADB_DB_APP_USER_PWD';" >> $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sql
	echo "GRANT ALL PRIVILEGES ON $NOM_BDD_APPLI.* TO '$MARIADB_DB_APP_USER_NAME'@'%' WITH GRANT OPTION;" >> $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sql
	
	
		# > script shell pour créer l'utilisateur applicatif
	rm -f $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sh
	echo "mysql -u root -p$MARIADB_MDP_ROOT_PASSWORD < ./creer-utilisateur-applicatif.sql" >> $CONTEXTE_DU_BUILD_DOCKER/creer-utilisateur-applicatif.sh
	
	rm -f $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sql
	echo "use mysql; " >> $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sql
	# plus facile d'appliquer les  mêmes droits aux deux utilisateurs pour commencer. donc idem pour $MARIADB_DB_MGMT_USER_NAME
	echo "-- # Plus facile d'appliquer les  mêmes droits aux deux utilisateurs pour commencer." >> $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sql
	echo "-- # Donc idem pour $MARIADB_DB_MGMT_USER_NAME" >> $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sql
	echo "GRANT ALL PRIVILEGES ON $NOM_BDD_APPLI.* TO '$MARIADB_DB_MGMT_USER_NAME'@'%' WITH GRANT OPTION;" >> $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sql

	# > script shell pour configurer l'utilisateur utilisé par le dveloppeur pour gérer la BDD applicative.
	rm -f $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sh
	echo "mysql -u root -p$MARIADB_MDP_ROOT_PASSWORD < ./configurer-utilisateur-mgmt.sql" >> $CONTEXTE_DU_BUILD_DOCKER/configurer-utilisateur-mgmt.sh
}

# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
# > construction du conteneur SERVEUR JEE  <
# >    -------------------------------     <
# >    ce conteneur est une dépendance     <
# >    -------------------------------     <
# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
# docker run -it --name $NOM_CONTENEUR_TOMCAT --rm -p $NUMERO_PORT_SRV_JEE:8080 tomcat:8.0
# docker run -it --name $NOM_CONTENEUR_TOMCAT --rm -p $NUMERO_PORT_SRV_JEE:8080 tomcat:$VERSION_TOMCAT
# docker run --name $NOM_CONTENEUR_TOMCAT -p $NUMERO_PORT_SRV_JEE:8080 tomcat:$VERSION_TOMCAT
docker run --name $NOM_CONTENEUR_TOMCAT -p $NUMERO_PORT_SRV_JEE:8080 -d tomcat:$VERSION_TOMCAT
# http://adressIP:8888/

# clear
# echo POINT DEBUG
# echo CONTENEUR TOMCAT CREE CONF DS CONTENEUR
# echo "   sudo docker exec -it ccc /bin/bash"
# read
# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
# >    construction du conteneur SGBDR     <
# >    -------------------------------     <
# >    ce conteneur est une dépendance     <
# >    -------------------------------     <
# >>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<
#



# export NOM_IMAGE_DOCKER_SGBDR=organis-action/sgbdr:v3
cd $CONTEXTE_DU_BUILD_DOCKER
clear
pwd
generer_fichiers
sudo docker build --tag $NOM_IMAGE_DOCKER_SGBDR -f ./mariadb.dockerfile $CONTEXTE_DU_BUILD_DOCKER
cd $MAISON



clear
# > créer le conteneur avec usr, et root_user
# La "--collation-server" permet de définir l'ordre lexicographique des mots formés à partir de l'alphabet définit par le jeu de caractères utilisé
# La "--character-set-server" permet de définir l'encodage et le jeu de caractères utilisé
# sudo docker run --name $NOM_CONTENEUR_MARIADB -e MYSQL_ROOT_PASSWORD=$MARIADB_MDP_ROOT_PASSWORD -e MYSQL_USER=$MARIADB_DB_MGMT_USER_NAME -e MYSQL_PASSWORD=$MARIADB_DB_MGMT_USER_PWD -p $NO_PORT_EXTERIEUR_MARIADB:3306 -v $REPERTOIRE_HOTE_BCKUP_CONF_MARIADB:/etc/mysql -d $NOM_IMAGE_DOCKER_SGBDR  --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
sudo docker run --name $NOM_CONTENEUR_MARIADB -e MYSQL_ROOT_PASSWORD=$MARIADB_MDP_ROOT_PASSWORD -e MYSQL_USER=$MARIADB_DB_MGMT_USER_NAME -e MYSQL_PASSWORD=$MARIADB_DB_MGMT_USER_PWD -p $NO_PORT_EXTERIEUR_MARIADB:3306 -d $NOM_IMAGE_DOCKER_SGBDR  --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci

#
# clear
# echo POINT DEBUG 1
# echo VERIF [REPERTOIRE_HOTE_BCKUP_CONF_MARIADB=$REPERTOIRE_HOTE_BCKUP_CONF_MARIADB]
# echo "VERIF /etc/mysql/my.cnf"
# echo "   sudo docker exec -it ccc /bin/bash"
# echo " ==>>> Maintenant, on va créer BDD et Utilisateur Applicatif."
# read
#
# exécution de la création bdd et utilisateur applicatif 
# clear
# echo POINT DEBUG 0 / creation image docker pour mariadb
# echo " ----------------------------------------------------"
# echo " VERIF [NOM_CONTENEUR_MARIADB=$NOM_CONTENEUR_MARIADB]"
# echo " ----------------------------------------------------"
# echo " VERIF [MARIADB_DB_MGMT_USER_NAME=$MARIADB_DB_MGMT_USER_NAME]"
# echo " VERIF [DB_MGMT_USER_NAME=$DB_MGMT_USER_NAME] "
# echo " VERIF [MARIADB_DB_MGMT_USER_PWD=$MARIADB_DB_MGMT_USER_PWD] "
# echo " VERIF [DB_MGMT_USER_PWD=$DB_MGMT_USER_PWD] "
# echo " --------------------------------------------------------  "
# echo " VERIF [docker images chercher => $NOM_IMAGE_DOCKER_SGBDR] "
# echo " --------------------------------------------------------  "
# read
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/creer-bdd-application.sh"
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/creer-utilisateur-applicatif.sh"
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/configurer-utilisateur-mgmt.sh"
# il faudrait re-démarrer mysqld
# docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "systemctl restart mysqld"

# pour laisser le serveur mariadb démarrer...
# sleep 7s
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "chmod +x /creer-bdd-application.sh"
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/creer-bdd-application.sh"

# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "chmod +x /creer-utilisateur-applicatif.sh"
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/creer-utilisateur-applicatif.sh"

# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "chmod +x /configurer-utilisateur-mgmt.sh"
# sudo docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c "/configurer-utilisateur-mgmt.sh"
echo ""
echo " ---------------------------------------------------------------------------------------------------- "
echo " ------------------------- "
echo " Exécuter: "
echo " ------------------------- "
echo ""
echo ""
echo ""
rm -f ./configurer-user-et-bdd-sql.sh
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"chmod +x /creer-bdd-application.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"/creer-bdd-application.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo ""
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"chmod +x /creer-utilisateur-applicatif.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"/creer-utilisateur-applicatif.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo ""
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"chmod +x /configurer-utilisateur-mgmt.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo "docker exec $NOM_CONTENEUR_MARIADB /bin/bash -c \"/configurer-utilisateur-mgmt.sh\"" >> ./configurer-user-et-bdd-sql.sh
echo " " 
sudo chmod +x ./configurer-user-et-bdd-sql.sh

echo "			" 
# echo "			sudo ./configurer-user-et-bdd-sql.sh" 
echo " " 
# echo " --------------------------------------------------------  "
# echo "   Pour créer BDD et utilisateurs SQL, exécutez:" 
# echo "			" 
# echo "			sudo ./configurer-user-et-bdd-sql.sh" 
# echo "			" 
echo " --------------------------------------------------------  "
echo " -- Installez \"HeidiSQL\" sur votre poste           ----  "
echo " -- travail 	:									   ----  "
echo " -- https://www.heidisql.com/						   ----  "
echo " -- 												   ----  "
echo " -- Avec \"HeidiSQL\", vous allez vérifier que vous  ----  "
echo " -- pouvez vous connecter à l'adressse IP $ADRESSE_IP_SGBDR sur   ----  "
echo " -- le numéro de port $NUMERO_PORT_SGBDR, avec les				   ----  "
echo " -- 2 utilisateurs suivants:						   ----  "
echo " -- 												   ----  "
echo " --------------------------------------------------------  "
echo "   - Un utilisateur SQL utilisé par l'application:"
echo "  	[nom d'utilisateur = $MARIADB_DB_MGMT_USER_NAME]"
echo "  	[mot de passe = $MARIADB_DB_MGMT_USER_PWD] "
echo "   - Un utilisateur SQL utilisé par le développeur avec HeidiSQL:"
echo "  	[nom d'utilisateur = $DB_MGMT_USER_NAME] "
echo "  	[mot de passe = $DB_MGMT_USER_PWD] "
echo "   - Vous constaterez de plus que tous les deux ont accès  "
echo "     à une bdd nommée \"$NOM_BDD_APPLI\", et ont les "
echo "     droits pour y créer / détruire une table."
echo " --------------------------------------------------------  "
echo " ---------------------------------------------------------------------------------------------------- "
# 
# avec 20 secondes d'attente, c'est bon, en général, l'exécution passe, le serveur est démarré
#
sleep 20s
# sleep 15s => testé, ce n'est pas assez.
sudo ./configurer-user-et-bdd-sql.sh
# sleep 5s
# sudo ./configurer-user-et-bdd-sql.sh
echo " --------------------------------------------------------  "
echo " --- Si la connexion pour l'un des ces  "
echo " --- utilisateurs devait échouer, ouvrez un nouveau        "
echo " --- terminal, exécutez la commande:  "
echo "			" 
echo "			sudo ./configurer-user-et-bdd-sql.sh" 
echo "			" 
echo " ---------------------------------------------------------------------------------------------------- "
read


############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################
##########################											GESTION SUDOERS												############################
############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################
############################################################################################################################################################
#
# TODO =>>> mettre à jour la configuration /etc/sudoers
rm -f $MAISON/lauriane/sudoers.ajout
# export NOM_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN=lauriane-deploiement
# export URL_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN=https://github.com/Jean-Baptiste-Lasselle/lauriane-deploiement.git
# MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME=lauriane
# MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD=lauriane
echo "" >> $MAISON/lauriane/sudoers.ajout
echo "# Allow DEPLOYEUR-MAVEN-PLUGIN to execute deployment commands" >> $MAISON/lauriane/sudoers.ajout
echo "$MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME ALL=NOPASSWD: /usr/bin/docker cp*, /usr/bin/docker restart*, /usr/bin/docker exec*, /bin/rm -rf ./$NOM_REPO_GIT_ASSISTANT_DEPLOYEUR_MVN_PLUGIN" >> $MAISON/lauriane/sudoers.ajout
echo "" >> $MAISON/lauriane/sudoers.ajout
# echo "" >> $MAISON/lauriane/sudoers.ajout
clear
echo " --- Justez avaant de toucher /etc/sudoers:  "
echo "			" 
echo "			cat $MAISON/lauriane/sudoers.ajout" 
echo "			" 
echo " ---------------------------------------------------------------------------------------------------- "
cat $MAISON/lauriane/sudoers.ajout
echo " ---------------------------------------------------------------------------------------------------- "
echo " ---------	Pressez une touche pour ajouter en fin de /etc/sudoers 							------- "
echo " ---------------------------------------------------------------------------------------------------- "
read
# cat $MAISON/lauriane/sudoers.ajout >> /etc/sudoers
# echo 'foobar ALL=(ALL:ALL) ALL' | sudo EDITOR='tee -a' visudo

# MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME=lauriane
# MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD=lauriane

# celui-ci marche, c'est testé:
cat $MAISON/lauriane/sudoers.ajout | sudo EDITOR='tee -a' visudo

clear
echo " --------------------------------------------------------  "
echo " --- De plus, l'utilisateur linux que votre plugin  "
echo " --- doit utiliser est: "
echo " --- 				 "
echo " --- 				nom d'utilisateur linux: $MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME"
echo " --- 				 "
echo " --- 				mot de passe: $MVN_PLUGIN_OPERATEUR_LINUX_USER_PWD"
echo " --- 				 "
echo " --- "
echo " --- "
echo " contenu du fichier         /etc/sudoers|grep $MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME       :"
cat /etc/sudoers|grep $MVN_PLUGIN_OPERATEUR_LINUX_USER_NAME
echo " --- "
echo " --- "
echo " --- "
echo " ---------------------------------------------------------------------------------------------------- "
read

# TODO: générer le lauriane/config.deployeur.plugin.xml

# TODO: installer le DATASDOURCE dans le serveur JEE

# # installation du $TOMCAT_HOME/conf/context.xml $CATALINA_BASE/conf/context.xml (si aucune configurationd 'hôtes virutels multiples, $CATALINE_BASE prend la valeur de $CATALINA_HOME)
# sudo docker cp $MAISON/lauriane/context.xml $NOM_CONTENEUR_TOMCAT:/usr/local/tomcat/conf
sudo docker cp $MAISON/lauriane/server.xml $NOM_CONTENEUR_TOMCAT:/usr/local/tomcat/conf

# Injection de la valeur du nom de la BDD de l'application, dans le script de création de la tabel de données de tests.
sed -i "s/VAL_NOM_BDD_APPLI/$NOM_BDD_APPLI/g" $MAISON/lauriane/create-bdd-test-data1.sql
chmod 777 $MAISON/lauriane/create-bdd-test-data1.sql
sudo docker cp $MAISON/lauriane/create-bdd-test-data1.sql $NOM_CONTENEUR_MARIADB:/root/creer-bdd-et-table-test-avec-donnees.sql
# Cette opération peut être laissée, suggérée à l'utililisateur
sudo docker exec -it $NOM_CONTENEUR_MARIADB /bin/bash -c "mysql -u root -p$MARIADB_MDP_ROOT_PASSWORD < /root/creer-bdd-et-table-test-avec-donnees.sql"



# # installation du dbcp.jar
# déjà installé de base avec tomcat 8.0
# # installation de la bonne version du connecteur jdbc, en fonction de la version de MariaDB

 # cette versiond e connecteur MariaDB / JDBC n'est comptatible qu'avec Java 8 et Java 9, pas Java 7, or c'esty Java 7 qui est installé dans le conteneur docker
# VERSION_CONNECTEUR_JDBC_MARIADB=2.2.1
VERSION_CONNECTEUR_JDBC_MARIADB=1.7.1
wget https://downloads.mariadb.com/Connectors/java/connector-java-$VERSION_CONNECTEUR_JDBC_MARIADB/mariadb-java-client-$VERSION_CONNECTEUR_JDBC_MARIADB.jar

# TODO: remplcaer automatiquement dans le fichier $MAISON/lauriane/context.xml, la valeur du nom du driver, l'adresse IP etc....

sudo docker cp ./mariadb-java-client-$VERSION_CONNECTEUR_JDBC_MARIADB.jar $NOM_CONTENEUR_TOMCAT:/usr/local/tomcat/lib


# installation de la JSTL dans le serveur (au lieu du projet) ...?
VERSION_JSTL=1.2
# wget http://central.maven.org/maven2/javax/servlet/jstl/1.2/jstl-$VERSION_JSTL.jar
# sudo docker cp ./jstl-1.2.jar $NOM_CONTENEUR_TOMCAT:/usr/local/tomcat/lib

# pour un éventuel passage en mode debug du serveur (utilisé pour: debug deploiement datasource)
# sudo docker cp $MAISON/lauriane/logging-debug.properties ciblededeploiement-composant-srv-jee:/usr/local/tomcat/conf/logging.properties
sudo docker cp $MAISON/lauriane/logging.properties ciblededeploiement-composant-srv-jee:/usr/local/tomcat/conf

# => Définit le niveau de log de l'applicationd ans le serveur jee
# NIVEAU_DE_LOG=INFO
# NIVEAU_DE_LOG=FINE
# NIVEAU_DE_LOG=FINEST
NIVEAU_DE_LOG=DEBUG
sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c "echo \"export CATALINA_OPTS=\\\"\$CATALINA_OPTS -Dorg.slf4j.simpleLogger.defaultLogLevel=$NIVEAU_DE_LOG\\\"\" >> /usr/local/tomcat/bin/setenv.sh"
 
sudo docker restart $NOM_CONTENEUR_TOMCAT


clear
echo " --------------------------------------------------------  "
echo " --- Enfin, dans le conteneur Tomcat, vous pouvez         "
echo " ---  "
echo " --- 				 "
# echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"rm -f /usr/local/tomcat/conf/context.xml\""
echo " --- vérifier le déploiement du connecteur JDBC /MARIADB: "
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"ls -all /usr/local/tomcat/lib\""
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"ls -all /usr/local/tomcat/lib|grep jdbc\""
echo " --- vérifier le déploiement du context.xml: "
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"cat /usr/local/tomcat/conf/context.xml\""
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"more /usr/local/tomcat/conf/context.xml\""
echo " --- vérifier les logs serveurs: "
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"ls -all /usr/local/tomcat/logs/\""
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"more /usr/local/tomcat/logs/catalina*.log|grep dbcp\""
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"rm -f /usr/local/tomcat/logs/catalina*.log\""
echo " --- 				sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c \"ls -all /usr/local/tomcat/logs/\""
echo " --- 				 "
echo " --- "
echo " --- "
echo " contenu du fichier  /usr/local/tomcat/conf/context.xml :"
sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c "cat /usr/local/tomcat/conf/context.xml"
echo " Bibliothèques serveur       :"
sudo docker exec -it $NOM_CONTENEUR_TOMCAT /bin/bash -c "ls -all /usr/local/tomcat/lib"
echo " --- "
echo " --- "
echo " --- "
echo " --- prochains coups d'essais: https://examples.javacodegeeks.com/enterprise-java/tomcat/tomcat-connection-pool-configuration-example/ "
echo " ---------------------------------------------------------------------------------------------------- "
read
# ----------------------------------------------------------------------------------------------------------------------------------------------
# pour consulter les logs serveur:
# --------------------------------
# sudo docker exec -it ciblededeploiement-composant-srv-jee /bin/bash -c "more /usr/local/tomcat/logs/catalina.2018-01-18.log"
# ----------------------------------------------------------------------------------------------------------------------------------------------



# ============= >>> générer les fichiers  (QUI VONT FFAIRE OBJET D'UN ADD DANS LES DOCKER COMPOSE FILE et autres DOCKERFILES) <<< =============
# ============= >>> générer les fichiers  (QUI VONT FFAIRE OBJET D'UN ADD DANS LES DOCKER COMPOSE FILE et autres DOCKERFILES) <<< =============
# ============= >>> générer les fichiers  (QUI VONT FFAIRE OBJET D'UN ADD DANS LES DOCKER COMPOSE FILE et autres DOCKERFILES) <<< =============

# ==>> donc 2 versionning:
#
#			¤¤ [VERSIONNING DE LA RECETTE] un pour le code de la recette de construction de la cible de déploiement
#			¤¤ [VERSIONNING DE LA DEPENDANCE] un repo git versionnant:
#													 + fichier docker-ompose.yml,
#													 + les fichiers dockerfiles et fichiers permettant de construire (avec un docker build par exemple) l'image customisée de chaque composant de l'infrastructure:
#													 		- [COMPOSANT SGBDR] (construire l'image mariadb avec un fichier de conf custom, permettant de changer le numéro de port):
# 																						  le fichier dockerfile: "dockerfile.lauriane={FROM mariaDB ADD ./mon.fichier.de.conf.custom RUN cp ./mon.fichier.de.conf.custom /etc/mysql/my.cnf}"
# 																						  le fichier de conf custom mariadb: "./mon.fichier.de.conf.custom"
#													 		- [COMPOSANT TOMCAT] (construire l'image mariadb avec un fichier de conf custom, permettant de changer le numéro de port)  dockerfile.lauriane={FROM mariaDB ADD ./mon.fichier.de.conf.custom RUN cp ./mon.fichier.de.conf.custom /etc/mysql/my.cnf}

 
#		et en fait, le code de la recette de déploiement effectue un checkout d'une version bien donnée du fichier docker-compose.yml
#		(et c'est là qu'est le lien entre le numéro de version de  la recette, et le numéro de version de la dépendance que constitue le fichier [docker-compose.yml])
#
# ==>> donc, en réalité, 1 repo git de versionning de la recette , et N repo git de chaque dépendance (de degré 1) de la recette.
# 
# -------------------------------------------
# le lien aux principes "the devops program":
# -------------------------------------------
#	¤¤ une dépendance de degré zéro, cest: moi-même.
#	¤¤ une dépendance de degré zéro de la recette, cest le code source de la recette elle-même.
#
#	¤¤ une dépendance de degré zéro d'une appli java, c'est le code source de l'appli java elle-même.
#	¤¤ une autre dépendance de degré zéro d'une appli java, c'est le code source/config du build de l'appli java.
#
# ------------------------------------------------------------------------------------------------------------------------------------------
#  !!!!!!!!!!!!!!!! et des roues imbriquées, petite roue dans grande roue, il y a une dimension supplémentaire avec les multiples repos GIT:
# ------------------------------------------------------------------------------------------------------------------------------------------
# Donc, dans l'arbre des dépendances, pour une dépendance de degré N: 
#  - le versionning du code source de la dépendance de degré N, mentionne le lien aux versions des dépendances de degré N+1
#  - le versionning du code source de la dépendance de degré N, permet de changer le numéro de version d'une dépendance de degré N+1 
# !!!!!!!! par exemple, pour changer le numéro de port de mariadb de la cible de déploiement
# !!!!!!!! (par config de mariadb et / ou changement de mapping docker numéro de port du conteneur docker ) :
# 		# ## ON DETRUIT LA CIBLE DE DEPLOIEMENT
# 		¤ on fait docker-compose down
# 		# ## ON EDITE DU CODE SOURCE
# 		¤ on fait une nouvelle version du fichier "docker-compose.yml" en changeant dans ce fichier le mapping du numéro de port dans le   et/ou le numéro de version checkouté pour le checkout du repo versionnant le dockerfile pour construire l'image {FROM mariaDB ADD ./mon.fichier.de.conf.custom RUN cp ./mon.fichier.de.conf.custom /etc/mysql/my.cnf} 
# 		¤ on édite sed le fichier "./docker-compose.yml", pour changer le mapping docker du numéro de port d'écoute de mariaDB avec un numéro de port exposé par le conteneur du composant SGBDR
# 		¤ on édite sed le fichier de conf custom mariadb "./mon.fichier.de.conf.custom", pour changer le numéro de port d'écoute de mariaDB ) "à l'intérieur du conteneur"
# 		# ## ON COMMIT l'un ou l'autre, ou les deux...
# 		¤ [git add "./docker-compose.yml"]
# 		¤ [git commit -m "nouveau mapping docker numéro de port mariaDB -p noportexterne=noportinterne"]
# 		¤ [git add "./mon.fichier.de.conf.custom"]
# 		¤ [git commit -m "nouveau numéro de port mariaDB noportinterne="]
# 		# ## ON TAGGUE
# 		¤ on détruit le tag ETAT_INITIAL_CIBLE_DEPLOIEMENT : [git tag -d vETAT_INITIAL_CIBLE_DEPLOIEMENT] (san détruire le commit associé au tag détruit)
# 		¤ on git taggue le commit  [git tag -a vETAT_INITIAL_CIBLE_DEPLOIEMENT -m "ETAT_INITIAL_CIBLE_DEPLOIEMENT: nouveau numéro de port etc..."] e nouvelle version du fichier 
# 		¤ on fait un git clone du repo versionnant docker-compose.yml et dockerfiles le  docker-compose.yml fait toujours référence aux images :latest comme ça on fait docker build et on refait docker-compose-up
# 		¤ on fait docker-compose up
# 		# ## IL MANQUE LA PARTIE DOKER BUILDS AVEC DOCKER COMMIT POUR VERSIONNER IMAGES MONTEES ..?
# 

# donc: versionner les docker compose file, faire des tags :
#		¤  CHANGER ADRESSE IP
#		¤  CHANGER (chaque paramètre de la cible de déploiement) ...
# en corrélation avec des :
# 		docker compose up
# 		docker compose up
#" ce qui donne un workflow:
#		¤  # edition de mon [docker-compose.yml] : 
#		¤  git add docker-compose.yml
#		¤  # edition d'un des dockerfile d'un des composants [composant-sgbdr.dockerfile] : on ajoute des directives ADD et des RUN
#		
#		¤  # pour chaque composant, il y a autant de docker file une "tour" de dockerfile qui se référencent les uns les autres avec FROM // par exemple un des docker file (et seulement ce dockerfile dans la tour) contient l'action d'appliquer un fichier custom {ADD ./fichier.custom.conf cp ./fichier.custom.conf /etc/mysql/my.cnf}
#		¤  # Donc pour chaque composant, il y a une tour de dockerfile dont la hauteur est exactement le nombre de paramètres pour la construction de la cible de déploiement. autant de docker file une "tour" de dockerfile qui se référencent les uns les autres avec FROM // par exemple un des docker file (et seulement ce dockerfile dans la tour) contient l'action d'appliquer un fichier custom {ADD ./fichier.custom.conf cp ./fichier.custom.conf /etc/mysql/my.cnf}
#		¤  # pour chaque composant, il y a une tour de dockerfile dont la hauteur est exactement le nombre de paramètres pour la construction de la cible de déploiement // par exemple un des docker file (et seulement ce dockerfile dans la tour) contient l'action d'appliquer un fichier custom {ADD ./fichier.custom.conf cp ./fichier.custom.conf /etc/mysql/my.cnf}
#		¤  git add docker-compose.yml
#		¤  git add composant-sgbdr.dockerfile
#		¤  git commit - m "ajout de la création de l'utilisateur applicatif"
#		¤  git push
#		¤  git push --tags



# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================
# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================
# ============= >>> MAIS EN FAIT IL FAUT FAIRE DE LA MACHINE A ETATS SUR VERSION DOCKER COMPOSE FILE <<< ======================================

