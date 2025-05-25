#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/strman.h"
#include "../include/types.h"

int overflowIndex(const int idx, const int len) {
    if (idx >= 0 && idx < len) return idx;
    if (idx < 0) return len - ((-1 * idx) - 1) % len - 1; // if len = 3 -1=len-1 -2=len-2 -3=len-3 -4=len-1 -5=len-2
    if (idx >= len) return idx % len;                     // if len = 3  3=0      4=1      5=2      6=0      7=1
}

int indexOf(const char* str, const char c, const int beginIndex) {
    char *ptr = strchr(str + beginIndex, c);
	return (ptr != NULL ? ptr - str : -1);
}

char charAt(const char* str, const int index) {
    if (str == NULL || index < 0 || index >= strlen(str)) return '\0';
    else return str[index];
}

char enhancedCharAt(const char* str, const int index) {
    if (str != NULL) return str[overflowIndex(index, strlen(str))];
    else return '\0';
}

char* allocStr(int length) {
    char *c = checkAlloc((char *)malloc((length + 1) * sizeof(char)));
    c[0] = '\0';
    return c;
}

char* str(char* string) {
    char *c = checkAlloc((char *)malloc((strlen(string) + 1) * sizeof(char)));
    c[0] = '\0';
    concat(&c, string);
    return c;
}

// Helper function to allocate and copy substring
char* substringHelper(const char* str, int beginIndex, int length) {
    int len = strlen(str);
    if (beginIndex >= len) return NULL;
    if (beginIndex + length > len) length = len - beginIndex;

    char* result = allocStr(length);
    strncpy(result, str + beginIndex, length);
    result[length] = '\0'; // Null-terminate the string
    return result;
}

char* enhancedSubstringHelper(const char* str, int beginIndex, int endIndex) {
    int count = 0;
    char* result;
    if(beginIndex < endIndex) {
        result = allocStr(endIndex - beginIndex + 2);
        for(int i = beginIndex; i <= endIndex; i++) { result[count] = charAt(str,i); count++; }
    }
    if(beginIndex > endIndex) {
        result = allocStr(beginIndex - endIndex + 2);
        for(int i = beginIndex; i >= endIndex; i--) { result[count] = charAt(str,i); count++; }
    }
    if(beginIndex == endIndex) { result = allocStr(2); result[count] = charAt(str,beginIndex); count++; }
    result[count] = '\0';
    return result;
}

// Function to get a substring from beginIndex to the end of the string
char* subStringFrom(const char* str, int beginIndex) {
    return substringHelper(str, beginIndex, strlen(str) - beginIndex);
}

// Function to get a substring with a given length
char* subStringWithLength(const char* str, int beginIndex, int length) {
    return substringHelper(str, beginIndex, length);
}

char* enhancedSubString(const char* str, int beginIndex, int length) {
    int len = strlen(str);
    char* string = enhancedSubstringHelper(str, overflowIndex(beginIndex, len), overflowIndex(length, len));
    if(string != NULL) return string;
    else return "";
}

char* generateSeparatorPattern(char priSep, char secSep, int len) {
    len = (len < 0 ? 0 : len);
    int size = len * 2 + 1;
    char *sepPattern = allocStr(size);
    for(int i = 0; i < size; i++) {
        if(i != len) sepPattern[i] = secSep;
        else sepPattern[i] = priSep;
    }
    sepPattern[size] = '\0';
    return sepPattern;
}

