%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <unistd.h>
#include <sys/select.h>
#include "include/colors.h"
#include "include/strman.h"
#include "include/types.h"
#include "include/safe_math.h"
#include "include/element.h"
#include "include/stack.h"
#include "include/scanner.h"
#include "long_long_int.h"

#define BLOCK_OK 0
#define BLOCK_SKIP 1

int yylex(void);
int yyerror(char* msg);

int problem = 0;
int skip_block = 0;
int loop = 0;

// πρεπει να βρω τροπο το skip_block να το κραταω για οσο ειμαι μεσα σε if και οταν τελειωσει να φευγει
// η καλυτερη λυση μου ειναι stack απλως δεν ξερω ποτε να το βγαλω δεν εχω βρει καποιο triger

// I need to protect the scan() from wrong types or buffer overflow

// There is no protection against buffer overflow for long int when there are exprs like add,sub,mul,....

extern FILE *yyin;
extern int yylineno;
extern int col;
extern int yyleng;
extern char* yytext;
extern int parse_subfile(const char* filename);

extern int temp_if_res;
extern int nan_error;
extern int nab_error;
extern int nas_error;

IntStack* ifExprStack = NULL;
IntStack* ifSkipBlockStack = NULL;
IntStack* elseExprStack = NULL;
IntStack* whileExprStack = NULL;

int intRes;
float floatRes;
long int longIntRes;
int boolRes;
char* stringRes = NULL;
char* lastID = NULL;

