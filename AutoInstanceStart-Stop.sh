#!/bin/bash


 # Atualizacao    : 03/08/2023
 # Autor          : Murilo Costa (murilo.c.costa@oracle.com)
 # Funcionalidade : Script para automatizacao de stop, start, restart, etc. de OCI compute instances
 # Argumentos     : start, stop, reset, softreset, softstop, diagnosticreboot [Actions validas]
 # Sintaxe        : ./script --action [Action] --OCID [Compute_OCID]
 #                : ./script --action stop --OCID <OCID>
 # Funcionamento  : Basicamente o que o script faz, é ler a variavel $2 da sintaxe do comando e redirecionar como argumento para o comando de start/stop do CLI
 # Dependencias   : OCI CLi precisa estar instalado e configurado no SO onde este script ira rodar, e o usuario associado ao OCI CLi precisa possuir policies de permissionamento de gerencias das compute instances
 #                  Este script foi pensado para ser executado em um sistema operacional linux.


    HOMEDIR="/tmp"
     ACTION="${2}"
  INST_OCID="${4}"
        LOG="${HOMEDIR}/instances_ger_log_$(date +%d%m%y).out"

 fn_ger()
 {
 	oci compute instance action --action ${ACTION} --instance-id ${INST_OCID} 1>> ${LOG} 2>&1
 	echo "" >> ${LOG}
 	echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -" >> ${LOG}
 	echo "" >> ${LOG}
 }


 fn_ger