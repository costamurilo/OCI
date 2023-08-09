#!/bin/bash
 clear
 echo ""

 # Atualizacao    : 09/08/2023
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --compute
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 # Autor          : Murilo Costa (murilo.c.costa@oracle.com)
 # Funcionalidade : Script para automatizacao de stop, start, restart, etc. de OCI compute instances
 # Argumentos     : start, stop, reset, softreset, softstop, diagnosticreboot [Actions validas]
 # Sintaxe        : ./script --compute --action [Action] --OCID [Compute_OCID]
 #                : ./script --compute --action stop --OCID <OCID>
 # Funcionamento  : Basicamente o que o script faz, é ler a variavel $2 da sintaxe do comando e redirecionar como argumento para o comando de start/stop do CLI
 # Dependencias   : OCI CLi precisa estar instalado e configurado no SO onde este script ira rodar, e o usuario associado ao OCI CLi precisa possuir policies de permissionamento de gerencias das compute instances
 #                  Este script foi pensado para ser executado em um sistema operacional linux.

 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --resource
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 


 HOMEDIR="$(pwd)"
     ARG="${1}"
     LOG="${HOMEDIR}/instances_ger_log_$(date +%d%m%y).out"



 >${HOMEDIR}/aux.out

 #Funcoes


   
   # Funcao para listar todas as instancias de um compartment


   # Funcao para testar return code
   fn_rc()
   {
     if [ ${?} -eq 0 ]
       then
         echo "Ok!"
       else
         echo "Nok! :\\"
     fi
   }

   # Funcao para gerenciar computes ( reboot / stop / start )
   fn_ger()
   {
    echo -e " - Executando acao de \"${ACTION}\" : \c"
    oci compute instance action --action ${ACTION} --instance-id ${INSTANCE_OCID} 1>> ${LOG} 2>&1
    fn_rc
    echo "" >> ${LOG}
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" >> ${LOG}
    echo "" >> ${LOG}
   }

   # Funcao para exibir cabecalho
   fn_cabec()
   {
    echo ""
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo "                                                  OCI Multi"
    echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
    echo ""
   }
   
   # Funcao para criar subir para split de arquivo - Utilizado em "--out"
   fn_cria_dir()
   {
     DIR="${HOMEDIR}/${1}"
     if [ -e ${DIR} ]
       then
         echo -e " - Diretorio \"${DIR}\" existe. Limpar conteudo? [s|n] : \c"
         read RESP
         if [ ${RESP} == s ]
           then
            echo -e " - Limpando diretorio \"${DIR}\" : \c"
            rm -rf ${DIR}/* 1>/dev/null 2>&1
            fn_rc
           else
             echo " - Parando execucao!"
         fi
       else
         echo -e " - Criando diretorio \"${DIR}\" : \c"
         mkdir -p ${DIR} 1>/dev/null 2>&1
         fn_rc
     fi
   }

   # Funcao para split de arquivos
   fn_split()
   {
     split --numeric-suffixes=1 --additional-suffix=.out -l${1} ${2} lista_${OPT}_ 1>/dev/null 2>&1
   }

 ##################################################################################################################################
  if [ -z ${1} ]
   then
     fn_cabec
     echo " - Por favor utilize algum argumento."
     echo "   Caso nao conheca os argumentos, consulte a documentacao do script no corpo do script."
     echo ""
     echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
     exit 100
 fi
 ##################################################################################################################################



 case ${ARG} in
   --compute)
      
           ACTION="${3}"
    INSTANCE_OCID="${5}"
     fn_cabec
     fn_ger
     echo ""
     echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
   ;;
     #
   --resource)
     RES_ARG="${2}"
       N_ARG="${3}"
     CPTM_ID="${4}"
         OUT="${HOMEDIR}/instance_list.out"

     case ${RES_ARG} in
       --list-all-instances)
         case ${N_ARG} in
           --compartment-id)
             fn_cabec
             echo -e " - Limpando ${OUT} : \c"
             sleep 2
             > ${OUT}
             fn_rc
             echo -e " - Incrementando ${OUT} com compute OCIDs : \c"
             oci compute instance list  --compartment-id ${CPTM_ID} --all 2>/dev/null | grep -w '\"id\":' | awk '{print $2}' | cut -f 2 -d \" >> ${OUT}
             fn_rc
             echo ""
             echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
           ;;
           -t)
             fn_cabec
             echo -e " - Especifique o caminho do arquivo contendo a coluna dos compartment IDs : \c"
             read ARQUIVO
             echo ""
             echo -e " - Limpando ${OUT} : \c"
             sleep 2
             > ${OUT}
             fn_rc
             echo -e " - Incrementando ${OUT} com compute OCIDs : \c"
             for COMP_ID in $(cat ${ARQUIVO})
             do
               oci compute instance list  --compartment-id ${COMP_ID} --all 2>/dev/null | grep -w '\"id\":' | awk '{print $2}' | cut -f 2 -d \" >> ${OUT}
             done
             fn_rc
             echo ""
             echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
           ;;

           *)
             fn_cabec  
             echo " Err: Argumento \"${N_ARG}\" invalido."
           ;;
         esac
       ;;
     esac
   ;;
   --split)
     fn_cabec
     OPT="out"
     echo -e " - Por favor informe o caminho do arquivo contendo a lista de recursos : \c"
     read LISTA
     echo " - Criando subdir \"${OPT}\" em ${HOMEDIR}."
     fn_cria_dir ${OPT}
     echo -e " - Por favor informe quantas linhas deseja por arquivo : \c"
     read LINES
     echo -e " - Dividindo lista em arquivos de [${LINES}] linhas : \c"
     #split --numeric-suffixes=1 --additional-suffix=.out -l${LINES} ${LISTA} lista_ 1>/dev/null 2>&1
     fn_split ${LINES} ${LISTA}
     mv lista_${OPT}*.out ${HOMEDIR}/${OPT}/
     fn_rc | tee -a ${HOMEDIR}/aux.out
     TEST="$(cat ${HOMEDIR}/aux.out | cut -f 1 -d \!)"
     if [ ${TEST} == Nok ]
       then
         echo " - Parando!"
       else
         echo -e " - Arquivos gerados : \c"
         ls -lrt ${HOMEDIR}/${OPT} | grep -vw total | awk '{ print $NF }' | xargs
     fi
     echo ""
     echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

   ;;
   --delete)
     DELARG="${2}"
     case ${DELARG} in
       --generate)
         OPT="del"
         DEL_LIST="${HOMEDIR}/${OPT}/delete_list.out"
         fn_cabec
         echo -e " - Criando diretorio \"${OPT}\" em ${HOMEDIR} : \c"
         fn_cria_dir ${OPT}

         echo -e " - Por favor informe o caminho do arquivo contendo a lista de recursos : \c"
         read LISTA
         
         echo -e " - Gerando lista com comandos de delete : \c"
         for LINE in $(cat ${LISTA})
         do
           echo "oci compute instance terminate --instance-id ${LINE} --force" >> ${DEL_LIST}
         done
         fn_rc

         echo -e " - Por favor informa quantas linhas deseja por arquivo dividido : \c"
         read LINES

         echo -e " - Dividindo lista em arquivos de [${LINES}] linhas : \c"
         fn_split ${LINES} ${DEL_LIST}
         mv lista_${OPT}*.out ${HOMEDIR}/${OPT}/
         fn_rc | tee -a ${HOMEDIR}/aux.out
         TEST="$(cat ${HOMEDIR}/aux.out | cut -f 1 -d \!)"
         if [ ${TEST} == Nok ]
           then
             echo " - Parando!"
           else
             echo -e " - Arquivos gerados : \c"
             ls -lrt ${HOMEDIR}/${OPT} | grep -vw total | awk '{ print $NF }' | xargs
         fi
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

       ;;
     esac
   ;;

     #
   *)
   
   ;;
     #
 esac
