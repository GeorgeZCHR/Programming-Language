%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <float.h>
#include "geo.tab.h"
#include "include/safe_math.h"
#include "include/strman.h"
#include "include/types.h"
#include "include/element.h"
#include "include/stack.h"

extern FILE *yyin;
extern int yyparse();
YY_BUFFER_STATE yy_create_buffer(FILE* file, int size);
void yy_switch_to_buffer(YY_BUFFER_STATE new_buffer);
void yy_delete_buffer(YY_BUFFER_STATE buffer);

extern int skip_block;
extern int loop;
extern IntStack* ifExprStack;
extern IntStack* elseExprStack;
extern IntStack* whileExprStack;
extern int checkPreviousIfs();

int col = 1;

int brace_depth = 0;
int temp_if_res;
int if_found = 0;
int else_if_found = 0;
int fi_found = 0;
int pop_else_cnt = 0;

int while_found = 0;

char* stringText;
int is_in_loop = 0;

int parse_subfile(const char* filename) {
  FILE* f = fopen(filename, "r");
  if (!f) return 0;

  YY_BUFFER_STATE saved = YY_CURRENT_BUFFER;
  YY_BUFFER_STATE newbuf = yy_create_buffer(f, YY_BUF_SIZE);
  yy_switch_to_buffer(newbuf);

  yyparse();

  yy_switch_to_buffer(saved);
  yy_delete_buffer(newbuf);
  fclose(f); return 1;
}

%}

%option yylineno
%x COMMENT
%x SKIP_BLOCK
%x STRING_APPEAR
%x BACKSLASH

ws0     	      [ \t]*
ws1               [ \t]+
letter  	      [A-Za-z_]
nzdigit 	      [1-9]
digit             (0|{nzdigit})
digits            {digit}+
symbol            [!@#\$%\^&*()_+\-={}\[\]|:;\'<>,.?/~`]
id     	          {letter}({letter}|{digit}){0,62}
string            ({letter}|{digit}|{symbol}|{ws0})*
number            ({digits})
numberWithDecimal (((({nzdigit}{digit}*)|0)\.{number})|{number})
noBraces          ([^{}]|\n)

%%

{ws0} { col += yyleng; }
\n    { col = 1; }

\"    {
          stringText = str("");
          BEGIN(STRING_APPEAR);
      }

"<=>" { col += yyleng; return SWAP; }
"+" { col += yyleng; return PLUS; }
"-" { col += yyleng; return MINUS; }
"*" { col += yyleng; return MUL; }
"/" { col += yyleng; return DIV; }
"%" { col += yyleng; return MOD; }
"^" { col += yyleng; return POW; }
"(" { col += yyleng; return LPAREN; }
")" { col += yyleng; return RPAREN; }
";" { col += yyleng; return SEM; }
"=" { col += yyleng; return ASSIGN; }
"," { col += yyleng; return COMMA; }
"[" { col += yyleng; return LBRACKET; }
"]" { col += yyleng; return RBRACKET; }

"{" {
        col += yyleng;

        if(elementIntAt(elseExprStack, elseExprStack->top) != -1) pop_else_cnt++;

        if(peekInt(elseExprStack)) {
            if (checkPreviousIfs()){
                if (peekInt(ifExprStack) == TRUE_VAL) skip_block = 1;
            }
            else skip_block = 1;
        }
        printf("--skip_block = %d--\n", skip_block);
        printIntStack(ifExprStack);
        if(skip_block) {
            printf("SKIP\n");
            brace_depth++;
            BEGIN(SKIP_BLOCK);
        }
        else {
            printf("NO SKIP\n");
            return LBRACE;
        }
    }

"}" {
        col += yyleng;
        pop_else_cnt--;
        if(elementIntAt(elseExprStack, elseExprStack->top) != -1 && pop_else_cnt == 0) popInt(elseExprStack);

        if(peekInt(elseExprStack)) popAndPushInt(elseExprStack, 0);

        if(!isIntStackEmpty(ifExprStack)) temp_if_res = popInt(ifExprStack);

        return RBRACE;
    }

":"     { col += yyleng; return COLON; }
"=="    { col += yyleng; return EQ; }
"!="    { col += yyleng; return NEQ; }
">"     { col += yyleng; return GT; }
"<"     { col += yyleng; return LT; }
">="    { col += yyleng; return GTE; }
"<="    { col += yyleng; return LTE; }
"&&"    { col += yyleng; return AND; }
"||"    { col += yyleng; return OR; }
"!"     { col += yyleng; return NOT; }

"if"    {
            col += yyleng;
            temp_if_res = -1;
            return IF;
        }

"else"  {
            col += yyleng;
            pushInt(elseExprStack, 1);
            if(temp_if_res != -1) pushInt(ifExprStack, temp_if_res);
            return ELSE;
        }

