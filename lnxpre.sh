#!/bin/bash

 clear
 echo ""
 echo "- ------------------------------------------------------------------- -"
 echo "-                         Linux Pre Reqs "
 echo "- ------------------------------------------------------------------- -"

 fn_rc()
 {
   if [ ${?} -eq 0 ]
     then
     	 echo "OK"
     else
     	 echo "NOK"
     	 exit 100
   fi
 }

 fn_grub_version()
 {
 	 echo -e " - Testando versao do Grub : \c"
   	which grub-install > /dev/null 2>&1

   if [ ${?} -ne 0 ]
   	 then
   	 	 which grub2-install > /dev/null 2>&1
   	 	 if [ ${?} -eq 0 ]
   	 	 	 then
   	 	 	 	 sleep 1
   	 	 	 	 echo -e "grub2 -> \c"
   	 	 	 	 sleep 1
   	 	 	 	 which grub2-install
   	 	 	 	 VGRUB=2
   	 	 	 else
   	 	 	 	 echo "Versao do Grub nao identificada."
   	 	 fi
   	 else
   	 	 sleep 1
   	 	 echo -e "grub -> \c"
   	 	 sleep 1
   	 	 which grub-install
   	 	 VGRUB=1
   fi
 }


 fn_grub_config()
 {
 	 case ${VGRUB} in
     2)
       echo ""
       echo " - Configurando grub2-install."
       echo -e " - Checando arquivo \"/etc/default/grub\" :  \c"
       CHKFILE="$(ls /etc/default/grub | wc -l 2>/dev/null)"
       if [ ${CHKFILE} -eq 0 ]
       	 then
       	 	 echo "NOK - Arquivo de config nao encontrado."
       	 	 exit 10
       	 else
       	 	 sleep 1
       	 	 echo "OK - Arquivo encontrado."
           echo -e " - Executando backup de \"/etc/default/grub\" em /tmp : \c"
           sleep 1
           tar -cvf /tmp/etc_default_grub.tar /etc/default/grub > /dev/null 2>&1
           fn_rc
           
           echo -e " - Gerando novo arquivo grub : \c"
           sleep 1

           cat /etc/default/grub | grep -v GRUB_CMDLINE_LINUX >> /tmp/grub 2>/dev/null
           echo "GRUB_SERIAL_COMMAND=\"serial --unit=0 --speed=115200\"" >> /tmp/grub 2>/dev/null 
           echo "GRUB_TERMINAL=\"serial console\"" >> /tmp/grub 2>/dev/null 
           echo "GRUB_CMDLINE_LINUX=\"console=tty1 console=ttyS0,115200\"" >> /tmp/grub 2>/dev/null 
           cat /tmp/grub > /etc/default/grub 2>/dev/null

           grub2-mkconfig -o /boot/grub2/grub.cfg 2>/dev/null

           fn_rc
       fi

     ;;

     1)
       
     ;;

     *)
       echo " [ ERR ] - Versao de grub nao encontrada"
       
     ;;

   esac
 }

 fn_dracut_module()
 {
  echo -e " - Alterando dracut hostonly : \c"
  dracut -N -f > /dev/null 2>&1
  fn_rc
  echo -e " - Inserindo linha em \"/etc/dracut.conf\" : \c"
  sleep 1
  echo "hostonly=\"no\"" >> /etc/dracut.conf 2>/dev/null
  fn_rc
 }

 # Execucao
 fn_grub_version
 fn_grub_config
 fn_dracut_module

 echo ""
 echo "Fim!"
 echo ""
