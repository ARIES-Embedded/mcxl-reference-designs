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

#ifndef CONFIG_H
#define CONFIG_H

#include <stdint.h>

typedef union {
	uint8_t bytes[6];
	struct {
		uint32_t wlow;
		uint32_t whigh;
	};
	uint64_t quad;
} MacAddr_t;

// TODO: MAC address configuration; the provided address here (ee:ee:ee:00:00:00)
// is locally administered (0x02 bit in the first octet is set).
// The quad-part is given in little endian, Example:
// The value 0x0000563412efcdab becomes the address ab:cd:ef:12:34:56
static const MacAddr_t s_MacAddress = {.quad = 0x0000000000eeeeee};

// TODO: This is the backup configuration should DHCP fail
static const uint8_t s_IPAddress[4] = {192, 168, 0, 5};
static const uint8_t s_NetMask[4] = {255, 255, 255, 0};
static const uint8_t s_GatewayAddress[4] = {192, 168, 0, 2};
static const uint8_t s_DNSServerAddress[4] = { 208, 67, 222, 222 }; // OpenDNS server

#endif
