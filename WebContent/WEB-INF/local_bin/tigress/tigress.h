/* This is tigress.h */

/* We don't support clang extensions:
   https://clang.llvm.org/docs/BlockLanguageSpec.html#the-block-type
*/
#ifdef __clang__ 
#undef __BLOCKS__
#endif

/* We don't support C11 features. 
   https://en.wikipedia.org/wiki/C11_(C_standard_revision)#Changes_from_C99
*/
#define _Noreturn
