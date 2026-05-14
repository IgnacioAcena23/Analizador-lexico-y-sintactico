# Proyecto Traductores e Interpretadores

Proyecto de construccion de un analizador lexico y sintactico de un lenguaje con sintaxis tipo json en donde se analizan las estructuras de tipos de datos básicas (strings, numbers, booleans, null) y tipos de dato estructurales (objetos y arrays).
Mediante la utilizacion de las herramientras Flex y Bison.

## Integrantes del equipo:

-> Ignacio Aceña. 
-> Claudia Medina. 
-> Roberto Siracusa.

## Estructura del proyecto

- lexer.l: Analizador lexico.
- parser.y: Analizador sintactico.
- index.html: Interfaz web para el analizador.
- prueba1.json, prueba2.json, prueba3.json: Archivos de prueba.
- reporte_tokens.json: Estructura basica con los tokens.
- Comandos.md: Comandos para compilar y ejecutar el analizador.

## Instalación de herramientas:

- En Linux:

Flex y Bison: sudo apt install flex bison
GCC: sudo apt install build-essential

- En Windows:

Descarga e instala MSYS2 desde msys2.org.
Abre la terminal de MSYS2 UCRT64.

Comandos en MSY2:
pacman -S mingw-w64-x86_64-flex mingw-w64-x86_64-bison
pacman -S mingw-w64-x86_64-gcc

Importante: Debes agregar la ruta C:\msys64\mingw64\bin a las Variables de Entorno (PATH) de tu sistema para usarlos desde cualquier terminal (PowerShell o CMD).

## Terminal 1:

python -m http.server 8000

## Terminal 2:

flex lexer.l
bison -d parser.y
gcc parser.tab.c lex.yy.c -o analizador.exe
.\analizador.exe pruebaX.json 

(X = Al número de prueba 1,2 o 3)

## Procedimiento:
1. Correr el serevidor python -m http.server 8000
2. Compilar los archivos .l y .y con Flex y Bison
3. Compilar el archivo .c con GCC
4. Ejecutar el analizador con los archivos de prueba
5. Abrir el navegador web en la dirección http://localhost:8000
6. Seleccionar el archivo JSON a analizar

