#!/bin/sh
#Arquitecturas virtuales: prácticas con vSphere 5.x ESXi
#Script 7.2:
#Creación de un full clone de una VM existente en cli
#Ene/2014

#Recuerda!:
# ESTO DEBE SER UN FICHERO TEXTO UNIX (NO MSDOS)
# DEBE TENER PERMISO DE EJECUCION (chmod +x fichero)

#Importar script de funciones
source $(dirname "$0")/script_functions.sh

#Directorio donde se ubican las máquinas
#Sustituir por el directorio de trabajo en cada caso
DATASTOREPATH=/vmfs/volumes/datastore23/MRG

#Imprimir su uso
if ( test $# -eq 0 )
then
   echo "Uso: $0 nombre_mv_a_copiar nombre_mv_copia"
   echo
   exit 0
fi


#Encontrar la ubicación e identificadores de la máquina a copiar
vmid=`get_vmid $1`
ubi=`get_vm_datastore_path $vmid`


#Comprobar que existe la máquina origen a clonar
if (! exist_vm $1)
then
    echo Una vm con nombre \'$1\' no existe
    exit 3
fi


#Comprobar que no existe la maquina clon
if (exist_vm $2)
then
    echo Una vm con nombre \'$2\' ya existe
    exit 3
fi


#Copiar recursivamente el directorio de la máquina origen a su destino (clon)
mkdir $DATASTOREPATH/"$2"
cp -r $DATASTOREPATH/"$1"/* $DATASTOREPATH/"$2"


#Cambiar nombre ficheros
for i in `ls $2`
do
    nuevoNombre=`stringreplace "$i" "$1" "$2"`
    mv "$2"/$i "$2"/$nuevoNombre
done

sedreplace "$1" "$2" "$2"/*.vmx
sedreplace "$1" "$2" "$2"/*.vmxf
sedreplace "$1" "$2" "$2"/"$2".vmdk




#Registar la máquina clon (ESTO ES IMPRESCINDIBLE)
vim-cmd solo/registervm $DATASTOREPATH/"$2"/*.vmx "$2"


#Listar todas las máquinas para comprobar que el clon está disponible
list_vm


#Para terminar arranca el clon desde el cliente de vSphere
vmid=`get_vmid $2`
vim-cmd vmsvc/power.on $vmid &
sleep 10
vim-cmd vmsvc/power.off $vmid &

