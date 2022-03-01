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

#include "Hal.h"

static VoidFunc Hal_ExtIrqCallback[32];

void Hal_SetExtIrqHandler(uint32_t irq, VoidFunc callback) {
	Hal_ExtIrqCallback[irq] = callback;
}

void Hal_EnableInterrupt(uint32_t irq) {
	Hal_EnableInterrupts(1 << irq);
}

void Hal_DisableInterrupt(uint32_t irq) {
	Hal_DisableInterrupts(1 << irq);
}

void Hal_EnableInterrupts(uint32_t mask) {
	g_InterruptController->enabled |= mask;
}

void Hal_DisableInterrupts(uint32_t mask) {
	g_InterruptController->enabled &= ~mask;
}

void Hal_Delay(uint32_t cycles) {
	uint32_t startTick = Hal_ReadTime32();
	while ((Hal_ReadTime32() - startTick) < cycles);
}

void Hal_TimerStart(uint64_t value) {
	Hal_DisableMachineInterrupt(IRQ_M_TIMER);
	uint64_t mtime;
	mtime = g_InterruptController->mtime;
	mtime |= (uint64_t)g_InterruptController->mtimeh_latch << 32ULL;
	mtime += value;
	g_InterruptController->mtimecmph_latch = (uint32_t)(mtime >> 32ULL);
	g_InterruptController->mtimecmp_latch = (uint32_t)mtime;
	Hal_EnableMachineInterrupt(IRQ_M_TIMER);
}

void Hal_TimerStop() {
	Hal_DisableMachineInterrupt(IRQ_M_TIMER);
}

void Hal_RaiseSoftInterrupt() {
	g_InterruptController->softinterrupt = 1;
}

void Hal_ClearSoftInterrupt() {
	g_InterruptController->softinterrupt = 0;
}

void Hal_VolatileCopy(volatile void* dst, volatile void* src, size_t length) {

	volatile uint8_t* d8 = (volatile uint8_t*) dst;
	volatile uint8_t* s8 = (volatile uint8_t*) src;

	if ((((uintptr_t)dst) | ((uintptr_t)src)) & 0x03) {
		// Atleast one address is unaligned - byte wise copy only
		for (size_t i = 0; i < length; ++i) {
			d8[i] = s8[i];
		}
	} else {
		// Aligned access, first copy all 32-bit words then copy (if exists) the remainder of last word
		volatile uint32_t* d32 = (volatile uint32_t*) dst;
		volatile uint32_t* s32 = (volatile uint32_t*) src;
		for (size_t i = 0; i < length / 4; ++i) {
			d32[i] = s32[i];
		}
		for (size_t i = length & ~3; i < length; ++i) {
			d8[i] = s8[i];
		}
	}
}

// Forward Declaration for Port.c
extern uintptr_t SystemInterruptHandler(uintptr_t stack, bool softInterrupt);

// Called from Crt.S

uintptr_t Hal_Exception(uintptr_t stack, uintptr_t addr, uint32_t mcause) {

	if ((mcause & 0x80000000) == 0) {
		UartWrite(g_Uart, "TRAP\n    stack    ");
		UartWriteHex32(g_Uart, stack, true);
		UartWrite(g_Uart, "    mepc     ");
		UartWriteHex32(g_Uart, addr, true);
		UartWrite(g_Uart, "    mcause   ");
		UartWriteHex32(g_Uart, mcause, true);
		UartWrite(g_Uart, "    irq en   ");
		UartWriteHex32(g_Uart, g_InterruptController->enabled, true);
		UartWrite(g_Uart, "    irq pen  ");
		UartWriteHex32(g_Uart, g_InterruptController->pending, true);
		UartWrite(g_Uart, "    mtval    ");
		UartWriteHex32(g_Uart, read_csr(mtval),true);
		UartWrite(g_Uart, "    mbadaddr ");
		UartWriteHex32(g_Uart, read_csr(mbadaddr), true);
		while(1);
	} else {
		if ((mcause & 0x7FFFFFFF) == IRQ_M_EXT) {
		uint32_t irq = g_InterruptController->pending & g_InterruptController->enabled;
		for (uint32_t i = 0; i < 32; ++i) {
			if ((irq & (1 << i)) && Hal_ExtIrqCallback[i]) {
				Hal_ExtIrqCallback[i]();
			}
		}
		} else if ((mcause & 0x7FFFFFFF) == IRQ_M_TIMER) {
			stack = SystemInterruptHandler(stack, false);
		} else if ((mcause & 0x7FFFFFFF) == IRQ_M_SOFT) {
			stack = SystemInterruptHandler(stack, true);
			Hal_ClearSoftInterrupt();
		}
	}

	return stack;

}
