#!/bin/sh

#Arquitecturas virtuales: prácticas con vsphere 5.1 ESXi
#Ejemplo de script
#Ene/2014

#Cuidado ESTO DEBE SER UN FICHERO TEXTO UNIX (NO MSDOS)
#--------------------------------------------

DATASTOREPATH=/vmfs/volumes/datastore22/myfolder

vm_list() { echo "Estas son las maquinas registradas en este servidor:"
            vim-cmd vmsvc/getallvms
           } #Una funcion para listar las maquinas registradas


#Algunos mensajes
#--------------------------------------------
echo "Este script se llama $0"
echo Uso: $0 vm_name

if ( test $# -gt 1 )
then
   echo "Este script se ha invocado con $# argumentos"
   echo "La lista de argumentos del script es \"$*\""
fi

if ( ! test $# -eq 1 ) 
then
	echo "Este script requiere uno y solo un argumento (nombre de la vm)"
    vm_list
	exit 1
else
    echo "El primer argumento es '$1' y debe ser el nombre de la vm"
fi

#Incluir las funciones que se proporcionan
#Suponemos que esta en el mismo directorio
#--------------------------------------------
funfile=`dirname $0`/script_functions.sh
if ( ! test -f $funfile )
then
	echo "No se encuentra script_functions.sh"
	exit 2
else
	#Incluir funciones
	. $funfile
fi

#Comprobar si existe la maquina (argumento 1)
#--------------------------------------------
if ( ! exist_vm $1 )
then
    echo Una vm con nombre \'$1\' no existe
    vm_list
    exit 3
fi

#Imprimir caracteristicas de la maquina
#--------------------------------------------
vmid=`get_vmid $1`
Nsnapshots=`count_snapshots $vmid`
vmx=`get_vm_vmx $vmid`
vmdir=`get_vm_dir $vmid`

echo "Maquina '$1':"
echo "  identificador           vmid=$vmid"
echo "  fichero configuracion   vmx=$vmx"
echo "  directorio donde esta   vmdir=$vmdir"
echo "  numero de snapshots     $Nsnapshots"

exit 0 #Recuerda que el 0 es el codigo de retorno cuando todo es OK






