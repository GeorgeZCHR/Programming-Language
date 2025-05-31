#ifndef STRMAN_H
#define STRMAN_H

int overflowIndex(const int idx, const int len);
int indexOf(const char* str, const char c, const int beginIndex);
char charAt(const char* str, const int index);
char enhancedCharAt(const char* str, const int index);
char* allocStr(int lenght);
char* str(char* string);
char* substringHelper(const char* str, int beginIndex, int length);
char* enhancedSubstringHelper(const char* str, int beginIndex, int endIndex);
char* subStringFrom(const char* str, int beginIndex);
char* subStringWithLength(const char* str, int beginIndex, int length);
char* enhancedSubString(const char* str, int beginIndex, int length);
char* generateSeparatorPattern(char priSep, char secSep, int len);
void normalizeWithSeparator(char* str, char priSep, char secSep, int sepPatternLen);
void equall(char** ptr, const char* text);
void concat(char** ptr, const char* text);
char* intToString(int num);
char* floatToString(float num);
char* longIntToString(long int num);
char* boolToString(int num);
char* charToString(const char c);

#endif