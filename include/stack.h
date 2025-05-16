#ifndef STACK_H
#define STACK_H

#include "element.h"

// For Geo language
typedef struct {
    Element* elements;
    int top;
} Stack;

// For Geo logic in program
typedef struct {
    char* name;
    int* elements;
    int top;
} IntStack;

// For Geo language
int isEmpty(Stack* s);
Stack* createStack();
void push(Stack* s, Element element);
Element* pop(Stack* s);
Element* peek(Stack* s);
Element* elementAt(Stack* s, int idx);
void printStackElements(Stack* s);
void freeStack(Stack* s);

// For Geo logic in program
int isIntStackEmpty(IntStack* s);
IntStack* createIntStack(char* name);
void pushInt(IntStack* s, int element);
int popInt(IntStack* s);
int popAndPushInt(IntStack* s, int value);
int peekInt(IntStack* s);
int elementIntAt(IntStack* s, int idx);
void printIntStack(IntStack* s);
void freeIntStack(IntStack* s);

#endif