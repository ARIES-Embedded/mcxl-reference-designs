/* Copyright (C) 2022 ARIES Embedded GmbH

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE. */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>
#include <stddef.h>

#include "RiscvDef.h"
#include "../../FpgaConfig.h"

typedef void(*VoidFunc)(void);

// Located in Hal.c

void Hal_SetExtIrqHandler(uint32_t irq, VoidFunc callback);
void Hal_EnableInterrupt(uint32_t irq);
void Hal_DisableInterrupt(uint32_t irq);
void Hal_EnableInterrupts(uint32_t mask);
void Hal_DisableInterrupts(uint32_t mask);
void Hal_Delay(uint32_t cycles);
void Hal_TimerStart(uint64_t value);
void Hal_TimerStop();
void Hal_RaiseSoftInterrupt();
void Hal_ClearSoftInterrupt();

void Hal_VolatileCopy(volatile void* dst, volatile void* src, size_t length);

// Located in Hal.S

void Hal_EnableMachineInterrupt(uint32_t irq);
void Hal_DisableMachineInterrupt(uint32_t irq);
void Hal_GlobalEnableInterrupts();
void Hal_GlobalDisableInterrupts();
uint32_t Hal_ReadTime32();
uint64_t Hal_ReadTime64();

// Private function called from Crt.S, not to be called directly
// uintptr_t Hal_Exception(uintptr_t stack, uintptr_t addr, uint32_t irq);

#endif // HAL_H