// Chat-GPT obviously :)
void flush_stdin() {
    struct timeval tv = {0, 0}; // No wait
    fd_set fds;
    int ch;

    do {
        FD_ZERO(&fds);
        FD_SET(STDIN_FILENO, &fds);
        if (select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) > 0) {
            while ((ch = getchar()) != EOF && ch != '\n');
        } else {
            break;
        }
    } while (1);
}

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
            concat(&errorMes, id);
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
            concat(&errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(&errorMes, id);
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
            concat(&errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(&errorMes, id);
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
            concat(&errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(&errorMes, id);
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
            concat(&errorMes, id);
            free(id);
            yyerror(errorMes);
        }
        else {
            problem = 1;
            char* errorMes = str("allready declared (in different type) ");
            concat(&errorMes, id);
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

void syntaxError() { yyerror(str("syntax error")); }

void divWithZeroError() { yyerror(str("division with 0 as denominator error")); }

void modWithZeroError() { yyerror(str("modulus with 0 as denominator error")); }

void tooBigNumError() { yyerror(str("too long number error")); }

void invalidCastingError() { yyerror(str("invalid casting error")); }

void nanError() { yyerror(str("not a number error")); }

void nabError() { yyerror(str("not a boolean error")); }

void nasError() { yyerror(str("not a string error")); }

void allreadyDeclaredVarError(char* id) {
    char* errorMes = str("allready declared variable ");
    concat(&errorMes, id);
    yyerror(errorMes);
}

void allreadyDeclaredWithOtherTypeVarError(char* id) {
    char* errorMes = str("allready declared with other type variable ");
    concat(&errorMes, id);
    yyerror(errorMes);
}

void undeclaredVariableError(char* id) {
    char* errorMes = str("undeclared variable ");
    concat(&errorMes, id);
    free(id);
    yyerror(errorMes);
}

void undeclaredSwappedVarError(char* id) {
    char* errorMes = str("undeclared and swapped ");
    concat(&errorMes, id);
    free(id);
    yyerror(errorMes);
}

int getIntFromIdHelper(char* id) {
    int is_found = NOT_FOUND;
    int res = getIntFromId(id, &is_found);
    if(is_found == FOUND) {
        intRes = res;
        free(id);
        return 0;
    }
    else {
        undeclaredVariableError(id);
        return 1;
    }
}

int getFloatFromIdHelper(char* id) {
    int is_found = NOT_FOUND;
    float res = getFloatFromId(id, &is_found);
    if(is_found == FOUND) {
        floatRes = res;
        free(id);
        return 0;
    }
    else {
        undeclaredVariableError(id);
        return 1;
    }
}

int getLongIntFromIdHelper(char* id) {
    int is_found = NOT_FOUND;
    long int res = getLongIntFromId(id, &is_found);
    if(is_found == FOUND) {
        longIntRes = res;
        free(id);
        return 0;
    }
    else {
        undeclaredVariableError(id);
        return 1;
    }
}

int getBoolFromIdHelper(char* id) {
    int is_found = NOT_FOUND;
    int res = getBoolFromId(id, &is_found);
    if(is_found == FOUND) {
        boolRes = res;
        free(id);
        return 0;
    }
    else {
        undeclaredVariableError(id);
        return 1;
    }
}

int getStringFromIdHelper(char* id) {
    int is_found = NOT_FOUND;
    char* res = getStringFromId(id, &is_found);
    if(is_found == FOUND) {
        stringRes = NULL;
        stringRes = str("");
        concat(&stringRes, res);
        free(res);
        free(id);
        return 0;
    }
    else {
        free(res);
        undeclaredVariableError(id);
        return 1;
    }
}

void setLastID(char* id) {
    if(lastID != NULL) {
        free(lastID);
    }
    lastID = NULL;
    lastID = str("");
    concat(&lastID, id);
}

%}

%debug

%token PLUS MINUS MUL DIV MOD POW
%token LPAREN RPAREN LBRACKET RBRACKET LBRACE RBRACE SEM ASSIGN COMMA COLON
%token EQ NEQ GT LT GTE LTE AND OR NOT SWAP
%token IF ELSE WHILE BLOCK INCLUDE
%token PRINT SCAN INT LONG FLOAT STRING BOOL ALL ERROR EXIT
%token TOO_LONG_NUMBER_ERR NOT_A_NUM

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
    | swap SEM stmts
    | printFunc SEM stmts
    | stmtIF
    | stmtWHILE
    | block stmts
    | includeCode
    | spcl
;

swap:
    ID SWAP ID { undeclaredSwappedVarError($1); undeclaredSwappedVarError($3); YYABORT; }

    // Because it's starting with ID there will be no difference from the others like exprI,... so only this func is needed
    | ID SWAP exprI { undeclaredSwappedVarError($1); YYABORT; }

    | INT_ID SWAP exprI {
        if(problem) { free($1); YYABORT; }
        else {
            int is_found = NOT_FOUND;
            int temp = getIntFromId($1, &is_found);
            if(is_found == NOT_FOUND) { undeclaredVariableError($1); YYABORT; }
            setInt($1, $3);
            setInt(lastID, temp);
            free($1);
        }
    }

    | FLOAT_ID SWAP exprF {
        if(problem) { free($1); YYABORT; }
        else {
            int is_found = NOT_FOUND;
            float temp = getFloatFromId($1, &is_found);
            if(is_found == NOT_FOUND) { undeclaredVariableError($1); YYABORT; }
            setFloat($1, $3);
            setFloat(lastID, temp);
            free($1);
        }
    }

    | LONG_INT_ID SWAP exprLI {
        if(problem) { free($1); YYABORT; }
        else {
            int is_found = NOT_FOUND;
            long int temp = getLongIntFromId($1, &is_found);
            if(is_found == NOT_FOUND) { undeclaredVariableError($1); YYABORT; }
            setLongInt($1, $3);
            setLongInt(lastID, temp);
            free($1);
        }
    }

    | BOOL_ID SWAP exprB {
        if(problem) { free($1); YYABORT; }
        else {
            int is_found = NOT_FOUND;
            int temp = getBoolFromId($1, &is_found);
            if(is_found == NOT_FOUND) { undeclaredVariableError($1); YYABORT; }
            setBool($1, $3);
            setBool(lastID, temp);
            free($1);
        }
    }

    | STRING_ID SWAP exprS {
        if(problem) { free($1); YYABORT; }
        else {
            int is_found = NOT_FOUND;
            char* temp = getStringFromId($1, &is_found);
            if(is_found == NOT_FOUND) { undeclaredVariableError($1); YYABORT; }
            setString($1, $3);
            setString(lastID, temp);
            free($1);
        }
    }
;

includeCode:
    INCLUDE exprS {
        // this is a real mid-rule action!
        if (!parse_subfile($2)) {
            char* errorMes = str("file does not exist --- ");
            concat(&errorMes, $2);
            yyerror(errorMes);
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

    | ERROR { syntaxError(); YYABORT; }
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
            printf("%s%s%s", C_ORANGE, $3, C_RESET);
            free($3);
        }
    }

// if an undeclared id used then memory leak will occur surely except if i use some global var and every time check it
// i did it only for int now i have to do it for float, long int, bool, string
stmtI:
    INT_ID ASSIGN exprI {
        if(problem || nan_error) {
            free($1);
            YYABORT;
        }
        else {
            setInt($1, $3);
            free($1);
        }
    }

    | INT_ID ASSIGN SCAN LPAREN RPAREN {
        int temp = scan_int("");
        if(nan_error) {
            free($1);
            nanError();
            YYABORT;
        }
        setInt($1, temp);
        free($1);
    }

    | INT_ID ASSIGN SCAN LPAREN exprS RPAREN {
        int temp = scan_int($5);
        if(nan_error) {
            free($1);
            free($5);
            nanError();
            YYABORT;
        }
        setInt($1, temp);
        free($1);
        free($5);
    }

    | INT_ID ASSIGN idAssignmentsI {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsI {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | ID ASSIGN exprI {
        undeclaredVariableError($1);
        YYABORT;
    }

    | INT declareListI { if(problem || nan_error) YYABORT; }

    | INT ID SWAP exprI {
        if(problem) YYABORT;
        else { undeclaredSwappedVarError($2); YYABORT; }
    }
;

declareListI:
    assignmentI
    | declareListI COMMA assignmentI
;

assignmentI:
    ID ASSIGN exprI {
        if(nan_error) intAssignment($1, 0);
        else intAssignment($1, $3);
    }

    | ID ASSIGN SCAN LPAREN RPAREN {
        int temp = scan_int("");
        if(nan_error) { free($1); nanError(); YYABORT; }
        intAssignment($1, temp);
    }

    | INT_ID ASSIGN SCAN LPAREN RPAREN {
        int temp = scan_int("");
        if(nan_error) { free($1); nanError(); YYABORT; }
        intAssignment($1, temp);
    }

    | ID ASSIGN SCAN LPAREN exprS RPAREN {
        int temp = scan_int($5);
        if(nan_error) {
            free($1);
            free($5);
            nanError();
            YYABORT;
        }
        free($5);
        intAssignment($1, temp);
    }

    | ID { intAssignment($1, 0); }

    | INT_ID ASSIGN exprI {
        problem = 1;
        allreadyDeclaredVarError($1);
        free($1);
    }

    | NOT_INT_ID ASSIGN exprI {
        problem = 1;
        allreadyDeclaredWithOtherTypeVarError($1);
        free($1);
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
        concat(&errorMes, $1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(&errorMes, $1);
        yyerror(errorMes);
    }
;

stmtF:
    FLOAT_ID ASSIGN exprF {
        if(problem || nan_error) {
            free($1);
            YYABORT;
        }
        else {
            setFloat($1, $3);
            free($1);
        }
    }

    | FLOAT_ID ASSIGN SCAN LPAREN RPAREN {
        float temp = scan_float("");
        if(nan_error) {
            free($1);
            nanError();
            YYABORT;
        }
        setFloat($1, temp);
        free($1);
    }

    | FLOAT_ID ASSIGN SCAN LPAREN exprS RPAREN {
        float temp = scan_float($5);
        if(nan_error) {
            free($1);
            free($5);
            nanError();
            YYABORT;
        }
        setFloat($1, temp);
        free($1);
        free($5);
    }

    | FLOAT_ID ASSIGN idAssignmentsF {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsF {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | ID ASSIGN exprF {
        undeclaredVariableError($1);
        YYABORT;
    }

    | FLOAT declareListF { if(problem || nan_error) YYABORT; }

    | FLOAT ID SWAP exprF {
        if(problem) YYABORT;
        else { undeclaredSwappedVarError($2); YYABORT; }
    }
;

declareListF:
    assignmentF
    | declareListF COMMA assignmentF
;

assignmentF:
    ID ASSIGN exprF {
        if(nan_error) floatAssignment($1, 0);
        floatAssignment($1, $3);
    }

    | ID ASSIGN SCAN LPAREN RPAREN {
        float temp = scan_float("");
        if(nan_error) { free($1); nanError(); YYABORT; }
        floatAssignment($1, temp);
    }

    | ID ASSIGN SCAN LPAREN exprS RPAREN {
        float temp = scan_float($5);
        if(nan_error) {
            free($1);
            free($5);
            nanError();
            YYABORT;
        }
        free($5);
        floatAssignment($1, temp);
    }

    | ID { floatAssignment($1, 0); }

    | FLOAT_ID ASSIGN exprF {
        problem = 1;
        allreadyDeclaredVarError($1);
        free($1);
    }

    | NOT_FLOAT_ID ASSIGN exprF {
        problem = 1;
        allreadyDeclaredWithOtherTypeVarError($1);
        free($1);
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
        concat(&errorMes, $1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(&errorMes, $1);
        yyerror(errorMes);
    }
;

stmtLI:
    LONG_INT_ID ASSIGN exprLI {
        if(problem || nan_error) {
            free($1);
            YYABORT;
        }
        else {
            setLongInt($1, $3);
            free($1);
        }
    }

    | LONG_INT_ID ASSIGN SCAN LPAREN RPAREN {
        long int temp = scan_long_int("");
        if(nan_error) { free($1); nanError(); YYABORT; }
        setLongInt($1, temp);
        free($1);
    }

    | LONG_INT_ID ASSIGN SCAN LPAREN exprS RPAREN {
        long int temp = scan_long_int($5);
        if(nan_error) { free($1); free($5); nanError(); YYABORT; }
        setLongInt($1, temp);
        free($1);
        free($5);
    }

    | LONG_INT_ID ASSIGN idAssignmentsLI {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }
    
    | ID ASSIGN idAssignmentsLI {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | ID ASSIGN exprLI {
        undeclaredVariableError($1);
        YYABORT;
    }

    | LONG INT declareListLI { if(problem || nan_error) YYABORT; }

    | LONG INT ID SWAP exprLI {
        if(problem) YYABORT;
        else { undeclaredSwappedVarError($3); YYABORT; }
    }
;

declareListLI:
    assignmentLI
    | declareListLI COMMA assignmentLI
;

assignmentLI:
    ID ASSIGN exprLI {
        if(nan_error) longIntAssignment($1, 0);
        longIntAssignment($1, $3);
    }

    | ID ASSIGN SCAN LPAREN RPAREN {
        long int temp = scan_long_int("");
        if(nan_error) { free($1); nanError(); YYABORT; }
        longIntAssignment($1, temp);
    }

    | ID ASSIGN SCAN LPAREN exprS RPAREN {
        long int temp = scan_long_int($5);
        if(nan_error) { free($1); free($5); nanError(); YYABORT; }
        free($5);
        longIntAssignment($1, temp);
    }

    | ID { longIntAssignment($1, 0); }

    | LONG_INT_ID ASSIGN exprLI {
        problem = 1;
        allreadyDeclaredVarError($1);
        free($1);
    }

    | NOT_LONG_INT_ID ASSIGN exprLI {
        problem = 1;
        allreadyDeclaredWithOtherTypeVarError($1);
        free($1);
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
        concat(&errorMes, $1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(&errorMes, $1);
        yyerror(errorMes);
    }
;

stmtB:
    BOOL_ID ASSIGN exprB {
        if(problem) {
            free($1);
            YYABORT;
        }
        else {
            setBool($1, $3);
            free($1);
        }
    }

    | BOOL_ID ASSIGN SCAN LPAREN RPAREN {
        int temp = scan_bool("");
        if(nab_error) { free($1); nabError(); YYABORT; }
        setBool($1, temp);
        free($1);
    }

    | BOOL_ID ASSIGN SCAN LPAREN exprS RPAREN {
        int temp = scan_bool($5);
        if(nab_error) { free($1); free($5); nabError(); YYABORT; }
        setBool($1, temp);
        free($1);
        free($5);
    }

    | BOOL_ID ASSIGN idAssignmentsB {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        }
        else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }

    | ID ASSIGN idAssignmentsB {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | ID ASSIGN exprB {
        undeclaredVariableError($1);
        YYABORT;
    }

    | BOOL declareListB { if(problem) YYABORT; }

    | BOOL ID SWAP exprB {
        if(problem) YYABORT;
        else { undeclaredSwappedVarError($2); YYABORT; }
    }
;

declareListB:
    assignmentB
    | declareListB COMMA assignmentB
;

assignmentB:
    ID ASSIGN exprB { boolAssignment($1, $3); }

    | ID ASSIGN SCAN LPAREN RPAREN {
        int temp = scan_bool("");
        if(nab_error) { free($1); nabError(); YYABORT; }
        boolAssignment($1, temp);
    }

    | ID ASSIGN SCAN LPAREN exprS RPAREN {
        int temp = scan_bool($5);
        if(nab_error) { free($1); free($5); nabError(); YYABORT; }
        free($5);
        boolAssignment($1, temp);
    }

    | ID { boolAssignment($1, TRUE_VAL); }

    | BOOL_ID ASSIGN exprB {
        problem = 1;
        allreadyDeclaredVarError($1);
        free($1);
    }

    | NOT_BOOL_ID ASSIGN exprB {
        problem = 1;
        allreadyDeclaredWithOtherTypeVarError($1);
        free($1);
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
        } else {
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
        concat(&errorMes, $1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(&errorMes, $1);
        yyerror(errorMes);
    }
;

stmtS:
    STRING_ID ASSIGN exprS {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        } else {
            setString($1, $3);
            free($1);
        }
    }

    | STRING_ID ASSIGN SCAN LPAREN RPAREN {
        char* temp = scan_string("");
        if(nas_error) { free($1); free(temp); nasError(); YYABORT; }
        setString($1, temp);
        free($1);
    }

    | STRING_ID ASSIGN SCAN LPAREN exprS RPAREN {
        char* temp = scan_string($5);
        if(nas_error) { free($1); free($5); free(temp); nasError(); YYABORT; }
        setString($1, temp);
        free($1);
        free($5);
    }

    | STRING_ID ASSIGN idAssignmentsS {
        if(problem) {
            free($1);
            free($3);
            YYABORT;
        } else {
            setVarFromId($1, $3);
            free($1);
            free($3);
        }
    }
    
    | ID ASSIGN idAssignmentsS {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | ID ASSIGN exprS {
        undeclaredVariableError($1);
        free($3);
        YYABORT;
    }

    | STRING declareListS { if(problem) YYABORT; }

    | STRING ID SWAP exprS {
        if(problem) YYABORT;
        else { undeclaredSwappedVarError($2); YYABORT; }
    }
;

declareListS:
    assignmentS
    | declareListS COMMA assignmentS
;

assignmentS:
    ID ASSIGN exprS { stringAssignment($1, $3); }

    | ID ASSIGN SCAN LPAREN RPAREN {
        char* temp = scan_string("");
        if(nas_error) { free($1); free(temp); nasError(); YYABORT; }
        stringAssignment($1, temp);
    }

    | ID ASSIGN SCAN LPAREN exprS RPAREN {
        char* temp = scan_string($5);
        if(nas_error) { free($1); free($5); free(temp); nasError(); YYABORT; }
        free($5);
        stringAssignment($1, temp);
    }

    | ID {
        char* str = NULL;
        equall(&str, "");
        stringAssignment($1, str);
    }

    | STRING_ID ASSIGN exprS {
        problem = 1;
        allreadyDeclaredVarError($1);
        free($1);
        free($3);
    }

    | NOT_STRING_ID ASSIGN exprS {
        problem = 1;
        allreadyDeclaredWithOtherTypeVarError($1);
        free($1);
        free($3);
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
        } else {
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
        concat(&errorMes, $1);
        yyerror(errorMes);
    }

    | ID {
        problem = 1;
        $$ = $1;
        char* errorMes = str("undeclared variable ");
        concat(&errorMes, $1);
        yyerror(errorMes);
    }
;

exprI:
    NOT_A_NUM { nan_error = 1; nanError(); $$ = 0; }

    | LPAREN INT RPAREN INT_NUM { $$ = $4; }
    | INT_NUM { $$ = $1; }

    | LPAREN INT RPAREN FLOAT_NUM { $$ = (int)$4; }
    | FLOAT_NUM { $$ = (int)$1; }

    | LPAREN INT RPAREN LONG_INT_NUM { $$ = getIntPart($4); }
    | LONG_INT_NUM { $$ = getIntPart($1); }

    | LPAREN INT RPAREN BOOL_VAL { $$ = $4; }
    | BOOL_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN INT RPAREN STRING_VAL {
        $$ = strcmp($4, "") == 0 ? 0 : 1;
        free($4);
    } // if str == "" then 0 else 1
    | STRING_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        undeclaredVariableError($1);
    }

    | LPAREN INT RPAREN INT_ID {
        setLastID($4);
        if(getIntFromIdHelper($4) == 0) $$ = intRes;
        else YYABORT;
    }

    | INT_ID {
        setLastID($1);
        if(getIntFromIdHelper($1) == 0) $$ = intRes;
        else YYABORT;
    }

    | LPAREN INT RPAREN FLOAT_ID {
        setLastID($4);
        if(getIntFromIdHelper($4) == 0) $$ = intRes;
        else YYABORT;
    }

    | FLOAT_ID {
        setLastID($1);
        if(getIntFromIdHelper($1) == 0) $$ = intRes;
        else YYABORT;
    }

    | LPAREN INT RPAREN LONG_INT_ID {
        setLastID($4);
        if(getIntFromIdHelper($4) == 0) $$ = intRes;
        else YYABORT;
    }

    | LONG_INT_ID {
        setLastID($1);
        if(getIntFromIdHelper($1) == 0) $$ = intRes;
        else YYABORT;
    }

    | LPAREN INT RPAREN BOOL_ID {
        setLastID($4);
        if(getIntFromIdHelper($4) == 0) $$ = intRes;
        else YYABORT;
    }

    | BOOL_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN INT RPAREN STRING_ID {
        setLastID($4);
        if(getIntFromIdHelper($4) == 0) $$ = intRes;
        else YYABORT;
    }

    | STRING_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }
 
    | exprI PLUS exprI { $$ = intAdd($1, $3); }

    | exprI MINUS exprI { $$ = intSub($1, $3); }

    | exprI MUL exprI { $$ = intMul($1, $3); }

    | exprI DIV exprI {
        if ($3 != 0) $$ = intDiv($1, $3);
        else {
            divWithZeroError();
            YYABORT;
        }
    }

    | exprI MOD exprI {
        if ($3 != 0) $$ = intMod($1, $3);
        else {
            modWithZeroError();
            YYABORT;
        }
    }

    | exprI POW exprI { $$ = intPow($1, $3); }

    | LPAREN exprI RPAREN { $$ = $2; }

    | MINUS exprI %prec UMINUS { $$ = -$2; }

    | PLUS exprI %prec UPLUS { $$ = $2; }
;

exprF:
    NOT_A_NUM { nan_error = 1; nanError(); $$ = 0; }

    | LPAREN FLOAT RPAREN FLOAT_NUM { $$ = $4; }
    | FLOAT_NUM { $$ = $1; }

    | LPAREN FLOAT RPAREN INT_NUM { $$ = $4; }
    | INT_NUM { $$ = $1; }

    | LPAREN FLOAT RPAREN LONG_INT_NUM { $$ = getIntPart($4); }
    | LONG_INT_NUM { $$ = getIntPart($1); }

    | LPAREN FLOAT RPAREN BOOL_VAL { $$ = $4; }
    | BOOL_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN FLOAT RPAREN STRING_VAL {
        $$ = strcmp($4, "") == 0 ? 0 : 1;
        free($4);
    }
    | STRING_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        undeclaredVariableError($1);
    }

    | LPAREN FLOAT RPAREN FLOAT_ID {
        setLastID($4);
        if(getFloatFromIdHelper($4) == 0) $$ = floatRes;
        else YYABORT;
    }

    | FLOAT_ID {
        setLastID($1);
        if(getFloatFromIdHelper($1) == 0) $$ = floatRes;
        else YYABORT;
    }

    | LPAREN FLOAT RPAREN INT_ID {
        setLastID($4);
        if(getFloatFromIdHelper($4) == 0) $$ = floatRes;
        else YYABORT;
    }

    | INT_ID {
        setLastID($1);
        if(getFloatFromIdHelper($1) == 0) $$ = floatRes;
        else YYABORT;
    }

    | LPAREN FLOAT RPAREN LONG_INT_ID {
        setLastID($4);
        if(getFloatFromIdHelper($4) == 0) $$ = floatRes;
        else YYABORT;
    }

    | LONG_INT_ID {
        setLastID($1);
        if(getFloatFromIdHelper($1) == 0) $$ = floatRes;
        else YYABORT;
    }

    | LPAREN FLOAT RPAREN BOOL_ID {
        setLastID($4);
        if(getFloatFromIdHelper($4) == 0) $$ = floatRes;
        else YYABORT;
    }

    | BOOL_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN FLOAT RPAREN STRING_ID {
        setLastID($4);
        if(getFloatFromIdHelper($4) == 0) $$ = floatRes;
        else YYABORT;
    }

    | STRING_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }


    | exprF PLUS exprF { $$ = floatAdd($1, $3); }

    | exprF MINUS exprF { $$ = floatSub($1, $3); }

    | exprF MUL exprF { $$ = floatMul($1, $3); }
    
    | exprF DIV exprF {
        if ($3 != 0) $$ = floatDiv($1, $3);
        else {
            divWithZeroError();
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
    NOT_A_NUM { nan_error = 1; nanError(); $$ = 0; }

    | LPAREN LONG INT RPAREN LONG_INT_NUM { $$ = $5; }
    | LONG_INT_NUM { $$ = $1; }

    | LPAREN LONG INT RPAREN INT_NUM { $$ = (long int)$5; }
    | INT_NUM { $$ = (long int)$1; }

    | LPAREN LONG INT RPAREN FLOAT_NUM { $$ = (long int)$5; }
    | FLOAT_NUM { $$ = (long int)$1; }

    | LPAREN LONG INT RPAREN BOOL_VAL { $$ = (long int)$5; }
    | BOOL_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN LONG INT RPAREN STRING_VAL {
        $$ = (long int)(strcmp($5, "") == 0 ? 0 : 1);
        free($5);
    }
    | STRING_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        undeclaredVariableError($1);
    }

    | LPAREN LONG INT RPAREN LONG_INT_ID {
        setLastID($5);
        if(getLongIntFromIdHelper($5) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | LONG_INT_ID {
        setLastID($1);
        if(getLongIntFromIdHelper($1) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | LPAREN LONG INT RPAREN INT_ID {
        setLastID($5);
        if(getLongIntFromIdHelper($5) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | INT_ID {
        setLastID($1);
        if(getLongIntFromIdHelper($1) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | LPAREN LONG INT RPAREN FLOAT_ID {
        setLastID($5);
        if(getLongIntFromIdHelper($5) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | FLOAT_ID {
        setLastID($1);
        if(getLongIntFromIdHelper($1) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | LPAREN LONG INT RPAREN BOOL_ID {
        setLastID($5);
        if(getLongIntFromIdHelper($5) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | BOOL_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN LONG INT RPAREN STRING_ID {
        setLastID($5);
        if(getLongIntFromIdHelper($5) == 0) $$ = longIntRes;
        else YYABORT;
    }

    | STRING_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | exprLI PLUS exprLI { $$ = $1 + $3;/* $$ = longIntAdd($1, $3); */ }

    | exprLI MINUS exprLI { $$ = $1 - $3; }

    | exprLI MUL exprLI {
        /* $$ = 1;
        printf("$%ld$", $1);
        LongLongInt num = multiply_long($1, $3);
        printf("%ld %ld", num.parts[1], num.parts[1]); */
        $$ = $1 * $3;
    }

    | exprLI DIV exprLI {
        if ($3 != 0) $$ = $1 / $3;
        else {
            divWithZeroError();
            YYABORT;
        }
    }

    | exprLI MOD exprLI {
        if ($3 != 0) $$ = $1 % $3;
        else {
            modWithZeroError();
            YYABORT;
        }
    }

    | exprLI POW exprLI { $$ = (long int)(pow((double)$1, (double)$3)); }

    | LPAREN exprLI RPAREN { $$ = $2; }

    | MINUS exprLI %prec UMINUS { $$ = -$2; }

    | PLUS exprLI %prec UPLUS { $$ = $2; }
    
    | TOO_LONG_NUMBER_ERR { tooBigNumError(); YYABORT; }
;

exprB:
    LPAREN BOOL RPAREN BOOL_VAL { $$ = $4; }
    | BOOL_VAL { $$ = $1; }

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

    | LPAREN BOOL RPAREN INT_NUM { $$ = $4 == 0 ? FALSE_VAL : TRUE_VAL; }
    | INT_NUM {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN FLOAT_NUM { $$ = $4 == 0 ? FALSE_VAL : TRUE_VAL; }
    | FLOAT_NUM {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN LONG_INT_NUM { $$ = $4 == 0 ? FALSE_VAL : TRUE_VAL; }
    | LONG_INT_NUM {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN STRING_VAL {
        $$ = strcmp($4, "") == 0 ? FALSE_VAL : TRUE_VAL;
        free($4);
    }
    | STRING_VAL {
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        undeclaredVariableError($1);
    }

    | LPAREN BOOL RPAREN BOOL_ID {
        setLastID($4);
        if(getBoolFromIdHelper($4) == 0) $$ = boolRes;
        else YYABORT;
    }

    | BOOL_ID {
        setLastID($1);
        if(getBoolFromIdHelper($1) == 0) $$ = boolRes;
        else YYABORT;
    }

    | LPAREN BOOL RPAREN INT_ID {
        setLastID($4);
        if(getBoolFromIdHelper($4) == 0) $$ = boolRes;
        else YYABORT;
    }

    | INT_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN FLOAT_ID {
        setLastID($4);
        if(getBoolFromIdHelper($4) == 0) $$ = boolRes;
        else YYABORT;
    }

    | FLOAT_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN LONG_INT_ID {
        setLastID($4);
        if(getBoolFromIdHelper($4) == 0) $$ = boolRes;
        else YYABORT;
    }

    | LONG_INT_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN BOOL RPAREN STRING_ID {
        setLastID($4);
        if(getBoolFromIdHelper($4) == 0) $$ = boolRes;
        else YYABORT;
    }

    | STRING_ID {
        setLastID($1);
        problem = 1;
        $$ = 0;
        invalidCastingError();
    }

    | LPAREN exprB RPAREN { $$ = $2; }
;

exprS:
    | LPAREN STRING RPAREN STRING_VAL { $$ = $4; }
    | STRING_VAL { $$ = $1; }

    | LPAREN STRING RPAREN INT_NUM { char* num = intToString($4); $$ = num; }
    | INT_NUM { char* num = intToString($1); $$ = num; }

    | LPAREN STRING RPAREN FLOAT_NUM { char* num = floatToString($4); $$ = num; }
    | FLOAT_NUM { char* num = floatToString($1); $$ = num; }

    | LPAREN STRING RPAREN LONG_INT_NUM { char* num = longIntToString($4); $$ = num; }
    | LONG_INT_NUM { char* num = longIntToString($1); $$ = num; }

    | LPAREN STRING RPAREN BOOL_VAL { char* num = boolToString($4); $$ = num; }
    | BOOL_VAL { char* val = boolToString($1); $$ = val; }

    | ID {
        setLastID($1);
        problem = 1;
        $$ = "";
        undeclaredVariableError($1);
    }

    | LPAREN STRING RPAREN INT_ID {
        setLastID($4);
        if(getStringFromIdHelper($4) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | INT_ID {
        setLastID($1);
        if(getStringFromIdHelper($1) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | LPAREN STRING RPAREN FLOAT_ID {
        setLastID($4);
        if(getStringFromIdHelper($4) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | FLOAT_ID {
        setLastID($1);
        if(getStringFromIdHelper($1) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | LPAREN STRING RPAREN LONG_INT_ID {
        setLastID($4);
        if(getStringFromIdHelper($4) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | LONG_INT_ID {
        setLastID($1);
        if(getStringFromIdHelper($1) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | LPAREN STRING RPAREN BOOL_ID {
        setLastID($4);
        if(getStringFromIdHelper($4) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | BOOL_ID {
        setLastID($1);
        if(getStringFromIdHelper($1) == 0) { $$ = strdup(stringRes); free(stringRes); }
        else YYABORT;
    }

    | LPAREN STRING RPAREN STRING_ID {
        setLastID($4);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($4, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($4);
        }
        else {
            undeclaredVariableError($4);
            free(res);
            YYABORT;
        }
    }

    | STRING_ID {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        if(is_found == FOUND) {
            $$ = res;
            free($1);
        }
        else {
            undeclaredVariableError($1);
            free(res);
            YYABORT;
        }
    }

    // maybe i can add exprI COLON exprI COLON exprI where second exprI is step
    | STRING_ID LPAREN RPAREN {
        setLastID($1);
        $$ = str("");
        free($1);
    }

    | STRING_ID LPAREN exprI RPAREN {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = charToString(enhancedCharAt(res,$3));
        free(res);
        free($1);
    }

    | STRING_ID LPAREN COLON RPAREN {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, 0, strlen(res) - 1);
        free(res);
        free($1);
    }

    | STRING_ID LPAREN COLON exprI RPAREN {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, 0, $4);
        free(res);
        free($1);
    }
    
    | STRING_ID LPAREN exprI COLON RPAREN {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, $3, strlen(res) - 1);
        free(res);
        free($1);
    }

    | STRING_ID LPAREN exprI COLON exprI RPAREN {
        setLastID($1);
        int is_found = NOT_FOUND;
        char* res = getStringFromId($1, &is_found);
        $$ = enhancedSubString(res, $3, $5);
        free(res);
        free($1);
    }

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

    flush_stdin();
    yyparse();
    freeAllMemory();
    freeIntStack(ifExprStack);
    freeIntStack(ifSkipBlockStack);
    freeIntStack(elseExprStack);
    freeIntStack(whileExprStack);
    free(lastID);
    return 0;
}

// i have to colorize the msg from the begging not now except if i make a temp
int yyerror(char* msg) {
    printf("%s%s%s:%s%d %sbefore/after %s%s%s\n",
    C_RED, msg, C_MAGENTA, C_CYAN_B, yylineno, C_MAGENTA, C_ORANGE, yytext, C_RESET);
    free(msg);
    return 1;
}