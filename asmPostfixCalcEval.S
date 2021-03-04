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
	subq $184, %rsp /*align stack pointer*/
	movq %rsp, %rbp  /* make %rbp point to local variables area */

	/*0(%rbp) stack of 20 8 byte integers
	160(%rbp) long pval
	168(%rbp) 4 bytes int op
	176(%rbp) counter 8 bytes*/

	call skipws
	movq $0, 176(%rbp) /*counter initialization*/
	movq %rax, %r12 /*r12 holds string s*/
	
.Levalloop:
	cmp $0, %r12 /*check if string is empty*/
	je .Lout

	/*check if first character is digit*/
	movq $0, %r8
	movsbq (%r12, %r8, 1), %rdi
	call isDigit
	cmp $1, %rax
	je .Ldigit

	/*check token type of string */
	movq %r12, %rdi
	call tokenType
	cmp $TOK_OP, %rax
	je .LtokenOP

	/*There was an invalid token and it was not a digit*/
	movq $invalidChar, %rdi
	call fatalError

.Ldigit:
	/*first integer in string is consumed*/
	movq %r12, %rdi
	leaq 160(%rbp), %rsi
	call consumeInt
	movq %rax, %r12 

	/*push that consumed integer to the stack*/
	movq %rbp, %rdi
	leaq 176(%rbp), %rsi 
	movq 160(%rbp), %rdx
	call stackPush

	jmp .LafterIfStatementsRemoveSpace /*jump to end of if statements*/

.LtokenOP:
	/*consume the operator by calling consumeOp*/
	movq %r12, %rdi
	leaq 168(%rbp), %rsi
	call consumeOp
	movq %rax, %r12
	
	/*Get value at the top of the stack*/
	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	call stackPop
	movq %rax, %r8

	/*Get value at the top of the stack*/
	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	call stackPop
	movq %rax, %r9

	/*evaluate the two values*/
	movl 168(%rbp), %edi
	movq %r9, %rsi
	movq %r8, %rdx
	call evalOp

	/*push the result of the two values on stack*/
	movq %rbp, %rdi
	leaq 176(%rbp), %rsi
	movq %rax, %rdx
	call stackPush

	jmp .LafterIfStatementsRemoveSpace /*jump to end of if statements*/

.LafterIfStatementsRemoveSpace:
	/*remove any leading zeros*/
	movq %r12, %rdi
	call skipws
	movq %rax, %r12

	jmp .Levalloop /*jump back to the start of loop*/

.Lout:
	/*check if theres only 1 value left in stack*/
	leaq 176(%rbp), %rsi
	cmp $1, (%rsi)
	jne .LmultItemInStack /*theres more than 1 or 0 values left*/

	/*there is only 1 value left*/
	movq %rbp, %rdi
	call stackPop

	movq %rbp, %rsp
	addq $184, %rsp
	popq %r12
	popq %rbp
	ret
	
.LmultItemInStack:
	movq $multItemInStack, %rdi
	call fatalError

/* vim:ft=gas:
 */
