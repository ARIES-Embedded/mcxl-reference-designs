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

#include "NetworkHal.h"

#include <string.h>
#include "printf.h"
#include "Hal.h"

typedef volatile struct {
	union {
		uint32_t csr;
		struct {
			uint32_t txready : 1;
			uint32_t rxready : 1;
			uint32_t txstart : 1;
			uint32_t rxack   : 1;
			uint32_t txirqen : 1;
			uint32_t txirqds : 1;
			uint32_t rxirqen : 1;
			uint32_t rxirqds : 1;
			uint32_t txirq   : 1;
			uint32_t rxirq   : 1;
		};
	};
	uint32_t txlength;
	uint32_t rxlength;
} EthCsr;

typedef volatile struct {
	uint32_t rev;
	uint32_t scratch;
	uint32_t command_config;
	uint32_t mac_0;
	uint32_t mac_1;
	uint32_t frm_length;
	uint32_t pause_quant;
	uint32_t rx_section_empty;
	uint32_t rx_section_full;
	uint32_t tx_section_empty;
	uint32_t tx_section_full;
	uint32_t rx_almost_empty;
	uint32_t rx_almost_full;
	uint32_t tx_almost_empty;
	uint32_t tx_almost_full;
	uint32_t mdio_addr0;
	uint32_t mdio_addr1;
} TseMac;

typedef volatile struct {
	union {
		struct {
			uint32_t _reserved1 : 6;
			uint32_t spdselm : 1;
			uint32_t coltsten : 1;
			uint32_t duplex : 1;
			uint32_t restartan : 1;
			uint32_t isolate : 1;
			uint32_t powerdown : 1;
			uint32_t autonegoen : 1;
			uint32_t speedsel : 1;
			uint32_t loopback : 1;
			uint32_t reset : 1;
		};
		uint32_t control;
	};
	union {
		struct {
			uint32_t extcap : 1;
			uint32_t jbberdt : 1;
			uint32_t linkstat : 1;
			uint32_t autonegoab : 1;
			uint32_t remfault : 1;
			uint32_t autonegocp : 1;
			uint32_t mfpsup : 1;
			uint32_t _reserved2 : 1;
			uint32_t extstat : 1;
		};
	};
	uint32_t status;
} Mdio;


static volatile uint8_t* m_TxBuffer;
static volatile uint8_t* m_RxBuffer;
static volatile EthCsr* m_EthCsr;
static volatile TseMac* m_Mac;
static volatile Mdio* m_Mdio;

void NetworkHal_Init(uint32_t dpramAddr, uint32_t dpramSize, uint32_t macMemAddr, uint64_t macAddr) {

	m_TxBuffer = (uint8_t*) (dpramAddr);
	m_RxBuffer = (uint8_t*) (dpramAddr + dpramSize);
	m_EthCsr = (EthCsr*) (dpramAddr + 2 * dpramSize);
	m_Mac = (TseMac*) macMemAddr;
	m_Mdio = (Mdio*) (macMemAddr+0x80 * sizeof(uint32_t));

	m_Mac->mdio_addr0 = 0;
	m_Mac->command_config = 0x2000;
	m_Mdio->reset = 1;

	while (m_Mac->command_config & 0x2000) {
		Hal_Delay(CLK_FREQ);
		printf_("Resetting MAC in progress\n");
	}

	m_Mac->mac_0 = (uint32_t) macAddr;
	m_Mac->mac_1 = (uint32_t) (macAddr >> 32);
	printf_("Set MAC address to %02x:%02x:%02x:%02x:%02x:%02x\n", 
		(uint8_t)(macAddr >>  0), (uint8_t)(macAddr >>  8), (uint8_t)(macAddr >> 16),
		(uint8_t)(macAddr >> 24), (uint8_t)(macAddr >> 32), (uint8_t)(macAddr >> 40));
	m_Mac->command_config = (0x00000020);
	Hal_Delay(CLK_FREQ);
	m_Mac->command_config |= 3;
	printf_("Intel TSE MAC initialized\n");
	m_EthCsr->rxirqen = 1;
}


bool NetworkHal_Transmit(uint8_t* data, uint32_t length) {
	if (!m_EthCsr->txready) {
		return false;
	}
	Hal_VolatileCopy(m_TxBuffer, data, length);
	m_EthCsr->txlength = length;
	m_EthCsr->txstart = 1;
	return true;
}

uint32_t NetworkHal_Receive(uint8_t* data) {
	if (!m_EthCsr->rxready) {
		return 0;
	}
	uint32_t length = m_EthCsr->rxlength;
	Hal_VolatileCopy(data, m_RxBuffer, length);
	m_EthCsr->rxack = 1;
	return length;
}

uint32_t NetworkHal_GetReceiveLength() {
	if (!m_EthCsr->rxready) {
		return 0;
	}
	uint32_t length = m_EthCsr->rxlength;
	return length;
}

bool NetworkHal_CheckAndAcknowledgeReceiveInterrupt() {
	bool rxirq = m_EthCsr->rxirq;
	if (rxirq) {
		m_EthCsr->rxirq = 1;
	}
	return rxirq;
}

bool NetworkHal_HasLink() {
	return (bool) m_Mdio->linkstat;
}
