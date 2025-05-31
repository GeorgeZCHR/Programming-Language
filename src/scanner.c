#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/strman.h"
#include "../include/types.h"
#include "../include/safe_math.h"
#include "../include/scanner.h"

int nab_error = 0;
int nas_error = 0;

int scan_int(const char* message) {
    char buffer[257];
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    return getIntPartFromStr(buffer);
}

float scan_float(const char* message) {
    char buffer[257], junk;
    double value;
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    if (sscanf(buffer, "%lf %c", &value, &junk) == 1) return getFloatPart(value);
    else { nan_error = 1; return 0; }
}

long int scan_long_int(const char* message) {
    char buffer[257];
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, sizeof(buffer), stdin)) nan_error = 1;
    return getLongIntPart(buffer);
}

int scan_bool(const char* message) {
    char* buffer = allocStr(257);
    char* subBuffer;
    int boolean = -1;
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, 256, stdin)) nab_error = 1;
    subBuffer = subStringWithLength(buffer, 0, strlen(buffer) - 1);
    if(strcmp(subBuffer, "false") == 0) boolean = FALSE_VAL;
    if(strcmp(subBuffer, "true") == 0) boolean = TRUE_VAL;
    if(boolean == -1) nab_error = 1;
    free(buffer);
    free(subBuffer);
    return boolean;
}

char* scan_string(const char* message) {
    char* buffer = allocStr(1025);
    char* subBuffer;
    if(strcmp(message, "") != 0) printf("%s", message);
    if (!fgets(buffer, 1024, stdin)) nas_error = 1;
    subBuffer = subStringWithLength(buffer, 0, strlen(buffer) - 1);
    free(buffer);
    return subBuffer;
}