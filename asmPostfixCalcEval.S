/*
 * postfix calculator (assembly language version)
 * eval function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2

	.section .rodata

/* TODO: add string constants and other read-only data here */
invalidChar: .string "invalid char"
multItemInStack: .string "multiple items on stack"

	.section .text

/*
 * eval - evaluate a postfix expression
 * Should directly or indirectly call fatalError if the expression is invalid.
 *
 * Params:
 *   s - C string containing a postfix expression
 *
 * Returns:
 *   the result of evaluating the expression
 */
	.globl eval
eval:
	/* TODO: implement */
	subq $8, %rsp /*align stack pointer*/

	movq $0, %r9 /*counter*/

	/*push %rdi*/
	call skipws
	/*pop %rdi*/

	pushq %rbp
	pushq %r12
	pushq %r13
	subq $176, %rsp
	movq %rsp, %rbp  /* make %rbp point to local variables area */
	movq %rax, %r12 /*r12 holds string s*/
	
.Levalloop:
	movzbq (%r12, %r9, 1), %rdi
	pushq %rdi
	call isDigit
	popq %rdi

	cmp $1, %rax
	je .Ldigit

	movq %r12, %rdi
	pushq %rdi
	call tokenType
	popq %rdi

	cmp TOK_OP, %rax
	je .LtokenOP


	jmp .Lelse

	movq %r12, %rdi
	pushq %rdi
	call skipws
	popq %rdi
	movq %rax, %r12

	jmp .Levalloop


	ret


.Ldigit:
	movq %r12, %rdi
	pushq %rdi
	call consumeInt
	popq %rdi
	movq %rax, %r12 /*first integer in string was consumed*/

.LtokenOP:
	call consumeOp
	movq %rax, %r12
	movq %rsi, %r8

.Lelse:
	movq $invalidChar, %rdi
	call printf

.Lout:
	cmp %r9, 1
	je .LmultItemInStack

	

.LmultItemInStack:
	movq $multItemInStack, %rdi
	call printf


/* vim:ft=gas:
 */
