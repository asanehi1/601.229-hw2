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
	pushq %rbp 
	pushq %r12
	pushq %r13
	subq $184, %rsp /*align stack pointer*/
	movq %rsp, %rbp  /* make %rbp point to local variables area */

	/*(%rbp) stack of 20 8 byte integers
	160(%rbp) long pval
	168(%rbp) 4 bytes int op
	176(%rbp) counter 8 bytes*/

	call skipws
	leaq (%rbp), %rdi
	movq %rax, %r12 /*r12 holds string s*/
	
.Levalloop:
	cmp 0, %r12
	je .Lout

	movq $0, %r8
	movzbq (%r12, %r8, 1), %rdi
	call isDigit
	cmp $1, %rax
	je .Ldigit

	movq %r12, %rdi
	call tokenType
	cmp TOK_OP, %rax
	je .LtokenOP

	movq $invalidChar, %rdi
	call fatalError

.LafterIfStatementsRemoveSpace:
	movq %r12, %rdi
	call skipws
	movq %rax, %r12

	jmp .Levalloop


.Ldigit:
	movq %r12, %rdi
	leaq 160(%rbp), %rsi
	call consumeInt
	movq %rax, %r12 /*first integer in string was consumed*/

	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	leaq 160(%rbp), %rdx
	call stackPush

	jmp .LafterIfStatementsRemoveSpace

.LtokenOP:
	movq %r12, %rdi
	leaq 176(%rbp), %rsi
	call consumeOp
	movq %rax, %r12
	
	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	call stackPop
	movq %rax, %r8

	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	call stackPop
	movq %rax, %r9

	leaq 168(%rbp), %rdi
	movq %r9, %rsi
	movq %r8, %rdx
	call evalOp

	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	movq %rax, %rdx
	call stackPush

	jmp .LafterIfStatementsRemoveSpace

.Lout:
	leaq 176(%rbp), %rsi
	cmp %rsi, 1
	je .LmultItemInStack

	movq %rbp, %rdi
	call stackPop

	ret
	

.LmultItemInStack:
	movq $multItemInStack, %rdi
	call fatalError


/* vim:ft=gas:
 */
