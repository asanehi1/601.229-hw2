#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "cPostfixCalc.h"

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
long eval(const char *s) {
  /* TODO: implement */
  // skip white space char in beginning
  s = skipws(s);
  
  long counter = 0;
  long *stack = (long *) malloc(sizeof(long) * MAX_STACK);
  while (s && strlen(s) > 0) {
    if (isSpace(s[0]) != 0) {
      s = skipws(s);
    } else if (isDigit(s[0])) {
      long pval;
      s = consumeInt(s, &pval);
      stackPush(stack, &counter, pval);
    } else {
      int op;
      s = consumeOp(s, &op);
      long v1 = stackPop(stack, &counter);
      long v2 = stackPop(stack, &counter);
     
      stackPush(stack, &counter, evalOp(op, v2, v1));
    }
  }
  if (counter != 1) {
    char * msg = "multiple items on stack";
    fatalError(msg);
  } else {
    return stackPop(stack, &counter);
  }
  /* Note: this function should be implemented by calling functions
   * declared in cPostfixCalc.h and defined in cPostfixCalcFuncs.c
   */
  
}
