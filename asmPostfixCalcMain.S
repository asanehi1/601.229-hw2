/*
 * postfix calculator (assembly language version)
 * main function implementation
 */

.section .rodata

/* TODO: add string constants and other read-only data here */
	incorrectNumArgs: .string "Wrong number of arguments\n"
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

	subq $8, %rsp /*stack alignment*/
	cmp $2, %rdi /*check if there are 2 arguments passed*/
	jne .LincorrectNumArguments /*jump if its not 2*/

	movq $1, %r9
	movq (%rsi, %r9, 8), %rdi /*move argv[1] into the rdi register*/
	call eval
	movq %rax, %rsi
	movq $calcResult, %rdi /*move result into rdi register then print it*/
	call printf

	movq $0, %rax
	addq $8, %rsp
	ret

.LincorrectNumArguments:
	/*pring error message*/
	movq $incorrectNumArgs, %rdi
	call printf
	movq $1, %rax
	addq $8, %rsp
	ret

/* vim:ft=gas:
 */
