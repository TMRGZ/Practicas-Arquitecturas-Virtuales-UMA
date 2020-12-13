#!/bin/sh
#Arquitecturas virtuales: prácticas con vSphere 5.x ESXi
#Script 7.1.I:
#Creación de una nueva VM con características mínimas desde cero en cli
#Ene/2014

#Recuerda!:
# ESTO DEBE SER UN FICHERO TEXTO UNIX (NO MSDOS)
# DEBE TENER PERMISO DE EJECUCION (chmod +x fichero)

#Importar script de funciones
source $(dirname "$0")/script_functions.sh

#Directorio donde se ubicará la maquina
DATASTOREPATH=/vmfs/volumes/datastore23/MRG

#Imprimir su uso
if ( test $# -eq 0 )
then
   echo "Uso: $0 nombre_mv_a_crear tipo_maquina* espacio_disco* n_tarjetas_red*"
   echo
   exit 0
fi

#Incluir funciones que se proporcionan

#Comprobar si existe una maquina con el mismo nombre
if (exist_vm $1)
then
    echo Una vm con nombre \'$1\' ya existe
    exit 3
fi


#Crear la nueva máquina (sugerencia: usar vim-cmd vmsvc/createdummyvm)
vim-cmd vmsvc/createdummyvm $1 $DATASTOREPATH

#Cambiar el tipo de máquina
if ( test $# -ge 2 )
then
   echo "Parametro tipo de maquina no implementado, arg: $2"
fi


#Aumentar el espacio del disco
if ( test $# -ge 3 )
then
   echo "Aumentando tamaño del disco para $1"
   vmkfstools -X $3 $DATASTOREPATH/$1/$1.vmdk
fi

#Añadir NIC a la máquina
if ( test $# -ge 4 )
then
    echo "Añadiendo los $4 NICs..."
    
    vmid=`get_vmid $1`

    for i in $( seq 1 $4 )
    do
        echo "Añadiendo NIC: $i"
        vim-cmd vmsvc/devices.createnic $vmid 1 e1000 "VM Network"
    done
fi




#Listar todas las máquinas para comprobar que se ha creado
list_vm







# TENER EN CUENTA ESTO SÓLO SI LA MÁQUINA NO ARRANCA:
# ¿Hay que añadir al fichero de configuración (.vmx) algún(os) campo(s) que es(son) imprescindible(S) para arrancar la máquina?
# Sugerencia: intenta arrancar la máquina una vez creada y busca en el fichero 
#            wmware.log por qué ha fallado el arranque



#Para terminar comprobar que la nueva máquina se puede arrancar 
#desde el cliente de vSphere


