#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/strman.h"
#include "../include/types.h"
#include "../include/colors.h"
#include "../include/safe_math.h"

Int* intTable = NULL;
int intCapacity = 0;  // Allocated size
int intSize = 0;      // Number of actual elements

Float* floatTable = NULL;
int floatCapacity = 0;
int floatSize = 0;

LongInt* longIntTable = NULL;
int longIntCapacity = 0;
int longIntSize = 0;

Bool* boolTable = NULL;
int boolCapacity = 0;
int boolSize = 0;

String* stringTable = NULL;
int stringCapacity = 0;
int stringSize = 0;

void* checkAlloc(void* ptr) {
    if (!ptr) {
        fprintf(stderr, "Memory allocation failed\n");
        exit(EXIT_FAILURE);
    }
    return ptr;
}

int getIntIndex(const char* label) {
    for (int i = 0; i < intSize; i++) {
        if (strcmp(intTable[i].label, label) == 0) return i;
    }
    return -1;
}

int getFloatIndex(const char* label) {
    for (int i = 0; i < floatSize; i++) {
        if (strcmp(floatTable[i].label, label) == 0) return i;
    }
    return -1;
}

int getLongIntIndex(const char* label) {
    for (int i = 0; i < longIntSize; i++) {
        if (strcmp(longIntTable[i].label, label) == 0) return i;
    }
    return -1;
}

int getBoolIndex(const char* label) {
    for (int i = 0; i < boolSize; i++) {
        if (strcmp(boolTable[i].label, label) == 0) return i;
    }
    return -1;
}

int getStringIndex(const char* label) {
    for (int i = 0; i < stringSize; i++) {
        if (strcmp(stringTable[i].label, label) == 0) return i;
    }
    return -1;
}

int getType(const char* label) {
    int idx;
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) return INT_TYPE;
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) return FLOAT_TYPE;
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) return LONG_INT_TYPE;
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) return BOOL_TYPE;
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) return STRING_TYPE;
    return INDEX_NOT_FOUND;
}

int checkOtherTables(const char* label, int type) {
    int idx;
    switch(type) {
        case(INT_TYPE):
            idx = getFloatIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getLongIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getBoolIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getStringIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            break;
        case(FLOAT_TYPE):
            idx = getIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getLongIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getBoolIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getStringIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            break;
        case(LONG_INT_TYPE):
            idx = getIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getFloatIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getBoolIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getStringIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            break;
        case(BOOL_TYPE):
            idx = getIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getFloatIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getLongIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getStringIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            break;
        case(STRING_TYPE):
            idx = getIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getFloatIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getLongIntIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            idx = getBoolIndex(label);
            if(idx != INDEX_NOT_FOUND) return INDEX_NOT_FOUND;
            break;
    }
    return FOUND;
}

int appendInt(const char* label, int value) {
    if(checkOtherTables(label, INT_TYPE) == -1) return -1;
    int idx = getIntIndex(label);
    if(idx == -1) {
        if (intSize >= intCapacity) {
            intCapacity = (intCapacity == 0) ? 8 : intCapacity * 2;
            Int* temp = checkAlloc(realloc(intTable, intCapacity * sizeof(Int)));
            intTable = temp;
        }

        strncpy(intTable[intSize].label, label, sizeof(intTable[intSize].label));
        intTable[intSize].label[sizeof(intTable[intSize].label) - 1] = '\0'; // safe null-termination
        intTable[intSize].value = value;
        // printf("Variable with label %s created with content %d\n", intTable[intSize].label, intTable[intSize].value);
        intSize++;
        return 0;
    }
    return 1;
}

float appendFloat(const char* label, float value) {
    if(checkOtherTables(label, FLOAT_TYPE) == -1) return -1;
    int idx = getFloatIndex(label);
    if(idx == -1) {
        if (floatSize >= floatCapacity) {
            floatCapacity = (floatCapacity == 0) ? 8 : floatCapacity * 2;
            Float* temp = checkAlloc(realloc(floatTable, floatCapacity * sizeof(Float)));
            floatTable = temp;
        }

        strncpy(floatTable[floatSize].label, label, sizeof(floatTable[floatSize].label));
        floatTable[floatSize].label[sizeof(floatTable[floatSize].label) - 1] = '\0'; // safe null-termination
        floatTable[floatSize].value = value;
        // printf("Variable with label %s created with content %g\n", floatTable[floatSize].label, floatTable[floatSize].value);
        floatSize++;
        return 0;
    }
    return 1;
}

