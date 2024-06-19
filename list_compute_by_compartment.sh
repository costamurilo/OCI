#!/bin/bash

 #
 # Created by : Murilo Costa
 # Uptade in  :
 # Func       : Lists the entire tree of compartments and subcompartments.
 #              Based on this list, it scans the compartments found looking for computes in the compartments. 


 clear
 echo ""
 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - "
 echo " - - -    Listagem de Computes por Compartment   - - - "
 echo " - - - - - - - - - - - - - - - - - - - - - - - - - - - "
 echo ""
 # Configurações iniciais
 TENANCY_ID="ocid1.tenancy.oc1..aaaaaaaawquag7eeulmm6e2yoykcvigene6piosc6rwgglznmt4d5iubifuq"
     REGION="sa-vinhedo-1" # Substitua pela sua região

 # Lista todas as árvores de compartments e subcompartments no tenancy
 COMPARTMENTS1="$(oci iam compartment list -c ${TENANCY_ID} --compartment-id-in-subtree True --access-level=ANY --limit 9999999 --query 'data[*].id' --raw-output 2>/dev/null | grep -Ev '\[|\]')"

 # Limpa a ',' da saída do comando anterior
 COMPARTMENTS="$(for i in ${COMPARTMENTS1}
                do
                  echo ${i} | cut -f 1 -d ,
                done)"
 #Conta quantos compartments foram encontrados
 COMPARTMENTS_QTT="$(for i in ${COMPARTMENTS1}
                do
                  echo ${i} | cut -f 1 -d ,
                done|wc -l)"


 # Função para listar recursos em um compartimento
 COUNT="0"
 list_resources_in_compartment()
 {
   COMPARTMENT_ID="${1}"
   echo " Listing resources in compartment [ ${COUNT} ] : ${COMPARTMENT_ID}"
   echo " Instances:"
   oci compute instance list --compartment-id ${COMPARTMENT_ID} --all --query 'data[*].{ID:id,Name:"display-name",State:state}' --output table 2>/dev/null
   echo ""
   COUNT="$((${COUNT}+1))"
 }
 echo " Quantidade de compartment listados : [ ${COMPARTMENTS_QTT} ]"
 echo " - - - - - - - - - - - - - - - - - - - - - - "
 echo ""

 # função
 for COMPARTMENT_ID1 in ${COMPARTMENTS}
 do
   list_resources_in_compartment ${COMPARTMENT_ID1}
 done
