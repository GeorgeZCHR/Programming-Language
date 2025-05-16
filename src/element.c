#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/types.h"
#include "../include/element.h"
#include "../include/strman.h"

Element constructIntElement(Type type, char* label, int value) {
    Element e;
    Int dataInt;
    strncpy(dataInt.label, label, sizeof(dataInt.label));
    dataInt.label[sizeof(dataInt.label) - 1] = '\0';
    dataInt.value = value;
    e.type = type;
    e.data.i = dataInt;
    return e;
}

Element constructFloatElement(Type type, char* label, float value) {
    Element e;
    Float dataFloat;
    strncpy(dataFloat.label, label, sizeof(dataFloat.label));
    dataFloat.label[sizeof(dataFloat.label) - 1] = '\0';
    dataFloat.value = value;
    e.type = type;
    e.data.f = dataFloat;
    return e;
}

Element constructLongIntElement(Type type, char* label, long int value) {
    Element e;
    LongInt dataLongInt;
    strncpy(dataLongInt.label, label, sizeof(dataLongInt.label));
    dataLongInt.label[sizeof(dataLongInt.label) - 1] = '\0';
    dataLongInt.value = value;
    e.type = type;
    e.data.li = dataLongInt;
    return e;
}

Element constructBoolElement(Type type, char* label, int value) {
    Element e;
    Bool dataBool;
    strncpy(dataBool.label, label, sizeof(dataBool.label));
    dataBool.label[sizeof(dataBool.label) - 1] = '\0';
    dataBool.value = (value == FALSE_VAL ? FALSE_VAL : TRUE_VAL);
    e.type = type;
    e.data.b = dataBool;
    return e;
}

Element constructStringElement(Type type, char* label, char* value) {
    Element e;
    String dataString;
    strncpy(dataString.label, label, sizeof(dataString.label));
    dataString.label[sizeof(dataString.label) - 1] = '\0';
    dataString.value = NULL;
    equall(&dataString.value, value);
    free(value);
    e.type = type;
    e.data.s = dataString;
    return e;
}

void printElement(Element e) {
    switch (e.type) {
    case TYPE_INT:
        printf("Element : { Type : TYPE_INT, Data : { Label : %s, Value : %d } }\n", e.data.i.label, e.data.i.value);
        break;
    case TYPE_FLOAT:
        printf("Element : { Type : TYPE_FLOAT, Data : { Label : %s, Value : %f } }\n", e.data.f.label, e.data.f.value);
        break;
    case TYPE_LONG_INT:
        printf("Element : { Type : TYPE_LONG_INT, Data : { Label : %s, Value : %ld } }\n", e.data.li.label, e.data.li.value);
        break;
    case TYPE_BOOL:
        printf("Element : { Type : TYPE_BOOL, Data : { Label : %s, Value : %s } }\n", e.data.b.label, (e.data.b.value == FALSE_VAL ? "false" : "true"));
        break;
    case TYPE_STRING:
        printf("Element : { Type : TYPE_STRING, Data : { Label : %s, Value : \"%s\" } }\n", e.data.s.label, e.data.s.value);
        break;
    }
}