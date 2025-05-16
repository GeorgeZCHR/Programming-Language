#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../include/stack.h"
#include "../include/types.h"
#include "../include/element.h"

// For Geo language
int isEmpty(Stack* s) {
    return s->top == -1;
}

Stack* createStack() {
    Stack* stack = (Stack*)malloc(sizeof(Stack));
    stack->elements = NULL;
    stack->top = -1;
    return stack;
}

void push(Stack* s, Element element) {
    s->top++;
    s->elements = (Element *)realloc(s->elements,(s->top + 1) * sizeof(Element));
    s->elements[s->top].type = element.type;
    s->elements[s->top].data = element.data;
}

Element* pop(Stack* s) {
    if(isEmpty(s)) {
        printf("Stack is empty!\n");
        return NULL;
    }
    Element* stackElement = (Element*)malloc(sizeof(Element));
    *stackElement = s->elements[s->top];
    s->top--;
    if (!isEmpty(s)) s->elements = (Element *)realloc(s->elements, (s->top + 1) * sizeof(Element));
    else {
        free(s->elements); // If the stack becomes empty, free it fully
        s->elements = NULL;
    }
    return stackElement;
}

Element* peek(Stack* s) {
    if (isEmpty(s)) {
        printf("Stack is empty!\n");
        return NULL;
    }
    Element* copyElement = (Element*)malloc(sizeof(Element));
    *copyElement = s->elements[s->top];
    return copyElement;
}

Element* elementAt(Stack* s, int idx) {
    if (isEmpty(s)) {
        printf("Stack is empty!\n");
        return NULL;
    }
    if(idx >= 0 && idx <= s->top) {
        Element* copyElement = (Element*)malloc(sizeof(Element));
        *copyElement = s->elements[idx];
        return copyElement;
    }
    printf("Index bigger than top!\n");
    return NULL;
}

void printStackElements(Stack* s) {
    printf("Stack : {\n");
    for(int i = 0; i <= s->top; i++) {
        printf("   ");
        printElement(s->elements[i]);
    }
    printf("}\n");
}

void freeStack(Stack *s) {
    while(!isEmpty(s)) pop(s);
    free(s);
}

// For Geo logic in program
int isIntStackEmpty(IntStack* s) {
    return s->top == -1;
}

IntStack* createIntStack(char* name) {
    IntStack* stack = (IntStack*)malloc(sizeof(IntStack));
    stack->name = name;
    stack->elements = NULL;
    stack->top = -1;
    return stack;
}

void pushInt(IntStack* s, int element) {
    s->top++;
    s->elements = (int*)realloc(s->elements,(s->top + 1) * sizeof(int));
    s->elements[s->top] = element;
}

int popInt(IntStack* s) {
    if (isIntStackEmpty(s)) {
        printf("%s is empty!\n", s->name);
        exit(EXIT_FAILURE); // or return a sentinel value like -1
    }
    int value = s->elements[s->top];
    s->top--;
    if (!isIntStackEmpty(s)) {
        s->elements = (int*)realloc(s->elements, (s->top + 1) * sizeof(int));
    } else {
        free(s->elements);
        s->elements = NULL;
    }
    return value;
}

int popAndPushInt(IntStack* s, int value) {
    int lastValue = popInt(s);
    pushInt(s, value);
    return lastValue;
}

// the peekInt will be used for specific ints like 0 and 1 not for normal stack
int peekInt(IntStack* s) {
    if (isIntStackEmpty(s)) return 0;
    return s->elements[s->top];
}

int elementIntAt(IntStack* s, int idx) {
    if (isIntStackEmpty(s)) return -1;
    if(idx >= 0 && idx <= s->top) return s->elements[idx];
    return -1;
}

void printIntStack(IntStack* s) {
    printf("%s : {", s->name);
    if(!isIntStackEmpty(s)) printf(" %d", s->elements[0]);
    for(int i = 1; i <= s->top; i++) printf(", %d", s->elements[i]);
    printf(" }\n");
}

void freeIntStack(IntStack* s) {
    while(!isIntStackEmpty(s)) popInt(s);
    free(s->name);
    s->name = NULL;
    free(s);
}