#!/bin/sh
#Arquitecturas virtuales: prácticas con vSphere 5.x ESXi
#Script 7.3:
#Creación de un linked clone de una VM existente en cli
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



#Comprobar que la máquina origen tiene uno y sólo un snapshot
contador=`count_snapshots $vmid`
case "$contador" in
    1)
        echo "Tiene un unico snapshot, continuando..."
        ;;
    * ) 
        echo "Error: No tiene un unico snapshot."
        exit 3
    ;;
esac


#Copiar los ficheros de definición de la máquina origen a la máquina clon:
# - fichero de configuración: .vmx,
# - fichero de definición del disco: .vmdk
# - fichero delta del snapshot
# Nota: es necesario averiguar los nombres de estos ficheros 
#       a partir del fichero de configuración

discoBase=`get_value "scsi0:0.fileName" $DATASTOREPATH/"$1"/"$1".vmx`
discoDelta=`get_value "VMFSSPARSE" $DATASTOREPATH/"$1"/"$discoBase"`


mkdir $DATASTOREPATH/"$2"
cp $DATASTOREPATH/"$1"/*.vmx $DATASTOREPATH/"$2"
cp $DATASTOREPATH/"$1"/"$discoBase" $DATASTOREPATH/"$2"/"$1".vmdk
cp $DATASTOREPATH/"$1"/"$discoDelta" $DATASTOREPATH/"$2"




#Sustituir los nombres de ficheros y sus respectivas referencias dentro de
#estos por el nombre clon 
for i in `ls $2`
do
    nuevoNombre=`stringreplace "$i" "$1" "$2"`
    mv "$2"/$i "$2"/$nuevoNombre
done

# Sustitcion referencia
linkOriginal=`get_value "parentFileNameHint" $DATASTOREPATH/$2/"$2".vmdk`
sedreplace "$1" "$2" "$2"/"$2".vmdk

#Cambiar la referencia del “parent disk” del fichero de definición del disco
#que debe de apuntar al de la máquina origen (en el directorio ..)
antiguoLink=`get_value "parentFileNameHint" $DATASTOREPATH/$2/"$2".vmdk`
sedreplace "$antiguoLink" "..\/$1\/$linkOriginal" "$2"/"$2.vmdk"


#¡Atención! Esto requiere un pequeño parsing del contenido 
#para sustituir aquellos campos de los ficheros de configuración que hacen 
#referencias a los ficheros.
sedreplace "$1" "$2" "$2"/*.vmx
antiguoFilename=`get_value "scsi0:0.fileName" $DATASTOREPATH/$2/"$2".vmx`
sedreplace "$antiguoFilename" "$2.vmdk" "$2"/"$2.vmx"




#Generar un fichero .vmsd (con nombre del clon) en el que se indica que
#es una máquina clonada.
#
#Coge un fichero .vsmd de un clon generado con VMware Workstation para ver
#el formato de este archivo
#
#Si no se genera el fichero .vmsd, al destruir el clon también se borra el
#disco base del snapshot, lo cual no es deseable ya que pertenece a la máquina 
#origen

echo ".encoding = \"UTF-8\"" >> "$2/$2.vmsd"
echo "cloneOf0 = \"../$1/$1.vmx\"" >> "$2/$2.vmsd"
echo "numCloneOf = \"1\"" >> "$2/$2.vmsd"
echo "sentinel0 = \"$2.vmdk\"" >> "$2/$2.vmsd"
echo "numSentinels = \"1\"" >> "$2/$2.vmsd"

#Una vez que el directorio clon contiene todos los ficheros necesarios
#hay que registrar la máquina clon (ESTO ES IMPRESCINDIBLE)
vim-cmd solo/registervm $DATASTOREPATH/"$2"/*.vmx "$2"


#Listar todas las máquinas para comprobar que el clon está disponible
list_vm


#Para terminar arranca el clon desde el cliente de vSphere
