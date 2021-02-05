#!/bin/bash

# Descarga libros completos de slideshare teniendo la URL de la primera imagen
 
temporaryfolder=$(mktemp -d book.XXX)
cd $temporaryfolder
url=$1
parsedurl=$(echo $url | sed -e 's/?cb=.*//g')
imagename=$(echo $parsedurl | sed -e 's/http:\/\/image.slidesharecdn.com\/.*\///g')
imagenumber=$(echo $imagename | sed -e 's/slide-\(.*\)-.*/\1/g')
first_image_number=$imagenumber
 
echo "Se procede a descargar la imagen $parsedurl y posteriores."
 
wget --tries 2 $parsedurl 2> /dev/null
wget_exit_status=$?
 
function loopie(){
    while [[ $wget_exit_status -eq 0 ]]
    do
        mv $imagename $imagenumber.jpg
        echo "Se ha descargado $imagename."
        imagenumber=$(($imagenumber+1))
        imagename=$(echo $imagename | sed -e "s/slide-.*-\(.*\)/slide-$imagenumber-\1/g")
        parsedurl=$(echo $parsedurl | sed -e "s/slide-.*-\(.*\)/slide-$imagenumber-\1/g")
        wget --tries 2 $parsedurl 2> /dev/null
        wget_exit_status=$?
        if [ $wget_exit_status -ne 0 ]
        then
            echo "Se ha terminado la descarga."
            read -p "Convertir imagenes en archivo PDF (Paquete imagemagick necesario) [s/n]: " pdffile
            case $pdffile in
            s|S)
                imagenumber=$(($imagenumber-1))
                list="$first_image_number.jpg"
                first_image_number=$(($first_image_number+1))
                for ((i=$first_image_number; i <= $imagenumber; i++))
                do
                    list="$list $i.jpg"
                done
                convert $list $temporaryfolder.pdf
            ;;
            n|N);;
            *) echo "No se reconoce esa opcion."
            esac
            read -p "Eliminar las imagenes [s/n]: " imgfiles
            case $imgfiles in
                s|S) rm *.jpg ;;
                n|N) exit 0 ;;
                *) echo "No se reconoce esa opcion, bye."
            esac
        fi
    done
}
 
if [[ $wget_exit_status -eq 0 ]]
then
    loopie
else
    echo "Hubo un error, comprueba la URL."
fi