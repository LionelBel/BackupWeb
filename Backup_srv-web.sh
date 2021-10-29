#!/bin/bash

## Script de sauvegarde du serveur web WordPress sous Linux Debian 10 sur serveur ftp ####

### Pré-recquis : installation de lftp pour l'envoi des sauveagardes au serveur ftp

### Information du serveur stp ###
hostname=srv-ftp
ftp_srv=192.168.56.108
user_ftp=ftpuser
pass_ftp=pass

### Rotation des backup (2 jours) ###
rotation='date +%d-%m-%Y --date='2 day ago''

### Date du jour ###
date="$(date +%d-%m-%Y)"

##########################################
### Sauvegarde du répertoire WordPress ###
##########################################
# Définition des variables
source="/var/www/html/wordpress"
name='basename $source'
dest="/home/manager/backup" # Répertoire de backup local

# Création du répertoire de backup local
[! -d $dest] && mkdir -p $dest

echo " Répertoire à sauvegarder : $source "

# Copie du répertoire WordPress
echo " Copie du repertoire : $name, dans le répertoire backup local "
cp -r $source $dest/$name-$date
#tar czf $dest/$name-$date.tar.gz -C $source/..$hostname

# Envoi de l'archive sur le serveur ftp
# echo " Envoi des fichier sur $hostname "
#lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "mirror -e -R $dest /home/ftpuser/ftp_dir/wordpress/$date;quit"

# Rotation des backup
#lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "rm -rf $rotation;quit"

# Suppression du repertoire de backup local
# rm -fr $dest
# echo " Sauvegarde répertoire WordPress terminée "

#########################################
### Sauvegarde bases de données MySQL ###
#########################################
# Définition des variables
mysql_user=root
name_mysql="msql"

# Backup de  la bases de donnée wordpress et création de l'archive
echo " Sauvegarde de la base de donnée : wordpress "
mysqldump --user=$mysql_user --databases wordpress > $dest_mysql/$name_mysql-$date.sql.gz

# Envoi de l'archive sur le serveur ftp
# echo " Envoi des fichier sur $hostname "
# lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "mirror -e -R $dest_mysql /home/ftpuser/ftp_dir/mysql/$date;quit"

# Rotation des backup
# lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "rm -rf $rotation;quit"

# Suppression du repertoire de backup local
# rm -fr $dest_mysql
# echo " Sauvegarde répertoire WordPress terminée "

########################################################################
### Sauvegarde des fichiers de configuration de Apache, MySQL et PHP ###
########################################################################
# Définition des variables
source1="/etc/apache2"
source2="/etc/mysql"
source3="/etc/php"
name_conf_apache="apacheconf"
name_conf_mysql="mysqlconf"
name_conf_php="phpconf"
				#####################
echo " Sauvegarde des fichiers de configuration Apache2 "
cp -r $source1 $dest/$name_conf_apache-$date
				######################
echo " Sauvegarde des fichiers de configuration MySQL "
cp -r $source2 $dest/$name_conf_mysql-$date
				######################
echo " Sauvegarde des fichiers de configuration PHP "
cp -r $source3 $dest/$name_conf_php-$date

#############################################
### Envoi des archives sur le serveur ftp ###
#############################################
