#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <ctype.h>
#include "../include/scanner.h"
#include "../include/safe_math.h"
#include "../include/strman.h"

int nan_error = 0;

int isNumber(const char* str) {
    int dotCounter = 0;
    if(strcmp(str,"+") == 0 || strcmp(str,"-") == 0 || strcmp(str,".") == 0 || strcmp(str,"\n") == 0) return 0;
    if(*str == '-' || *str == '+') str++;
    if(*str == '.') { str++; dotCounter++; }
    if(!*str) return 0;
    while(*str) {
        if(!isdigit((unsigned char)*str)) {
            if(*str == '.') dotCounter++;
            else if(*str == '\n') {}
            else return 0;
        }
        str++;
    }
    if(dotCounter > 1) return 0;
    return 1;
}

int getIntPartFromStr(char* numText) {
    if(!isNumber(numText)) return NOT_A_NUMBER;
    long int num = atol(numText);
    return getIntPart(num);
}

int getIntPart(long int num) {
    if(num >= MIN_INT && num <= MAX_INT) return (int) num;
    if(num < MIN_INT) return MIN_INT;
    if(num > MAX_INT) return MAX_INT;
}

float getFloatPart(double num) {
    if((num >= FLT_MIN && num <= FLT_MAX) || (num >= -FLT_MAX && num <= -FLT_MIN)) return (float) num;
    if(num > FLT_MAX) return FLT_MAX;
    if(num > -FLT_MIN && num < FLT_MIN) return 0;
    if(num < -FLT_MAX) return -FLT_MAX;
}

int isSmallerThanLongMax(const char* numStr) {
    const char* LONG_MAX_STR = "92233720368547758077"; // the last 7 is because of the '\n' from enter
    int len = strlen(numStr);
    int lenMax = strlen(LONG_MAX_STR);

    if (len < lenMax) return 0;               // Definitely safe
    if (len > lenMax) return 1;               // Too many digits

    return strcmp(numStr, LONG_MAX_STR) > 0;
}

int isBiggerThanLongMin(const char* numStr) {
    const char* LONG_MIN_STR = "-92233720368547758088"; // the last 8 is because of the '\n' from enter
    int len = strlen(numStr);
    int lenMin = strlen(LONG_MIN_STR);

    if (len < lenMin) return 0;               // Definitely safe
    if (len > lenMin) return 1;               // Too many digits

    return strcmp(numStr, LONG_MIN_STR) > 0;
}

int checkInteger(const char* text) {
    if(!isNumber(text)) return NOT_A_NUMBER;
    long int num = atol(text);
    if(num >= MIN_INT && num <= MAX_INT) return T_INT;
    // I need a function that will take num and check if it's bigger that Long Max or smaller that Long Min
    // int is_bigger_than_min_long_int = text[0] == '-' && isBiggerThanLongMin(text) == 0;
    // int is_smaller_than_max_long_int = text[0] != '-' && isSmallerThanLongMax(text) == 0;
    // if(is_bigger_than_min_long_int && is_smaller_than_max_long_int) {printf("@@@\n");return T_LONG_INT;}
    // if(is_bigger_than_min_long_int) {printf("###\n");return IT_IS_MAX_LONG_INT;}
    // if(is_smaller_than_max_long_int) {printf("$$$\n");return IT_IS_MIN_LONG_INT;}
    return T_LONG_INT;
}

long int getLongIntPart(const char* text) {
    int res = checkInteger(text);
    if(res == T_INT || res == T_LONG_INT) return (long int) atol(text);
    else if(res == IT_IS_MAX_LONG_INT) return MAX_LONG_INT;
    else if(res == IT_IS_MIN_LONG_INT) return MIN_LONG_INT;
    else if(res == NOT_A_NUMBER) nan_error = 1;
    return 0;
}

long int getLongIntPartFromLongInt(long int num) {
    char* numText = longIntToString(num);
    long int newNum = getLongIntPart(numText);
    free(numText);
    return newNum;
}

int checkFloatingPoint(const char* text) {
    if(!isNumber(text)) return NOT_A_NUMBER;
    double num = atof(text);
    if(num >= FLT_MIN && num <= FLT_MAX)return T_FLOAT;
    else if(num >= DBL_MIN && num <= DBL_MAX) return T_DOUBLE;
    else return T_LONG_DOUBLE;
}

// I dont have a way to check if a number is bigger or smaller than long int or to take the max or min yet
// If some expr is bigger than long_int_max or smaller than long_int_min then OVERFLOW

int intAdd(long int num1, long int num2) { return getIntPart(num1 + num2); }

int intSub(long int num1, long int num2) { return getIntPart(num1 - num2); }

int intMul(long int num1, long int num2) { return getIntPart(num1 * num2); }

int intDiv(long int num1, long int num2) { return getIntPart(num1 / num2); }

int intMod(long int num1, long int num2) { return getIntPart(num1 % num2); }

int intPow(long int num1, long int num2) { return getIntPart((int)(pow((double)num1, (double)num2))); }

float floatAdd(double num1, double num2) { return getFloatPart(num1 + num2); }

float floatSub(double num1, double num2) { return getFloatPart(num1 - num2); }

float floatMul(double num1, double num2) { return getFloatPart(num1 * num2); }

float floatDiv(double num1, double num2) { return getFloatPart(num1 / num2); }

float floatPow(double num1, double num2) { return getFloatPart((pow(num1, num2))); }

/* long int longIntAdd(long int num1, long int num2) {
    // long int num1new = getLongIntPartFromLongInt(num1);
    // long int num2new = getLongIntPartFromLongInt(num2);
    printf("num1new = %ld\n", num1);
    printf("num2new = %ld\n", num2);
    if(num1 >= MAX_LONG_INT/2.0 && num2 >= MAX_LONG_INT/2.0) return MAX_LONG_INT;
    if(num1 <= MIN_LONG_INT/2.0 && num2 <= MIN_LONG_INT/2.0) return MIN_LONG_INT;
    return num1 + num2;
}

long int longIntSub(long int num1, long int num2) {
    long int num1new = getLongIntPartFromLongInt(num1);
    long int num2new = getLongIntPartFromLongInt(num2);
    if(num1new >= MAX_LONG_INT/2.0 && num2new >= MAX_LONG_INT/2.0) return MAX_LONG_INT;
    if(num1new <= MIN_LONG_INT/2.0 && num2new <= MIN_LONG_INT/2.0) return MIN_LONG_INT;
    return num1new + num2new;
} */