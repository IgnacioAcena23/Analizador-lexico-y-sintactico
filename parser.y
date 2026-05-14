%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern char* yytext;
extern FILE *yyin;

void yyerror(const char *s);
FILE *json_log;
int first_token = 1;

/* line = línea capturada en el momento exacto del lexer (no del reduce) */
void log_token_json(int line, const char* categoria, const char* token_name, const char* lexema) {
    if (!first_token) fprintf(json_log, ",\n");

    /* Escapar comillas y backslashes del lexema para JSON válido */
    char escaped[1024];
    int j = 0;
    for (int i = 0; lexema[i] && j < 1020; i++) {
        if (lexema[i] == '"' || lexema[i] == '\\') {
            escaped[j++] = '\\';
        }
        escaped[j++] = lexema[i];
    }
    escaped[j] = '\0';

    fprintf(json_log, "  {\"linea\": %d, \"categoria\": \"%s\", \"token\": \"%s\", \"lexema\": \"%s\"}",
            line, categoria, token_name, escaped);
    first_token = 0;
}
%}

%locations
%define parse.error verbose

%union {
    char* sval;
}

%token LBRACE RBRACE LBRACKET RBRACKET COLON COMMA
%token <sval> STRING NUMBER BOOLEAN NULL_TOKEN

%start json

%%

json:
    valor
    ;

objeto:
    LBRACE { log_token_json(@1.first_line, "structural", "LBRACE", "{"); }
    miembros
    RBRACE { log_token_json(@4.first_line, "structural", "RBRACE", "}"); }
    | LBRACE { log_token_json(@1.first_line, "structural", "LBRACE", "{"); }
      RBRACE { log_token_json(@3.first_line, "structural", "RBRACE", "}"); }
    ;

miembros:
    par_clave_valor
    | miembros COMMA { log_token_json(@2.first_line, "structural", "COMMA", ","); } par_clave_valor
    ;

par_clave_valor:
    STRING { log_token_json(@1.first_line, "processed", "KEY", $1); }
    COLON  { log_token_json(@3.first_line, "structural", "COLON", ":"); }
    valor
    ;

arreglo:
    LBRACKET { log_token_json(@1.first_line, "structural", "LBRACKET", "["); }
    elementos
    RBRACKET { log_token_json(@4.first_line, "structural", "RBRACKET", "]"); }
    | LBRACKET { log_token_json(@1.first_line, "structural", "LBRACKET", "["); }
      RBRACKET { log_token_json(@3.first_line, "structural", "RBRACKET", "]"); }
    ;

elementos:
    valor
    | elementos COMMA { log_token_json(@2.first_line, "structural", "COMMA", ","); } valor
    ;

valor:
    STRING      { log_token_json(@1.first_line, "processed", "STRING", $1); }
    | NUMBER    { log_token_json(@1.first_line, "processed", "NUMBER", $1); }
    | BOOLEAN   { log_token_json(@1.first_line, "processed", "BOOLEAN", $1); }
    | NULL_TOKEN { log_token_json(@1.first_line, "processed", "NULL", $1); }
    | objeto
    | arreglo
    ;

%%

int had_error = 0;

void yyerror(const char *s) {
    /* Escapar yytext para mostrarlo en el JSON */
    char err_lex[256];
    int j = 0;
    for (int i = 0; yytext[i] && j < 250; i++) {
        if (yytext[i] == '"' || yytext[i] == '\\') err_lex[j++] = '\\';
        err_lex[j++] = yytext[i];
    }
    err_lex[j] = '\0';

    /* Escapar mensaje de Bison para JSON válido */
    char err_msg[512];
    j = 0;
    for (int i = 0; s[i] && j < 500; i++) {
        if (s[i] == '"' || s[i] == '\\') err_msg[j++] = '\\';
        err_msg[j++] = s[i];
    }
    err_msg[j] = '\0';

    if (!first_token) fprintf(json_log, ",\n");
    fprintf(json_log, "  {\"linea\": %d, \"categoria\": \"error\", \"token\": \"SYNTAX_ERROR\", \"lexema\": \"%s\", \"mensaje\": \"%s\"}",
            yylloc.first_line, err_lex, err_msg);
    first_token = 0;
    had_error = 1;
}

/* Mapea el código de token devuelto por yylex a su nombre legible */
const char* token_to_name(int tok) {
    switch(tok) {
        case LBRACE:     return "LBRACE";
        case RBRACE:     return "RBRACE";
        case LBRACKET:   return "LBRACKET";
        case RBRACKET:   return "RBRACKET";
        case COLON:      return "COLON";
        case COMMA:      return "COMMA";
        case STRING:     return "STRING";
        case NUMBER:     return "NUMBER";
        case BOOLEAN:    return "BOOLEAN";
        case NULL_TOKEN: return "NULL";
        default:         return "UNKNOWN";
    }
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Uso: %s archivo.json\n", argv[0]);
        return 1;
    }

    FILE *f = fopen(argv[1], "r");
    if (!f) {
        printf("No se pudo abrir el archivo: %s\n", argv[1]);
        return 1;
    }

    json_log = fopen("reporte_tokens.json", "w");
    if (!json_log) {
        printf("No se pudo crear el reporte JSON\n");
        return 1;
    }

    fprintf(json_log, "[\n");

    yyin = f;
    yyparse();

    /* Si hubo error, seguir leyendo el resto del archivo con el lexer
       para que los tokens restantes se registren como "unprocessed" (gris en la web) */
    if (had_error) {
        int tok;
        while ((tok = yylex()) != 0) {
            if (tok < 0) continue; /* Saltar caracteres no reconocidos */
            log_token_json(yylineno, "unprocessed", token_to_name(tok), yytext);
        }
    }

    fprintf(json_log, "\n]\n");
    fclose(json_log);
    fclose(f);

    printf("Reporte generado. Abre http://localhost:8000 en tu navegador.\n");

    return 0;
}