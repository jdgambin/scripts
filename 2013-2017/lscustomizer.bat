rem writed by hikari ( http://hikari.sytes.net )
@echo off
color 0a
title Logon Customizer v0.1 [ Windows 7 ]
mode con: cols=150 lines=50
:ini
cls
echo.
echo  lscustomizer   ...gNMMM@@MMMNa+..
echo  v0.1       ..M@M#"=!........?7TWMMN&,
echo          ..MMY=...`.....`...```....?YMMa.
echo        .JM#^..``.```````````````....`.JW@N.
echo       .M#^.``.`.```````````````.`..````.,WMh.
echo     .MM5.J.J..```.````````..`.JJ.,,`...``.JMN.
echo    .MM.JY^` .MMa .```````.`.M"=  .dMN,`.`.`.MM,
echo   .@M.M$    @@MMN.``````.`dF     J@@MMp````..MM,
echo   M@^JF     ?WH"Jb .`````JF       "H"^M,..```.@N
echo  JMF dF         JN `````.@F           gF `.`.`J@F
echo  J@'`Jh.........JF .````.4b...........MF````.`.@b
echo  M@ `.!!!!!!!!!!?````````.!!!??????????.`````` @N
echo  M@ `.......`.`.``.`.....`````.`....`...````.. @M
echo  d@,``.NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNr````.``.@F
echo  J@b ```JNWHHHHHHHHHHHHHHHHHHHHHHHHHHd@ ``````J@F
echo   MM.``` @KHHHHHHHHHHHHHHHHHHHHHHHHHHW@.````..@M
echo   .@N ``.JMKHHHHHHHHHHHHHHHHHHHHHHHHHM@ ```.`dM3
echo    J@N.```?MKHHHHHHHHHHHNHYY9HHHHHHHHMF.``..d@$
echo     .MN,``.JMNHHHHHHHNY!.`````..4NHNM5..``.MM^^
echo       4Mh,`..TMNHHHH@ ...```...`..MD..``.JMY`
echo        .W@N,``.?HNN# ...`..``J.M#^.`.`.J@#"^
echo          .TMMa,`..`T"MMQQHMH"T!..``..@MY!
echo            `"MMNg...````````...+MMM"^^ 
echo                 `""WMMM@@@MM@M#""!    [ by hikari ]
echo.
echo 1. Modificar imagen de inicio de session.
echo 2. Restaurar imagen de inicio de session.
echo 3. Salir.
choice /C 123 
if %errorlevel%==1 ( goto :first )
if %errorlevel%==2 ( goto :second )
if %errorlevel%==3 ( goto:eof )
:first
set /p img="Introduce el path hacia la imagen que deseas utilizar (debe pesar menos de 256 Kb): "
if EXIST %img% (
	call :bytes %img%
	goto:eof
) else (
	echo El archivo no existe...
	pause > nul
	goto:ini
)
:second
	echo Editando el registro...
	REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background /v "OEMBackground" /t REG_DWORD /d 0 /f > nul 2<&1
	echo Eliminando archivos y directorios...
	rd /S /Q %windir%\system32\oobe\info > nul 2<&1
	goto:question
:bytes
	set filepath=%~d1%~p1%~n1%~x1
	if %~z1 LSS 262144 (
		echo Archivo valido
		echo Editando el registro...
		REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\Background /v "OEMBackground" /t REG_DWORD /d 1 /f > nul 2<&1
		echo Creando directorios y copiando archivo...
		if not exist %windir%\system32\oobe\info ( mkdir %windir%\system32\oobe\info > nul 2<&1 )
		if not exist %windir%\system32\oobe\info\backgrounds ( mkdir %windir%\system32\oobe\info\backgrounds > nul 2<&1 )
		copy /Y %filepath% %windir%\system32\oobe\info\backgrounds\backgroundDefault.jpg > nul 2<&1
		goto:question
	) else (
		echo La imagen es mayor de 262144 bytes, pesa %~z1 bytes no puedes utilizarla...
		pause > nul
		goto:ini
	)
:question
	choice /M "Desea cerrar sesion para ver el resultado "
		if %errorlevel%==1 ( logoff )
		if %errorlevel%==2 ( goto:eof )