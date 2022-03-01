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

OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv", "elf32-littleriscv")
OUTPUT_ARCH( "riscv" )

MEMORY {
	OCRAM (rx) : ORIGIN = 0x00000000, LENGTH = 128K
}

ENTRY(__reset_vector__)

_end_of_memory = ORIGIN(OCRAM) + LENGTH(OCRAM) - 1;
_sp = ALIGN(_end_of_memory - 0x10, 4);

SECTIONS
{
	.init :
	{
		. = 0x10;
		KEEP(*(.init))
		*(.init)

		. = 0x20;
		KEEP(*(.exception))
		*(.exception)

	} > OCRAM


	.text :	{
		*.text
		. = ALIGN(4);
	} > OCRAM

	.rodata : {
		*(.rodata.*)
		*(.srodata.*)
		. = ALIGN(4);
	} > OCRAM

	. = ALIGN(4);

	__lma_data_start__ = .;
	.data : {
		. = ALIGN(4);
		__vma_data_start__ = .;
		_gp = . + 0x800;
		*(.data)
	} > OCRAM
	. = ALIGN(4);
	__vma_data_end__ = .;
	__lma_data_end__ = __vma_data_end__ - __vma_data_start__ + __lma_data_start__;


	. = ALIGN(4);

	__bss_start__ = .;

	.bss : {
		*(.bss)
		*(.sbss)
	} > OCRAM

	. = ALIGN(4);

	__bss_end__ = .;

	_end = .;
}
