#!/bin/bash

 # Criado por : Murilo Costa
 # Email : murilo.c.costa@oracle.com
 # Data : 17/02/2023 
 # Script usado para criar estrutura de filesystems para instalação do OCI Storage Gateway

 # Pre requisitos
 # Executar passos do fdisk
 # Executar passos de criação do VG vg_data #####


 mkdir -p /tmp/sg #> /dev/null 2>&1
 echo "/data          vg_data    140 " >> /tmp/sg/lista.lst

 # Set de variaveis

 HOMEDIR="/tmp/sg"
   LISTA="${HOMEDIR}/lista.lst"
    NAME="$(cat ${LISTA}  | awk '{ print $2 }' | cut -f 2 -d _)"
     FSS="$(cat /tmp/sg/lista.lst | awk '{ print $1 }')"


 clear

 val_vg(){

 	   VALIDA="$(vgs | grep -w ${VGNAME} | wc -l)"
 	   if [ ${VALIDA} -eq 0 ]
 	     then
 	     	 echo ""
 	     	 echo " Vg \"${VGNAME}\" inexistente."
 	     	 echo ""
 	     	 echo -e " Verifique o nome do VG e digite novamente.\c"
 	     	 exit 100
 	     else
 	     	 echo " VG \"${VGNAME}\" validado!"
 	     	 echo ""
 	   fi
 }

 # Execucao do script
 echo ""
 vgs
 echo ""

 echo -e " Digite o nome do VG onde a estrutura da aplicacao deve ser criada : \c"
 read VGNAME

 echo ""
 val_vg
 echo ""

 # Criacao dos LVs
 echo " - Criando estrutura do data"
 echo ""

 echo " - Criando LV lv_${NAME} "
 sleep 1
 lvcreate -y -L$(cat /tmp/sg/lista.lst | awk '{ print $3 }')G -n lv_${NAME} ${VGNAME} > /dev/null 2>&1
 mkfs.ext4 /dev/mapper/${VGNAME}-lv_${NAME}  > /dev/null 2>&1
 
 
 echo ""
 echo " - Criando estrutura de filesystems"
 echo ""

 # Criacao dos mountpoints / mountagem dos FS / composicao do fstab

 echo  " - Criando FS ${FSS}  "
 sleep 1
 mkdir -p ${FSS} > /dev/null 2>&1
 #unset LV
 #LV="/dev/mapper/${VGNAME}-lv_data"
 
       
 echo  " - Compondo /etc/fstab  "
 $(echo "/dev/mapper/${VGNAME}-lv_data    ${FSS}    ext4    defaults 0  2" >> /etc/fstab)

 mount /data  #> /dev/null 2>&1
 echo ""
 
 
 echo ""
 echo ""
 echo ""

 df -hPT 

 echo ""
 echo ""
 echo " Fim! "
