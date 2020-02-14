@echo off
:inicio
setlocal EnableDelayedExpansion
call headerusers.bat

set /p file=Please input your users file:

IF "%file%"=="" (
ECHO "%file%" is NOT defined
pause
goto inicio
) ELSE (goto next)

:next
set /p var=Type the number:
if not '%var%'=='' set var=%var:~0,1%
if '%var%'=='1' goto op1
if '%var%'=='2' goto op2
if '%var%'=='3' goto op3

echo "%var%" is not valid, try again
pause
goto inicio

:op1

echo ------ Creando cuentas de usuario, permisos y directorios --------
for /F "tokens=1-7 useback Skip=1 delims=;" %%a in ("%file:"=%") do (
	
	set nombre=%%a
	set apellido=%%b
	set clave=%%c
   	set firstLetter=!nombre:~0,1!
   	set usuario=!apellido!!firstLetter!
	set expire=%%d
	set time=%%e
	set grupo=%%f
	set changePasswd=%%g
    set firstExpire=!expire:~0,1!
    set secondExpire=!expire:~5,2!
	
	IF !changePasswd! EQU SI set changePasswd=!changePasswd:SI=YES!
	
	rem Verifica si el usuario existe y si no lo crea, si pertenece al grupo direccion cambia la hora, modificando el valor SI a YES
	IF ERRORLEVEL 1 echo El usuario !usuario! ya existe

	IF NOT ERRORLEVEL 1 (
	echo Creando cuenta de !usuario!
	net user !usuario! Cambiar01/ /add /fullname:"!nombre! !apellido!" /times:!firstExpire!!secondExpire!,!time! /passwordchg:!changePasswd! /logonpasswordchg:yes>nul
	IF !grupo! EQU Direccion net user !usuario! /times:!firstExpire!!secondExpire!,7AM-10PM>nul
	)

	IF ERRORLEVEL 1 echo El grupo !grupo! ya existe

	rem Si el grupo no existe lo crea y lo asigna a los usuarios
	IF NOT ERRORLEVEL 1 (
		echo Creando grupo !grupo! el %date:~0,10% %time:~0,8% >> c:/grupos_creados.txt
		net localgroup !grupo! /add >> c:/grupos_creados.txt 2>&1
		net localgroup !grupo! !usuario! /add>nul
	)

	rem Crea las carpetas conrrespondientes asignados los permisos especificados en el documento.
	IF NOT EXIST c:/Departamentos (
	mkdir "c:/Departamentos"
	IF !grupo! EQU Direccion cacls "c:/Departamentos" /t /e /g Direccion:r>nul
	)
	
	
	IF NOT EXIST c:/Departamentos/Produccion (
	IF !grupo! EQU Produccion mkdir "c:/Departamentos/Produccion">nul
	IF !grupo! EQU Produccion cacls "c:/Departamentos/Produccion" /e /g Produccion:c>nul
	)
	IF NOT EXIST c:/Departamentos/Direccion (
	IF !grupo! EQU Direccion mkdir "c:/Departamentos/Direccion">nul
	IF !grupo! EQU Direccion cacls "c:/Departamentos/Direccion" /e /g Direccion:c>nul
	)
	IF NOT EXIST c:/Departamentos/Administracion (
	IF !grupo! EQU Administracion mkdir "c:/Departamentos/Administracion">nul
	IF !grupo! EQU Administracion cacls "c:/Departamentos/Administracion" /e /g Administracion:c>nul
	IF !grupo! EQU Administracion cacls "c:/Departamentos/Comercial" /e /g Administracion:r>nul
	)
	IF NOT EXIST c:/Departamentos/Comercial (
	IF !grupo! EQU Comercial mkdir "c:/Departamentos/Comercial">nul
	IF !grupo! EQU Administracion cacls "c:/Departamentos/Comercial" /e /g Administracion:r>nul
	IF !grupo! EQU Comercial cacls "c:/Departamentos/Comercial" /e /g Comercial:c>nul
	)
	
	rem Crea las carpetas para cada usuario asignando los permisos y su jefe dependiendo del grupo asignara, pedro, jose mario o juan de dios
	IF NOT EXIST g:/usuarios/Raid5_!usuario! (
	mkdir "g:/usuarios/Raid5_!usuario!"
	cacls "g:/usuarios/Raid5_!usuario!" /e /g !usuario!:c>nul
	)
	
	IF !grupo! EQU Administracion (
	cacls "g:/usuarios/Raid5_!usuario!" /e /g MorenoP:c>nul
	)
	IF !grupo! EQU Comercial (
	cacls "g:/usuarios/Raid5_!usuario!" /e /g PradosJ:c>nul
	)
	IF !grupo! EQU Produccion (
	cacls "g:/usuarios/Raid5_!usuario!" /e /g SantanderJ:c>nul
	)	
)

rem Verifica si existen las carpetas 
IF EXIST c:/Departamentos echo La carpeta Departamentos ya existe 
IF EXIST c:/Departamentos/Direccion echo La carpeta Direccion ya existe 
IF EXIST c:/Departamentos/Produccion echo La carpeta Produccion ya existe 
IF EXIST c:/Departamentos/Comercial echo La carpeta Comercial  ya existe 
IF EXIST c:/Departamentos/Administracion echo La carpeta Administracion ya existe
IF EXIST g:/usuarios/Raid5_!usuario! echo Los usuarios disponen una carpeta creada en el raid 5

rem Descativa la herencia de permisos y remueve al grupo usuarios al heredarse por defecto en todos los directorios, permite acceder a todos los usuarios del sistema a todos los directorios
echo:
echo Asignando permisos a las carpetas padre
echo:
icacls "c:/Departamentos" /t /inheritance:d>nul
icacls "c:/Departamentos" /t /remove Usuarios>nul
rem Añade usuarios solo a la carpeta padre
icacls "c:/Departamentos" /grant Usuarios:rx>nul
icacls "g:/usuarios" /t /inheritance:d>nul
icacls "g:/usuarios" /t /remove Usuarios>nul
icacls "g:/usuarios" /grant Usuarios:rx>nul

pause
goto inicio

:op2
for /F "tokens=1-7 useback Skip=1 delims=;" %%a in ("%file:"=%") do (
	set nombre=%%a
	set apellido=%%b
   	set firstLetter=!nombre:~0,1!
   	set usuario=!apellido!!firstLetter!
	
	IF ERRORLEVEL 1 echo El usuario !usuario! no existe
	
	IF NOT ERRORLEVEL 1  (
	echo ------ Borrando cuenta de !usuario! --------
	echo:
	net user !usuario! /delete
	)



)

echo ------ Proceso finalizado --------

pause
goto inicio

:op3
echo Press any key to exit.
pause>nul
exit