int appendLongInt(const char* label, long int value) {
    if(checkOtherTables(label, LONG_INT_TYPE) == -1) return -1;
    int idx = getLongIntIndex(label);
    if(idx == -1) {
        if (longIntSize >= longIntCapacity) {
            longIntCapacity = (longIntCapacity == 0) ? 8 : longIntCapacity * 2;
            LongInt* temp = checkAlloc(realloc(longIntTable, longIntCapacity * sizeof(LongInt)));
            longIntTable = temp;
        }

        strncpy(longIntTable[longIntSize].label, label, sizeof(longIntTable[longIntSize].label));
        longIntTable[longIntSize].label[sizeof(longIntTable[longIntSize].label) - 1] = '\0'; // safe null-termination
        longIntTable[longIntSize].value = value;
        // printf("Variable with label %s created with content %ld\n", longIntTable[longIntSize].label, longIntTable[longIntSize].value);
        longIntSize++;
        return 0;
    }
    return 1;
}

int appendBool(const char* label, int value) {
    if(checkOtherTables(label, BOOL_TYPE) == -1) return -1;
    int idx = getBoolIndex(label);
    if(idx == -1) {
        if (boolSize >= boolCapacity) {
            boolCapacity = (boolCapacity == 0) ? 8 : boolCapacity * 2;
            Bool* temp = checkAlloc(realloc(boolTable, boolCapacity * sizeof(Bool)));
            boolTable = temp;
        }

        strncpy(boolTable[boolSize].label, label, sizeof(boolTable[boolSize].label));
        boolTable[boolSize].label[sizeof(boolTable[boolSize].label) - 1] = '\0'; // safe null-termination
        boolTable[boolSize].value = value;
        // printf("Variable with label %s created with content %d\n", boolTable[boolSize].label, boolTable[boolSize].value);
        boolSize++;
        return 0;
    }
    return 1;
}

int appendString(const char* label, const char* value) {
    if(checkOtherTables(label, STRING_TYPE) == -1) return -1;
    int idx = getStringIndex(label);
    if(idx == INDEX_NOT_FOUND) {
        if (stringSize >= stringCapacity) {
            stringCapacity = (stringCapacity == 0) ? 8 : stringCapacity * 2;
            String* temp = checkAlloc(realloc(stringTable, stringCapacity * sizeof(String)));
            stringTable = temp;
        }

        strncpy(stringTable[stringSize].label, label, sizeof(stringTable[stringSize].label));
        stringTable[stringSize].label[sizeof(stringTable[stringSize].label) - 1] = '\0'; // safe null-termination
        stringTable[stringSize].value = NULL;
        equall(&stringTable[stringSize].value, value);
        free(value);
        // printf("Variable with label %s created with content %s\n", stringTable[stringSize].label, stringTable[stringSize].value);
        stringSize++;
        return 0;
    }
    return 1;
}

int setInt(const char* label, int value) {
    int idx = getIntIndex(label);
    if (idx != INDEX_NOT_FOUND) { intTable[idx].value = value; return DECLARED; }
    return UNDECLARED_P;
}

int setFloat(const char* label, float value) {
    int idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) { floatTable[idx].value = value; return DECLARED; }
    return UNDECLARED_P;
}

int setLongInt(const char* label, long int value) {
    int idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { longIntTable[idx].value = value; return DECLARED; }
    return UNDECLARED_P;
}

int setBool(const char* label, int value) {
    int idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) { boolTable[idx].value = (value == FALSE_VAL ? FALSE_VAL : TRUE_VAL); return DECLARED; }
    return UNDECLARED_P;
}

int setString(const char* label, const char* value) {
    int idx = getStringIndex(label);
    if (idx != INDEX_NOT_FOUND) { equall(&stringTable[idx].value, value); free(value); return DECLARED; }
    free(value);
    return UNDECLARED_P;
}

