#ifndef ELEMENT_H
#define ELEMENT_H

#include "types.h"

typedef enum {
    TYPE_INT      = 0,
    TYPE_FLOAT    = 1,
    TYPE_LONG_INT = 2,
    TYPE_BOOL     = 3,
    TYPE_STRING   = 4
} Type;

typedef union {
    Int i;
    Float f;
    LongInt li;
    Bool b;
    String s;
} Data;

typedef struct {
    Type type;
    Data data;
} Element;

Element constructIntElement(Type type, char* label, int value);
Element constructFloatElement(Type type, char* label, float value);
Element constructLongIntElement(Type type, char* label, long int value);
Element constructBoolElement(Type type, char* label, int value);
Element constructStringElement(Type type, char* label, char* value);
void printElement(Element e);

#endif