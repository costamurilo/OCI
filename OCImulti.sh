#!/bin/bash
 clear
 echo ""

 # Atualizacao    : 11/08/2023

 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --compute
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 # Finalidade      : Script multi funções para automatizacao de stop, start, restart, etc. de OCI compute instances, gerar relatórios com OCID de computes, split de listas, 
 #                   e delete de instances.
 #                     
 # Dependencias    : OCI CLi precisa estar instalado e configurado no SO onde este script ira rodar, e o usuario associado ao OCI CLi precisa possuir policies de permissionamento de gerencias das compute instances
 #                  Este script foi pensado para ser executado em um sistema operacional linux.
 #
 # Sintaxe         : OCImulti.sh --action [Action] --OCID [Compute_OCID]
 #
 # Exemplo         : OCImulti.sh --action stop --OCID <OCID>
 #
 # Actions validas : start, stop, reset, softreset, softstop, diagnosticreboot
 #
 # Funcionamento   : Basicamente o que o script faz, é ler a variavel $2 da sintaxe do comando e redirecionar como argumento para o comando de start/stop do CLI
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --list-all-instances
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 # Finalidade      : Listar os OCIDs de compute instances contidas dentro de um ou mais compartments especificado(s) pelo usuario e compor um arquivo com estas informacoes. 
 #                   Pode tambem redirecionar a saida completa da consulta para o arquivo.
 #
 # Dependencias    : OCI CLi precisa estar instalado e configurado no SO onde este script ira rodar, e o usuario associado ao OCI CLi precisa possuir policies de permissionamento de gerencias das compute instances
 #                   Este script foi pensado para ser executado em um sistema operacional linux.
 #                   Este argumento somente pode ser utilizado acompanhado de um ou mais argumentos, conforme segue :
 #
 # Argumentos      :
 #                 --compartment-id
 #                                   Utilize este argumento para especificar o compartment OCID onde deseja executar a consulta.
 #                                   Este argumento direciona somente o OCID das computes para o arquivo de saida.
 #                       Exemplo:
 #                                   OCImulti.sh --list-all-instances --compartiment-id <Compartment OCID>
 #                  -t
 #                                   Utilize este argumento para informar ao script um arquivo contendo um compartment OCID ou mais. 
 #                                   Este argumento e interativo. Sera necessario informar ao script o caminho e nome do arquivo contendo a lista de compartments OCID.
 #                       Exemplo:
 #                                   OCImult.sh --list-all-instances -t
 #                                   
 #
 #                 --all
 #                                    Se utilizado em conjunto com os argumentos "--compartment-id" ou "-t", redireciona a saida completa ( Com todas as informacoes ) da 
 #                                    consulta para o arquivo de saida.
 #                                    Caso seja utilizado com o argumento '-t', a execucao sera interativa, necessitando informar o caminho com a lista de compartment OCID.
 #                       Exemplo:
 #                                    OCImulti.sh --list-all-instances -all
 #                                    OCImulti.sh --list-all-instances -t -all
 #                     
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --split
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 # Finalidade      : Quebrar um arquivo de saida extenso em varios arquivos menores para facilitar a carga de trabalho.
 #                   Pode ser necessario antes de alguma consulta extensa para diminuir o tempo de resposta das consultas.
 #
 # Observacoes     : O home do script OCImulti sempre sera o diretorio corrente onde o mesmo esta sendo executado.
 #                   O argumento "--split" e interativo e devera interagir da seguinte maneira :
 #                     1 - Pedira para informar onde se encontra o arquivo com as informacoes a serem divididas;
 #                     2 - Informara a criacao do subdiretorio "out" dentro do home ( ou seja, dentro de onde o script esta sendo executado. );
 #                     3 - Caso o script esteja sendo re-executado e o diretorio "out" ja exista ele pergunta se deve limpar o conteudo;
 #                         Caso opte por nao limpar o conteudo, o script sera encerrado;
 #                     4 - Pedira para informar quantas linhas cada arquivo de saida devera ter;
 #                     5 - Informa a divisao dos arquivos;
 #                     6 - Informa a conclusao do processo exibindo o local onde os arquivos foram gerados e seus nomes.
 #
 # Argumentos      : Nao possui argumentos.
 #
 #                   Os arquivos serao gerados no seguinte formato : lista_out_nº.out.
 #                   Durante a executacao deste processo, o arquivo "aux.out" é gerado como apoio de status de execucao do processo. O mesmo e limpo a cada execucao do script.
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 #                                                                   --delete
 # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
 # Finalidade      : Gerar scripts com os comandos para deleção de compute instances, e caso necessario executar os scripts de delecao de compute instances.
 #      
 # Observacoes     : O argumento "--delete" sempre devera ser utilizado acompanhado de um ou mais argumentos.
 #                   O argumento "--delete" e interativo e devera interagir da seguinte maneira :
 #                     1 - Informara a criacao do subdiretorio "del" dentro do home ( ou seja, dentro de onde o script esta sendo executado. );
 #                     2 - Caso o script esteja sendo re-executado e o diretorio "del" ja exista ele pergunta se deve limpar o conteudo;
 #                         Caso opte por nao limpar o conteudo, o script sera encerrado;
 #                         Caso opte por limpar, informara a limpeza com sucesso;
 #                     3 - Pedira o caminho do arquivo contendo a lista de recusros ( OCIDs ) a serem considerados para gerar o script com os comandos de delecao;
 #                         Caso o arquivo esteja no mesmo diretorio do script, basta digitar o nome do arquivo;
 #                     4 - Informara o status da geracao da lista completa com os comandos de delecao;
 #                     5 - O split ( divisao ) dos scripts com comandos de delecao e automatico. O script devera perguntar quantas linhas deseja em cada arquivo;
 #                     6 - O script devera informar o status da geracao dos scrits informando a quantidade de linhas escolhas no campo "[n°]";
 #                     7 - O script informa a conclusao do processo exibindo o local e os scripts gerados.
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
   --list-all-instances)
       N_ARG="${2}"
     CPTM_ID="${3}"
         OUT="${HOMEDIR}/instance_list.out"
     if [ -z ${2} ]
       then
         fn_cabec
         echo " Err.: O argumento \"--list-all-instances\" precisa ser utilizado em conjunto com outro argumento."
         echo "       Argumentos:"
         echo ""
         echo "                -t       Use para apontar um arquivo contendo uma lista em modo coluna dos compartment OCIDs."
         echo "                --all    Usado em conjunto com "-t" envia a saida completa da consulta para o arquivo de saida"
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
         exit 100
     fi
     case ${N_ARG} in
       --compartment-id)
         if [ -z ${4} ]
           then
             if [ -z ${3} ]
               then
                 fn_cabec
                 echo " Err.: Forneca o Compartment OCID para que a consulta seja executada."
                 echo " "
                 echo " Sintaxe:"
                 echo "         OCImulti.sh --list-all-instances --compartment-id <compartment ocid>"
                 echo ""
                 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
                 exit 100
             fi
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
           else
             if [ ${4} == --all ]
               then
                 fn_cabec
                 echo -e " - Limpando ${OUT} : \c"
                 sleep 2
                 > ${OUT}
                 fn_rc
                 echo -e " - Incrementando ${OUT} com compute INFOs : \c"
                 oci compute instance list  --compartment-id ${CPTM_ID} --all 2>/dev/null >> ${OUT}
                 fn_rc
                 echo ""
                 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
               else
                 fn_cabec
                 echo "Err.: Argumento \"${4}\" invalido."
                 echo ""
                 echo "Sintaxe:"
                 echo "       OCImulti.sh --list-all-instances --compartiment-id <compartment ocid> --all"
                 echo ""
                 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
             fi
         fi
       ;;
       -t)
         if [ -z ${3} ]
           then
             fn_cabec
             echo -e " - Especifique o caminho do arquivo contendo a coluna dos compartment OCIDs : \c"
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
           else
             if [ ${3} == --all ]
               then
                 fn_cabec
                 echo -e " - Especifique o caminho do arquivo contendo a coluna dos compartment OCIDs : \c"
                 read ARQUIVO
                 echo ""
                 echo -e " - Limpando ${OUT} : \c"
                 sleep 2
                 > ${OUT}
                 fn_rc
                 echo -e " - Incrementando ${OUT} com compute OCIDs : \c"
                 for COMP_ID in $(cat ${ARQUIVO})
                 do
                   oci compute instance list  --compartment-id ${COMP_ID} --all 2>/dev/null >> ${OUT}
                 done
                 fn_rc
                 echo ""
                 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
               else
                 fn_cabec
                 echo "Argumento \"${3}\" invalido."
                 echo ""
                 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"

             fi
         fi
       ;;
        #
       *)
         fn_cabec
         echo " - Argumento \"${N_ARG}\" invalido."
         echo "   Caso nao conheca os argumentos, consulte a documentacao do script no corpo do script."
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
         exit 100
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
     fn_split ${LINES} ${LISTA}
     mv lista_${OPT}*.out ${HOMEDIR}/${OPT}/
     fn_rc | tee -a ${HOMEDIR}/aux.out
     TEST="$(cat ${HOMEDIR}/aux.out | cut -f 1 -d \!)"
     if [ ${TEST} == Nok ]
       then
         echo " - Parando!"
       else
         echo -e " - Arquivos gerados em ${HOMEDIR}/${OPT} : \c"
         ls -lrt ${HOMEDIR}/${OPT} | grep -vw total | awk '{ print $NF }' | xargs
     fi
     echo ""
     echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
   ;;
   --delete)
     if [ -z ${2} ]
       then
         fn_cabec
         echo " Err.: Utilize o argumento "--delete" juntamente com outros argumentos. "
         echo " "
         echo " Sintaxe:"
         echo "         OCImulti.sh --delete --generate"
         echo "         OCImulti.sh --delete --exec"
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
         exit 100
     fi
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
         chmod 755 ${HOMEDIR}/${OPT}/lista_${OPT}*.out 2>/dev/null
         fn_rc | tee -a ${HOMEDIR}/aux.out
         TEST="$(cat ${HOMEDIR}/aux.out | cut -f 1 -d \!)"
         if [ ${TEST} == Nok ]
           then
             echo " - Parando!"
           else
             echo -e " - Arquivos gerados em \"${HOMEDIR}/${OPT}/\" : \c"
             ls -lrt ${HOMEDIR}/${OPT} | grep -vw total | awk '{ print $NF }' | xargs
         fi
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
       ;;
       --exec)
         f
       ;;
       *)
         fn_cabec
         echo " - Argumento \"${DELARG}\" invalido."
         echo " - Por favor utilize algum argumento valido!"
         echo "   Caso nao conheca os argumentos, consulte a documentacao do script no corpo do script."
         echo ""
         echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
         exit 100
       ;;
     esac
   ;;

     #
   *)
     fn_cabec
     echo " - Argumento \"${ARG}\" invalido."
     echo " - Por favor utilize algum argumento valido!"
     echo "   Caso nao conheca os argumentos, consulte a documentacao do script no corpo do script."
     echo ""
     echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
     exit 100
   ;;
    #
 esac
