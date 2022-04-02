#!/bin/bash
# Criado: Tácio de Jesus Andrade - tacio@multiti.com
# Data: 30-05-2016
# Ultima modificação: 02/04/2022
# Função: Script que executa o backup do mysql e comacta com 7zip
# Informações: Antes de executar esse script tenha instalado os pacotes p7zip-full e o mysql-client,
#              além disso, crie um usuário no Mysql ou MariaDB apenas para leitura com o comando:
# mysql> grant select privileges on *.* to user 'backup'@'%' identified by 'senha';
# mysql> flush privileges;
# OU
# MariaDB> CREATE USER 'backup'@'localhost' IDENTIFIED BY 'L*5eqWj8';
# MariaDB> GRANT LOCK TABLES, SELECT, PROCESS ON *.* TO 'backup'@'localhost';
# MariaDB> FLUSH PRIVILEGES;

# Variaveis do usuario e senha do Mysql
USER=backup
PASSWORD=senha
# Variaveis de arquivos
LOG="/var/log/BackupMysql.log"
BACKUP="/home/backup/`date +%d`/"

echo "Backup iniciado `date`" > $LOG

# Deleta o backup antigo
rm -rf $BACKUP/*.7z 2> /dev/null

echo "Inicio da exportacao dos bancos `date`" >> $LOG

# Lista os bancos de dados
mysql -u$USER -p$PASSWORD -e "show databases" | cut -d ' ' -f1 | sed '1d' > /tmp/bancos.txt

# Comando que executa os dumps dos bancos de dados
while read banco; do
  mysqldump -u$USER -p$PASSWORD $banco > $BACKUP/$banco.sql 2>> $LOG
done < /tmp/bancos.txt

echo "Fim da exportacao dos bancos `date`" >> $LOG

echo "Inicio da compressao dos bancos `date`" >> $LOG

# Verifica se o diretório de backup existe, caso não exista, cria
if [ ! -d "$BACKUP" ]; then
	mkdir -p $BACKUP
fi

cd $BACKUP

# Compacta os bancos
for i in *.sql ; do
	7za a -t7z -m0=lzma -mx=9 -mfb=64 -md=32m -ms=on $BACKUP/$i.7z $BACKUP/$i > /dev/null
done

# Deleta o banco sem ser compactado
rm -fr $BACKUP/*.sql
rm /tmp/bancos.txt

echo "Fim da compressao dos bancos `date`" >> $LOG

# Escreve no arquivo de log o tamanho de cada arquivo da pasta
ls -lh $BACKUP >> $LOG

echo "Backup finalizado `date`" >> $LOG
