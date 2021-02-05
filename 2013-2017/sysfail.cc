/* sysfail-v0.2 - Animacion en C++
 * Escrito por: euphoria <@euphoricpsyque>
 * Fecha de creacion original: 28/12/13
 * Fecha de modificacion actual: 03/07/2014
 */

#include <iostream>
using std::cout;
using std::cin;
using std::endl;

#include <chrono>
using std::chrono::milliseconds;

#include <thread>
using std::this_thread::sleep_for;

#include <cstdlib>

#ifdef _WIN32
    void clearScreen()
    {
        system("cls");
    }
#else
    void clearScreen()
    {
        system("clear");
    }
#endif

/* Despliega renglon a renglon numeros con espacios que forman bloques de numeros aleatoreos */

void primeraAnimacion(unsigned int);

/*
Genera varios bloques de numeros completos entre llamadas de funciones al sistema (no encontre una forma mejor :/...
para limpiar la pantalla). Al finalizar escribe un mensaje.
*/

void segundaAnimacion(unsigned short, unsigned int); 

int main()
{
    unsigned int limiteLineas;
    unsigned short numeroRevoluciones;

    cout<<"Ingresa un numero de lineas: ";
    cin>>limiteLineas;

    cout<<"Ingresa numero de revoluciones: ";
    cin>>numeroRevoluciones;

    if(limiteLineas % 10 == 0) /* Se filtra el input de lineas para permitir solo multiplos de 10 */
        limiteLineas *= 100;
    else
    {
        cout<<"Error: Valor invalido, el numero de lineas debe ser multiplo de 10."<<endl;
        return 1;
    }

    clearScreen();

    primeraAnimacion(limiteLineas);

    segundaAnimacion(numeroRevoluciones, limiteLineas);

    return 0;
}

void primeraAnimacion(unsigned int limiteLineas)
{
    unsigned short numeroAleatoreo;

    for(unsigned int digito = 1; digito <= limiteLineas; digito++)
    {
        if(digito == 90) /* Se adiciona 10 al numero de linea para pasar inmediatamente a la nueva linea evitando imprimir un bloque de numeros extra (se quieren 9 bloques) */
            digito += 10;

        if(digito % 10 != 0) /* Comprobar cantidad de numeros impresos en linea, si no son 10 o multiplo de 10 se imprime un numero aleatorio */
        {
            numeroAleatoreo = rand() % 9;
            cout<<" "<<numeroAleatoreo;
        }

        if(digito % 10 == 0) /* Comprobar numero de caracteres impresos en linea, si son 10 o multiplo de 10 se imprimen dos espacios */
            cout<<"  ";

        if(digito % 100 == 0) /* Comprobar numero de caracteres impresos en linea, si son 100 o multiplo se imprime fin de linea */
        {
            cout<<endl;
            digito += 10; /* Despues de cada fin de linea se suma 10 para evitar imprimir otro bloque de numeros a la izquierda */
        }

        milliseconds entre_linea( 1 );
        sleep_for( entre_linea ); /* Duerme un milisegundo */
    }
}

void segundaAnimacion( unsigned short numeroRevoluciones, unsigned int limiteLineas)
{
    unsigned int posicionMensaje[3], numeroAleatoreo, revCont = 0;

    while(revCont < numeroRevoluciones) /* Crea bloques de numeros aleatoreos y limpia la pantalla entre cada uno de ellos, al terminar imprime un mensaje entre los bloques */
    {
        revCont += 1;

        milliseconds entre_imagen( 100 );
        sleep_for( entre_imagen ); /* Espera 100 milisegundos entre cada "imagen" de bloques */

        clearScreen();

        for(unsigned int digitos = 1; digitos <= limiteLineas; digitos++)
        {

            if(digitos == 90)
                digitos += 10;

            if(revCont > numeroRevoluciones - 1) /* Si nos encontramos la ultima vuelta del bucle while se imprime el mensaje */
            {
                posicionMensaje[0] = limiteLineas / 2 - 250;

                if(digitos == posicionMensaje[0])
                {
                    cout<<"   +---------------+";
                    digitos += 10; /* Se adiciona 10 para rellenar el espacio dejado por el mensaje */
                }

                posicionMensaje[1] = limiteLineas / 2 - 150;

                if(digitos == posicionMensaje[1])
                {
                    cout<<"   |SYSTEM  FAILURE|";
                    digitos += 10;
                }

                posicionMensaje[2] = limiteLineas / 2 - 50;

                if(digitos == posicionMensaje[2])
                {
                    cout<<"   +---------------+";
                    digitos += 10;
                }
            }

            if(digitos % 10 != 0)
            {
                numeroAleatoreo = rand() % 9;
                cout<<" "<<numeroAleatoreo;
            }

            if(digitos % 10 == 0)
                cout<<"  ";

            if(digitos % 100 == 0)
            {
                cout<<endl;
                digitos += 10;
            }

        } //Finaliza for

    } //Finaliza while
}