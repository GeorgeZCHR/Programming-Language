#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/safe_math.h"
#include "../include/scanner.h"

int scan_int(const char* message) {
    char buffer[256];
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    return getIntPartFromStr(buffer);
}

float scan_float(const char* message) {
    char buffer[256], junk;
    double value;
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    if (sscanf(buffer, "%lf %c", &value, &junk) == 1) return getFloatPart(value);
    else { nan_error = 1; return 0; }
}

long int scan_long_int(const char* message) {
    char buffer[256];
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    return getLongIntPart(buffer);
}