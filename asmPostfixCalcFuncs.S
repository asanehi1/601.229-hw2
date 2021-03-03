/*
 * postfix calculator (assembly language version)
 * function implementation
 */

.equ TOK_INT, 0
.equ TOK_OP, 1
.equ TOK_UNKNOWN, 2

.equ MAX_STACK, 20

	.section .rodata

eNegativeValue: .string "Negative value"

/* TODO: add other string constants and other read-only data here */

	.section .text

/*
 * addPositive function (this is just an example function)
 */
	.globl addPositive
addPositive:
	subq $8, %rsp                /* align stack pointer */

	movq $0, %r10                /* let %r10 be 0 */
	cmpq %rdi, %r10              /* compare 1st param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */
	cmpq %rsi, %r10              /* compare 2nd param to 0 */
	jg .LaddPositiveNegativeOperand /* if less, it's negative */

	/* both operands are non-negative, do the addition */
	movq %rsi, %rax              /* move second parameter to %rax */
	addq %rdi, %rax              /* add first parameter to second */
	jmp .LaddPositiveDone

.LaddPositiveNegativeOperand:
	movq $eNegativeValue, %rdi
	call fatalError
9:	jmp 9b                       /* should not get here */

.LaddPositiveDone:
	/* the sum is now in %rax */
	addq $8, %rsp                /* restore stack pointer */
	ret

/*
 * fatalError - print an error message an exit with an exit code of 1.
 * Prints a message of the form "Error: <message text>" to standard output.
 * Does not return!
 *
 * Params:
 *   msg - description of the error which occurred
	*/
errorMsg:	 .string "Error: %s\n"
	.globl fatalError
fatalError:
	/* TODO: implement */
	/* note that this function should not return */
	subq $8, %rsp
	movq %rdi, %rsi
	movq $errorMsg, %rdi
	
	call printf

	movq $1, %rdi /*Arg1: exit status is 0*/
	addq $8, %rsp    
	call exit


/*
 * isSpace - tests a character code to determine whether or not it
 * is a space character.
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a space or tab character, 0 otherwise
 *   (the function is allowed to also return 1 if c is a newline
 *   or carriage return, but it's only required to handle
 *   spaces and tabs)
	*/
	.globl isSpace
isSpace:
	/* TODO: implement */
	subq $8, %rsp                /* align stack pointer */

	mov $' ', %rsi
	cmpq %rdi, %rsi	
        je .Lspace
	
	movq $'\t', %rsi
        cmpq %rdi, %rsi              
        je .Lspace

	/* else if not space*/
	movq $0, %rax
	addq $8, %rsp
	ret

	.Lspace:
	movq $1, %rax
	addq $8, %rsp
	ret
	
/*
 * isDigit - tests a character code to determine whether it is one
 * of the digits '0' through '9'
 *
 * Params:
 *   c - an ASCII character code
 *
 * Returns:
 *   1 if c is a digit, 0 otherwise
 */
	.globl isDigit
isDigit:
	/* TODO: implement */
	subq $8, %rsp                /* align stack pointer */

        mov $'0', %r11
        cmpq %rdi, %r11
        jle .LisItLessThanNine
	
        /* else if smaller than 1 */
        movq $0, %rax
        addq $8, %rsp
        ret

        .LisItLessThanNine:
	mov $'9', %r11
        cmpq %rdi, %r11
        jge .LitIsDigit

	/* else if bigger than 9*/
        movq $0, %rax
        addq $8, %rsp
        ret

	.LitIsDigit:
	movq $1, %rax
        addq $8, %rsp
        ret

/*
 * skipws - skips any whitespace characters (as determined by isSpace)
 * at the beginning of a C character string.
 *
 * Params:
 *   s - pointer to a C character string
 *
 * Returns:
 *   pointer to the first non-space character in the string, or NULL
 *   if there are no non-space characters before the end of the string
 *   is reached
	*/
	.globl skipws
skipws:
	/* TODO: implement */
	subq $8, %rsp

	mov $0, %r9 /* counter*/
	mov %rdi, %r10 /*copy value in rdi into r10	*/

	.Lloop:
	movsbq (%r10, %r9, 1), %rdi /* copy first byte into rdi*/
	cmp $0, %rdi /*is Null */
	je .Lfail
	
	push %rdi
        call isSpace
	pop %rdi 
	cmp $0, %eax
	
	je .Lpass /* if not space*/
	add $1, %r9 /*counter++*/
	jmp .Lloop /* if space, loop again*/

	.Lpass:
	addq $8, %rsp
	leaq (%r10, %r9, 1), %rax
	ret

	.Lfail:
	addq $8, %rsp
	mov $0, %rax /* return null*/
	ret

/*
 * tokenType - return the token type (TOK_INT, TOK_OP, or TOK_UNKNOWN)
 * of the token at the beginning of given C character string.
 *
 * Params:
 *   s - nonempty C character string (which should not have any leading
 *       space characters)
 *
 * Returns:
 *   the token type
 */
	.globl tokenType
tokenType:
	/* TODO: implement */
	subq $8, %rsp

	movq $0, %r9
	movsbq (%rdi, %r9, 1), %rdi

	
	push %rdi
	call isDigit
	pop %rdi
	cmp $1, %eax
	je .Ldigit

	
        cmp $'+', %rdi
	je .Lop

	cmp $'-', %rdi
        je .Lop

	cmp $'*', %rdi
        je .Lop

	cmp $'/', %rdi
        je .Lop

	jmp .Lunknown


	.Ldigit:
	movq $TOK_INT, %rax 
	addq $8, %rsp
	ret

	.Lop:
        movq $TOK_OP, %rax
        addq $8, %rsp
        ret

	.Lunknown:
        movq $TOK_UNKNOWN, %rax
        addq $8, %rsp
        ret

