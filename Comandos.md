# Terminal 1:

python -m http.server 8000

# Terminal 2:

flex lexer.l
bison -d parser.y
gcc parser.tab.c lex.yy.c -o analizador.exe
.\analizador.exe pruebaX.json 

(X = Al número de prueba 1,2 o 3)


Procedimiento:
1. Correr el serevidor python -m http.server 8000
2. Compilar los archivos .l y .y con Flex y Bison
3. Compilar el archivo .c con GCC
4. Ejecutar el analizador con los archivos de prueba
5. Abrir el navegador web en la dirección http://localhost:8000
6. Seleccionar el archivo JSON a analizar