#/bin/bash

mostrarAyuda(){
	underline=`tput smul`
	nounderline=`tput rmul`
	echo -e "Modo de uso:"
	echo -e "\t$0 [-dfaMHms] -u ${underline}url${nounderline} [-b ${underline}browser${nounderline}] [-h]\n"
	echo -e "Opciones:"
	echo -e "\t-u se indica una URL."
	echo -e "\t-b se indica el nombre de un navegador web que se localize en \$PATH, para ver la(s) miniatura(s)."
	echo -e "\t-d se genera URL al thumbnail por defecto."
	echo -e "\t-f se generan URLs a los cuatro thumbnails principales."
	echo -e "\t-a se generan URLs a todas las imagenes disponibles."
	echo -e "\t-h se despliega este mensaje de ayuda."
	echo -e "\t--Imagenes extra:"
	echo -e "\t-M se incluye la version de maxima resolucion del thumbnail."
	echo -e "\t-H se incluye la version de calidad alta del thumbnail."
	echo -e "\t-m se incluye la version de calidad media del thumbnail."
	echo -e "\t-s se incluye la version de calidad estandar del thumbnail."
	exit 0
}

errorMessage(){
	case $1 in
		invalidopt)
			echo "$0: opcion invalida: -$OPTARG: prueba $0 -h para mas informacion" >&2
		;;
		needarg)
			echo "$0: uso invalido de opcion -$OPTARG: requiere un argumento" >&2
		;;
		noarg)
			echo "$0: no se indico ningun argumento: prueba $0 -h para mas informacion" >&2
		;;
		nourl)
			echo "$0: no se ha indicado url: pruebe $0 -h para mas informacion" >&2
		;;
		invalidurl)
			echo "$0: $youtubeurl: url invalida" >&2
		;;
		*)
			echo "$0: error no especificado" >&2
		;;
	esac
	exit 1
}

mostrarURLs(){
	if [ "$1" == "a" ]; then
		for index in {0..8}; do
			echo ${thumbnails[$index]}
		done
	else
		for index in {0..3}; do
			echo ${thumbnails[$index]}
		done
	fi
}

agregarURLs(){
	if [ "$1" == "a" ]; then
		for index in {0..8}; do
			parameters="$parameters ${thumbnails[$index]} "
		done
		dflag=0
		Hflag=0
		mflag=0
		sflag=0
		Mflag=0
	else
		for index in {0..3}; do
			parameters="$parameters ${thumbnails[$index]} "
		done
		dflag=0
		Hflag=0
		mflag=0
		sflag=0
		Mflag=0
	fi
}

uflag=0
bflag=0
aflag=0
fflag=0
dflag=0
Hflag=0
mflag=0
sflag=0
Mflag=0
hflag=0

if [ $# -lt 1 ]; then
	errorMessage noarg
fi

while getopts ":u:b:dfaHmsMh" opt
do
	case $opt in
	u)
		uflag=1
		youtubeurl=$OPTARG
	;;
	b)
		bflag=1
		browsr=$OPTARG
	;;
	d)
		dflag=1
	;;
	f)
		fflag=1
	;;
	a)
		aflag=1
	;;
	H)
		Hflag=1
	;;
	m)
		mflag=1
	;;
	s)
		sflag=1
	;;
	M)
		Mflag=1
	;;
	h)
		hflag=1
	;;
	\?)
		errorMessage invalidopt
	;;
	:)
		errorMessage needarg
	;;
	esac
done

if [ $hflag -eq 1 ]; then
	mostrarAyuda
fi

if [ $uflag -eq 0 ]; then
	errorMessage nourl
fi

case $youtubeurl in
	http://youtube*|http://www.youtube*|https://youtube*|https://www.youtube*|youtube*|www.youtube*)
		youtubeid=`echo $youtubeurl | sed -e 's/.*youtube.com\/watch?v=//g'`
	;;
	http://youtu.be*|http://www.youtu.be*|https://youtu.be*|https://www.youtu.be*|youtu.be*|www.youtu.be*)
		youtubeid=`echo $youtubeurl | sed -e 's/.*youtu.be\///g'`
	;;
	*)
		errorMessage invalidurl
	;;
esac

declare -a thumbnails	#Array con todas las variantes de URL.

number=0

for name in 0 1 2 3 default hqdefault mqdefault sddefault maxresdefault
do
	thumbnails[$number]=http://img.youtube.com/vi/$youtubeid/$name.jpg
	number=$(($number + 1))
done

parameters=""	#Se utiliza para reunir los parametros pasados al browser.

if [ $bflag -eq 0 ]
then	#Se muestran las URLs cada una bajo otra.
	if [ $aflag -eq 1 ]; then
		mostrarURLs a
	elif [ $fflag -eq 1 ]; then
		mostrarURLs f
	else
		if [ $dflag -eq 0 -a $Hflag -eq 0 -a $mflag -eq 0 -a $sflag -eq 0 -a $Mflag -eq 0 ]; then
			echo ${thumbnails[0]}
		fi
	fi

	if [ $dflag -eq 1 -o $Hflag -eq 1 -o $mflag -eq 1 -o $sflag -eq 1 -o $Mflag -eq 1 ] && [ $aflag -eq 0 ]; then
		[ $dflag -eq 1 ] && echo ${thumbnails[4]}
		[ $Hflag -eq 1 ] && echo ${thumbnails[5]}
		[ $mflag -eq 1 ] && echo ${thumbnails[6]}
		[ $sflag -eq 1 ] && echo ${thumbnails[7]}
		[ $Mflag -eq 1 ] && echo ${thumbnails[8]}
	fi
else	#Se apilan las URLs cada una al lado de la otra con un espacio vacio como separacion.
	if [ $aflag -eq 1 ]; then
		agregarURLs a
	elif [ $fflag -eq 1 ]; then
		agregarURLs f
	else
		if [ $dflag -eq 0 -a $Hflag -eq 0 -a $mflag -eq 0 -a $sflag -eq 0 -a $Mflag -eq 0 ]; then
			parameters=${thumbnails[0]}
		fi
	fi

	if [ $dflag -eq 1 -o $Hflag -eq 1 -o $mflag -eq 1 -o $sflag -eq 1 -o $Mflag -eq 1 ] && [ $aflag -eq 0 ]; then
		[ $dflag -eq 1 ] && parameters="$parameters ${thumbnails[4]} "
		[ $Hflag -eq 1 ] && parameters="$parameters ${thumbnails[5]} "
		[ $mflag -eq 1 ] && parameters="$parameters ${thumbnails[6]} "
		[ $sflag -eq 1 ] && parameters="$parameters ${thumbnails[7]} "
		[ $Mflag -eq 1 ] && parameters="$parameters ${thumbnails[8]} "
	fi
	$browsr $parameters &
fi

exit 0