"while" {
            col += yyleng;
            while_found = 1;
            return WHILE;
        }

"print"     { col += yyleng; return PRINT; }
"scan"      { col += yyleng; return SCAN; }
"long"      { col += yyleng; return LONG; }
"int"       { col += yyleng; return INT; }
"float"     { col += yyleng; return FLOAT; }
"string"    { col += yyleng; return STRING; }
"bool"      { col += yyleng; return BOOL; }
"all"       { col += yyleng; return ALL; }
"include"   { col += yyleng; return INCLUDE; }

"true"  {
            col += yyleng;
            yylval.boolVal = TRUE_VAL;
            return BOOL_VAL;
        }

"false" {
            col += yyleng;
            yylval.boolVal = FALSE_VAL;
            return BOOL_VAL;
        }

"//".*  { col += yyleng; /* Ignore single comment line */ }
"/*"    { BEGIN(COMMENT); }
"exit"  { col += yyleng; return EXIT; }

{number}  {
            col += yyleng;
            int type = checkInteger(yytext);
            if(type == T_INT) {
                //printf("int\n");
                yylval.intVal = atoi(yytext);
                return INT_NUM;
            }
            if(type == T_LONG_INT) {
                //printf("long int\n");
                yylval.longIntVal = atol(yytext);
                return LONG_INT_NUM;
            }
            if(type == IT_IS_MAX_LONG_INT) {
                //printf("long int max\n");
                yylval.longIntVal = MAX_LONG_INT;
                return LONG_INT_NUM;
            }
            if(type == IT_IS_MIN_LONG_INT) {
                //printf("long int min\n");
                yylval.longIntVal = MIN_LONG_INT;
                return LONG_INT_NUM;
            }
            if(type == NOT_A_NUMBER) {
                //printf("not a num\n");
                return NOT_A_NUM;
            }
          }

{numberWithDecimal} {
                        col += yyleng;
                        yylval.floatVal = atof(yytext);
                        return FLOAT_NUM;
                    }

{id}  {
          col += yyleng;
          int type = getType(yytext);
          switch(type) {
              case INT_TYPE:{
                  yylval.intIdName = strdup(yytext);
                  return INT_ID;
              }
              case FLOAT_TYPE:{
                  yylval.floatIdName = strdup(yytext);
                  return FLOAT_ID;
              }
              case LONG_INT_TYPE:{
                  yylval.longIntIdName = strdup(yytext);
                  return LONG_INT_ID;
              }
              case BOOL_TYPE:{
                  yylval.boolIdName = strdup(yytext);
                  return BOOL_ID;
              }
              case STRING_TYPE:{
                  yylval.stringIdName = strdup(yytext);
                  return STRING_ID;
              }
              case INDEX_NOT_FOUND:{
                  yylval.idName = strdup(yytext);
                  return ID;
              }
          }
      }

.     { col += yyleng; return ERROR; /* Bison can't handle this so error :) */}

<COMMENT>{
  "*/"  {
            col += yyleng;
            /* if(is_in_loop) BEGIN(LOOP);
            else  */BEGIN(INITIAL);
        }

  .|\n  { col += yyleng; /* skip comment content */ }
}

<SKIP_BLOCK>{
  "{"   {
            col += yyleng;
            brace_depth++;
            if(elementIntAt(elseExprStack, elseExprStack->top) != -1) pop_else_cnt++;
        }

  "}"   {
            col += yyleng;
            brace_depth--;
            pop_else_cnt--;

            if(elementIntAt(elseExprStack, elseExprStack->top) != -1 && pop_else_cnt == 0) popInt(elseExprStack);

            printf("brace depth = %d\n", brace_depth);

            if(!isIntStackEmpty(ifExprStack)) temp_if_res = popInt(ifExprStack);

            if(brace_depth == 0) {  
                printf("UNSKIP\n");
                skip_block = 0;
                BEGIN(INITIAL);
                if(peekInt(elseExprStack)) popAndPushInt(elseExprStack, 0);
                return BLOCK;
            }
        }

  {noBraces}  { col += yyleng;  /* skip block content */  }
}

<STRING_APPEAR>{
  "\\"      { BEGIN(BACKSLASH); }

  {string}  {
                col += yyleng;
                concat(&stringText, yytext);
            }

  "\""      {
                col += 1;
                yylval.stringVal = stringText;
                BEGIN(INITIAL);
                return STRING_VAL;
            }
}

<BACKSLASH>{
  "n"   {
            col += 1;
            concat(&stringText, "\n");
            BEGIN(STRING_APPEAR);             /* maybe add colors */
        }

  "t"   {
            col += 4;
            concat(&stringText, "    ");
            BEGIN(STRING_APPEAR);             /* maybe vars to tell how much \n \t */
        }

  "\\"  {
            col += 1;
            concat(&stringText, "\\");
            BEGIN(STRING_APPEAR);
        }
}

%%