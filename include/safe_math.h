#ifndef SAFE_MATH_H
#define SAFE_MATH_H

#define TOO_LONG_NUMBER_ERROR -1
#define T_INT 0
#define T_LONG_INT 1
#define T_FLOAT 2
#define T_DOUBLE 3
#define T_LONG_DOUBLE 4

#define MAX_INT 2147483647
#define MIN_INT -2147483648

int getIntPart(long int num);
float getFloatPart(double num);
int isSmallerThanLongMax(const char *numStr);
int isBiggerThanLongMin(const char *numStr);
int checkInteger(const char* text);
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

#endif