int setVarFromId(const char* p_label, const char* s_label) {
    int p_idx, s_idx;
    p_idx = getIntIndex(p_label);
    if(p_idx != INDEX_NOT_FOUND) {
        s_idx = getIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { intTable[p_idx].value = intTable[s_idx].value; return DECLARED; }
        s_idx = getFloatIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { intTable[p_idx].value = (int)floatTable[s_idx].value; return DECLARED; }
        s_idx = getLongIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { intTable[p_idx].value = getIntPart(longIntTable[s_idx].value); return DECLARED; }
        s_idx = getBoolIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { intTable[p_idx].value = boolTable[s_idx].value; return DECLARED; }
        s_idx = getStringIndex(s_label);
        if (s_idx != INDEX_NOT_FOUND) { intTable[p_idx].value = 0; return DECLARED; }
        return UNDECLARED_S;
    }

    p_idx = getFloatIndex(p_label);
    if(p_idx != INDEX_NOT_FOUND) {
        s_idx = getIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { floatTable[p_idx].value = intTable[s_idx].value; return DECLARED; }
        s_idx = getFloatIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { floatTable[p_idx].value = floatTable[s_idx].value; return DECLARED; }
        s_idx = getLongIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { floatTable[p_idx].value = getIntPart(longIntTable[s_idx].value); return DECLARED; }
        s_idx = getBoolIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { floatTable[p_idx].value = boolTable[s_idx].value; return DECLARED; }
        s_idx = getStringIndex(s_label);
        if (s_idx != INDEX_NOT_FOUND) { floatTable[p_idx].value = 0; return DECLARED; }
        return UNDECLARED_S;
    }

    p_idx = getLongIntIndex(p_label);
    if(p_idx != INDEX_NOT_FOUND) {
        s_idx = getIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { longIntTable[p_idx].value = intTable[s_idx].value; return DECLARED; }
        s_idx = getFloatIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { longIntTable[p_idx].value = (int)floatTable[s_idx].value; return DECLARED; }
        s_idx = getLongIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { longIntTable[p_idx].value = longIntTable[s_idx].value; return DECLARED; }
        s_idx = getBoolIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) { longIntTable[p_idx].value = boolTable[s_idx].value; return DECLARED; }
        s_idx = getStringIndex(s_label);
        if (s_idx != INDEX_NOT_FOUND) { longIntTable[p_idx].value = 0; return DECLARED; }
        return UNDECLARED_S;
    }

    p_idx = getBoolIndex(p_label);
    if(p_idx != INDEX_NOT_FOUND) {
        s_idx = getIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            boolTable[p_idx].value = (intTable[s_idx].value == FALSE_VAL ? FALSE_VAL : TRUE_VAL);
            return DECLARED;
        }
        s_idx = getFloatIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            boolTable[p_idx].value = (floatTable[s_idx].value == FALSE_VAL ? FALSE_VAL : TRUE_VAL);
            return DECLARED;
        }
        s_idx = getLongIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            boolTable[p_idx].value = (longIntTable[s_idx].value == FALSE_VAL ? FALSE_VAL : TRUE_VAL);
            return DECLARED;
        }
        s_idx = getBoolIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            boolTable[p_idx].value = boolTable[s_idx].value;
            return DECLARED;
        }
        s_idx = getStringIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            if(strcmp(stringTable[s_idx].value, "") == 0) boolTable[p_idx].value = FALSE_VAL;
            else boolTable[p_idx].value = TRUE_VAL;
            return DECLARED;
        }
        return UNDECLARED_S;
    }

    p_idx = getStringIndex(p_label);
    if(p_idx != INDEX_NOT_FOUND) {
        s_idx = getIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            char* str_num = intToString(intTable[s_idx].value, str_num);
            equall(&stringTable[p_idx].value, str_num);
            free(str_num);
            return DECLARED;
        }
        s_idx = getFloatIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            char* str_num = floatToString(floatTable[s_idx].value, str_num);
            equall(&stringTable[p_idx].value, str_num);
            free(str_num);
            return DECLARED;
        }
        s_idx = getLongIntIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            char* str_num = longIntToString(longIntTable[s_idx].value, str_num);
            equall(&stringTable[p_idx].value, str_num);
            free(str_num);
            return DECLARED;
        }
        s_idx = getBoolIndex(s_label);
        if(s_idx != INDEX_NOT_FOUND) {
            equall(&stringTable[p_idx].value, (boolTable[s_idx].value == FALSE_VAL ? "false" : "true"));
            return DECLARED;
        }
        s_idx = getStringIndex(s_label);
        if (s_idx != INDEX_NOT_FOUND) { equall(&stringTable[p_idx].value, stringTable[s_idx].value); return DECLARED; }
        return UNDECLARED_S;
    }
    return UNDECLARED_P;
}

