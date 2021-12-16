#!/bin/bash

#Entrada Script
    clear
    ejecucion=S #Con esto señalaremos que el script este siempre en funcionamiento, principalmente
                #cuando creemos el menu y queramos seguir ejecutandolo.

#FuncionMenu

    menu() {
        clear
            echo "Menu"

            echo "1. Copia de Seguridad"
            echo "2. Dar de alta a un usuario"
            echo "3. Dar de baja a un usuario" 
            echo "4. Mostrar usuarios"
            echo "5. Mostrar log del sistema"
            echo "6. Salir"

            read -p "Elige una opción " opcion

            case $opcion in

            1) 
                copia 
            ;;

            2) 
                alta 
            ;;

            3) 
                baja 
            ;;

            4) 
                verusu 
            ;;

            5) 
                verlog 
            ;;

            6) 
                exit 
            ;;

            *)
                echo "Error. Introduzca un numero del 1 al 6. "
                read -p "¿Quiere volver al menú? (S/N) " ejecucion
            ;;
            esac
    }

#Funciones

#FuncionCopiaSeguridad

    copia(){
        cpzip=copiausuarios_`date +%d%m%Y`_`date +%I`-`date +%M`-`date +%S`.zip
        zipdep=`ls -tr copia* 2>/dev/null | head -n 1`
        cantarchivos=`ls -l . | grep copiausuarios | wc -l`
        limite=1
        #Estas variables serviran para hacer funcionar este funcion, la variable limite
        #establecera la cantidad maxima de copias del archivo comprimido que creara el programa
        #mientras que las otras nos permitira crear el fichero .zip y eliminarlo.


        if [ $cantarchivos -le $limite ] #Señalaremos que la primera variable no superara la
                                         #variable que señalamos antes.
            then
                echo "Copiando fichero de usuarios. Espere"
                sleep 1
                zip -r copiausuarios_`date +%d%m%Y`_`date +%I`-`date +%M`-`date +%S`.zip ./usuarios.csv 1> /dev/null #con la parte final evitaremos que, al ejecutar por 
                                                                                                                     #el script no nos muestre ningun error al no existir ningun zip
                echo "Copia de seguridad creada. Su nombre es $cpzip"
                echo "Copia de seguridad $cpzip creada el `date +%d/%m/%Y` a las `date +%I`:`date +%M`h" >> log.log #Con esto mandamos la informacion al log
            else #Aqui eliminaremos las copias mas antiguas.
                echo "Existen ya dos copias de seguridad. Eliminando la mas antigua"
                sleep 2
                echo "Copia de seguridad $zipdep fue eliminada el `date +%d/%m/%Y` a las `date +%I`:`date +%M`h" >> log.log
                eliminarzip=`ls -tr copia* | head -n 1 | xargs rm -R`
                $eliminarzip
                echo "Se va a proceder ahora a crear una nueva copia"
                sleep 2
                echo "Copia de seguridad $cpzip creada el `date +%d/%m/%Y` a las `date +%I`:`date +%M`h" >> log.log
                zip -r copiausuarios_`date +%d%m%Y`_`date +%I`-`date +%M`-`date +%S`.zip ./usuarios.csv 1> /dev/null
            fi
        read -p "¿Quiere volver al menú? (S/N) " ejecucion
    }

#FunciónExiste

    existe() {
        if  grep -w $nombreusuario usuarios.csv #Comprueba el usuario en el fichero "usuarios.csv" situado en el mismo directorio
            then
                return 1 #devolvemos un 1 si el usuario existe
            else
                return 0 #devolvemos un 0 si el usuario no existe
                existe
        fi
}

#FunciónLogin

    login(){
        valido=0 #Inicializamos variable valido a 0, para controlar si un usuario es válido en el sistema o no (0=no es valido; 1=valido)
        read -p "Introduzca el nombre de usuario: " nombreusuario

        existe #Llamamos a la funcion y dejará en $? el valor del return
        valido=$? #Asi recogemos el valor devuelto por la funcion existe

        if  [ $valido -eq 1 -o $nombreusuario == "admin" ] #Si el usuario existe o es "admin" lo damos por válido
            then
                echo "El usuario introducido es válido"
                sleep 1
                menu 
            else    
                echo "El usuario introducido no es válido"
                sleep 1
                login
        fi
}

