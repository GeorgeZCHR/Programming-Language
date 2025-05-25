#ifndef SCANNER_H
#define SCANNER_H

extern int nan_error;

int scan_int(const char* message);
float scan_float(const char* message);
long int scan_long_int(const char* message);

#endif