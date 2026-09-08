struct exception_ptr { void *object; };
int _ZNSt15__exception_ptreqERKNS_13exception_ptrES2_(const struct exception_ptr *a, const struct exception_ptr *b) __asm__("_ZNSt15__exception_ptreqERKNS_13exception_ptrES2_");
int _ZNSt15__exception_ptreqERKNS_13exception_ptrES2_(const struct exception_ptr *a, const struct exception_ptr *b) { return a->object == b->object; }