/*
 * consumeInt - consume one or more digit characters at the beginning
 * of given C character string, convert them to an integer value, and
 * store the integer value in the long (64 bit signed integer)
 * variable that pval points to.
 *
 * Params:
 *   s    - pointer to a nonempty C character string which should start
 *          with a digit character
 *   pval - points to a long variable where the converted integer value
 *          should be stored
 *
 * Returns:
 *   pointer to the first character in the string that is not a digit
 */
	.globl consumeInt
consumeInt:
	/* TODO: implement */
	subq $8, %rsp
	
	mov $0, %r11
        mov %rdi, %r10 /*copy valye in rdi into r10    */                                                                          

        .Lloop2:
        movzbl (%r10), %eax /* copy first byte   */                                                               
	mov %rax, %rdi

	push %rdi
	push %r11
        call isDigit 
	pop %r11
	pop %rdi
	
        cmp $0, %eax
        je .Lend /*if not digit*/
	
	imul $10, %r11 /* sum = sum * 10*/
	subq $'0', %rdi /*change from ascii*/
	add %rdi, %r11 /* sum = sum + nextDigit*/
	
	
	inc %r10
	
        jmp .Lloop2 //if digit loop again
	
        .Lend:
	mov %r11, (%rsi) // move int to pval
        mov %r10, %rax //return pointer to first
	
	addq $8, %rsp
	
	ret

	


/*
 * consumeOp - consume an operator character from the beginning of the
 * given C character string.
 *
 * Params:
 *   s - pointer to a nonempty C character string
 *   op - pointer to an int (32 bit signed integer) variable where the
 *        ASCII code of the first character of s should be stored
 *
 * Returcns:
 *   a pointer to the second character of s
 */
	.globl consumeOp
consumeOp:
	/* TODO: implement */
	subq $8, %rsp
	mov $0, %r11
	
	movsbq (%rdi, %r11, 1), %r10 //move s[0] into r10
	movl %r10d, (%rsi) // move r10 to rsi
	
	add $1, %r11
	leaq (%rdi, %r11, 1), %rax // point to s[0 + 1]
	addq $8, %rsp 
	ret

/*
 * stackPush - push a long (64 bit signed integer) value onto the stack.
 * Calls the fatalError function if the stack is full.
 * A full stack contains MAX_STACK (20) values.
 * If a value is successfully pushed on the stack, the count should
 * be incremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *   val   - the value to push onto the stack
 *
 * Returns:
 *   nothing
	*/
failedStack:	.string "Stack is full cannot push"
	.globl stackPush
stackPush:
	/* TODO: implement */
	subq $8, %rsp
	movq (%rsi), %r11
        cmp $MAX_STACK, %r11 /* cmp *count to max stack*/                                                        
        je .Lerror1 /* if true, fatal error   */                                                 


	/* stack[*count] = val
	// stack is %rdi, count is %rsi, val is %rdx*/
	movq %rdx, (%rdi, %r11, 8)
	
        
	addq $1, (%rsi) // *count ++  
	
	addq $8, %rsp
	ret

	.Lerror1:
        addq $8, %rsp
	movq $failedStack, %rdi
        call fatalError
	ret

/*
 * stackPop - pops a long (64 bit signed integer) value from the stack.
 * Calls the fatalError function if the stack is empty.
 * If a value is successfully popped off the stack, the count should
 * be decremented by 1.
 *
 * Params:
 *   stack - pointer to the beginning of the stack storage array
 *   count - pointer to a long variable storing the number of items
 *           currently on the stack
 *
 * Returns:
 *   the value popped from the stack
	*/
failedPop:	.string "Stack is empty cannot pop"
	.globl stackPop
stackPop:
	/* TODO: implement */
	subq $8, %rsp
	cmpq $0, (%rsi) // cmp *count to 0   
	je .Lerror // if true, fatal error
	subq $1, (%rsi) // else *count --
	movq (%rsi), %r11
	movsbq (%rdi, %r11, 8), %r10 
	movq %r10, %rax // return stack[*count]
	addq $8, %rsp
	ret

	.Lerror:
	addq $8, %rsp
	movq $failedPop, %rdi
	call fatalError
	ret // i dont think we should reach this

/*
 * evalOp - evaluate a computation by applying an operator to two operands.
 *
 * Params:
 *   op - the operator ('+', '-', '*', or '/')
 *   left - the left operand
 *   right - the right operand
 *
 * Returns:
 *   the result of applying the operator to the operands
 */
	.globl evalOp
evalOp:
	subq $8, %rsp
	cmp $'+', %rdi // if +
	je .Ladd

	cmp $'-', %rdi // if -                                                                
	je .Lsub

	cmp $'*', %rdi // if *                                                                
	je .Lmult

	cmp $'/', %rdi // if /                                                                
	je .Ldiv

	.Ladd:
	add %rsi, %rdx /* add left + right*/
	movq %rdx, %rax
	addq $8, %rsp
	ret

	.Lsub:
        sub %rdx, %rsi // sub left - right
        movq %rsi, %rax
	addq $8, %rsp
        ret

	.Lmult:
	imul %rsi, %rdx //mult left * right 
	mov %rdx, %rax
	addq $8, %rsp
        ret

	.Ldiv:
	cmp $0, %rdx
	je .Lfailed // can't have denominator be 0
	movq %rsi, %rax
	mov %rdx, %r11
	mov $0, %rdx
        idivq %r11 //divide the contents of %rax by the contents of %r11 
        //%rax has the quotient of above idiv
	addq $8, %rsp
        ret

	.Lfailed:
	addq $8, %rsp
        mov $0, %rax //return null
	ret

/* vim:ft=gas:
 */