#FunciónAltaUsuario

    alta(){
        read -p "Ingrese el nombre del usuario: " nombre
        read -p "Ingrese primer apellido: " apellido1
        read -p "Ingrese segundo apellido: " apellido2
        read -p "Ingrese el DNI: " dniusuario


        #Con lo de abajo trozeramos los datos introducidos arriba para crear el nombre del
        #usuario para el programa.

        nombreusuario=$(echo $nombre | cut -c1 )
        nombreusuario=$nombreusuario$(echo $apellido1 | cut -c1,2,3 )
        nombreusuario=$nombreusuario$(echo $apellido2 | cut -c1,2,3 )
        nombreusuario=$nombreusuario$(echo $dniusuario | cut -c6,7,8 )
        nombreusuario=$(echo $nombreusuario | tr '[:upper:]' '[:lower:]')

        echo "EL usuario es $nombreusuario"

        existe
        if  [ $? -eq 0 ]
        then
            echo "El usuario introducido no existe en el sistema"
            echo "Agregando usuario al sistema"

            sleep 2

            echo "$nombre:$apellido1:$apellido2:$dniusuario:$nombreusuario" >> usuarios.csv #Introduciremos con esto a los usuarios 
                                                                                            #al fichero .csv donde se almacenaran estos
            echo "El usuario $nombreusuario fue insertado el `date +%d/%m/%Y` a las `date +%I`:`date +%M`h" >> log.log
            read -p "¿Quiere volver al menú? (S/N) " ejecucion
        else
            echo "El usuario $nombreusuario ya existe"
            read -p "¿Quiere volver al menú? (S/N) " ejecucion
        fi
    }

#FunciónBajaUsuario

    baja(){
        read -p "Inserta el nombre del usuario a eliminar " borraruser
        usuaborrar=`grep $borraruser usuarios.csv`
        echo "Comprobando si el usuario existe ..."

        existe
        
        if  [ $? -eq 1 ]
                                                                                       #el nombre de usuario completo
        then

            sleep 1

            echo "Dando de baja al Usuario. Espere."

            sleep 2

            grep -v "$borraruser" usuarios.csv > tmpfile && mv tmpfile usuarios.csv #Con esto borraremos del fichero a los usuarios indicados
            echo "El Usuario $borraruser ha sido dado de baja"
            echo "El usuario $borraruser fue dado de baja el `date +%d/%m/%Y` a las `date +%I`:`date +%M`h" >> log.log
            
            sleep 1
            
            read -p "¿Quiere volver al menú? (S/N) " ejecucion
            else
            echo "El usuario $borraruser no existe"
            read -p "¿Quiere volver al menú? (S/N) " ejecucion
        fi

    }

#FunciónVerUsuarios

    verusu(){
        echo "Mostrando los usuarios"
        sleep 2
        cat usuarios.csv | cut -d ':' -f 5 | sort #Simple, nos mostrara la lista ordenada de usuarios
        read -p "¿Quiere volver al menú? (S/N) " ejecucion
    }

#FunciónVerLog

    verlog(){
        cat log.log | more #SImple tambien, leer el fichero log completo con un more
        read -p "¿Quiere volver al menú? (S/N) " ejecucion
    }

#FunciónComprobar

#Scripts SISTEMA
#Con esto comprobaremos si el fichero usuarios existe, y si no es asi lo crea

if test -f ./usuarios.csv
    then
    echo "El fichero de los usuarios existe. Abriendo el menú."
    else 
    echo "El fichero de usuarios no existe. Creando uno nuevo y abriendo el menú."
    touch usuarios.csv
    touch log.log
fi

#LlamadasFunciones
#Una vez ejecutada la comprobacion del fichero usuarios llamaremos a la funcion login
#una vez que esta se completa entraremos en un bucle que es donde se encuentra la funcion menú
#esta siempre se estara ejecutando mientras la variable sea "S" y esto, siempre sera asi a no ser
#que se lo indiquemos en alguna de las preguntas que hacemos en alguno de las funciones.

sleep 3
login

while [ $ejecucion = S ]
    do
        menu
    done