# Práctica 08 - Procesadores de Lenguajes#
## 1. Objetivo de la práctica ##

El objetivo de la práctica consiste en realizar un **analizador sintáctico recursivo no predictivo** o *parser* para un el antiguo lenguaje ***PL/0*** con ayuda de la libería **Jison**, permitiendo backtracking. Además, se pide modificar la gramática del lenguaje **PL/0** Para que acepte las sentencias *if-then-else* y maneje argumentos en los procedimientos (*PROCEDURE* y *CALL* ). 

Posteriormente, se deberá realizar un análisis de ámbito o semántico para comprobar la aparición de los identificadores, asegurándonos, por ejemplo, que no se le asigna un valor a una constante (*CONST*), o que se intente hacer un *CALL* con un identificador de una variable, y no de un procedimiento.

Finalmente, se debe modificar la estructura del programa *Ruby/Sinatra* para poder almacenar usuarios que guardan programas, y proveer una ruta para ver los programas guardados por un determinado usuario.

## 2. Acceso a la página web ##
Se puede acceder a la página web de *Heroku* alojada en el siguiente enlace:

- Despliegue en Heroku: [http://alu0100828788-pl-prct08.herokuapp.com](http://alu0100828788-pl-prct08.herokuapp.com)- Pruebas: [http://alu0100828788-pl-prct08.herokuapp.com/test](http://alu0100828788-pl-prct08.herokuapp.com/test)

## 3. Dependencias ##
Se ha hecho uso de la librerías siguientes:

- [jQuery](http://jquery.com/)
- [MathJax](http://docs.mathjax.org/en/latest/start.html)

Otras librerías pertenecen al lado del *servidor* (ruby). Además, no es necesario descargar ninguna dependencia externa (vienen incluidas en el repositorio, o están referenciadas de manera online).

