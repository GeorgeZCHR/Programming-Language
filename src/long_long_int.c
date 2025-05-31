#include <stdio.h>
#include <stdint.h>
#include "long_long_int.h"

LongLongInt LLInt(long int low, long int high) {
    LongLongInt result;
    result.parts[0] = low;
    result.parts[1] = high;
    return result;
}

LongLongInt multiply_long(long int a, long int b) {
    int isNegative = (a < 0) ^ (b < 0);

    // Work with absolute values
    //int64_t ua = a < 0 ? -((int64_t)a) : (int64_t)a;
    //int64_t ub = b < 0 ? -((int64_t)b) : (int64_t)b;

    // Break each into 32-bit halves
    int64_t a_low = (int32_t)a;
    int64_t a_high = a >> 32;
    printf("a = %lx a_high = %lx a_low = %lx\n", a, a_high, a_low);
    int64_t b_low = (int32_t)b;
    int64_t b_high = b >> 32;

    // Compute partial products
    int64_t ll = a_low * b_low;
    int64_t lh = a_low * b_high;
    int64_t hl = a_high * b_low;
    int64_t hh = a_high * b_high;

    int64_t mid = (ll >> 32) + (lh & 0xFFFFFFFF) + (hl & 0xFFFFFFFF);
    int64_t low = (ll & 0xFFFFFFFF) | (mid << 32);
    int64_t high = hh + (lh >> 32) + (hl >> 32) + (mid >> 32);

    // Apply sign if needed
    if (isNegative) {
        // Two's complement of 128-bit result
        low = ~low + 1;
        high = ~high + (low == 0 ? 1 : 0);
    }

    LongLongInt result;
    result.parts[0] = (long)low;
    result.parts[1] = (long)(isNegative ? -((long)high) - ((low == 0) ? 0 : 1) : high);
    printf("res_high = %lx res_low = %lx\n", result.parts[1], result.parts[0]);
    return result;
}