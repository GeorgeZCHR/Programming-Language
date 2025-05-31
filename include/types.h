#ifndef TYPES_H
#define TYPES_H

#define INT_TYPE 0
#define FLOAT_TYPE 1
#define LONG_INT_TYPE 2
#define BOOL_TYPE 3
#define STRING_TYPE 4

#define TRUE_VAL 1
#define FALSE_VAL 0
#define NOT_BOOL -1

#define DECLARED 0
#define UNDECLARED_P 1
#define UNDECLARED_S 2

#define INDEX_NOT_FOUND -1
#define FOUND 0
#define NOT_FOUND 1

typedef struct {
    char label[64];
    int value;
} Int;

typedef struct {
    char label[64];
    float value;
} Float;

typedef struct {
    char label[64];
    long int value;
} LongInt;

typedef struct {
    char label[64];
    int value;
} Bool;

typedef struct {
    char label[64];
    char* value;
} String;

void* checkAlloc(void* ptr);
int getIntIndex(const char* label);
int getFloatIndex(const char* label);
int getLongIntIndex(const char* label);
int getBoolIndex(const char* label);
int getStringIndex(const char* label);
int getType(const char* label);
int checkOtherTables(const char* label, int type);
int appendInt(const char* label, int value);
float appendFloat(const char* label, float value);
int appendLongInt(const char* label, long int value);
int appendBool(const char* label, int value);
int appendString(const char* label, char* value);
int setInt(const char* label, int value);
int setFloat(const char* label, float value);
int setLongInt(const char* label, long int value);
int setBool(const char* label, int value);
int setString(const char* label, char* value);
int setVarFromId(const char* p_label, const char* s_label);
int getIntFromId(const char* label, int* is_found);
float getFloatFromId(const char* label, int* is_found);
long int getLongIntFromId(const char* label, int* is_found);
int getBoolFromId(const char* label, int* is_found);
char* getStringFromId(const char* label, int* is_found);
void printIntTable();
void printFloatTable();
void printLongIntTable();
void printBoolTable();
void printStringTable();
void printAllTables();
void printValue(const char* label);
void freeIntTable();
void freeFloatTable();
void freeLongIntTable();
void freeBoolTable();
void freeStringTable();
void freeAllMemory();

#endif

/* stmtIF:
    IF LPAREN exprB RPAREN {  */ 
        /* if(isIntStackEmpty(ifSkipBlockStack)) {
        printf("%sinside if 1%s\n",C_YELLOW,C_RESET);
        pushInt(ifExprStack, $3);
        if(peekInt(ifExprStack) == FALSE_VAL) pushInt(ifSkipBlockStack, 1);
        else pushInt(ifSkipBlockStack, 0);
    } else { 
            printf("%sinside if multiple%s\n",C_YELLOW,C_RESET);
            pushInt(ifExprStack, $3);
            if(peekInt(ifExprStack) == FALSE_VAL) pushInt(ifSkipBlockStack, 1);
            else pushInt(ifSkipBlockStack, 0);
     } */
    /* if(checkPreviousIfs()) {
        pushInt(ifExprStack, $3);
        if(peekInt(ifExprStack) == FALSE_VAL) skip_block = 1;
    } else skip_block = 1;
     } block else_stmts
; */




/* else_stmts:
    end_if
    | ELSE IF LPAREN exprB RPAREN {   */
        /* printf("%selse if%s\n",C_YELLOW,C_RESET);
        if(peekInt(ifExprStack) == TRUE_VAL) popAndPushInt(ifSkipBlockStack, 1);
        else { popAndPushInt(ifExprStack, $4); if(peekInt(ifExprStack) == FALSE_VAL) popAndPushInt(ifSkipBlockStack, 1); } */
        /* if(checkPreviousIfs()) { 
            popAndPushInt(ifExprStack, $4);
            if(peekInt(ifExprStack) == FALSE_VAL) skip_block = 1; }
        else skip_block = 1;                                        } block else_stmts

    | ELSE {  */
        /* printf("%selse%s\n",C_YELLOW,C_RESET);
    if(elementIntAt(ifExprStack, ifExprStack->top - 1) == -1) {
        //printf("111\n");
        if(peekInt(ifExprStack) == TRUE_VAL) popAndPushInt(ifSkipBlockStack, 1);
    } else {
        printf("$$$\n");printIntStack(ifExprStack); printIntStack(ifSkipBlockStack);printf("$$$\n");
        if(elementIntAt(ifExprStack, ifExprStack->top - 1) == FALSE_VAL) {
            popAndPushInt(ifSkipBlockStack, 1);
        }
        if(elementIntAt(ifExprStack, ifExprStack->top - 1) == FALSE_VAL && peekInt(ifExprStack) == TRUE_VAL) {
            popAndPushInt(ifSkipBlockStack, 1);
        }
    } */ 
              /* if (checkPreviousIfs()) {
                if (peekInt(ifExprStack) == TRUE_VAL) {
                    skip_block = 1;
                    printf("skip_block = %d\n", skip_block);
                }
              } else skip_block = 1; */ 
           /*  } block end_if
; */


/* end_if:
    SEM {  */
        /* popForIf(); printf("%sout of if%s\n",C_YELLOW,C_RESET); */ //popInt(ifExprStack);
    /* { printf("This block will not execute\n"); } */
    
    /* {  printf("This block will execute\n"); printIntStack(ifExprStack); printIntStack(ifSkipBlockStack);
                if(peekInt(ifSkipBlockStack)) printf("%sThis block of code won't execute%s\n",C_RED,C_RESET);
                else printf("%sThis block of code will execute%s\n",C_GREEN,C_RESET);                            } */
                
    /* { printf("%sOut of the block%s\n",C_YELLOW,C_RESET);
                    if(peekInt(ifSkipBlockStack)) popAndPushInt(ifSkipBlockStack, 0); } */ 
                /* } stmts
; */