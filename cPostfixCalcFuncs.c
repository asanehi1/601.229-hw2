#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include "cPostfixCalc.h"

/*
 * Example function (see tests in cTests.c)
 */
long addPositive(long a, long b) {
  if (a < 0L || b < 0L) {
    printf("Error: values must be positive\n");
    exit(1);
  }
  return a + b;
}

/*

 * fatalError - print an error message an exit with an exit code of 1.
 * Prints a message of the form "Error: <message text>" to standard output.
 * Does not return!
 *
 * Params:
 *   msg - description of the error which occurred
 */
void fatalError(const char *msg) {
  /* TODO: implement */
  printf("Error: %s\n", msg);
  exit(1);
}

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
int isSpace(int c) {
  /* TODO: implement */
  // isspace checks for all white space and returns non zero if true
  if (isspace(c) != 0) {
    return 1;
  }
  return 0;
}

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
int isDigit(int c) {
  /* TODO: implement */
  //isdigit returns non zero int if digit
  if (isdigit(c) != 0) {
    return 1;
  }
  return 0;
}

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
const char *skipws(const char *s) {
  /* TODO: implement */
 
  for (int i = 0; i < (int) strlen(s); i++) {
    if (isSpace(s[i]) == 0) {
      return s + i;
    }
  }
  
  return NULL;
}

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
int tokenType(const char *s) {
  /* TODO: implement */
  int i = 0, digit = -1;
  while(i < (int)strlen(s) && 1 != isSpace(s[i])) {
    digit = isDigit(s[i++]);
  }

  char *n = (char *) calloc(i, sizeof(char) + 1);
  memcpy(n, s, i);

  if (n[0] == '+' || n[0] == '-' || n[0] == '*' || n[0] == '/') {
    free(n);
    return TOK_OP;
  } else if(digit == 1) {
    free(n);
    return TOK_INT;
  }
  free(n);
  return TOK_UNKNOWN;
}

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
const char *consumeInt(const char *s, long *pval) {
  /* TODO: implement */
  int i = 0;
  while(i < (int)strlen(s) && 1 == isDigit(s[i])) {
    i++;
  }

  char *num = (char *) calloc(i + 1, sizeof(char));
  memcpy(num, s, i);

  *pval = (long)strtol(num, NULL, 10);
  free(num);
  return (s + i);
}

/*
 * consumeOp - consume an operator character from the beginning of the
 * given C character string.
 *
 * Params:
 *   s - pointer to a nonempty C character string
 *   op - pointer to an int (32 bit signed integer) variable where the
 *        ASCII code of the first character of s should be stored
 *
 * Returns:
 *   a pointer to the second character of s
 */
const char *consumeOp(const char *s, int *op) {
  /* TODO: implement */
  *op = s[0];
  return s + 1;
}

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
void stackPush(long stack[], long *count, long val) {
  /* TODO: implement */
  if (*count == MAX_STACK) {
    fatalError("Stack is full, cannot push!");
  } 

  stack[*count] = val;
  *count += 1UL;
}

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
long stackPop(long stack[], long *count) {
  /* TODO: implement */
  if (*count == 0UL) {
    free(stack);
    fatalError("Stack is empty, cannot pop!");
  } 

  *count -= 1UL;
  return stack[*count];
}

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
long evalOp(int op, long left, long right) {
  /* TODO: implement */
  switch(op) {
    case '+': return left + right; break;
    case '-': return left - right; break;
    case '*': return left * right; break;
    default: return left / right; break;
  }
}
