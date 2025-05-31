#ifndef SCANNER_H
#define SCANNER_H

extern int nan_error; // not a number error
extern int nab_error; // not a bool error(str representation)
extern int nas_error; // not a string error

int scan_int(const char* message);
float scan_float(const char* message);
long int scan_long_int(const char* message);
int scan_bool(const char* message);
char* scan_string(const char* message);

#endif