int getIntFromId(const char* label, int* is_found) {
    int idx;
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return intTable[idx].value; }
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return (int)floatTable[idx].value; }
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return getIntPart(longIntTable[idx].value); }
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return boolTable[idx].value; }
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return 0; }
    *is_found = NOT_FOUND;
    return NOT_FOUND;
}

float getFloatFromId(const char* label, int* is_found) {
    int idx;
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return floatTable[idx].value; }
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return intTable[idx].value; }
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return getIntPart(longIntTable[idx].value); }
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return boolTable[idx].value; }
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return 0; }
    *is_found = NOT_FOUND;
    return NOT_FOUND;
}

long int getLongIntFromId(const char* label, int* is_found) {
    int idx;
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return longIntTable[idx].value; }
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return intTable[idx].value; }
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return (long int)floatTable[idx].value; }
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return boolTable[idx].value; }
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return 0; }
    *is_found = NOT_FOUND;
    return NOT_FOUND;
}

int getBoolFromId(const char* label, int* is_found) {
    int idx;
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return boolTable[idx].value; }
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return intTable[idx].value; }
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return (long int)floatTable[idx].value; }
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return longIntTable[idx].value; }
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return 0; }
    *is_found = NOT_FOUND;
    return NOT_FOUND;
}

char* getStringFromId(const char* label, int* is_found) {
    int idx;
    idx = getIntIndex(label);
    if(idx != INDEX_NOT_FOUND) {
        *is_found = FOUND;
        char* str_num = intToString(intTable[idx].value, str_num);
        return str_num;
    }
    idx = getFloatIndex(label);
    if(idx != INDEX_NOT_FOUND) {
        *is_found = FOUND;
        char* str_num = floatToString(floatTable[idx].value, str_num);
        return str_num;
    }
    idx = getLongIntIndex(label);
    if(idx != INDEX_NOT_FOUND) {
        *is_found = FOUND;
        char* str_num = longIntToString(longIntTable[idx].value, str_num);
        return str_num;
    }
    idx = getBoolIndex(label);
    if(idx != INDEX_NOT_FOUND) {
        *is_found = FOUND;
        char* str_num = boolToString(boolTable[idx].value, str_num);
        return str_num;
    }
    idx = getStringIndex(label);
    if(idx != INDEX_NOT_FOUND) { *is_found = FOUND; return strdup(stringTable[idx].value); }
    *is_found = NOT_FOUND;
    return ""; // i will have to update wherever getStringFromId exist and check if return == "" so not found
}

void printIntTable() {
    printf("%sInt Table\n%s--------------------%s\n", C_CYAN_B, C_YELLOW, C_RESET);
    if(intSize == 0) printf("%sEmpty%s\n", C_RED, C_RESET);
    for(int i = 0; i < intSize; i++)
        printf("%s%4d.%s %s %s=%s %d%s\n", C_MAGENTA, i + 1, C_GREEN, intTable[i].label, C_WHITE, C_CYAN,  intTable[i].value, C_RESET);
    printf("%s--------------------%s\n\n", C_YELLOW, C_RESET);
}

void printFloatTable() {
    printf("%sFloat Table\n%s--------------------%s\n", C_CYAN_B, C_YELLOW, C_RESET);
    if(floatSize == 0) printf("%sEmpty%s\n", C_RED, C_RESET);
    for(int i = 0; i < floatSize; i++)
        printf("%s%4d.%s %s %s=%s %g%s\n", C_MAGENTA, i + 1, C_GREEN, floatTable[i].label, C_WHITE, C_CYAN,  floatTable[i].value, C_RESET);
    printf("%s--------------------%s\n\n", C_YELLOW, C_RESET);
}

