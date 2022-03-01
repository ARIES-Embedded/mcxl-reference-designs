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

#include "Uart.h"

void UartWriteInt(Uart* pUart, int32_t i, bool newline) {

	// A 32 bit integer has at most 10 digits + sign + zero byte
	char buffer[12] = {0};

	// To prevent overflow, handle this as special case
	if (i == INT32_MIN) {

		buffer[0] = '-';
		buffer[1] = '2';
		buffer[2] = '1';
		buffer[3] = '4';
		buffer[4] = '7';
		buffer[5] = '4';
		buffer[6] = '8';
		buffer[7] = '3';
		buffer[8] = '6';
		buffer[9] = '4';
		buffer[10] = '8';
		buffer[11] = 0;

	} else {

		uint8_t bufferIndex = 0;

		if (i < 0) {
			i = -i;
			buffer[bufferIndex++] = '-';
		}

		int32_t temp = i / 10;

		while (temp) {
			temp /= 10;
			bufferIndex++;
		}

		do {
			buffer[bufferIndex--] = (i % 10) + '0';
			i /= 10;
		} while(i);

	}

	UartWrite(pUart, buffer);

	if (newline) {
		UartWrite(pUart, "\n");
	}

}

void UartWriteHex32(Uart* pUart, uint32_t ui, bool newline) {
	UartWriteHex8(pUart, (ui>>24) & 0xFF, false);
	UartWriteHex8(pUart, (ui>>16) & 0xFF, false);
	UartWriteHex8(pUart, (ui>>8) & 0xFF, false);
	UartWriteHex8(pUart, (ui) & 0xFF, newline);
}

void UartWriteHex8(Uart* pUart, uint8_t byte, bool newline) {
	uint8_t l = byte & 0x0F;
	uint8_t h = (byte >> 4) & 0x0F;
	l = (l < 0x0A) ? l + '0' : l + 'A' - 10;
	h = (h < 0x0A) ? h + '0' : h + 'A' - 10;
	UartPut(pUart, h);
	UartPut(pUart, l);
	if (newline) {
		UartWrite(pUart, "\n");
	}
}

void UartWrite(Uart* pUart, const char* str) {
	while (*str) {
		if (*str == '\n') UartPut(pUart, '\r');
		UartPut(pUart, *str++);
	}
}

void UartPut(Uart* pUart, char c) {
	while (!(pUart->status & UART_TRDY));
	pUart->txdata = c;
}

char UartGet(Uart* pUart) {
	while (!(pUart->status & UART_RRDY));
	return pUart->rxdata;
}

bool UartGetNonBlocking(Uart* pUart, char* c) {
	if (pUart->status & UART_RRDY) {
		*c = pUart->rxdata;
		return true;
	}
	return false;
}
