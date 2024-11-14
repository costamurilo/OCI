#!/bin/bash

 # Criado por : Murilo Costa
 # Email : murilo.c.costa@oracle.com
 # Data : 17/02/2023 


 # Pre requisitos
 # Criar vg com minimo de 700GB
 # Script interativo.
 # Executar estes comandos antes de executar o script
 # mkdir -p /tmp/sg
 # cd /tmp/sg
 # echo "/ocisg          ocisg    10 " >> /tmp/sg/lista.lst
 # echo "/ocisg/cache    cache    500" >> /tmp/sg/lista.lst
 # echo "/ocisg/metadata metadata 100" >> /tmp/sg/lista.lst
 # echo "/ocisg/log      log      30 " >> /tmp/sg/lista.lst

 # Instalacao do Storage gateway
 # Filesystem da instacao : /ocisg
 # Filesystem do cache    : /ocisg/cache
 # Filesystem do metadata : /ocisg/metadata
 # Filesystem do log      : /ocisg/log


 # Set de variaveis

 HOMEDIR="/tmp/sg"
   LISTA="${HOMEDIR}/lista.lst"
    NAME="ocisg cache metadata log"
     FSS="/ocisg /ocisg/cache /ocisg/metadata /ocisg/log"

 ######################################################################################################################
 clear

 # Funcoes
 fn_rc(){
 	     if [ ${?} -eq 0 ]
 	     	 then
 	     	 	 echo "OK"
 	     	 else
 	     	 	 echo "NOK"
 	     fi
 }

 val_vg(){
 	   echo " Validando VG \"${VGNAME}\" "
 	   sleep 1

 	   VALIDA="$(vgs | grep -w ${VGNAME} | wc -l)"
 	   if [ ${VALIDA} -eq 0 ]
 	     then
 	     	 echo ""
 	     	 echo " Vg \"${VGNAME}\" inexistente."
 	     	 sleep 1
 	     	 echo ""
 	     	 echo -e " Verifique o nome do VG e digite novamente.\c"
 	     	 sleep 1
 	     	 echo " Fim! "
 	     	 exit 100
 	     else
 	     	 VGSIZE="$(vgs | grep -w ${VGNAME} | awk '{ print $6 }' | cut -f 2 -d \< | cut -f 1 -d .)"
 	     	 if [ ${VGSIZE} -gt 700 ]
 	     	 	 then
 	     	 	 	 echo " Volume do VG \"${VGNAME}\" OK! [ ${VGSIZE} ]"
 	     	 	 	 sleep 1
    	     	 echo " VG \"${VGNAME}\" validado!"
    	     	 sleep 1
 	     	     echo ""
 	     	   else
 	     	   	 echo " Volume do VG \"${VGNAME}\" insuficiente : [ ${VGSIZE} ] "
 	     	   	 echo " Para continuar utilize um VG com pelo menos 700GB."
 	     	   	 echo " Fim."
 	     	   	 #exit 200
 	     	 fi
 	   fi
 }

 val_dir(){
         echo ""
         echo " Checando se o dir [/tmp/sg ] existe : "
         sleep 1
         DIR="/tmp/sg"
         if [  -e ${DIR} ]
           then
           	 echo " Diretorio [ /tmp/sg ] existente."
           	 sleep 1
           	 echo  -e " Limpando diretorio : \c"
           	 unalias rm > /dev/null 2>&1
           	 rm -f ${DIR}/* > /dev/null 2>&1
           	 sleep 1
           	 fn_rc
           else
           	 echo " Diretorio [ /tmp/sg ] nao existente."
           	 echo  -e " Criando diretorio : \c"
           	 mkdir -p /tmp/sg > /dev/null 2>&1
           	 fn_rc
         fi

 }

 ######################################################################################################################
 # Execucao do script
 
 # Valida o diretorio /tmp/sg
 val_dir

 echo ""
 vgs
 echo ""

 echo -e " Digite o nome do VG onde a estrutura do Storage Gateway deve ser criado : \c"
 read VGNAME
 echo ""
 
 # Valida o tamanho do VG
 val_vg

 # Coleta o tamanho desejado de cada filesystem

 echo -e " Digite o tamanho desejado para o Filesystem \"/ocisg\" [ 10 ] : \c"
 read OCISG_SIZE
 if [ -z ${OCISG_SIZE} ]
 	 then
 	 	 OCISG_SIZE="10"
 fi

 echo -e " Digite o tamanho desejado para o Filesystem \"/ocisg/cache\" [ 500 ] : \c"
 read OCISG_CACHE_SIZE
 if [ -z ${OCISG_CACHE_SIZE} ]
 	 then
 	 	 OCISG_CACHE_SIZE="500"
 fi

 echo -e " Digite o tamanho desejado para o Filesystem \"/ocisg/metadata\" [ 100 ] : \c"
 read OCISG_METADATA_SIZE
 if [ -z ${OCISG_METADATA_SIZE} ]
 	 then
 	 	 OCISG_METADATA_SIZE="100"
 fi

 echo -e " Digite o tamanho desejado para o Filesystem \"/ocisg/log\" [ 30 ] : \c"
 read OCISG_LOG_SIZE
 if [ -z ${OCISG_LOG_SIZE} ]
 	 then
 	 	 OCISG_LOG_SIZE="30"
 fi

 echo ""
 # --------------------------------------------------------------------------------------------------------------------





 # Criacao dos LVs
 echo " - Criando estrutura de Filesystem do Storage Gateway"
 echo ""

 for LV in ${NAME}
 do
   case ${LV} in
   	 ocisg)
       echo " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L${OCISG_SIZE}G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
       
     ;;

     cache)
       echo  " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L${OCISG_CACHE_SIZE}G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
       
     ;;

       metadata)
       echo  " - Criando LV lv_sg_${LV}  "
       sleep 1
       lvcreate -y -L${OCISG_METADATA_SIZE}G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
       
     ;;

       log)
       echo  " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L${OCISG_LOG_SIZE}G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
       
     ;;

     *)
       echo " - Opcao desconhecida."
     ;;
   esac
 done
 
 echo ""
 echo " - Criando estrutura de filesystems"
 echo ""

 # Criacao dos mountpoints / mountagem dos FS / composicao do fstab
 for FS in ${FSS}
 do
   case ${FS} in
   	 /ocisg)
       echo  " - Criando FS ${FS}  "
       sleep 1
       mkdir -p ${FS} > /dev/null 2>&1
       unset LV
       LV="/dev/mapper/${VGNAME}-lv_sg_ocisg"
       mount ${LV} ${FS}  > /dev/null 2>&1
       

       echo  " - Compondo /etc/fstab  "
       $(echo "/dev/mapper/${VGNAME}-lv_sg_ocisg    ${FS}    xfs    defaults 0  0" >> /etc/fstab)
       echo ""
     ;;

     /ocisg/cache)
       echo  " - Criando FS ${FS}  "
       sleep 1
       mkdir -p ${FS} > /dev/null 2>&1
       unset LV
       LV="/dev/mapper/${VGNAME}-lv_sg_cache"
       mount ${LV} ${FS} 
       

       echo  " - Compondo /etc/fstab  "
       $(echo "/dev/mapper/${VGNAME}-lv_sg_cache    ${FS}    xfs    defaults 0  0" >> /etc/fstab)
       echo ""
       
     ;;

       /ocisg/metadata)
       echo  " - Criando FS ${FS}  "
       sleep 1
       mkdir -p ${FS} > /dev/null 2>&1
       unset LV
       LV="/dev/mapper/${VGNAME}-lv_sg_metadata"
       mount ${LV} ${FS} > /dev/null 2>&1
       

       echo  " - Compondo /etc/fstab  "
       $(echo "/dev/mapper/${VGNAME}-lv_sg_metadata    ${FS}    xfs    defaults 0  0" >> /etc/fstab)
       echo ""
       
     ;;

       /ocisg/log)
       echo  " - Criando FS ${FS}  "
       sleep 1
       mkdir -p ${FS} > /dev/null 2>&1
       unset LV
       LV="/dev/mapper/${VGNAME}-lv_sg_log"
       mount ${LV} ${FS} > /dev/null 2>&1
       

       echo  " - Compondo /etc/fstab  "
       $(echo "/dev/mapper/${VGNAME}-lv_sg_log    ${FS}    xfs    defaults 0  0" >> /etc/fstab)
       echo ""
       
     ;;

     *)
       echo " - Opcao desconhecida."
     ;;
   esac
 done
 
 echo ""
 echo ""
 echo ""

 df -hPT 

 echo ""
 echo ""
 echo " Fim! "