void printLongIntTable() {
    printf("%sLong Int Table\n%s--------------------%s\n", C_CYAN_B, C_YELLOW, C_RESET);
    if(longIntSize == 0) printf("%sEmpty%s\n", C_RED, C_RESET);
    for(int i = 0; i < longIntSize; i++)
        printf("%s%4d.%s %s %s=%s %ld%s\n", C_MAGENTA, i + 1, C_GREEN, longIntTable[i].label, C_WHITE, C_CYAN,  longIntTable[i].value, C_RESET);
    printf("%s--------------------%s\n\n", C_YELLOW, C_RESET);
}

void printBoolTable() {
    printf("%sBool Table\n%s--------------------%s\n", C_CYAN_B, C_YELLOW, C_RESET);
    if(boolSize == 0) printf("%sEmpty%s\n", C_RED, C_RESET);
    for(int i = 0; i < boolSize; i++)
        printf("%s%4d.%s %s %s=%s %s%s\n", C_MAGENTA, i + 1, C_GREEN, boolTable[i].label, C_WHITE, C_ORANGE, (boolTable[i].value == FALSE_VAL ? "false" : "true"), C_RESET);
    printf("%s--------------------%s\n\n", C_YELLOW, C_RESET);
}

void printStringTable() {
    printf("%sString Table\n%s--------------------%s\n", C_CYAN_B, C_YELLOW, C_RESET);
    if(stringSize == 0) printf("%sEmpty%s\n", C_RED, C_RESET);
    for(int i = 0; i < stringSize; i++)
        printf("%s%4d.%s %s %s= %s\"%s\"%s\n", C_MAGENTA, i + 1, C_GREEN, stringTable[i].label, C_WHITE, C_ORANGE, stringTable[i].value, C_RESET);
    printf("%s--------------------%s\n\n", C_YELLOW, C_RESET);
}

void printAllTables() {
    printIntTable();
    printFloatTable();
    printLongIntTable();
    printBoolTable();
    printStringTable();
}

void printValue(const char* label) {
    int idx;
    idx = getIntIndex(label);
    if (idx != INDEX_NOT_FOUND) {
        printf("%s%s %s= %s%d%s\n", C_GREEN, label, C_WHITE, C_CYAN, intTable[idx].value, C_RESET); return;
    }
    idx = getFloatIndex(label);
    if (idx != INDEX_NOT_FOUND) {
        printf("%s%s %s= %s%g%s\n", C_GREEN, label, C_WHITE, C_CYAN, floatTable[idx].value, C_RESET); return;
    }
    idx = getLongIntIndex(label);
    if (idx != INDEX_NOT_FOUND) {
        printf("%s%s %s= %s%ld%s\n", C_GREEN, label, C_WHITE, C_CYAN, longIntTable[idx].value, C_RESET); return;
    }
    idx = getBoolIndex(label);
    if (idx != INDEX_NOT_FOUND) {
        printf("%s%s %s= %s%s%s\n", C_GREEN, label, C_WHITE, C_ORANGE, (boolTable[idx].value == FALSE_VAL ? "false" : "true"), C_RESET); return;
    }
    idx = getStringIndex(label);
    if (idx != INDEX_NOT_FOUND) {
        printf("%s%s %s= %s\"%s\"%s\n", C_GREEN, label, C_WHITE, C_ORANGE, stringTable[idx].value, C_RESET); return;
    }
    printf("%sVariable %s%s%s does not exist..%s\n", C_RED, C_GREEN, label, C_RED, C_RESET);
}

void freeIntTable() {
    free(intTable);
    intTable = NULL;
    intSize = 0;
    intCapacity = 0;
}

void freeFloatTable() {
    free(floatTable);
    floatTable = NULL;
    floatSize = 0;
    floatCapacity = 0;
}

void freeLongIntTable() {
    free(longIntTable);
    longIntTable = NULL;
    longIntSize = 0;
    longIntCapacity = 0;
}

void freeBoolTable() {
    free(boolTable);
    boolTable = NULL;
    boolSize = 0;
    boolCapacity = 0;
}

void freeStringTable() {
    for (int i = 0; i < stringSize; i++) {
        free(stringTable[i].value);
        stringTable[i].value = NULL;
    }
    free(stringTable);
    stringTable = NULL;
    stringSize = 0;
    stringCapacity = 0;
}

void freeAllMemory() {
    freeIntTable();
    freeFloatTable();
    freeLongIntTable();
    freeBoolTable();
    freeStringTable();
}