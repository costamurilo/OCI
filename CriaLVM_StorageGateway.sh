#!/bin/bash

 # Criado por : Murilo Costa
 # Email : murilo.c.costa@oracle.com
 # Data : 17/02/2023 
 # Script usado para criar estrutura de filesystems para instalação do OCI Storage Gateway

 # Pre requisitos
 # Criar vg com minimo de 700GB
 # Script interativo.
 # Executar estes comandos antes de executar o script
 # mkdir -p /tmp/sg
 # cd /tmp/sg
 # echo "/ocisg          ocisg    1 " >> /tmp/sg/lista.lst
 # echo "/ocisg/cache    cache    500" >> /tmp/sg/lista.lst
 # echo "/ocisg/metadata metadata 80" >> /tmp/sg/lista.lst
 # echo "/ocisg/log      log      20 " >> /tmp/sg/lista.lst

 # Instalacao do Storage gateway
 # Filesystem da instacao : /ocisg
 # Filesystem do cache    : /ocisg/cache
 # Filesystem do metadata : /ocisg/metadata
 # Filesystem do log      : /ocisg/log


 # Set de variaveis

 HOMEDIR="/tmp/sg"
   LISTA="${HOMEDIR}/lista.lst"
    NAME="$(cat ${LISTA}  | awk '{ print $2 }')"
     FSS="$(cat lista.lst | awk '{ print $1 }')"

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

 echo -e " Digite o nome do VG onde a estrutura do Storage Gateway deve ser criado : \c"
 read VGNAME

 echo ""
 val_vg
 echo ""

 # Criacao dos LVs
 echo " - Criando estrutura de Filesystem do Storage Gateway"
 echo ""

 for LV in ${NAME}
 do
   case ${LV} in
   	 ocisg)
       echo " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L10G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
     ;;

     cache)
       echo  " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L500G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
     ;;

       metadata)
       echo  " - Criando LV lv_sg_${LV}  "
       sleep 1
       lvcreate -y -L100G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
       mkfs.xfs /dev/mapper/${VGNAME}-lv_sg_${LV} -f > /dev/null 2>&1
     ;;

       log)
       echo  " - Criando LV lv_sg_${LV} "
       sleep 1
       lvcreate -y -L30G -n lv_sg_${LV} ${VGNAME} > /dev/null 2>&1
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
