#!/bin/bash
if [ "$1" ==  "1a" ]; then
	if [ $# -eq 3 ]; then
		limite=$2
		folder=$3
	else
		read -p "Introduce numero de archivos a crear: " limite
		read -p "Introduce nombre de carpeta: " folder
	fi

	if [ ! -d "$folder" ]; then
		mkdir "$folder"
	fi

	contador=0

	while read line; do
		./text2leetbeta -t "$line" "$folder"/$contador
		echo "$line" >> "$folder"/$contador
		contador=$(($contador + 1))
		if [ $contador -eq $limite ]; then
			break
		fi
	done < wordlist

	exit 0
fi

if [ "$1" == "1b" ]; then
	if [ ! -d "output1b" ]; then
		mkdir "output1b"
	fi

	argumentos=""

	for i in {1..50}; do
		argumentos="$argumentos output1b/$i "
	done

	./text2leetbeta -t "texto prueba" $argumentos

	exit 0
fi

if [ "$1" == "2a" ]; then
	if [ $# -eq 4 ]; then
		archivo=$2
		folder=$3
		limite=$4
	else
		read -p "Introduce nombre del archivo base: " archivo
		read -p "Introduce nombre de carpeta: " folder
		read -p "Introduce numero de archivos a crear: " limite
	fi

	if [ ! -d "$folder" ]; then
		mkdir "$folder"
	fi

	contador=0

	while [ $contador -le $limite ]; do
		./text2leetbeta wordlist "$folder"/$contador
		contador=$(($contador + 1))
	done

	exit 0
fi

if [ "$1" == "2b" ]; then
	if [ ! -d "output2b" ]; then
		mkdir "output2b"
	fi

	argumentos=""

	for i in {1..50}; do
		argumentos="$argumentos output2b/$i "
	done

	./text2leetbeta wordlist $argumentos

	exit 0
fi

echo "Argumentos: 1a [limite] [carpeta], 1b, 2a [archivo] [carpeta] [limite], 2b."

exit 0