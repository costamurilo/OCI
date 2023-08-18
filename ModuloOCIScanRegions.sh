#!/bin/bash
 clear
 echo ""
 fn_rc()
   {
     if [ ${?} -eq 0 ]
       then
         echo "Ok!"
         STT="OK"
       else
         echo "Nok! :\\"
         STT="NOK"
     fi
   }

 HOMEDIR="$(pwd)"
 OUT="${HOMEDIR}/instance_list.out"
 AUX="${HOMEDIR}/aux.out"
 #LISTA="/tmp/listar"
 CPTM_ID="${1}"
 REGION="$(cat ~/.oci/config | grep region | cut -f 2 -d =)"
 REGION_AVAIL="$(oci iam region-subscription list 2>/dev/null | jq -r '.data[]."region-name"' | xargs)"
 BKP="${HOMEDIR}/bkp"
 
 >${OUT}
 rm -r ${BKP}/*

 if [ -z ${BKP} ]
   then
   	 rm -r ${BKP}/* 2>/dev/null
   else
   	 echo -e " - Criando diretorio de backup em \"${BKP}\" : \c"
   	 mkdir -p ${BKP} 2>/dev/null
   	 fn_rc
 fi

 echo -e " - Informe o caminho do arquivo de configuracao do OCI CLi. Padrao - [ /root/.oci/config ] : \c"
 read ORIG

 echo -e " - Executando backup de \"${ORIG}\": \c"
 cp -p ${ORIG} ${BKP}/config_orig_$(date +%d%m%Y%H%M) 2>/dev/null
 fn_rc
 if [ ${?} -eq 0 ]
 	 then
     ORIGBKP="${BKP}/$(ls -rt ${BKP} | grep -i orig)"
     echo -e " - Backup criado com sucesso : ${ORIGBKP}"
   else
   	 echo " - Falha ao criar backup do original. Parando."
   	 exit 100
 fi
 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
 echo " - As seguintes regioes serao pesquisadas : ${REGION_AVAIL}"
 for NEW_REGION in ${REGION_AVAIL}
 do
 	 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
 	 echo ""
 	 >${AUX}
 	 echo " - Executando para a regiao : ${NEW_REGION}."
   echo -e " - Gerando arquivo de config para regiao listada : \c"
 	 cat ${ORIGBKP} | sed 's/region='${REGION}'/region='${NEW_REGION}'/g' >> ${AUX} #2>/dev/null
 	 cp  ${AUX} ${ORIG}
 	 fn_rc
 	 echo " - Arquivo gerado :"
 	 echo ""
 	 cat ${ORIG}
 	 echo ""
 	 echo -e " - Executando consultas na regiao ${NEW_REGION}. Resultado em [ ${OUT} ] : \c"
 	 oci compute instance list  --compartment-id ${CPTM_ID} --all 2>/dev/null | grep -w '\"id\":' | awk '{print $2}' | cut -f 2 -d \" >> ${OUT}
 	 fn_rc
 	 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
 done
 
 echo -e " - Restaurando arquivo de configuracao original : \c"
 cp -p ${ORIGBKP} ${ORIG} 2>/dev/null
 fn_rc
 if [ ${STT} == OK ]
 	 then
 	 	 echo " - Procedimento finalizado com sucesso!"
 	 	 rm ${BKP}/* 2>/dev/null
 	 else
 	 	 echo " - Falha ao executar processo."
 fi
