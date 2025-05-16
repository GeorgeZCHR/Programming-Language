#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include "../include/safe_math.h"
#include "../include/strman.h"

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

int isSmallerThanLongMax(const char *numStr) {
    const char *LONG_MAX_STR = "9223372036854775807";
    int len = strlen(numStr);
    int lenMax = strlen(LONG_MAX_STR);

    if (len < lenMax) return 0;               // Definitely safe
    if (len > lenMax) return 1;               // Too many digits

    return strcmp(numStr, LONG_MAX_STR) > 0;
}

int isBiggerThanLongMin(const char *numStr) {
    const char *LONG_MIN_STR = "-9223372036854775808";
    int len = strlen(numStr);
    int lenMin = strlen(LONG_MIN_STR);

    if (len < lenMin) return 0;               // Definitely safe
    if (len > lenMin) return 1;               // Too many digits

    return strcmp(numStr, LONG_MIN_STR) > 0;
}

int checkInteger(const char* text) {
    long int num = atol(text);
    if(num >= -2147483648 && num <= 2147483647) return T_INT;
    if((text[0] == '-' && isBiggerThanLongMin(text) == 0) ||
       (text[0] != '-' && isSmallerThanLongMax(text) == 0)) return T_LONG_INT;
    return TOO_LONG_NUMBER_ERROR;
}

int checkFloatingPoint(const char* text) {
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