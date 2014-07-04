# Pr�ctica 08 - Procesadores de Lenguajes#
## 1. Objetivo de la pr�ctica ##

El objetivo de la pr�ctica consiste en realizar un **analizador sint�ctico recursivo no predictivo** o *parser* para un el antiguo lenguaje ***PL/0*** con ayuda de la liber�a **Jison**, permitiendo backtracking. Adem�s, se pide modificar la gram�tica del lenguaje **PL/0** Para que acepte las sentencias *if-then-else* y maneje argumentos en los procedimientos (*PROCEDURE* y *CALL* ). 

Posteriormente, se deber� realizar un an�lisis de �mbito o sem�ntico para comprobar la aparici�n de los identificadores, asegur�ndonos, por ejemplo, que no se le asigna un valor a una constante (*CONST*), o que se intente hacer un *CALL* con un identificador de una variable, y no de un procedimiento.

Finalmente, se debe modificar la estructura del programa *Ruby/Sinatra* para poder almacenar usuarios que guardan programas, y proveer una ruta para ver los programas guardados por un determinado usuario.

## 2. Acceso a la p�gina web ##
Se puede acceder a la p�gina web de *Heroku* alojada en el siguiente enlace:

- Despliegue en Heroku: [http://alu0100828788-pl-prct08.herokuapp.com](http://alu0100828788-pl-prct08.herokuapp.com)- Pruebas: [http://alu0100828788-pl-prct08.herokuapp.com/test](http://alu0100828788-pl-prct08.herokuapp.com/test)

## 3. Dependencias ##
Se ha hecho uso de la librer�as siguientes:

- [jQuery](http://jquery.com/)
- [MathJax](http://docs.mathjax.org/en/latest/start.html)

Otras librer�as pertenecen al lado del *servidor* (ruby). Adem�s, no es necesario descargar ninguna dependencia externa (vienen incluidas en el repositorio, o est�n referenciadas de manera online).

