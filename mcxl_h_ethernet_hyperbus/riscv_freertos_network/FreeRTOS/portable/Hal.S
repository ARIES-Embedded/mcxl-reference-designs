# Copyright (C) 2022 ARIES Embedded GmbH
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

.text

.global Hal_EnableMachineInterrupt
.global Hal_DisableMachineInterrupt
.global Hal_GlobalEnableInterrupts
.global Hal_GlobalDisableInterrupts
.global Hal_ReadTime32
.global Hal_ReadTime64

Hal_EnableMachineInterrupt:
	li t0, 1
	sll a0, t0, a0
	csrs mie, a0
	ret

Hal_DisableMachineInterrupt:
	li t0, 1
	sll a0, t0, a0
	csrc mie, a0
	ret

Hal_GlobalEnableInterrupts:
	csrs mstatus, 8
	ret

Hal_GlobalDisableInterrupts:
	csrc mstatus, 8
	ret

Hal_ReadTime32:
	csrr a0, time
	ret

Hal_ReadTime64:
	csrr a1, timeh
	csrr a0, time
	csrr t0, timeh
	bne a1, t0, Hal_ReadTime64
	ret