void normalizeWithSeparator(char* str, char priSep, char secSep, int sepPatternLen) {
    char *normalizedStr = allocStr(1023);
    normalizedStr[0] = '\0';
    char *part1, *part2;
    char *sepPattern = generateSeparatorPattern(priSep, secSep, sepPatternLen);

    int index = indexOf(str, priSep, 0);
    if (index != -1) {
        part1 = subStringWithLength(str, 0, index); // All before primary seperator
        part2 = subStringFrom(str, index + 1);      // All after  primary seperator

        strcat(normalizedStr, part1);
        free(part1);
        strcat(normalizedStr, sepPattern);
        while ((index = indexOf(part2, priSep, 0)) != -1) {
            part1 = subStringWithLength(part2, 0, index); // All before primary seperator
            part2 = subStringFrom(part2, index + 1);      // All after  primary seperator

            strcat(normalizedStr, part1);
            free(part1);
            strcat(normalizedStr, sepPattern);
        }
        strcat(normalizedStr, part2);
        free(part2);
        //strcpy(str,normalizedStr);
        strncpy(str, normalizedStr, strlen(normalizedStr) + 1);
    }
    free(sepPattern);
    free(normalizedStr);
}

void equall(char** ptr, const char* text) {
    char* temp = checkAlloc(realloc(*ptr, (strlen(text) + 1) * sizeof(char)));
    strcpy(temp, text);
    *ptr = temp;
}

void concat(char** ptr, const char* text) {
    if (*ptr == NULL) {
        *ptr = checkAlloc(calloc(strlen(text) + 1, sizeof(char)));
        strcpy(*ptr, text);
    } else {
        int oldLen = strlen(*ptr);
        int newLen = oldLen + strlen(text) + 1;
        char* temp = checkAlloc(realloc(*ptr, newLen * sizeof(char)));
        *ptr = temp;
        strncat(*ptr, text, strlen(text));
    }
}

char* intToString(int num) {
    char* str = NULL;
    asprintf(&str, "%d", num); // ONLY in GNU the asprintf()
    return str;
}

char* floatToString(float num) {
    char* str = NULL;
    asprintf(&str, "%f", num); // ONLY in GNU the asprintf()
    return str;
}

char* longIntToString(long int num) {
    char* str = NULL;
    asprintf(&str, "%ld", num); // ONLY in GNU the asprintf()
    return str;
}

char* boolToString(int num) {
    char* str = NULL;
    if(num == FALSE_VAL) asprintf(&str, "%s", "false");  // ONLY in GNU the asprintf()
    else                 asprintf(&str, "%s", "true");   // ONLY in GNU the asprintf()
    return str;
}

char* charToString(const char c) {
    char* str = NULL;
    if(c != '\0') { str = allocStr(2); str[0] = c; str[1] = '\0'; }
    else          { str = allocStr(1); str[0] = '\0'; }
    return str;
}

// If i want make that when str is number return number else 0 i suppose
/* int isStringInt(const char *str) {
    if (str == NULL || *str == '\0') return INDEX_NOT_FOUND;
    int size = sizeof(int);
    if (*str == '-' || *str == '+') str =+ size;
    if (*str == '\0') return INDEX_NOT_FOUND;
    while (*str) {
        if (!isdigit(*str)) return INDEX_NOT_FOUND;
        str =+ size;
    }

    return true;
}

int stringToNum(const char* str) {

} */

// // It tokenizes a declaration input
void tok(char* inputText) {
    char *text = str(inputText);

    normalizeWithSeparator(text, '=', ' ', 1);
    normalizeWithSeparator(text, ',', ' ', 1);
    printf("---%s---\n", text);

    char **table = NULL;
    int capacity = 0;
    int count = 0;

    char *token = strtok(text, " ;");
    if (token && strcmp(token, "int") == 0) {
        while ((token = strtok(NULL, " ;")) != NULL) {
            if (count >= capacity) { // Resize if needed
                capacity = (capacity == 0) ? 8 : capacity * 2;
                table = realloc(table, capacity * sizeof(char*));
                if (!table) {
                    fprintf(stderr, "Memory allocation failed\n");
                    exit(1);
                }
            }

            table[count] = strdup(token);
            count++;
        }
    }
    
    for (int j = 0; j < count; j++) {
        printf("Token%d: %s\n", j + 1, table[j]);
    }

    for (int j = 0; j < count; j++) {
        free(table[j]);
    }
    free(table);
    free(text);
}