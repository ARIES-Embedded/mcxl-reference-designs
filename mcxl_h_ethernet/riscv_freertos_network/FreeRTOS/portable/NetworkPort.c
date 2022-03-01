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

/* Standard includes. */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

/* FreeRTOS includes. */
#include "../include/FreeRTOS.h"
#include "../include/task.h"
#include "../include/queue.h"
#include "../include/semphr.h"
#include "../../FpgaConfig.h"
#include "../../FreeRTOSIPConfig.h"
#include "../../Config.h"

/* FreeRTOS+TCP includes. */
#include "../include/FreeRTOS_IP.h"
#include "../include/FreeRTOS_Sockets.h"
#include "../include/FreeRTOS_IP_Private.h"
#include "../include/NetworkBufferManagement.h"
#include "../include/NetworkInterface.h"

// Port specific includes
#include "NetworkHal.h"

void xNetworkReceiveTask(void*);
void Irq_Network();

static TaskHandle_t m_NetworkTaskHandle;

BaseType_t xApplicationGetRandomNumber( uint32_t * pulNumber ) {
	*pulNumber = rand(); 
	return pdTRUE;
}

BaseType_t xNetworkInterfaceInitialise(void) {
	NetworkHal_Init(MEMADDR_DPRAM, DPRAM_SIZE, MEMADDR_MAC, s_MacAddress.quad);
	Hal_Delay(CLK_FREQ); // Wait 1 second for link
	while (!NetworkHal_HasLink()) {
		printf_("Link not up, waiting...\n");
		Hal_Delay(CLK_FREQ);
		if (NetworkHal_HasLink()) break;
		Hal_Delay(CLK_FREQ);
		if (NetworkHal_HasLink()) break;
		Hal_Delay(CLK_FREQ);
	}
	BaseType_t retval = xTaskCreate(xNetworkReceiveTask, "NetworkTask", 1024, 0, priorityHIGH, &m_NetworkTaskHandle);
	if (retval != pdPASS) {
		printf_("Failed to create NetworkTask: %x\n", retval);
		return pdFALSE;
	}
	configASSERT(m_NetworkTaskHandle);
	Hal_SetExtIrqHandler(IRQ_ETH, Irq_Network);
	Hal_EnableInterrupt(IRQ_ETH);
	return pdTRUE;
}

BaseType_t xNetworkInterfaceOutput(NetworkBufferDescriptor_t * const pxDescriptor, BaseType_t xReleaseAfterSend) {

	bool success = NetworkHal_Transmit(pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength);

	if (!success) {
		// Streaming interface should require less that 600 cycles to forward the entire packet to MAC
		// If first transmit was unsuccessful, wait 600 cycles, then attempt again
		// If transmit failed again, then the MAC is most likely not accepting any more packets.
		Hal_Delay(600);
		success = NetworkHal_Transmit(pxDescriptor->pucEthernetBuffer, pxDescriptor->xDataLength);
	}

	if (xReleaseAfterSend != pdFALSE) {
		vReleaseNetworkBufferAndDescriptor(pxDescriptor);
	}

	return (success) ? pdTRUE : pdFALSE;

}

uint32_t ulApplicationGetNextSequenceNumber(uint32_t ulSourceAddress, uint16_t usSourcePort, uint32_t ulDestinationAddress, uint16_t usDestinationPort) {

	// TODO: Generate a randomized TCP Initial Sequence Number per RFC 6528
	// Currently just return a random number per built in rand()

	(void) ulSourceAddress;
	(void) usSourcePort;
	(void) ulDestinationAddress;
	(void) usDestinationPort;

	return rand();
}


void xNetworkReceiveTask(void* param) {

	NetworkBufferDescriptor_t *pxBufferDescriptor;
	size_t xBytesReceived;
	IPStackEvent_t xRxEvent;

	while (1) {
		// Using deferred interrupt handling
		uint32_t taskReady = ulTaskNotifyTakeIndexed(0, pdTRUE, portMAX_DELAY);
		if (taskReady) { // Received interrupt
			xBytesReceived = NetworkHal_GetReceiveLength();
			if (xBytesReceived) {
				pxBufferDescriptor = pxGetNetworkBufferWithDescriptor(xBytesReceived, 0);
				if (pxBufferDescriptor) {
					NetworkHal_Receive(pxBufferDescriptor->pucEthernetBuffer);
					pxBufferDescriptor->xDataLength = xBytesReceived;
					if (eConsiderFrameForProcessing(pxBufferDescriptor->pucEthernetBuffer) == eProcessBuffer) {
						xRxEvent.eEventType = eNetworkRxEvent;
						xRxEvent.pvData = (void*) pxBufferDescriptor;
						if (xSendEventStructToIPTask(&xRxEvent, 0) == pdFALSE){
							vReleaseNetworkBufferAndDescriptor(pxBufferDescriptor);
						}
					} else {
						vReleaseNetworkBufferAndDescriptor(pxBufferDescriptor);
					}
				}
			}
		}
	}
}

void Irq_Network() {
	bool rxirq = NetworkHal_CheckAndAcknowledgeReceiveInterrupt();
	if (rxirq) {
		BaseType_t xHigherPriorityTaskWoken = pdFALSE;
		vTaskNotifyGiveFromISR(m_NetworkTaskHandle, &xHigherPriorityTaskWoken);
		portYIELD_FROM_ISR(xHigherPriorityTaskWoken);
	}
}
