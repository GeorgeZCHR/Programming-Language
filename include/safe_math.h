#ifndef SAFE_MATH_H
#define SAFE_MATH_H

#include "scanner.h"

#define NOT_A_NUMBER -1
#define T_INT 0
#define T_LONG_INT 1
#define T_FLOAT 2
#define T_DOUBLE 3
#define T_LONG_DOUBLE 4

#define MAX_INT 2147483647
#define MIN_INT -2147483648
#define MAX_LONG_INT 9223372036854775807
#define MIN_LONG_INT (-9223372036854775808LL)

#define IT_IS_MAX_LONG_INT 1000
#define IT_IS_MIN_LONG_INT 1001

extern int nan_error;

int isNumber(const char *str);
int checkInteger(const char* text);
int getIntPartFromStr(char* numtext);
int getIntPart(long int num);
float getFloatPart(double num);
int isSmallerThanLongMax(const char *numStr);
int isBiggerThanLongMin(const char *numStr);
long int getLongIntPart(const char* text);
long int getLongIntPartFromLongInt(long int num);
int checkFloatingPoint(const char* text);
int intAdd(long int num1, long int num2);
int intSub(long int num1, long int num2);
int intMul(long int num1, long int num2);
int intDiv(long int num1, long int num2);
int intMod(long int num1, long int num2);
int intPow(long int num1, long int num2);
float floatAdd(double num1, double num2);
float floatSub(double num1, double num2);
float floatMul(double num1, double num2);
float floatDiv(double num1, double num2);
float floatPow(double num1, double num2);
//long int longIntAdd(long int num1, long int num2);

#endif