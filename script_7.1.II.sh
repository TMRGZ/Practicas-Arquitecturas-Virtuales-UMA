#!/bin/sh
#Arquitecturas virtuales: prácticas con vSphere 5.x ESXi
#Script 7.1.I:
#Borrado de una VM existente en cli
#Ene/2014

#Recuerda!:
# ESTO DEBE SER UN FICHERO TEXTO UNIX (NO MSDOS)
# DEBE TENER PERMISO DE EJECUCION (chmod +x fichero)

#Importar script de funciones
source $(dirname "$0")/script_functions.sh

#Directorio donde se ubican las máquinas
#Sustituir por el directorio de trabajo en cada caso
DATASTOREPATH=/vmfs/volumes/datastore23/MRG

#Incluir funciones que se proporcionan
if ( test $# -eq 0 )
then
   echo "Uso: $0 nombre_mv_a_borrar"
   echo
   exit 0
fi


#Comprobar si existe la máquina en cuestión
if (! exist_vm $1)
then
    echo Una vm con nombre \'$1\' no existe
    exit 3
fi


#Solicitar confirmación de borrado
read -p "¿Seguro de que quieres borrar la MV: $1? (s/n) " elec
case "$elec" in
    y|Y|s|S ) 
        vmid=`get_vmid $1`
        estado=`vim-cmd vmsvc/power.getstate $vmid | tail -1`
        
        #Apagar la máquina si está encendida
        case "$estado" in
            "Powered off")
                echo "Máquina ya apagada."
            ;;
            * ) 
                vim-cmd vmsvc/power.off $vmid
            ;;
        esac
    
        #Borrar la máquina (sugerencia: usar vim-cmd vmsvc/destroy)
        echo "Borrando..."
        vim-cmd vmsvc/destroy $vmid

        #Listar todas las máquinas para comprobar que se ha borrado
        list_vm
    ;;
    n|N ) 
        echo "Se ha cancelado la operación"
    ;;
    * ) echo "Entrada invalida, cancelando...";;
esac

    






