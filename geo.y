%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include "include/colors.h"
#include "include/strman.h"
#include "include/types.h"
#include "include/safe_math.h"
#include "include/element.h"
#include "include/stack.h"

#define BLOCK_OK 0
#define BLOCK_SKIP 1

int yylex(void);
int yyerror(const char *msg);

int problem = 0;
int skip_block = 0;
int loop = 0;

// πρεπει να βρω τροπο το skip_block να το κραταω για οσο ειμαι μεσα σε if και οταν τελειωσει να φευγει
// η καλυτερη λυση μου ειναι stack απλως δεν ξερω ποτε να το βγαλω δεν εχω βρει καποιο triger

extern FILE *yyin;
extern int yylineno;
extern int col;
extern int yyleng;
extern char* yytext;
extern int parse_subfile(const char* filename);

extern int temp_if_res;

IntStack* ifExprStack = NULL;
IntStack* ifSkipBlockStack = NULL;
IntStack* elseExprStack = NULL;
IntStack* whileExprStack = NULL;

void intAssignment(char* id, int value) {
    if(problem) free(id);
    else if(peekInt(ifSkipBlockStack)) free(id);
    else {
        int res = appendInt(id, value);
        if(res == 0) free(id);
        else if(res == 1) {
            problem = 1;
            char* errorMes = str("allready declared ");
            concat(&errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(&errorMes,id);
            free(id);
            yyerror(errorMes);
        }
    }
}

void floatAssignment(char* id, float value) {
    if(problem) free(id);
    else if(peekInt(ifSkipBlockStack)) free(id);
    else {
        int res = appendFloat(id, value);
        if(res == 0) free(id);
        else if(res == 1) {
            problem = 1;
            char* errorMes = str("allready declared ");
            concat(errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(errorMes,id);
            free(id);
            yyerror(errorMes);
        }
    }
}

void longIntAssignment(char* id, long int value) {
    if(problem) free(id);
    else if(peekInt(ifSkipBlockStack)) free(id);
    else {
        int res = appendLongInt(id, value);
        if(res == 0) free(id);
        else if(res == 1) {
            problem = 1;
            char* errorMes = str("allready declared ");
            concat(errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(errorMes,id);
            free(id);
            yyerror(errorMes);
        }
    }
}

void boolAssignment(char* id, int value) {
    if(problem) free(id);
    else if(peekInt(ifSkipBlockStack)) free(id);
    else {
        int res = appendBool(id, value);
        if(res == 0) free(id);
        else if(res == 1) {
            problem = 1;
            char* errorMes = str("allready declared ");
            concat(errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(errorMes,id);
            free(id);
            yyerror(errorMes);
        }
    }
}

void stringAssignment(char* id, char* value) {
    if(problem) free(id);
    else if(peekInt(ifSkipBlockStack)) { free(id); free(value); }
    else {
        int res = appendString(id, value);
        if(res == 0) free(id);
        else if(res == 1) {
            problem = 1;
            char* errorMes = str("allready declared ");
            concat(errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(errorMes,id);
            free(id);
            yyerror(errorMes);
        }
    }
}

void popForIf() {
    if(!isIntStackEmpty(ifSkipBlockStack) && !isIntStackEmpty(ifExprStack)){
        popInt(ifExprStack);
        popInt(ifSkipBlockStack);
    }
}

// if(element == 0) return 0; palia
int checkPreviousIfs() {
    int cnt = 1;
    int element = elementIntAt(ifExprStack, ifExprStack->top - cnt);
    printf("$$$ %d == 1 $$$ and $$$ %d == 0\n",elementIntAt(elseExprStack, cnt-1), element);
    while(element != -1) {
        if(elementIntAt(elseExprStack, cnt-1) == 1 && element == 0) {return 0;}
        cnt++;
        element = elementIntAt(ifExprStack, ifExprStack->top - cnt);
        printf("$$$ %d == 1 $$$ and $$$ %d == 0\n",elementIntAt(elseExprStack, cnt-1), element);
    }
    return 1;
}

int checkPreviousWhiles() {
    int cnt = 1;
    int element = elementIntAt(whileExprStack, whileExprStack->top - cnt);
    printf("$$$ %d == 1 $$$ and $$$ %d == 0\n",elementIntAt(whileExprStack, cnt-1), element);
    while(element != -1) {
        if(element == 0) return 0;
        cnt++;
        element = elementIntAt(whileExprStack, whileExprStack->top - cnt);
        printf("$$$ %d == 1 $$$ and $$$ %d == 0\n",elementIntAt(whileExprStack, cnt-1), element);
    }
    return 1;
}
%}

%debug

%token PLUS MINUS MUL DIV MOD POW
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE SEM ASSIGN COMMA COLON
%token EQ NEQ GT LT GTE LTE AND OR NOT
%token IF ELSE WHILE BLOCK INCLUDE
%token PRINT INT LONG FLOAT STRING BOOL ALL ERROR EXIT
%token TOO_LONG_NUMBER_ERR

%right UMINUS UPLUS
%left PLUS MINUS
%left MUL DIV MOD
%right POW

%nonassoc IF
%nonassoc ELSE

%token <idName> ID
%token <intIdName> INT_ID
%token <floatIdName> FLOAT_ID
%token <longIntIdName> LONG_INT_ID
%token <boolIdName> BOOL_ID
%token <stringIdName> STRING_ID
%token <intVal> INT_NUM
%token <floatVal> FLOAT_NUM
%token <longIntVal> LONG_INT_NUM
%token <boolVal> BOOL_VAL
%token <stringVal> STRING_VAL

%union {
    char* idName;
    char* intIdName;
    char* floatIdName;
    char* longIntIdName;
    char* boolIdName;
    char* stringIdName;
    int intVal;
    float floatVal;
    long int longIntVal;
    int boolVal;
    char* stringVal;
}

%type <intVal> stmtI exprI
%type <floatVal> stmtF exprF
%type <longIntVal> stmtLI exprLI
%type <boolVal> stmtB exprB
%type <stringVal> stmtS exprS
%type <idName> idAssignmentsI idAssignmentsF idAssignmentsLI idAssignmentsB idAssignmentsS
%type <idName> assignmentErrors NOT_INT_ID NOT_FLOAT_ID NOT_LONG_INT_ID NOT_BOOL_ID NOT_STRING_ID

%%
prog:
    stmts
;
// Every type_id is allready declared, only ID is undeclared first and then it will became type_id
// so a lot of checks with if id is declared are unneccery

// with the help of stack i have to make sure that every paren or brace or bracket will open and close right sometime
// i use the int brace_depth

// the simple if works fine if i have only the simple, if i have the if else only then it works fine only with false

// when i will introduce ranges then i will have to check for decrerations and others
stmts:
    | errors
    | stmtI SEM stmts
    | stmtF SEM stmts
    | stmtLI SEM stmts
    | stmtB SEM stmts
    | stmtS SEM stmts
    | printFunc SEM stmts
    | stmtIF
    | stmtWHILE
    | block stmts
    | includeCode
    | spcl
;

includeCode:
    INCLUDE exprS {
        // this is a real mid-rule action!
        if (!parse_subfile($2)) {
            char error[256] = "file does not exist --- ";
            strcat(error, $2);
            yyerror(error);
            free($2);
            YYABORT;
        }
        free($2);
    }
    stmts
;

stmtWHILE:
    WHILE LPAREN exprB RPAREN {
        if(checkPreviousWhiles()) {
            pushInt(whileExprStack, $3);
            if(peekInt(whileExprStack) == FALSE_VAL) skip_block = 1;
            else loop = 1;
        }
        else skip_block = 1;
    } block stmts
;

stmtIF:
    IF LPAREN exprB RPAREN {
        if(checkPreviousIfs()) {
            pushInt(ifExprStack, $3);
            if(peekInt(ifExprStack) == FALSE_VAL) skip_block = 1;
        }
        else skip_block = 1;
    } block else_stmts
;

else_stmts:
    end_if

    | ELSE IF LPAREN exprB RPAREN {
        if(checkPreviousIfs()) { 
            popAndPushInt(ifExprStack, $4);
            if(peekInt(ifExprStack) == FALSE_VAL) skip_block = 1;
        } else skip_block = 1;
    } block else_stmts

    | ELSE block end_if
;

end_if:
    { /* popInt(ifExprStack);  printf("--");printIntStack(ifExprStack); */ } stmts
;

block:
    BLOCK { /* printf("--");printIntStack(ifExprStack); */ }
    | LBRACE stmts RBRACE { /* printf("--");printIntStack(ifExprStack); */ }
;

// spcl doesn't need checking for skip_block because it's for debug purposes only or for (error and exit) !
// when bison sends values from down to up i don't need to remove them because of skip_block i just free the memory and send
// them up. The checking of skip_block will only stop the logic (mostly types.h's functions)
spcl:
    PRINT ALL               { printAllTables(); } stmts
    | PRINT INT_ID          { printValue($2); free($2); } stmts
    | PRINT FLOAT_ID        { printValue($2); free($2); } stmts
    | PRINT LONG_INT_ID     { printValue($2); free($2); } stmts
    | PRINT BOOL_ID         { printValue($2); free($2); } stmts
    | PRINT STRING_ID       { printValue($2); free($2); } stmts
    | PRINT INT             { printIntTable(); } stmts
    | PRINT FLOAT           { printFloatTable(); } stmts
    | PRINT LONG INT        { printLongIntTable(); } stmts
    | PRINT BOOL            { printBoolTable(); } stmts
    | PRINT STRING          { printStringTable(); } stmts
    | EXIT                  { printf("%sGeo ended safely!%s\n\n", C_GREEN, C_RESET); YYACCEPT; }
;

errors:
    ID ID ASSIGN assignmentErrors {
        char* errorMes = str("wrong type ");
        concat(&errorMes, $1);
        free($1);
        free($2);
        free($4);
        yyerror(errorMes);
        YYABORT;
    }

    | ERROR { yyerror("syntax error"); YYABORT; }
;

assignmentErrors:
    ID              { $$ = $1; }
    | INT_ID        { $$ = $1; }
    | FLOAT_ID      { $$ = $1; }
    | LONG_INT_ID   { $$ = $1; }
    | BOOL_ID       { $$ = $1; }
    | STRING_ID     { $$ = $1; }
    | STRING_VAL    { $$ = $1; }
;

printFunc:
    PRINT LPAREN exprS RPAREN {
        if(problem) {
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($3);
        else {
            printf("%s%s%s\n", C_ORANGE, $3, C_RESET);
            free($3);
        }
    }

// if an undeclared id used then memory leak will occur surely except if i use some global var and every time check it
// i did it only for int now i have to do it for float, long int, bool, string
stmtI:
    INT_ID ASSIGN exprI {
        if(problem) {
            free($1);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($1);
        else {
            setInt($1, $3);
            free($1);
        }
    }

    | INT_ID ASSIGN idAssignmentsI {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) {
            free($1);
            free($3);
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsI {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        free($3);
        yyerror(errorMes);
        YYABORT;
    }

    | ID ASSIGN exprI {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(error);
        YYABORT;
    }

    | INT declareListI { if(problem) YYABORT; }
;

declareListI:
    assignmentI
    | declareListI COMMA assignmentI
;

assignmentI:
    ID ASSIGN exprI { intAssignment($1, $3); }

    | ID { intAssignment($1,  0); }

    | INT_ID ASSIGN exprI {
        char* errorMes = str("allready declared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(error);
        YYABORT;
    }

    | NOT_INT_ID ASSIGN exprI {
        char* errorMes = str("allready declared with other type variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(error);
        YYABORT;
    }
;

NOT_INT_ID:
    FLOAT_ID      { $$ = $1; }
    | LONG_INT_ID { $$ = $1; }
    | BOOL_ID     { $$ = $1; }
    | STRING_ID   { $$ = $1; }
;

idAssignmentsI:
    INT_ID ASSIGN idAssignmentsI {
        if(problem) {
            $$ = $1;
            free($3);
        }
        else if(peekInt(ifSkipBlockStack)) {
            $$ = $1;
            free($3);
        }
        else {
            setVarFromId($1, $3);
            $$ = $1;
            free($3);
        }
    }

    | INT_ID { $$ = $1; }

    | ID ASSIGN idAssignmentsI {
        problem = 1;
        $$ = $1;
        free($3);
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }
;

stmtF:
    FLOAT_ID ASSIGN exprF {
        if(problem) {
            free($1);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($1);
        else {
            setFloat($1, $3);
            free($1);
        }
    }

    | FLOAT_ID ASSIGN idAssignmentsF {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) {
            free($1);
            free($3);
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsF {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        free($3);
        yyerror(errorMes);
        YYABORT;
    }

    | ID ASSIGN exprF {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | FLOAT declareListF { if(problem) YYABORT; }
;

declareListF:
    assignmentF
    | declareListF COMMA assignmentF
;

assignmentF:
    ID ASSIGN exprF { floatAssignment($1, $3); }

    | ID { floatAssignment($1, 0); }

    | FLOAT_ID ASSIGN exprF {
        char* errorMes = str("allready declared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | NOT_FLOAT_ID ASSIGN exprF {
        char* errorMes = str("allready declared with other type variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }
;

NOT_FLOAT_ID:
    INT_ID        { $$ = $1; }
    | LONG_INT_ID { $$ = $1; }
    | BOOL_ID     { $$ = $1; }
    | STRING_ID   { $$ = $1; }
;

idAssignmentsF:
    FLOAT_ID ASSIGN idAssignmentsF {
        if(problem) {
            $$ = $1;
            free($3);
        }
        else if(peekInt(ifSkipBlockStack)) {
            $$ = $1;
            free($3);
        }
        else {
            setVarFromId($1, $3);
            $$ = $1;
            free($3);
        }
    }

    | FLOAT_ID { $$ = $1; }

    | ID ASSIGN idAssignmentsF {
        problem = 1;
        $$ = $1;
        free($3);
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }
;

stmtLI:
    LONG_INT_ID ASSIGN exprLI {
        if(problem) {
            free($1);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($1);
        else {
            setLongInt($1, $3);
            free($1);
        }
    }

    | LONG_INT_ID ASSIGN idAssignmentsLI {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) {
            free($1);
            free($3);
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }
    
    | ID ASSIGN idAssignmentsLI {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        free($3);
        yyerror(errorMes);
        YYABORT;
    }

    | ID ASSIGN exprLI {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | LONG INT declareListLI { if(problem) YYABORT; }
;

declareListLI:
    assignmentLI
    | declareListLI COMMA assignmentLI
;

assignmentLI:
    ID ASSIGN exprLI { longIntAssignment($1, $3); }

    | ID { longIntAssignment($1, 0); }

    | LONG_INT_ID ASSIGN exprLI {
        char* errorMes = str("allready declared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | NOT_LONG_INT_ID ASSIGN exprLI {
        char* errorMes = str("allready declared with other type variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }
;

NOT_LONG_INT_ID:
    INT_ID      { $$ = $1; }
    | FLOAT_ID  { $$ = $1; }
    | BOOL_ID   { $$ = $1; }
    | STRING_ID { $$ = $1; }
;

idAssignmentsLI:
    LONG_INT_ID ASSIGN idAssignmentsLI {
        if(problem) {
            $$ = $1;
            free($3);
        }
        else if(peekInt(ifSkipBlockStack)) {
            $$ = $1;
            free($3);
        }
        else {
            setVarFromId($1, $3);
            $$ = $1;
            free($3);
        }
    }

    | LONG_INT_ID { $$ = $1; }

    | ID ASSIGN idAssignmentsF {
        problem = 1;
        $$ = $1;
        free($3);
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }
;

stmtB:
    BOOL_ID ASSIGN exprB {
        if(problem) {
            free($1);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($1);
        else {
            setBool($1, $3);
            free($1);
        }
    }

    | BOOL_ID ASSIGN idAssignmentsB {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) {
            free($1);
            free($3);
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsB {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        free($3);
        yyerror(errorMes);
        YYABORT;
    }

    | ID ASSIGN exprB {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | BOOL declareListB { if(problem) YYABORT; }
;

declareListB:
    assignmentB
    | declareListB COMMA assignmentB
;

assignmentB:
    ID ASSIGN exprB { boolAssignment($1, $3); }

    | ID { boolAssignment($1, TRUE_VAL); }

    | BOOL_ID ASSIGN exprB {
        char* errorMes = str("allready declared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | NOT_BOOL_ID ASSIGN exprB {
        char* errorMes = str("allready declared with other type variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }
;

NOT_BOOL_ID:
    INT_ID        { $$ = $1; }
    | FLOAT_ID    { $$ = $1; }
    | LONG_INT_ID { $$ = $1; }
    | STRING_ID   { $$ = $1; }
;

idAssignmentsB:
    BOOL_ID ASSIGN idAssignmentsB {
        if(problem) {
            $$ = $1;
            free($3);
        }
        else if(peekInt(ifSkipBlockStack)) {
            $$ = $1;
            free($3);
        }
        else {
            setVarFromId($1, $3);
            $$ = $1;
            free($3);
        }
    }

    | BOOL_ID { $$ = $1; }

    | ID ASSIGN idAssignmentsB {
        problem = 1;
        $$ = $1;
        free($3);
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }
;

stmtS:
    STRING_ID ASSIGN exprS {
        if(problem) {
            free($1);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) free($1);
        else {
            setString($1, $3);
            free($1);
        }
    }

    | STRING_ID ASSIGN idAssignmentsS {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else if(peekInt(ifSkipBlockStack)) {
            free($1);
            free($3);
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }
    
    | ID ASSIGN idAssignmentsS {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        free($3);
        yyerror(errorMes);
        YYABORT;
    }

    | ID ASSIGN exprS {
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | STRING declareListS { if(problem) YYABORT; }
;

declareListS:
    assignmentS
    | declareListS COMMA assignmentS
;

assignmentS:
    ID ASSIGN exprS { stringAssignment($1, $3); }

    | ID {
        char* str = NULL;
        equall(&str, "");
        stringAssignment($1, str);
    }

    | STRING_ID ASSIGN exprS {
        char* errorMes = str("allready declared variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }

    | NOT_STRING_ID ASSIGN exprS {
        char* errorMes = str("allready declared with other type variable ");
        concat(errorMes,$1);
        free($1);
        yyerror(errorMes);
        YYABORT;
    }
;

NOT_STRING_ID:
    INT_ID        { $$ = $1; }
    | FLOAT_ID    { $$ = $1; }
    | LONG_INT_ID { $$ = $1; }
    | BOOL_ID     { $$ = $1; }
;

idAssignmentsS:
    STRING_ID ASSIGN idAssignmentsS {
        if(problem) {
            $$ = $1;
            free($3);
        }
        else if(peekInt(ifSkipBlockStack)) {
            $$ = $1;
            free($3);
        }
        else {
            setVarFromId($1, $3);
            $$ = $1;
            free($3);
        }
    }

    | STRING_ID { $$ = $1; }

    | ID ASSIGN idAssignmentsS {
        problem = 1;
        $$ = $1;
        free($3);
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(errorMes,$1);
        yyerror(errorMes);
    }
;

exprI:
    INT_NUM { $$ = $1; }

    | FLOAT_NUM { $$ = (int)$1; }

    | LONG_INT_NUM { $$ = getIntPart($1); }

    | BOOL_VAL { $$ = $1; }
//**********************************************************************
    | STRING_VAL { $$ = 0; free($1); } // if str "" then 0 else 1
//**********************************************************************

    | ID {
        problem = 1;
        $$ = 0;
        char* errorMes = str("undeclared variable ");
        concat(errorMes, $1);
        free($1);
        yyerror(errorMes);
    }

    | INT_ID {
        int is_found = NOT_FOUND;
        int res = getIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | FLOAT_ID {
        int is_found = NOT_FOUND;
        int res = (int)getFloatFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        int res = getIntPart(getIntFromId($1, &is_found));
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | BOOL_ID {
        int is_found = NOT_FOUND;
        int res = getBoolFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
//**********************************************************************
    | STRING_ID {
        int res = getStringIndex($1);
        if(res == FOUND) {
            $$ = 0;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
//**********************************************************************    
    | exprI PLUS exprI { $$ = intAdd($1, $3); }

    | exprI MINUS exprI { $$ = intSub($1, $3); }

    | exprI MUL exprI { $$ = intMul($1, $3); }

    | exprI DIV exprI {
        if ($3 != 0) $$ = intDiv($1, $3);
        else {
            yyerror(str("division with 0 as denominator error"));
            YYABORT;
        }
    }

    | exprI MOD exprI {
        if ($3 != 0) $$ = intMod($1, $3);
        else {
            yyerror("modulus with 0 as denominator error");
            YYABORT;
        }
    }

    | exprI POW exprI { $$ = intPow($1, $3); }

    | LPAREN exprI RPAREN { $$ = $2; }

    | MINUS exprI %prec UMINUS { $$ = -$2; }

    | PLUS exprI %prec UPLUS { $$ = $2; }
;

exprF:
    | FLOAT_NUM { $$ = $1; }

    | INT_NUM { $$ = $1; }

    | LONG_INT_NUM { $$ = getIntPart($1); }

    | BOOL_VAL { $$ = $1; }
//**********************************************************************
    | STRING_VAL { $$ = 0; free($1); }
//**********************************************************************
    | ID {
        problem = 1;
        $$ = 0;
        char* errorMes = str("undeclared variable ");
        concat(errorMes, $1);
        free($1);
        yyerror(errorMes);
    }

    | FLOAT_ID {
        int is_found = NOT_FOUND;
        float res = getFloatFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | INT_ID {
        int is_found = NOT_FOUND;
        int res = getIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        int res = getIntPart(getLongIntFromId($1, &is_found));
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | BOOL_ID {
        int is_found = NOT_FOUND;
        int res = getBoolFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | STRING_ID {
        int res = getStringIndex($1);
        if(res == FOUND) {
            $$ = 0;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | exprF PLUS exprF { $$ = floatAdd($1, $3); }

    | exprF MINUS exprF { $$ = floatSub($1, $3); }

    | exprF MUL exprF { $$ = floatMul($1, $3); }
    
    | exprF DIV exprF {
        if ($3 != 0) $$ = floatDiv($1, $3);
        else {
            yyerror(str("division with 0 as denominator error"));
            YYABORT;
        }
    }

    | exprF POW exprF { $$ = floatPow($1, $3); }

    | LPAREN FLOAT RPAREN exprF { $$ = $4; }

    | LPAREN exprF RPAREN { $$ = $2; }

    | MINUS exprF %prec UMINUS { $$ = -$2; }

    | PLUS exprF %prec UPLUS { $$ = $2; }
;

// I need to put more safety If possible
exprLI:
    LONG_INT_NUM { $$ = $1; }

    | INT_NUM { $$ = (long int)$1; }

    | FLOAT_NUM { $$ = (long int)$1; }

    | BOOL_VAL { $$ = (long int)$1; }

    | STRING_VAL { $$ = 0; free($1); }

    | ID {
        problem = 1;
        $$ = 0;
        char* errorMes = str("undeclared variable ");
        concat(errorMes, $1);
        free($1);
        yyerror(errorMes);
    }

    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        long int res = getLongIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | INT_ID {
        int is_found = NOT_FOUND;
        long int res = getIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | FLOAT_ID {
        int is_found = NOT_FOUND;
        long int res = (long int)getFloatFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        long int res = getLongIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
    
    | BOOL_ID {
        int is_found = NOT_FOUND;
        long int res = (long int)getBoolFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | STRING_ID {
        int res = getStringIndex($1);
        if(res == FOUND) {
            $$ = 0;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | exprLI PLUS exprLI { $$ = $1 + $3; }

    | exprLI MINUS exprLI { $$ = $1 - $3; }

    | exprLI MUL exprLI { $$ = $1 * $3; }

    | exprLI DIV exprLI {
        if ($3 != 0) $$ = $1 / $3;
        else {
            yyerror(str("division with 0 as denominator error"));
            YYABORT;
        }
    }

    | exprLI MOD exprLI {
        if ($3 != 0) $$ = $1 % $3;
        else {
            yyerror(str("modulus with 0 as denominator error"));
            YYABORT;
        }
    }

    | exprLI POW exprLI { $$ = (long int)(pow((double)$1, (double)$3)); }

    | LPAREN exprLI RPAREN { $$ = $2; }

    | MINUS exprLI %prec UMINUS { $$ = -$2; }

    | PLUS exprLI %prec UPLUS { $$ = $2; }
    
    | TOO_LONG_NUMBER_ERR { yyerror(str("too long number error")); YYABORT; }
;

exprB:
    BOOL_VAL { $$ = $1; }

    | exprB EQ exprB { $$ = $1 == $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB NEQ exprB { $$ = $1 != $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB GT exprB { $$ = $1 > $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB LT exprB { $$ = $1 < $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB GTE exprB { $$ = $1 >= $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB LTE exprB { $$ = $1 <= $3 ? TRUE_VAL : FALSE_VAL; }

    | exprB AND exprB {
        if($1 == FALSE_VAL && $3 == FALSE_VAL) $$ = FALSE_VAL;
        if($1 == FALSE_VAL && $3 == TRUE_VAL ) $$ = FALSE_VAL;
        if($1 == TRUE_VAL  && $3 == FALSE_VAL) $$ = FALSE_VAL;
        if($1 == TRUE_VAL  && $3 == TRUE_VAL ) $$ = FALSE_VAL;
    }

    | exprB OR exprB {
        if($1 == FALSE_VAL || $3 == FALSE_VAL) $$ = FALSE_VAL;
        if($1 == FALSE_VAL || $3 == TRUE_VAL ) $$ = TRUE_VAL;
        if($1 == TRUE_VAL  || $3 == FALSE_VAL) $$ = TRUE_VAL;
        if($1 == TRUE_VAL  || $3 == TRUE_VAL ) $$ = TRUE_VAL;
    }

    | NOT exprB { $$ = $2 == TRUE_VAL ? FALSE_VAL : TRUE_VAL; }

    | INT_NUM { $$ = $1 == 0 ? FALSE_VAL : TRUE_VAL; }

    | FLOAT_NUM { $$ = $1 == 0 ? FALSE_VAL : TRUE_VAL; }

    | LONG_INT_NUM { $$ = $1 == 0 ? FALSE_VAL : TRUE_VAL; }

    | STRING_VAL {
        $$ = strcmp($1, "") == 0 ? FALSE_VAL : TRUE_VAL;
        free($1);
    }

    | ID {
        problem = 1;
        $$ = 0;
        char* errorMes = str("undeclared variable ");
        concat(errorMes, $1);
        free($1);
        yyerror(errorMes);
    }

    | BOOL_ID {
        int is_found = NOT_FOUND;
        int res = getBoolFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
    
    | INT_ID {
        int is_found = NOT_FOUND;
        int res = getIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res == 0 ? FALSE_VAL : TRUE_VAL;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
    
    | FLOAT_ID {
        int is_found = NOT_FOUND;
        float res = getFloatFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res == 0 ? FALSE_VAL : TRUE_VAL;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
    
    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        long int res = getLongIntFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res == 0 ? FALSE_VAL : TRUE_VAL;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }
    
    | STRING_ID {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = strcmp(res, "") != 0 ? TRUE_VAL : FALSE_VAL;
            free(res);
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free(res);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | LPAREN exprB RPAREN { $$ = $2; }
;

exprS:
    STRING_VAL { $$ = $1; }

    | ID {
        problem = 1;
        $$ = "";
        char* errorMes = str("undeclared variable ");
        concat(errorMes, $1);
        free($1);
        yyerror(errorMes);
    }

    | INT_ID {
        int is_found = NOT_FOUND;
        char* res = intToString(getIntFromId($1, &is_found), res);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | FLOAT_ID {
        int is_found = NOT_FOUND;
        char* res = floatToString(getFloatFromId($1, &is_found), res);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | LONG_INT_ID {
        int is_found = NOT_FOUND;
        char* res = longIntToString(getLongIntFromId($1, &is_found), res);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | BOOL_ID {
        int is_found = NOT_FOUND;
        char* res = boolToString(getBoolFromId($1, &is_found), res);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    | STRING_ID {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            char* errorMes = str("undeclared variable ");
            concat(errorMes, $1);
            free(res);
            free($1);
            yyerror(errorMes);
            YYABORT;
        }
    }

    // maybe i can add exprI COLON exprI COLON exprI where second exprI is step
    | STRING_ID LPAREN exprI RPAREN {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = charToString(enhancedCharAt(res,$3));
        free(res);
        free($1);
    }

    | STRING_ID LPAREN COLON RPAREN {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, 0, strlen(res) - 1);
        free(res);
        free($1);
    }

    | STRING_ID LPAREN COLON exprI RPAREN {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, 0, $4);
        free(res);
        free($1);
    }
    
    | STRING_ID LPAREN exprI COLON RPAREN {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, $3, strlen(res) - 1);
        free(res);
        free($1);
    }

    | STRING_ID LPAREN exprI COLON exprI RPAREN {
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, $3, $5);
        free(res);
        free($1);
    }

    | INT_NUM { char* num = intToString($1, num); $$ = num; }

    | FLOAT_NUM { char* num = floatToString($1, $$); $$ = num; }

    | LONG_INT_NUM { char* num = longIntToString($1, $$); $$ = num; }

    | BOOL_VAL { char* num = boolToString($1, $$); $$ = num; }

    | exprS PLUS exprS { concat(&$1, $3); $$ = $1; free($3); }

    | LPAREN exprS RPAREN { $$ = $2; }
;

%%
// if i put a bigger number than the max it will rise an error but if the expr is bigger it will overflow. Be careful
int main(int argc, char** argv) {
    char* name1 = str("ifExprStack");
    ifExprStack = createIntStack(name1);
    char* name2 = str("ifSkipBlockStack");
    ifSkipBlockStack = createIntStack(name2);
    char* name3 = str("elseExprStack");
    elseExprStack = createIntStack(name3);
    char* name4 = str("whileExprStack");
    whileExprStack = createIntStack(name4);

    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) { perror("Cannot open file"); return 1; }
    } else yyin = stdin; // fallback to keyboard input

    yyparse();
    freeAllMemory();
    freeIntStack(ifExprStack);
    freeIntStack(ifSkipBlockStack);
    freeIntStack(elseExprStack);
    freeIntStack(whileExprStack);
    return 0;
}

// i have to colorize the msg from the begging not now except if i make a temp
int yyerror(char* msg) {
    printf("%s%s%s:%d in %s\n", C_RED, C_RESET, msg, yylineno, yytext);
    free(msg);
    return 1;
}