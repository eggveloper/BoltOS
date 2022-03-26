#ifndef KMAIN_H
#define KMAIN_H

#include <core/boot.h>

#define KERNEL_ASCII    "                      :::::::::   ::::::::  :::    :::::::::::\n" \
                        "                     :+:    :+: :+:    :+: :+:        :+:     \n" \
                        "                    +:+    +:+ +:+    +:+ +:+        +:+      \n" \
                        "                   +#++:++#+  +#+    +:+ +#+        +#+       \n" \
                        "                  +#+    +#+ +#+    +#+ +#+        +#+        \n" \
                        "                 #+#    #+# #+#    #+# #+#        #+#         \n" \
                        "                #########   ########  ########## ###          \n"
#define KERNEL_NAME    "Bolt"
#define KERNEL_VERSION "0.0.1d"
#define KERNEL_DATE     __DATE__
#define KERNEL_TIME     __TIME__

void kmain(unsigned long magic, unsigned long addr) __asm__("kmain");

#endif
