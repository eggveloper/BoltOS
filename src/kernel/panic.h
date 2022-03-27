#ifndef CORE_PANIC_H
#define CORE_PANIC_H

#define __PANIC(format, ...) kernel_panic( \
    "\nPANIC at %s:%d:%s(): " \
    format "\n" "%s", \
    __FILE__, __LINE__, __func__, __VA_ARGS__ \
);

#define PANIC(...) __PANIC(__VA_ARGS__, "")

#endif
