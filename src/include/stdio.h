#ifndef STDIO_H
#define STDIO_H

void printf(const char* format, ...);

#include <stdarg.h>

#define DEVICE_SCREEN 0

void printf(const char* format, ...);
void vprintf(int device, const char* format, va_list arg);

#endif
