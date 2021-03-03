/*
 * postfix calculator (assembly language version)
 * main function implementation
 */

.section .rodata

/* TODO: add string constants and other read-only data here */
	errorMsg1: .string "Wrong number of arguments\n"
	calcResult: .string "Result is: %ld\n"

.section .text

/*
 * main function: program entry point
 *
 * Params:
 *   argc - number of command line arguments (including program name)
 *   argv - array of pointers to command line arguments
 *
 * Returns:
 *   exit code
 */
	.globl main
main:
	/* TODO: implement */

	subq $8, %rsp
	cmp $2, %rdi
	jne .LincorrectNumArguments

	movzbq (%rsi, 1, 1), %rdi
	call eval
	mov %eax, %rsi
	movq $calcResult, %rdi
	call printf

	movq $0, %rax
	addq $8, %rsp
	ret

.LincorrectNumArguments:
	movq $errorMsg1, %rdi
	call printf
	movq $1, %rax
	addq $8, %rsp
	ret

/* vim:ft=gas:
 */
