#ifndef LONG_LONG_INT_H
#define LONG_LONG_INT_H

typedef struct {
    long int parts[2];  // parts[0] = lower 64 bits, parts[1] = upper 64 bits
} LongLongInt;

LongLongInt LLInt(long int low, long int high);
LongLongInt multiply_long(long int a, long int b);

#endif