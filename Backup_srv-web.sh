#!/bin/bash

## Script de sauvegarde du serveur web WordPress sous Linux Debian 10 sur serveur ftp ####

### Information du serveur stp ###
hostname=srv-ftp
ftp_srv=192.168.56.108
user_ftp=ftpuser
pass_ftp=pass

### Rotation des backup (2 jours) ###
rotation='date + %d-%m-%Y --date='2 day ago''

### Date du jour ###
date="$(date +"%d-%m-%Y")"

##########################################
### Sauvegarde du répertoire WordPress ###
##########################################
# Définition des variables
source="/var/www/html/wordpress"
name='basename $source-$date'
dest="/home/manager/backup/wordpress" # Répertoire de backup local

# Création du répertoire de backup local
[! -d $dest] && mkdir -p $dest

echo " Répertoire à sauvegarder : $source "

# Création de l'archive
echo " Création de l'archive : $name-$date "
tar czf $dest/$name-$date.tar.gz -C $source/..$hostname

# Envoi de l'archive sur le serveur ftp
echo " Envoi des fichier sur $hostname "
lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "mirror -e -R $dest /home/ftpuser/ftp_dir/wordpress/$date;quit"

# Rotation des backup
lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "rm -rf $rotation;quit"

# Suppression du repertoire de backup local
rm -fr $dest
echo " Sauvegarde répertoire WordPress terminée "

#########################################
### Sauvegarde bases de données MySQL ###
#########################################
# Définition des variables
mysql_user=root
name_mysql="msql-$date"
dest_mysql="/home/manager/backup/mysql" # Répertoire de backup local

# Création du répertoire de backup local
[! -d $dest_mysql] && mkdir -p $dest_mysql

# Backup de  la bases de donnée WordPress et création de l'archive
echo " Sauvegarde de la base de donnée : wordpress et Création de l'archive : $name_mysql "
mysqldump --user=$mysql_user --databases wordpress | gzip > $dest_mysql/$name_mysql.sql.gz

# Envoi de l'archive sur le serveur ftp
echo " Envoi des fichier sur $hostname "
lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "mirror -e -R $dest_mysql /home/ftpuser/ftp_dir/mysql/$date;quit"

# Rotation des backup
lftp ftp://$user_ftp:$pass_ftp@$ftp_srv -e "rm -rf $rotation;quit"

# Suppression du repertoire de backup local
rm -fr $dest_mysql
echo " Sauvegarde répertoire WordPress terminée "

