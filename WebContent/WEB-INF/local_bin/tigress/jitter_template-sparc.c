/*
 * MyJIT 
 * Copyright (C) 2010 Petr Krajca, <krajcap@inf.upol.cz>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */
#include<sys/wait.h>
#include<assert.h>
#include<ctype.h>
//#include<dlfcn.h>
#include<limits.h>
#include<stdarg.h>
#include<stdint.h>
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<sys/mman.h>
#include<sys/types.h>
#include<unistd.h>

#define JITLIB_CORE_H
#define FR_IMM	(jit_mkreg(JIT_RTYPE_FLOAT, JIT_RTYPE_IMM, 0))
#define R_IMM	(jit_mkreg(JIT_RTYPE_INT, JIT_RTYPE_IMM, 0)) // used by amd64 and sparc
#define GET_OP(op) ((jit_opcode) (op->code & 0xfff8))
#define GET_OP_SUFFIX(op) (op->code & 0x0007)
#define IS_IMM(op) (op->code & IMM)
#define IS_SIGNED(op) (!(op->code & UNSIGNED))
#define ARG_TYPE(op, arg) (((op)->spec >> ((arg) - 1) * 2) & 0x03)
#define JIT_BUFFER_OFFSET(jit)       ((jit_value)jit->ip - (jit_value)jit->buf)
#define MIN(a,b) ((a) < (b) ? (a) : (b))
#define MAX(a,b) ((a) > (b) ? (a) : (b))
#define TRACE_PREV      (1)
#define TRACE_NEXT      (2)
#define R(x) (jit_mkreg(JIT_RTYPE_INT, JIT_RTYPE_REG, (x)))
#define FR(x) (jit_mkreg(JIT_RTYPE_FLOAT, JIT_RTYPE_REG, (x)))
typedef long jit_value;
typedef unsigned long jit_unsigned_value;
typedef double jit_float;
void *malloc(size_t size);
void free(void *ptr);
void *realloc(void *ptr, size_t size);
struct jit_tree;
struct jit_set;
struct jit_rmap;
struct jit_debug_info;
typedef struct jit_op {
        unsigned short code;
        unsigned char spec;
        unsigned char arg_size;
        unsigned char assigned;
        unsigned char fp;
 unsigned char in_use;
        double flt_imm;
        jit_value arg[3];
        jit_value r_arg[3];
        long patch_addr;
        struct jit_op * jmp_addr;
        struct jit_op * next;
        struct jit_op * prev;
        struct jit_set * live_in;
        struct jit_set * live_out;
        struct jit_rmap * regmap;
        int normalized_pos;
        struct jit_tree * allocator_hints;
 struct jit_debug_info *debug_info;
 unsigned long code_offset;
 unsigned long code_length;
} jit_op;
typedef struct jit_label {
        long pos;
        jit_op * op;
        struct jit_label * next;
} jit_label;
typedef struct {
        unsigned type: 1;
        unsigned spec: 2;
        unsigned part: 1;
        unsigned id: 28;
} jit_reg;
static inline jit_value JIT_REG_TO_JIT_VALUE(jit_reg r)
{
        jit_value v;
        memcpy(&v, &r, sizeof(jit_reg));
        return v;
}
static inline jit_reg JIT_REG(jit_value v)
{
        jit_reg r;
        memcpy(&r, &v, sizeof(jit_value));
        return r;
}
static inline jit_value jit_mkreg(int type, int spec, int id)
{
 jit_reg r;
 r.type = type;
 r.spec = spec;
 r.id = id;
 r.part = 0;
 return JIT_REG_TO_JIT_VALUE(r);
}
static inline jit_value jit_mkreg_ex(int type, int spec, int id)
{
 jit_reg r;
 r.type = type;
 r.spec = spec;
 r.id = id;
 r.part = 1;
 return JIT_REG_TO_JIT_VALUE(r);
}
enum jit_inp_type {
 JIT_SIGNED_NUM,
 JIT_UNSIGNED_NUM,
 JIT_FLOAT_NUM,
 JIT_PTR
};
enum jit_warning {
 JIT_WARN_DEAD_CODE = 0x00000001,
 JIT_WARN_OP_WITHOUT_EFFECT = 0x00000002,
 JIT_WARN_INVALID_DATA_SIZE = 0x00000004,
 JIT_WARN_UNINITIALIZED_REG = 0x00000008,
 JIT_WARN_UNALIGNED_CODE = 0x00000010,
 JIT_WARN_INVALID_CODE_REFERENCE = 0x00000020,
 JIT_WARN_INVALID_DATA_REFERENCE = 0x00000040,
 JIT_WARN_MISSING_PATCH = 0x00000080,
 JIT_WARN_REGISTER_TYPE_MISMATCH = 0x00000100,
 JIT_WARN_ALL = 0x7fffffff
};
struct jit * jit_init();
struct jit_op * jit_add_op(struct jit * jit, unsigned short code, unsigned char spec, jit_value arg1, jit_value arg2, jit_value arg3, unsigned char arg_sizee, struct jit_debug_info *debug_info);
struct jit_op * jit_add_fop(struct jit * jit, unsigned short code, unsigned char spec, jit_value arg1, jit_value arg2, jit_value arg3, double flt_imm, unsigned char arg_sizee, struct jit_debug_info *debug_info);
struct jit_debug_info *jit_debug_info_new(const char *filename, const char *function, int lineno);
void jit_generate_code(struct jit * jit);
void jit_free(struct jit * jit);
void jit_dump_ops(struct jit * jit, int verbosity);
void jit_check_code(struct jit *jit, int warnings);
void jit_trace(struct jit *jit, int verbosity);
void jit_enable_optimization(struct jit * jit, int opt);
void jit_disable_optimization(struct jit * jit, int opt);
jit_op * jit_add_prolog(struct jit *, void *, struct jit_debug_info *);
jit_label * jit_get_label(struct jit * jit);
int jit_allocai(struct jit * jit, int size);
typedef jit_value jit_tree_key;
typedef void * jit_tree_value;
typedef struct jit_tree {
 struct jit_tree * left;
 struct jit_tree * right;
 int color;
 jit_tree_key key;
 jit_tree_value value;
} jit_tree;
static inline int jit_internal_is_red(jit_tree * n)
{
 if (n == NULL) return 0;
 return (n->color == (1));
}
static inline jit_tree * jit_internal_rotate_left(jit_tree * h)
{
 jit_tree * x = h->right;
 h->right = x->left;
 x->left = h;
 x->color = x->left->color;
 x->left->color = (1);
 return x;
}
static inline jit_tree * jit_internal_rotate_right(jit_tree * h)
{
 jit_tree * x = h->left;
 h->left = x->right;
 x->right = h;
 x->color = x->right->color;
 x->right->color = (1);
 return x;
}
static inline void jit_internal_color_flip(jit_tree * h)
{
 h->color = !h->color;
 h->left->color = !h->left->color;
 h->right->color = !h->right->color;
}
static inline jit_tree * jit_internal_fixup(jit_tree * h)
{
 if (jit_internal_is_red(h->right)) h = jit_internal_rotate_left(h);
 if (jit_internal_is_red(h->left) && (jit_internal_is_red(h->left->left))) {
  h = jit_internal_rotate_right(h);
  jit_internal_color_flip(h);
 }
 if (jit_internal_is_red(h->left) && jit_internal_is_red(h->right)) jit_internal_color_flip(h);
 return h;
}
static inline jit_tree * jit_internal_node_new(jit_tree_key key, jit_tree_value value)
{
 jit_tree * res = malloc(sizeof(jit_tree));
 res->key = key;
 res->value = value;
 res->color = (1);
 res->left = NULL;
 res->right = NULL;
 return res;
}
static jit_tree * jit_internal_node_insert(jit_tree * h, jit_tree_key key, jit_tree_value value, int * found)
{
 if (h == NULL) return jit_internal_node_new(key, value);
 if (jit_internal_is_red(h->left) && jit_internal_is_red(h->right)) jit_internal_color_flip(h);
 if (h->key == key) {
  h->value = value;
  if (found) *found = 1;
 } else if (h->key > key) h->left = jit_internal_node_insert(h->left, key, value, found);
 else h->right = jit_internal_node_insert(h->right, key, value, found);
 return jit_internal_fixup(h);
}
static jit_tree * jit_tree_insert(jit_tree * root, jit_tree_key key, jit_tree_value value, int * found)
{
 if (found) *found = 0;
 root = jit_internal_node_insert(root, key, value, found);
 root->color = (0);
 return root;
}
static jit_tree * jit_tree_search(jit_tree * h, jit_tree_key key)
{
 if ((h == NULL) || (h->key == key)) return h;
 if (h->key > key) return jit_tree_search(h->left, key);
 return jit_tree_search(h->right, key);
}
static inline jit_tree * jit_internal_move_red_left(jit_tree * h)
{
 jit_internal_color_flip(h);
 if (jit_internal_is_red(h->right->left)) {
  h->right = jit_internal_rotate_right(h->right);
  h = jit_internal_rotate_left(h);
  jit_internal_color_flip(h);
 }
 return h;
}
static inline jit_tree * jit_internal_move_red_right(jit_tree * h)
{
 jit_internal_color_flip(h);
 if (jit_internal_is_red(h->left->left)) {
  h = jit_internal_rotate_right(h);
  jit_internal_color_flip(h);
 }
 return h;
}
static inline jit_tree_key jit_internal_node_min(jit_tree * x)
{
 if (x->left == NULL) return x->key;
 else return jit_internal_node_min(x->left);
}
static jit_tree * jit_internal_delete_min(jit_tree * h)
{
 if (h->left == NULL) {
  free(h);
  return NULL;
 }
 if ((!jit_internal_is_red(h->left)) && (!jit_internal_is_red(h->left->left)))
  h = jit_internal_move_red_left(h);
 h->left = jit_internal_delete_min(h->left);
 return jit_internal_fixup(h);
}
static jit_tree * jit_internal_delete_node(jit_tree * h, jit_tree_key key, int * found)
{
 if (h == NULL) {
  if (found) *found = 0;
  return NULL;
 }
 if (key < h->key) {
  if ((!jit_internal_is_red(h->left)) && (h->left) && (!jit_internal_is_red(h->left->left)))
   h = jit_internal_move_red_left(h);
  h->left = jit_internal_delete_node(h->left, key, found);
 } else {
  if (jit_internal_is_red(h->left)) h = jit_internal_rotate_right(h);
  if ((key == h->key) && (h->right == NULL)) {
   free(h);
   if (found) *found = 1;
   return NULL;
  }
  if (!jit_internal_is_red(h->right) && (h->right) && !jit_internal_is_red(h->right->left)) h = jit_internal_move_red_right(h);
  if (key == h->key) {
   h->value = jit_tree_search(h->right, jit_internal_node_min(h->right))->value;
   h->key = jit_internal_node_min(h->right);
   h->right = jit_internal_delete_min(h->right);
   if (found) *found = 1;
  }
  else h->right = jit_internal_delete_node(h->right, key, found);
 }
 return jit_internal_fixup(h);
}
static inline jit_tree * jit_tree_delete(jit_tree * root, jit_tree_key key, int * found)
{
 root = jit_internal_delete_node(root, key, found);
 if (root) root->color = (0);
 return root;
}
static inline jit_tree * jit_tree_addall(jit_tree * target, jit_tree * n)
{
 if (n == NULL) return target;
 target = jit_tree_addall(target, n->left);
 target = jit_tree_insert(target, n->key, n->value, NULL);
 target = jit_tree_addall(target, n->right);
 return target;
}
static inline jit_tree * jit_tree_clone(jit_tree * root)
{
 return jit_tree_addall(NULL, root);
}
static void jit_tree_walk(jit_tree *h, void (*func)(jit_tree_key key, jit_tree_value value, void *thunk), void *thunk)
{
        if (!h) return;
 jit_tree_walk(h->left, func, thunk);
        func(h->key, h->value, thunk);
 jit_tree_walk(h->right, func, thunk);
}
static inline void jit_print_tree(jit_tree * h, int level)
{
 if (h == NULL) return;
 for (int i = 0; i < level; i++)
  printf(" ");
 printf("%i:%li\n", (int)h->key, (long)h->value);
 jit_print_tree(h->left, level + 1);
 jit_print_tree(h->right, level + 1);
}
static void jit_tree_free(jit_tree * h)
{
 if (h == NULL) return;
 jit_tree_free(h->left);
 jit_tree_free(h->right);
 free(h);
}
static int jit_tree_subset(jit_tree * root, jit_tree * n)
{
 if (n == NULL) return 1;
 return jit_tree_search(root, n->key) && jit_tree_subset(root, n->left) && jit_tree_subset(root, n->right);
}
static int jit_tree_equal(jit_tree * r1, jit_tree * r2)
{
 return jit_tree_subset(r1, r2) && jit_tree_subset(r2, r1);
}
static int jit_tree_size(jit_tree *h)
{
 if (h == NULL) return 0;
 return jit_tree_size(h->left) + jit_tree_size(h->right) + 1;
}
typedef struct {
 int id;
 char * name;
 char callee_saved;
 char fp;
 short priority;
} jit_hw_reg;
struct jit_reg_allocator {
 int gp_reg_cnt;
 int fp_reg_cnt;
 int fp_reg;
 int gp_arg_reg_cnt;
 int fp_arg_reg_cnt;
 jit_hw_reg * ret_reg;
 jit_hw_reg * fpret_reg;
 jit_hw_reg * gp_regs;
 jit_hw_reg * fp_regs;
 jit_hw_reg ** gp_arg_regs;
 jit_hw_reg ** fp_arg_regs;
 struct jit_func_info * current_func_info;
};
typedef struct jit_rmap {
 jit_tree * map;
} jit_rmap;
struct jit_allocator_hint {
 int last_pos;
 int should_be_calleesaved;
 int should_be_eax;
 int refs;
};
typedef struct jit_prepared_args {
 int count;
 int ready;
 int gp_args;
 int fp_args;
 int stack_size;
 jit_op * op;
 struct jit_out_arg {
  union {
   long generic;
   double fp;
  } value;
  int argpos;
  char isreg;
  char isfp;
  char size;
 } * args;
} jit_prepared_args;
typedef struct jit_set {
 jit_tree * root;
} jit_set;
struct jit_func_info {
 int general_arg_cnt;
 int float_arg_cnt;
 long allocai_mem;
 int arg_capacity;
 struct jit_inp_arg {
  enum jit_inp_type type;
  int size;
  char passed_by_reg;
  union {
   int reg;
   int stack_pos;
  } location;
  int spill_pos;
  int gp_pos;
  int fp_pos;
  int overflow;
  int phys_reg;
 } * args;
 int gp_reg_count;
 int fp_reg_count;
 int has_prolog;
 struct jit_op *first_op;
};
struct jit {
 unsigned char * buf;
 unsigned int buf_capacity;
 unsigned char * ip;
 struct jit_op * ops;
 struct jit_op * last_op;
 struct jit_reg_allocator * reg_al;
 struct jit_op * current_func;
 jit_label * labels;
 jit_prepared_args prepared_args;
 int push_count;
 unsigned int optimizations;
};
struct jit_debug_info {
        const char *filename;
 const char *function;
        int lineno;
        int warnings;
};
void jit_patch_external_calls(struct jit * jit);
void jit_patch_local_addrs(struct jit *jit);
void jit_collect_statistics(struct jit * jit);
void jit_optimize_st_ops(struct jit * jit);
int jit_optimize_join_addmul(struct jit * jit);
int jit_optimize_join_addimm(struct jit * jit);
void jit_optimize_frame_ptr(struct jit * jit);
void jit_optimize_unused_assignments(struct jit * jit);
static int jit_internal_is_cond_branch_op(jit_op *op);
static inline void jit_set_free(jit_set * s);
void jit_trace_callback(struct jit *jit, jit_op *op, int verbosity, int trace);
void jit_init_arg_params(struct jit * jit, struct jit_func_info * info, int argpos, int * phys_reg);
void jit_assign_regs(struct jit * jit);
struct jit_reg_allocator * jit_reg_allocator_create();
void jit_reg_allocator_free(struct jit_reg_allocator * a);
void jit_gen_op(struct jit * jit, jit_op * op);
char * jit_reg_allocator_get_hwreg_name(struct jit_reg_allocator * al, int reg);
int jit_reg_in_use(jit_op * op, int reg, int fp);
jit_hw_reg * jit_get_unused_reg(struct jit_reg_allocator * al, jit_op * op, int fp);
void jit_internal_rmap_free(jit_rmap * regmap);
void jit_allocator_hints_free(jit_tree *);
static struct jit_op * jit_op_new(unsigned short code, unsigned char spec, long arg1, long arg2, long arg3, unsigned char arg_size)
{
 struct jit_op * r = malloc(sizeof(struct jit_op));
 r->code = code;
 r->spec = spec;
 r->fp = 0;
 r->arg[0] = arg1;
 r->arg[1] = arg2;
 r->arg[2] = arg3;
 r->r_arg[0] = -1;
 r->r_arg[1] = -1;
 r->r_arg[2] = -1;
 r->assigned = 0;
 r->arg_size = arg_size;
 r->next = NULL;
 r->prev = NULL;
 r->patch_addr = 0;
 r->jmp_addr = NULL;
 r->regmap = NULL;
 r->live_in = NULL;
 r->live_out = NULL;
 r->allocator_hints = NULL;
 r->debug_info = NULL;
 return r;
}
static inline void jit_op_append(jit_op * op, jit_op * appended)
{
 appended->next = op->next;
 if (op->next != NULL) op->next->prev = appended;
 appended->prev = op;
 op->next = appended;
}
static inline void jit_op_prepend(jit_op * op, jit_op * prepended)
{
 prepended->prev = op->prev;
 if (op->prev != NULL) op->prev->next = prepended;
 prepended->next = op;
 op->prev = prepended;
}
static inline jit_op * jit_op_first(jit_op * op)
{
 while (op->prev != NULL) op = op->prev;
 return op;
}
static inline jit_op * jit_op_last(jit_op * op)
{
 while (op->next != NULL) op = op->next;
 return op;
}
static inline void jit_free_op(struct jit_op *op)
{
        if (op->live_in) jit_set_free(op->live_in);
        if (op->live_out) jit_set_free(op->live_out);
        jit_internal_rmap_free(op->regmap);
        jit_allocator_hints_free(op->allocator_hints);
 if (op->debug_info) free(op->debug_info);
        if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
                struct jit_func_info * info = (struct jit_func_info *)op->arg[1];
                free(info->args);
                free(info);
        }
        free(op);
}
static inline void jit_op_delete(jit_op *op)
{
 op->prev->next = op->next;
 if (op->next) op->next->prev = op->prev;
 jit_free_op(op);
}
static inline int jit_is_label(struct jit * jit, void * ptr)
{
 jit_label * lab = jit->labels;
 while (1) {
  if (lab == NULL) return 0;
  if (lab == ptr) return 1;
  lab = lab->next;
 }
}
static inline struct jit_func_info * jit_current_func_info(struct jit * jit)
{
 return (struct jit_func_info *)(jit->current_func->arg[1]);
}
static inline void jit_internal_funcall_prepare(struct jit * jit, jit_op * op, int count)
{
 jit->prepared_args.args = malloc(sizeof(struct jit_out_arg) * count);
 jit->prepared_args.count = count;
 jit->prepared_args.ready = 0;
 jit->prepared_args.stack_size = 0;
 jit->prepared_args.op = op;
 jit->prepared_args.gp_args = 0;
 jit->prepared_args.fp_args = 0;
}
static inline void jit_internal_funcall_put_arg(struct jit * jit, jit_op * op)
{
 int pos = jit->prepared_args.ready;
 struct jit_out_arg * arg = &(jit->prepared_args.args[pos]);
 arg->isreg = !(op->code & 0x02);
 arg->isfp = 0;
 arg->value.generic = op->arg[0];
 arg->argpos = jit->prepared_args.gp_args++;
 jit->prepared_args.ready++;
 if (jit->prepared_args.ready > jit->reg_al->gp_arg_reg_cnt)
  jit->prepared_args.stack_size += (sizeof(void *));
}
static inline void jit_internal_funcall_fput_arg(struct jit * jit, jit_op * op)
{
 int pos = jit->prepared_args.ready;
 struct jit_out_arg * arg = &(jit->prepared_args.args[pos]);
 arg->isreg = !(op->code & 0x02);
 arg->isfp = 1;
 arg->size = op->arg_size;
 arg->argpos = jit->prepared_args.fp_args++;
 if ((op->code & 0x02)) arg->value.fp = op->flt_imm;
 else arg->value.generic = op->arg[0];
 jit->prepared_args.ready++;
 if (jit->prepared_args.ready > jit->reg_al->fp_arg_reg_cnt) {
  jit->prepared_args.stack_size += op->arg_size;
 }
}
static inline jit_value jit_value_align(jit_value value, jit_value alignment)
{
 return (value + (alignment - 1)) & (- alignment);
}
static inline jit_set * jit_set_new()
{
 jit_set * s = malloc(sizeof(jit_set));
 s->root = NULL;
 return s;
}
static inline jit_set * jit_set_clone(jit_set * s)
{
 jit_set * clone = jit_set_new();
 clone->root = jit_tree_clone(s->root);
 return clone;
}
static inline void jit_set_free(jit_set * s)
{
 jit_tree_free(s->root);
 free(s);
}
static inline void jit_set_addall(jit_set * target, jit_set * s)
{
 target->root = jit_tree_addall(target->root, s->root);
}
static inline int jit_set_get(jit_set * s, int value)
{
 return (jit_tree_search(s->root, value) != NULL);
}
static inline void jit_set_add(jit_set * s, int value)
{
 s->root = jit_tree_insert(s->root, value, (void *)1, NULL);
}
static inline void jit_set_remove(jit_set * s, int value)
{
 s->root = jit_tree_delete(s->root, value, NULL);
}
static inline int jit_set_equal(jit_set * s1, jit_set * s2)
{
 return jit_tree_equal(s1->root, s2->root);
}
static inline int jit_set_size(jit_set *s)
{
 return jit_tree_size(s->root);
}
typedef enum {
 sparc_r0 = 0,
 sparc_r1 = 1,
 sparc_r2 = 2,
 sparc_r3 = 3,
 sparc_r4 = 4,
 sparc_r5 = 5,
 sparc_r6 = 6,
 sparc_r7 = 7,
 sparc_r8 = 8,
 sparc_r9 = 9,
 sparc_r10 = 10,
 sparc_r11 = 11,
 sparc_r12 = 12,
 sparc_r13 = 13,
 sparc_r14 = 14,
 sparc_r15 = 15,
 sparc_r16 = 16,
 sparc_r17 = 17,
 sparc_r18 = 18,
 sparc_r19 = 19,
 sparc_r20 = 20,
 sparc_r21 = 21,
 sparc_r22 = 22,
 sparc_r23 = 23,
 sparc_r24 = 24,
 sparc_r25 = 25,
 sparc_r26 = 26,
 sparc_r27 = 27,
 sparc_r28 = 28,
 sparc_r29 = 29,
 sparc_r30 = 30,
 sparc_r31 = 31,
 sparc_g0 = 0, sparc_zero = 0,
 sparc_g1 = 1,
 sparc_g2 = 2,
 sparc_g3 = 3,
 sparc_g4 = 4,
 sparc_g5 = 5,
 sparc_g6 = 6,
 sparc_g7 = 7,
 sparc_o0 = 8,
 sparc_o1 = 9,
 sparc_o2 = 10,
 sparc_o3 = 11,
 sparc_o4 = 12,
 sparc_o5 = 13,
 sparc_o6 = 14, sparc_sp = 14,
 sparc_o7 = 15, sparc_callsite = 15,
 sparc_l0 = 16,
 sparc_l1 = 17,
 sparc_l2 = 18,
 sparc_l3 = 19,
 sparc_l4 = 20,
 sparc_l5 = 21,
 sparc_l6 = 22,
 sparc_l7 = 23,
 sparc_i0 = 24,
 sparc_i1 = 25,
 sparc_i2 = 26,
 sparc_i3 = 27,
 sparc_i4 = 28,
 sparc_i5 = 29,
 sparc_i6 = 30, sparc_fp = 30,
 sparc_i7 = 31,
 sparc_nreg = 32,
 sparc_f0 = 0,
 sparc_f1 = 1,
 sparc_f2 = 2,
 sparc_f3 = 3,
 sparc_f4 = 4,
 sparc_f5 = 5,
 sparc_f6 = 6,
 sparc_f7 = 7,
 sparc_f8 = 8,
 sparc_f9 = 9,
 sparc_f10 = 10,
 sparc_f11 = 11,
 sparc_f12 = 12,
 sparc_f13 = 13,
 sparc_f14 = 14,
 sparc_f15 = 15,
 sparc_f16 = 16,
 sparc_f17 = 17,
 sparc_f18 = 18,
 sparc_f19 = 19,
 sparc_f20 = 20,
 sparc_f21 = 21,
 sparc_f22 = 22,
 sparc_f23 = 23,
 sparc_f24 = 24,
 sparc_f25 = 25,
 sparc_f26 = 26,
 sparc_f27 = 27,
 sparc_f28 = 28,
 sparc_f29 = 29,
 sparc_f30 = 30,
 sparc_f31 = 31,
} jit_internal_SparcRegister;
typedef enum {
 sparc_bn = 0, sparc_bnever = 0,
 sparc_be = 1,
 sparc_ble = 2,
 sparc_bl = 3,
 sparc_bleu = 4,
 sparc_bcs = 5, sparc_blu = 5,
 sparc_bneg = 6,
 sparc_bvs = 7, sparc_boverflow = 7,
 sparc_ba = 8, sparc_balways = 8,
 sparc_bne = 9,
 sparc_bg = 10,
 sparc_bge = 11,
 sparc_bgu = 12,
 sparc_bcc = 13, sparc_bgeu = 13,
 sparc_bpos = 14,
 sparc_bvc = 15, sparc_bnoverflow = 15
} jit_internal_SparcCond;
typedef enum {
 sparc_feq = 0,
 sparc_fl = 1,
 sparc_fg = 2,
 sparc_unordered = 3,
 sparc_fba = 8,
 sparc_fbn = 0,
 sparc_fbu = 7,
 sparc_fbg = 6,
 sparc_fbug = 5,
 sparc_fbl = 4,
 sparc_fbul = 3,
 sparc_fblg = 2,
 sparc_fbne = 1,
 sparc_fbe = 9,
 sparc_fbue = 10,
 sparc_fbge = 11,
 sparc_fbuge = 12,
 sparc_fble = 13,
 sparc_fbule = 14,
 sparc_fbo = 15
} jit_internal_SparcFCond;
typedef enum {
 sparc_icc = 4,
    sparc_xcc = 6,
    sparc_fcc0 = 0,
 sparc_fcc1 = 1,
 sparc_fcc2 = 2,
 sparc_fcc3 = 3
} jit_internal_SparcCC;
typedef enum {
 sparc_icc_short = 0,
    sparc_xcc_short = 2
} jit_internal_SparcCCShort;
typedef enum {
 sparc_fitos_val = 196,
 sparc_fitod_val = 200,
 sparc_fitoq_val = 204,
 sparc_fxtos_val = 132,
 sparc_fxtod_val = 136,
 sparc_fxtoq_val = 140,
 sparc_fstoi_val = 209,
 sparc_fdtoi_val = 210,
 sparc_fqtoi_val = 211,
 sparc_fstod_val = 201,
 sparc_fstoq_val = 205,
 sparc_fdtos_val = 198,
 sparc_fdtoq_val = 206,
 sparc_fqtos_val = 199,
 sparc_fqtod_val = 203,
 sparc_fmovs_val = 1,
 sparc_fmovd_val = 2,
 sparc_fnegs_val = 5,
 sparc_fnegd_val = 6,
 sparc_fabss_val = 9,
 sparc_fabsd_val = 10,
 sparc_fsqrts_val = 41,
 sparc_fsqrtd_val = 42,
 sparc_fsqrtq_val = 43,
 sparc_fadds_val = 65,
 sparc_faddd_val = 66,
 sparc_faddq_val = 67,
 sparc_fsubs_val = 69,
 sparc_fsubd_val = 70,
 sparc_fsubq_val = 71,
 sparc_fmuls_val = 73,
 sparc_fmuld_val = 74,
 sparc_fmulq_val = 75,
 sparc_fsmuld_val = 105,
 sparc_fdmulq_val = 111,
 sparc_fdivs_val = 77,
 sparc_fdivd_val = 78,
 sparc_fdivq_val = 79,
 sparc_fcmps_val = 81,
 sparc_fcmpd_val = 82,
 sparc_fcmpq_val = 83,
 sparc_fcmpes_val = 85,
 sparc_fcmped_val = 86,
 sparc_fcmpeq_val = 87
} jit_internal_SparcFOp;
typedef enum {
 sparc_membar_load_load = 0x1,
 sparc_membar_store_load = 0x2,
 sparc_membar_load_store = 0x4,
 sparc_membar_store_store = 0x8,
 sparc_membar_lookaside = 0x10,
 sparc_membar_memissue = 0x20,
 sparc_membar_sync = 0x40,
    sparc_membar_all = 0x4f
} jit_internal_SparcMembarFlags;
typedef struct {
 unsigned int op : 2;
 unsigned int disp : 30;
} jit_internal_sparc_format1;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op2 : 3;
 unsigned int disp : 22;
} jit_internal_sparc_format2a;
typedef struct {
 unsigned int op : 2;
 unsigned int a : 1;
 unsigned int cond : 4;
 unsigned int op2 : 3;
 unsigned int disp : 22;
} jit_internal_sparc_format2b;
typedef struct {
 unsigned int op : 2;
 unsigned int a : 1;
 unsigned int cond : 4;
 unsigned int op2 : 3;
 unsigned int cc01 : 2;
 unsigned int p : 1;
 unsigned int d19 : 19;
} jit_internal_sparc_format2c;
typedef struct {
 unsigned int op : 2;
 unsigned int a : 1;
 unsigned int res : 1;
 unsigned int rcond: 3;
 unsigned int op2 : 3;
 unsigned int d16hi: 2;
 unsigned int p : 1;
 unsigned int rs1 : 5;
 unsigned int d16lo: 14;
} jit_internal_sparc_format2d;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int asi : 8;
 unsigned int rs2 : 5;
} jit_internal_sparc_format3a;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int x : 1;
 unsigned int asi : 7;
 unsigned int rs2 : 5;
} jit_internal_sparc_format3ax;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int imm : 13;
} jit_internal_sparc_format3b;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int x : 1;
 unsigned int imm : 12;
} jit_internal_sparc_format3bx;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int opf : 9;
 unsigned int rs2 : 5;
} jit_internal_sparc_format3c;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int cc01 : 2;
 unsigned int res : 6;
 unsigned int rs2 : 5;
} jit_internal_sparc_format4a;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int rs1 : 5;
 unsigned int i : 1;
 unsigned int cc01 : 2;
 unsigned int simm : 11;
} jit_internal_sparc_format4b;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int cc2 : 1;
 unsigned int cond : 4;
 unsigned int i : 1;
 unsigned int cc01 : 2;
 unsigned int res : 6;
 unsigned int rs2 : 5;
} jit_internal_sparc_format4c;
typedef struct {
 unsigned int op : 2;
 unsigned int rd : 5;
 unsigned int op3 : 6;
 unsigned int cc2 : 1;
 unsigned int cond : 4;
 unsigned int i : 1;
 unsigned int cc01 : 2;
 unsigned int simm : 11;
} jit_internal_sparc_format4d;
void jit_optimize_st_ops(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_ST)
  && (op->prev)
  && (op->prev->code == (JIT_MOV | 0x02))
  && (op->arg[1] == op->prev->arg[0])
  && (((((long)(op->prev->arg[1])) >= INT32_MIN) && (((long)(op->prev->arg[1])) <= INT32_MAX)))
  && (!jit_set_get(op->live_out, op->arg[1])))
  {
   if (!(op->code & 0x02)) {
    op->code = JIT_X86_STI | 0x01;
    op->spec = (((0x00) << 4) | ((0x02) << 2) | (0x01));
   } else {
    op->code = JIT_X86_STI | 0x02;
    op->spec = (((0x00) << 4) | ((0x02) << 2) | (0x02));
   }
   op->arg[1] = op->prev->arg[1];
   op->prev->code = JIT_NOP;
   op->prev->spec = (((0x00) << 4) | ((0x00) << 2) | (0x00));
  }
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_STX)
  && (op->prev)
  && (op->prev->code == (JIT_MOV | 0x02))
  && (op->arg[2] == op->prev->arg[0])
  && (((((long)(op->prev->arg[1])) >= INT32_MIN) && (((long)(op->prev->arg[1])) <= INT32_MAX)))
  && (!jit_set_get(op->live_out, op->arg[2])))
  {
   if (!(op->code & 0x02)) {
    op->code = JIT_X86_STXI | 0x01;
    op->spec = (((0x02) << 4) | ((0x01) << 2) | (0x01));
   } else {
    op->code = JIT_X86_STXI | 0x02;
    op->spec = (((0x02) << 4) | ((0x01) << 2) | (0x02));
   }
   op->arg[2] = op->prev->arg[1];
   op->prev->code = JIT_NOP;
   op->prev->spec = (((0x00) << 4) | ((0x00) << 2) | (0x00));
  }
 }
}
void jit_optimize_frame_ptr(struct jit * jit)
{
 if (!jit->optimizations & (0x01)) return;
 struct jit_func_info * info = NULL;
 int uses_frame_ptr = 0;
 for (jit_op * op = jit_op_first(jit->ops); ; op = op->next) {
  if (!op || ((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   if (info && !uses_frame_ptr) {
    info->has_prolog = 0;
    uses_frame_ptr = 0;
   }
   if (op) info = (struct jit_func_info *) op->arg[1];
  }
  if (!op) break;
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_ALLOCA) || (((jit_opcode) (op->code & 0xfff8)) == JIT_UREG) || (((jit_opcode) (op->code & 0xfff8)) == JIT_LREG) || (((jit_opcode) (op->code & 0xfff8)) == JIT_SYNCREG)) {
   uses_frame_ptr |= 1;
  }
 }
}
void jit_optimize_unused_assignments(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if ((((op)->spec >> ((1) - 1) * 2) & 0x03) == 0x03) {
   if ((((jit_opcode) (op->code & 0xfff8)) == JIT_ADDC) || (((jit_opcode) (op->code & 0xfff8)) == JIT_ADDX)
   || (((jit_opcode) (op->code & 0xfff8)) == JIT_SUBC) || (((jit_opcode) (op->code & 0xfff8)) == JIT_SUBX)) continue;
   if (!jit_set_get(op->live_out, op->arg[0])) {
    op->code = JIT_NOP;
    op->spec = (((0x00) << 4) | ((0x00) << 2) | (0x00));
   }
  }
 }
}
static inline void jit_internal_make_nop(jit_op * op)
{
 op->code = JIT_NOP;
 op->spec = (((0x00) << 4) | ((0x00) << 2) | (0x00));
}
static jit_op * jit_internal_get_related_op(jit_op * op, int result_reg)
{
 jit_op * nextop = op->next;
 if ((nextop->arg[0] != result_reg) && (jit_set_get(nextop->live_out, result_reg))) return NULL;
 int used = 0;
 for (int i = 0; i < 3; i++)
  if (((((nextop)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01) && (nextop->arg[i])) {
   used = 1;
   break;
  }
 if (used) return nextop;
 return NULL;
}
static int jit_internal_join_2ops(jit_op * op, int opcode1, int opcode2, int (* joinfn)(jit_op *, jit_op *))
{
 if (op->code == opcode1) {
  jit_value result_reg = op->arg[0];
  jit_op * nextop = jit_internal_get_related_op(op, result_reg);
  if (nextop && (nextop->code == opcode2)) return joinfn(op, nextop);
 }
 return 0;
}
static int jit_internal_shift_index(int arg)
{
 if (arg == 2) return 1;
 if (arg == 4) return 2;
 if (arg == 8) return 3;
 assert(0);
}
static inline int jit_internal_pow2(int arg)
{
 int r = 1;
 for (int i = 0; i < arg; i++)
  r *= 2;
 return r;
}
static inline int jit_internal_is_suitable_mul(jit_op * op)
{
 jit_value arg = op->arg[2];
 return ((((op->code == (JIT_MUL | 0x02)) && ((arg == 2) || (arg == 4) || (arg == 8))))
 || ((op->code == (JIT_LSH | 0x02)) && ((arg == 1) || (arg == 2) || (arg == 3))));
}
static inline int jit_internal_make_addmuli(jit_op * op, jit_op * nextop)
{
 nextop->code = JIT_X86_ADDMUL | 0x02;
 nextop->spec = (((0x02) << 4) | ((0x01) << 2) | (0x03));
 nextop->arg[1] = op->arg[1];
 nextop->arg_size = (((jit_opcode) (op->code & 0xfff8)) == JIT_MUL ? jit_internal_shift_index(op->arg[2]) : op->arg[2]);
 jit_internal_make_nop(op);
 return 1;
}
static int jit_internal_join_muli_addi(jit_op * op, jit_op * nextop)
{
 if (!((((long)(nextop->arg[2])) >= INT32_MIN) && (((long)(nextop->arg[2])) <= INT32_MAX))) return 0;
 if (!jit_internal_is_suitable_mul(op)) return 0;
 return jit_internal_make_addmuli(op, nextop);
}
static int jit_internal_join_muli_ori(jit_op * op, jit_op * nextop)
{
 if (!jit_internal_is_suitable_mul(op)) return 0;
 int max = (((jit_opcode) (op->code & 0xfff8)) == JIT_MUL) ? max = op->arg[2] : jit_internal_pow2(op->arg[2]);
 if ((nextop->arg[2] > 0) && (nextop->arg[2] < max)) return jit_internal_make_addmuli(op, nextop);
 else return 0;
}
static int jit_internal_join_muli_addr(jit_op * op, jit_op * nextop)
{
 if ((!jit_internal_is_suitable_mul(op) || (nextop->arg[1] == nextop->arg[2]))) return 0;
 jit_value add_reg = (nextop->arg[1] == op->arg[0]) ? nextop->arg[2] : nextop->arg[1];
 nextop->code = JIT_X86_ADDMUL | 0x01;
 nextop->spec = (((0x01) << 4) | ((0x01) << 2) | (0x03));
 nextop->arg[1] = add_reg;
 nextop->arg[2] = op->arg[1];
 nextop->arg_size = (((jit_opcode) (op->code & 0xfff8)) == JIT_MUL ? jit_internal_shift_index(op->arg[2]) : op->arg[2]);
 jit_internal_make_nop(op);
 return 1;
}
int jit_optimize_join_addmul(struct jit * jit)
{
 int change = 0;
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  change |= jit_internal_join_2ops(op, JIT_MUL | 0x02, JIT_ADD | 0x02, jit_internal_join_muli_addi);
  change |= jit_internal_join_2ops(op, JIT_LSH | 0x02, JIT_ADD | 0x02, jit_internal_join_muli_addi);
  change |= jit_internal_join_2ops(op, JIT_MUL | 0x02, JIT_ADD | 0x01, jit_internal_join_muli_addr);
  change |= jit_internal_join_2ops(op, JIT_LSH | 0x02, JIT_ADD | 0x01, jit_internal_join_muli_addr);
  change |= jit_internal_join_2ops(op, JIT_MUL | 0x02, JIT_OR | 0x02, jit_internal_join_muli_ori);
  change |= jit_internal_join_2ops(op, JIT_LSH | 0x02, JIT_OR | 0x02, jit_internal_join_muli_ori);
 }
 return change;
}
static int jit_internal_join_addr_addi(jit_op * op, jit_op * nextop)
{
 if (!((((long)(nextop->arg[2])) >= INT32_MIN) && (((long)(nextop->arg[2])) <= INT32_MAX))) return 0;
 jit_internal_make_nop(op);
 nextop->code = JIT_X86_ADDIMM;
 nextop->spec = (((0x01) << 4) | ((0x01) << 2) | (0x03));
 nextop->arg[2] = nextop->arg[2];
 memcpy(&nextop->flt_imm, &(nextop->arg[2]), sizeof(jit_value));
 nextop->arg[1] = op->arg[1];
 nextop->arg[2] = op->arg[2];
 return 1;
}
static int jit_internal_join_addi_addr(jit_op * op, jit_op * nextop)
{
 if (!((((long)(op->arg[2])) >= INT32_MIN) && (((long)(op->arg[2])) <= INT32_MAX))) return 0;
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_SUB) op->arg[2] = -op->arg[2];
 jit_internal_make_nop(op);
 nextop->code = JIT_X86_ADDIMM;
 nextop->spec = (((0x01) << 4) | ((0x01) << 2) | (0x03));
 if (nextop->arg[1] == nextop->arg[2]) op->arg[2] *= 2;
 memcpy(&nextop->flt_imm, &(op->arg[2]), sizeof(jit_value));
 if (nextop->arg[1] == op->arg[0]) nextop->arg[1] = op->arg[1];
 if (nextop->arg[2] == op->arg[0]) nextop->arg[2] = op->arg[1];
 return 1;
}
int jit_optimize_join_addimm(struct jit * jit)
{
 int change = 0;
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  change |= jit_internal_join_2ops(op, JIT_ADD | 0x01, JIT_ADD | 0x02, jit_internal_join_addr_addi);
  change |= jit_internal_join_2ops(op, JIT_ADD | 0x01, JIT_SUB | 0x02, jit_internal_join_addr_addi);
  change |= jit_internal_join_2ops(op, JIT_ADD | 0x02, JIT_ADD | 0x01, jit_internal_join_addi_addr);
  change |= jit_internal_join_2ops(op, JIT_SUB | 0x02, JIT_ADD | 0x01, jit_internal_join_addi_addr);
 }
 return change;
}
inline jit_hw_reg * jit_internal_rmap_get(jit_rmap * rmap, jit_value reg);
static inline int jit_internal_GET_REG_POS(struct jit * jit, int r)
{
 struct jit_func_info * info = jit_current_func_info(jit);
 if (JIT_REG(r).spec == (0)) {
  if (JIT_REG(r).type == (0)) {
   return - (info->allocai_mem + (16) + JIT_REG(r).id * (sizeof(void *)) + (sizeof(void *)));
  } else {
   return - (info->allocai_mem + (16) + info->gp_reg_count * (sizeof(void *)) + JIT_REG(r).id * sizeof(double) + sizeof(double));
  }
 }
 if (JIT_REG(r).spec == (3)) {
  int arg_id = JIT_REG(r).id;
  struct jit_inp_arg * a = &(jit_current_func_info(jit)->args[arg_id]);
  return a->spill_pos;
 }
 assert(0);
}
static inline int jit_internal_space_for_outgoing_args(struct jit *jit, jit_op *op) {
 int passed_gp_args = 0;
 int passed_fp_args = 0;
 op = op->next;
 while (op && (((jit_opcode) (op->code & 0xfff8)) != JIT_PROLOG)) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PREPARE) {
   passed_gp_args = ((passed_gp_args) > (op->arg[0]) ? (passed_gp_args) : (op->arg[0]));
   passed_fp_args = ((passed_fp_args) > (op->arg[1]) ? (passed_fp_args) : (op->arg[1]));
  }
  op = op->next;
 }
 int stack_gp_args = ((0) > (passed_gp_args - jit->reg_al->gp_arg_reg_cnt) ? (0) : (passed_gp_args - jit->reg_al->gp_arg_reg_cnt));
 int stack_fp_args = ((0) > (passed_fp_args - jit->reg_al->fp_arg_reg_cnt) ? (0) : (passed_fp_args - jit->reg_al->fp_arg_reg_cnt));
 return stack_gp_args * (sizeof(void *)) + stack_fp_args * sizeof(double);
}
int jit_allocai(struct jit * jit, int size)
{
 int real_size = jit_value_align(size, 16);
 jit_add_op(jit, JIT_ALLOCA | 0x02, (((0x00) << 4) | ((0x00) << 2) | (0x02)), (long)real_size, 0, 0, 0, NULL);
 jit_current_func_info(jit)->allocai_mem += real_size;
 return -(jit_current_func_info(jit)->allocai_mem + (16));
}
static inline void jit_internal_init_arg(struct jit_inp_arg * arg, int p)
{
 static const int in_regs[] = { sparc_i0, sparc_i1, sparc_i2, sparc_i3, sparc_i4, sparc_i5 };
 if (p < 6) {
  arg->passed_by_reg = 1;
  arg->location.reg = in_regs[p];
  arg->spill_pos = 92 + (p - 6) * 4;
 } else {
  arg->passed_by_reg = 0;
  arg->location.stack_pos = 92 + (p - 6) * 4;
  arg->spill_pos = arg->location.stack_pos;
 }
 arg->overflow = 0;
 arg->phys_reg = p;
}
void jit_init_arg_params(struct jit * jit, struct jit_func_info * info, int p, int * phys_reg)
{
 struct jit_inp_arg * a = &(info->args[p]);
 jit_internal_init_arg(a, *phys_reg);
 *phys_reg = *phys_reg + 1;
 if ((a->type == JIT_FLOAT_NUM) && (a->size == sizeof(double))) {
  a->overflow = 1;
  *phys_reg = *phys_reg + 1;
 }
}
static inline void jit_internal_emit_cond_op_op(struct jit * jit, struct jit_op * op, int cond, int imm)
{
 if (imm) {
  if (op->r_arg[2] != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((((jit->ip)))); __f->op = (2); __f->imm = ((((op->r_arg[2])))); __f->i = 1; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->rs2 = ((((sparc_g0)))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->rs2 = ((((op->r_arg[2])))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0)); __f->i = 1; __f->rd = ((op->r_arg[0])); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format4d *__f = (jit_internal_sparc_format4d*)((jit->ip)); __f->op = (0x2); __f->rd = (op->r_arg[0]); __f->op3 = (0x2c); __f->cc2 = ((sparc_xcc) >> 2) & 0x1; __f->cond = cond; __f->i = 1; __f->cc01= (sparc_xcc) & 0x3; __f->simm = (1); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_branch_op(struct jit * jit, struct jit_op * op, int cond, int imm)
{
 if (imm) {
  if (op->r_arg[2] != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((((jit->ip)))); __f->op = (2); __f->imm = ((((op->r_arg[2])))); __f->i = 1; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->rs2 = ((((sparc_g0)))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = ((((op->r_arg[1])))); __f->rs2 = ((((op->r_arg[2])))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((cond)); __f->op2 = (2); __f->disp = (((!jit_is_label(jit, (void *)(op->r_arg[0])) ? (op->r_arg[0]) : ((((long)jit->buf + (long)((jit_label *)(op->r_arg[0]))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_branch_mask_op(struct jit * jit, struct jit_op * op, int cond, int imm)
{
 if (imm) {
  if (op->r_arg[2] != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((op->r_arg[2])); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((op->r_arg[1])); __f->op3 = (((16) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((sparc_g0)); __f->rs1 = ((op->r_arg[1])); __f->rs2 = ((sparc_g0)); __f->op3 = (((16) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((sparc_g0)); __f->rs1 = ((op->r_arg[1])); __f->rs2 = ((op->r_arg[2])); __f->op3 = (((16) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((cond)); __f->op2 = (2); __f->disp = (((!jit_is_label(jit, (void *)(op->r_arg[0])) ? (op->r_arg[0]) : ((((long)jit->buf + (long)((jit_label *)(op->r_arg[0]))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_op_and_overflow_branch(struct jit * jit, struct jit_op * op, int alu_op, int imm, int negation)
{
 long a1 = op->r_arg[0];
 long a2 = op->r_arg[1];
 long a3 = op->r_arg[2];
 if (imm) {
  switch (alu_op) {
   case JIT_ADD: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a2))); __f->rs1 = (((a2))); __f->op3 = (0|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
   case JIT_SUB: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a2))); __f->rs1 = (((a2))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
   default: assert(0);
  }
 } else {
  switch (alu_op) {
   case JIT_ADD: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a2))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
   case JIT_SUB: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a2))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
   default: assert(0);
  }
 }
 op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
 if (!negation) do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((sparc_boverflow)); __f->op2 = (2); __f->disp = (((!jit_is_label(jit, (void *)(a1)) ? (a1) : ((((long)jit->buf + (long)((jit_label *)(a1))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 else do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((sparc_bnoverflow)); __f->op2 = (2); __f->disp = (((!jit_is_label(jit, (void *)(a1)) ? (a1) : ((((long)jit->buf + (long)((jit_label *)(a1))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_fpbranch_op(struct jit * jit, struct jit_op * op, int cond, int arg1, int arg2)
{
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fcmpd_val)); __f->rd = (0); __f->rs1 = ((arg1)); __f->rs2 = ((arg2)); __f->op3 = (53); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((cond)); __f->op2 = (6); __f->disp = (((!jit_is_label(jit, (void *)(op->r_arg[0])) ? (op->r_arg[0]) : ((((long)jit->buf + (long)((jit_label *)(op->r_arg[0]))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline int jit_internal_is_spilled(int arg_id, jit_op * prepare_op, int * reg)
{
 jit_hw_reg * hreg = jit_internal_rmap_get(prepare_op->regmap, arg_id);
 if (hreg) {
  *reg = hreg->id;
  return 0;
 }
 return 1;
}
static const int jit_internal_OUT_REGS[] = { sparc_o0, sparc_o1, sparc_o2, sparc_o3, sparc_o4, sparc_o5 };
static inline void jit_internal_emit_set_arg_imm(struct jit * jit, int value, int slot)
{
 if (slot < 6) do { if ((value) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((jit_internal_OUT_REGS[slot])))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(value) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((jit_internal_OUT_REGS[slot]))); __f->op2 = (4); __f->disp = ((((uint32_t)(value))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(value) >= -4096) && ((int32_t)(value) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(value))); __f->i = 1; __f->rd = (((jit_internal_OUT_REGS[slot]))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((jit_internal_OUT_REGS[slot]))); __f->op2 = (4); __f->disp = ((((uint32_t)(value))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(value)&0x3ff)); __f->i = 1; __f->rd = (((jit_internal_OUT_REGS[slot]))); __f->rs1 = (((jit_internal_OUT_REGS[slot]))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
 else {
  do { if ((value) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(value) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(value))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(value) >= -4096) && ((int32_t)(value) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(value))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(value))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(value)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((92 + (slot - 6) * 4)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((sparc_sp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
static inline void jit_internal_emit_set_arg_reg(struct jit * jit, int sreg, int slot)
{
 if (slot < 6) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((jit_internal_OUT_REGS[slot]))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((sreg))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((92 + (slot - 6) * 4)); __f->i = 1; __f->rd = ((sreg)); __f->rs1 = ((sparc_sp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_set_arg_freg(struct jit * jit, int sreg, int slot)
{
 if (slot < 6) {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sreg)); __f->rs1 = ((sparc_fp)); __f->op3 = (36); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((jit_internal_OUT_REGS[slot])); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((92 + (slot - 6) * 4)); __f->i = 1; __f->rd = ((sreg)); __f->rs1 = ((sparc_sp)); __f->op3 = (36); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_set_arg_mem(struct jit * jit, int disp, int slot)
{
 if (slot < 6) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((disp)); __f->i = 1; __f->rd = ((jit_internal_OUT_REGS[slot])); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 else {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((disp)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((92 + (slot - 6) * 4)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((sparc_sp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
static inline void jit_internal_emit_arguments(struct jit * jit)
{
 int assoc_gp = 0;
 int sreg = 0;
 for (int i = 0; i < jit->prepared_args.count; i++) {
  struct jit_out_arg * arg = &(jit->prepared_args.args[i]);
  long value = arg->value.generic;
  if (!arg->isfp) {
   if (arg->isreg) {
    if (jit_internal_is_spilled(value, jit->prepared_args.op, &sreg))
     jit_internal_emit_set_arg_mem(jit, jit_internal_GET_REG_POS(jit, value), assoc_gp++);
    else jit_internal_emit_set_arg_reg(jit, sreg, assoc_gp++);
   } else jit_internal_emit_set_arg_imm(jit, value, assoc_gp++);
   continue;
  }
  if (arg->size == sizeof(float)) {
   if (arg->isreg) {
    if (jit_internal_is_spilled(value, jit->prepared_args.op, &sreg)) {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, value))); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     sreg = sparc_f30;
    }
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((sreg)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    jit_internal_emit_set_arg_freg(jit, sparc_f30, assoc_gp++);
   } else {
    float fl = (float)arg->value.fp;
    int fl_val;
    memcpy(&fl_val, &fl, sizeof(float));
    jit_internal_emit_set_arg_imm(jit, fl_val, assoc_gp++);
   }
  } else {
   if (arg->isreg) {
    long value = arg->value.generic;
    if (jit_internal_is_spilled(value, jit->prepared_args.op, &sreg)) {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, value))); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     sreg = sparc_f30;
    }
    jit_internal_emit_set_arg_freg(jit, sreg, assoc_gp++);
    jit_internal_emit_set_arg_freg(jit, sreg + 1, assoc_gp++);
   } else {
    int fl_val[2];
    memcpy(fl_val, &(arg->value.fp), sizeof(double));
    jit_internal_emit_set_arg_imm(jit, fl_val[0], assoc_gp++);
    jit_internal_emit_set_arg_imm(jit, fl_val[1], assoc_gp++);
   }
  }
 }
}
static inline void jit_internal_emit_funcall(struct jit * jit, struct jit_op * op, int imm)
{
 jit_internal_emit_arguments(jit);
 if (!imm) {
  do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((sparc_o7)); __f->rs1 = (((op->r_arg[0]))); __f->rs2 = (((sparc_g0))); __f->op3 = (56); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else {
  op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
  if (op->r_arg[0] == (long)(NULL)) {
   do { jit_internal_sparc_format1 *__f = (jit_internal_sparc_format1*)((jit->ip)); __f->op = 1; __f->disp = ((unsigned int)(((unsigned int)(0))) >> 2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  } else if (jit_is_label(jit, (void *)op->r_arg[0]))
   do { jit_internal_sparc_format1 *__f = (jit_internal_sparc_format1*)((jit->ip)); __f->op = 1; __f->disp = ((unsigned int)(((unsigned int)(((long)jit->buf - (long)jit->ip) + (long)((jit_label *)(op->r_arg[0]))->pos))) >> 2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else {
   do { jit_internal_sparc_format1 *__f = (jit_internal_sparc_format1*)((jit->ip)); __f->op = 1; __f->disp = ((unsigned int)(((unsigned int)((long)op->r_arg[0] - (long)jit->ip))) >> 2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  }
 }
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static void jit_internal_emit_get_arg_int(struct jit * jit, struct jit_inp_arg * arg, int dest_reg, int associated)
{
 int read_from_stack = 0;
 int stack_pos;
 if (!arg->passed_by_reg) {
  read_from_stack = 1;
  stack_pos = arg->location.stack_pos;
 }
 if (arg->passed_by_reg && !associated) {
  read_from_stack = 1;
  stack_pos = arg->spill_pos;
 }
 if (read_from_stack) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((stack_pos)); __f->i = 1; __f->rd = ((dest_reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((dest_reg))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((arg->location.reg))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static void jit_internal_emit_get_arg_float(struct jit * jit, struct jit_inp_arg * arg, int dest_reg, int associated)
{
 if (associated) {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((arg->location.reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((dest_reg)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((arg->location.stack_pos)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((dest_reg)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
static void jit_internal_emit_get_arg_double(struct jit * jit, jit_op * op, struct jit_inp_arg * arg, int dest_reg, int associated)
{
 int arg_id = op->r_arg[1];
 if (associated) {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((arg->location.reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((dest_reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((arg->location.stack_pos)); __f->i = 1; __f->rd = ((dest_reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
 int reg_id = jit_mkreg_ex(arg->type == (1), (3), arg_id);
 associated = (jit_internal_rmap_get(op->regmap, reg_id) == NULL);
 struct jit_inp_arg arg2;
 jit_internal_init_arg(&arg2, arg->phys_reg + 1);
 if (associated && arg2.passed_by_reg) {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-4)); __f->i = 1; __f->rd = ((arg2.location.reg)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-4)); __f->i = 1; __f->rd = ((dest_reg + 1)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else {
  do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((arg2.spill_pos)); __f->i = 1; __f->rd = ((dest_reg + 1)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
static void jit_internal_emit_get_arg(struct jit * jit, jit_op * op)
{
 int dreg = op->r_arg[0];
 int arg_id = op->r_arg[1];
 struct jit_inp_arg * arg = &(jit_current_func_info(jit)->args[arg_id]);
 int reg_id = jit_mkreg(arg->type == JIT_FLOAT_NUM ? (1) : (0), (3), arg_id);
 int associated = (jit_internal_rmap_get(op->regmap, reg_id) != NULL);
 if (arg->type != JIT_FLOAT_NUM) jit_internal_emit_get_arg_int(jit, arg, dreg, associated);
 else {
  if (arg->size == sizeof(float)) jit_internal_emit_get_arg_float(jit, arg, dreg, associated);
  if (arg->size == sizeof(double)) jit_internal_emit_get_arg_double(jit, op, arg, dreg, associated);
 }
}
void jit_patch_external_calls(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if ((op->code == (JIT_CALL | 0x02)) && (!jit_is_label(jit, (void *)op->arg[0])))
   do { long __p = ((long)((long)op->r_arg[0])) >> 2; long __t = ((long)(jit->buf + (long)op->patch_addr)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(jit->buf + (long)op->patch_addr); if (__f->op == 0) { *(int *)(jit->buf + (long)op->patch_addr) &= ~(0x03fffff); *(int *)(jit->buf + (long)op->patch_addr) |= (0x03fffff & __location); } else { *(int *)(jit->buf + (long)op->patch_addr) &= ~(0x3fffffff); *(int *)(jit->buf + (long)op->patch_addr) |= (0x3fffffff & __location); } } while (0);;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_MSG)
   do { long __p = ((long)(printf)) >> 2; long __t = ((long)(jit->buf + (long)op->patch_addr)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(jit->buf + (long)op->patch_addr); if (__f->op == 0) { *(int *)(jit->buf + (long)op->patch_addr) &= ~(0x03fffff); *(int *)(jit->buf + (long)op->patch_addr) |= (0x03fffff & __location); } else { *(int *)(jit->buf + (long)op->patch_addr) &= ~(0x3fffffff); *(int *)(jit->buf + (long)op->patch_addr) |= (0x3fffffff & __location); } } while (0);;
 }
}
void jit_patch_local_addrs(struct jit *jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_REF_DATA)) {
   unsigned char *buf = jit->buf + (long) op->patch_addr;
   jit_value addr = jit_is_label(jit, (void *)op->arg[1]) ? ((jit_label *)op->arg[1])->pos : op->arg[1];
   do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((buf))); __f->op = 0; __f->rd = (((op->r_arg[0]))); __f->op2 = (4); __f->disp = ((((uint32_t)(jit->buf + addr))>>10)) & 0x3fffff; (((buf))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((buf))); __f->op = (2); __f->imm = (((uint32_t)(jit->buf + addr)&0x3ff)); __f->i = 1; __f->rd = (((op->r_arg[0]))); __f->rs1 = (((op->r_arg[0]))); __f->op3 = (((0))|2); (((buf))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0);
  }
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_DATA)) {
   unsigned char *buf = jit->buf + (long) op->patch_addr;
   jit_value addr = jit_is_label(jit, (void *)op->arg[0]) ? ((jit_label *)op->arg[0])->pos : op->arg[0];
   *((jit_value *)buf) = (jit_value) (jit->buf + addr);
  }
 }
}
static inline int jit_internal__bit_pop(unsigned int x) {
 x = (x & 0x55555555) + ((x >> 1) & 0x55555555);
 x = (x & 0x33333333) + ((x >> 2) & 0x33333333);
 x = (x & 0x0F0F0F0F) + ((x >> 4) & 0x0F0F0F0F);
 x = (x & 0x00FF00FF) + ((x >> 8) & 0x00FF00FF);
 x = (x & 0x0000FFFF) + ((x >>16) & 0x0000FFFF);
 return x;
}
void jit_internal_emit_optimized_multiplication(struct jit * jit, long a1, long a2, long a3)
{
 int bits = jit_internal__bit_pop(a3);
 unsigned long ar = (unsigned long)a3;
 int in_tmp = 0;
 for (int i = 0; i < 32; i++) {
  if (ar & 0x1) {
   bits--;
   if (bits == 0) {
    if (!in_tmp) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((i)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((i)); __f->i = 1; __f->rd = ((sparc_g2)); __f->rs1 = ((a2)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((sparc_g1))); __f->rs2 = (((sparc_g2))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    }
   } else {
    if (!in_tmp) {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((i)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((a2)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     in_tmp = 1;
    } else {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((i)); __f->i = 1; __f->rd = ((sparc_g2)); __f->rs1 = ((a2)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->rs2 = (((sparc_g2))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    }
   }
  }
  ar >>= 1;
  if (bits == 0) break;
 }
}
void jit_internal_emit_mul(struct jit * jit, jit_op * op)
{
 long a1 = op->r_arg[0];
 long a2 = op->r_arg[1];
 long a3 = op->r_arg[2];
 if ((op->code & 0x02)) {
  if (a3 == 0) {
   do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((sparc_g0))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   return;
  }
  if (a3 == 1) {
   if (a1 != a2) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   return;
  }
  if ((a3 > 0) && (jit_internal__bit_pop(a3) <= 5)) {
   jit_internal_emit_optimized_multiplication(jit, a1, a2, a3);
   return;
  }
  if ((a3 < 0) && (jit_internal__bit_pop(-a3) <= 5)) {
   jit_internal_emit_optimized_multiplication(jit, a1, a2, -a3);
   do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((a1)))); __f->rs1 = (((sparc_g0))); __f->rs2 = ((((a1)))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   return;
  }
  if ((!(op->code & 0x04))) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 } else {
  if ((!(op->code & 0x04))) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
static void jit_internal_emit_sparc_round(struct jit * jit, long a1, long a2)
{
 static double zero_point_5 = 0.5;
 do { if ((0) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(0) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(0))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(0) >= -4096) && ((int32_t)(0) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(0))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(0))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(0)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fabss_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((sparc_f31)); __f->rs1 = ((0)); __f->rs2 = ((a2 + 1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fcmpd_val)); __f->rd = (0); __f->rs1 = ((a2)); __f->rs2 = ((sparc_f30)); __f->op3 = (53); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { if (((long)&zero_point_5) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)((long)&zero_point_5) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((long)&zero_point_5))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)((long)&zero_point_5) >= -4096) && ((int32_t)((long)&zero_point_5) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)((long)&zero_point_5))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((long)&zero_point_5))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)((long)&zero_point_5)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
 do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_g1)); __f->rs2 = ((sparc_g0)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 unsigned char * br1 = jit->ip;
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((sparc_fbge)); __f->op2 = (6); __f->disp = ((0)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fnegs_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { long __p = ((long)(jit->ip)) >> 2; long __t = ((long)(br1)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(br1); if (__f->op == 0) { *(int *)(br1) &= ~(0x03fffff); *(int *)(br1) |= (0x03fffff & __location); } else { *(int *)(br1) &= ~(0x3fffffff); *(int *)(br1) |= (0x3fffffff & __location); } } while (0);;
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_faddd_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtoi_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static void jit_internal_emit_sparc_floor(struct jit * jit, long a1, long a2, int floor)
{
 do { if ((0) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(0) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(0))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(0) >= -4096) && ((int32_t)(0) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(0))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(0))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(0)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fabss_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((sparc_f31)); __f->rs1 = ((0)); __f->rs2 = ((a2 + 1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fcmpd_val)); __f->rd = (0); __f->rs1 = ((a2)); __f->rs2 = ((sparc_f30)); __f->op3 = (53); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 unsigned char * br1 = jit->ip;
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = (((floor ? sparc_fbe : sparc_fbne))); __f->op2 = (6); __f->disp = ((0)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtoi_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fitod_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fcmpd_val)); __f->rd = (0); __f->rs1 = ((a2)); __f->rs2 = ((sparc_f30)); __f->op3 = (53); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 unsigned char * br2 = jit->ip;
 do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((sparc_fbe)); __f->op2 = (6); __f->disp = ((0)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { if (((floor ? -1 : 1)) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)((floor ? -1 : 1)) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((floor ? -1 : 1)))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)((floor ? -1 : 1)) >= -4096) && ((int32_t)((floor ? -1 : 1)) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)((floor ? -1 : 1)))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((floor ? -1 : 1)))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)((floor ? -1 : 1))&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
 do { long __p = ((long)(jit->ip)) >> 2; long __t = ((long)(br1)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(br1); if (__f->op == 0) { *(int *)(br1) &= ~(0x03fffff); *(int *)(br1) |= (0x03fffff & __location); } else { *(int *)(br1) &= ~(0x3fffffff); *(int *)(br1) |= (0x3fffffff & __location); } } while (0);;
 do { long __p = ((long)(jit->ip)) >> 2; long __t = ((long)(br2)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(br2); if (__f->op == 0) { *(int *)(br2) &= ~(0x03fffff); *(int *)(br2) |= (0x03fffff & __location); } else { *(int *)(br2) &= ~(0x3fffffff); *(int *)(br2) |= (0x3fffffff & __location); } } while (0);;
 do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtoi_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a1))); __f->rs2 = (((sparc_g1))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
}
static inline void jit_internal_emit_ureg(struct jit * jit, long vreg, long hreg_id)
{
 if (JIT_REG(vreg).spec == (3)) {
  if (JIT_REG(vreg).type == (0)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, vreg))); __f->i = 1; __f->rd = ((hreg_id)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else {
   int arg_id = JIT_REG(vreg).id;
   struct jit_inp_arg * a = &(jit_current_func_info(jit)->args[arg_id]);
   if (a->passed_by_reg) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a->spill_pos)); __f->i = 1; __f->rd = ((hreg_id)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  }
 }
 if (JIT_REG(vreg).spec == (0)) {
  if (JIT_REG(vreg).type != (1))
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, vreg))); __f->i = 1; __f->rd = ((hreg_id)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
  else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, vreg))); __f->i = 1; __f->rd = ((hreg_id)); __f->rs1 = ((sparc_fp)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
 }
}
void jit_gen_op(struct jit * jit, struct jit_op * op)
{
 long a1 = op->r_arg[0];
 long a2 = op->r_arg[1];
 long a3 = op->r_arg[2];
 int found = 1;
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_ADD: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_ADDC: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_ADDX: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0x8|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0x8|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0x8|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_SUB: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_SUBC: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0x4|(((16)) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_SUBX: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xc|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g0))); __f->op3 = (0xc|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xc|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_RSB:
   if ((op->code & 0x02)) {
    do { if ((a3) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(a3) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(a3))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(a3) >= -4096) && ((int32_t)(a3) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(a3))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)(a3))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(a3)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((sparc_g1))); __f->rs2 = (((a2))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a3))); __f->rs2 = (((a2))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_NEG: if (a1 != a2) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
         do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((a1)))); __f->rs1 = (((sparc_g0))); __f->rs2 = ((((a1)))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
         break;
  case JIT_NOT: if (a1 != a2) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
         do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a1))); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|7); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
         break;
  case JIT_OR: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (((0))|2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (((0))|2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_AND: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_XOR: if ((op->code & 0x02)) { if (a3 != 0) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (((0))|3); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|3); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (((0))|3); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;;
  case JIT_LSH: if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (37); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_RSH:
   if ((!(op->code & 0x04))) {
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else {
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case JIT_MUL: jit_internal_emit_mul(jit, op); break;
  case JIT_HMUL:
   if ((!(op->code & 0x04))) {
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g0))); __f->rs1 = (((a2))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else {
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g0))); __f->rs1 = (((a2))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g0))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = (0); __f->rs2 = (0); __f->op3 = (40); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_DIV:
   if ((!(op->code & 0x04))) {
    if ((op->code & 0x02)) {
     switch (a3) {
      case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((1)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 8: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 16: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((4)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 32: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((5)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     }
    }
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((31)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (0); __f->rs1 = ((sparc_g1)); __f->rs2 = ((sparc_g0)); __f->op3 = (48); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xf|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xf|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else {
    if ((op->code & 0x02)) {
     switch (a3) {
      case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((1)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 8: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 16: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((4)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
      case 32: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((5)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (38); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     }
    }
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (0); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (48); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    if ((op->code & 0x02)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->op3 = (0xe|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    else do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xe|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case JIT_MOD:
   if ((op->code & 0x02)) {
    switch (a3) {
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0x01)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0x03)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     case 8: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0x07)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     case 16: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0x0f)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
     case 32: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0x1f)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = ((((0)) ? 0x10 : 0) | (1)); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); goto op_complete;
    }
   }
   if ((!(op->code & 0x04))) {
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((31)); __f->i = 1; __f->rd = ((sparc_g1)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (0); __f->rs1 = ((sparc_g1)); __f->rs2 = ((sparc_g0)); __f->op3 = (48); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else {
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (0); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (48); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   if ((!(op->code & 0x04))) {
    if ((op->code & 0x02)) {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((a2))); __f->op3 = (0xf|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    } else {
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xf|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->rs2 = (((a3))); __f->op3 = (0xb|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    }
   } else {
    if ((op->code & 0x02)) {
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((a2))); __f->op3 = (0xe|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((a3))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    } else {
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g1))); __f->rs1 = (((a2))); __f->rs2 = (((a3))); __f->op3 = (0xe|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->rs2 = (((a3))); __f->op3 = (0xa|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    }
   }
   do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = (((a2))); __f->rs2 = (((sparc_g1))); __f->op3 = (0x4|((((0))) ? 0x10 : 0)); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_LT: jit_internal_emit_cond_op_op(jit, op, (!(op->code & 0x04)) ? sparc_bl : sparc_blu, (op->code & 0x02)); break;
  case JIT_LE: jit_internal_emit_cond_op_op(jit, op, (!(op->code & 0x04)) ? sparc_ble : sparc_bleu, (op->code & 0x02)); break;
  case JIT_GT: jit_internal_emit_cond_op_op(jit, op, (!(op->code & 0x04)) ? sparc_bg : sparc_bgu, (op->code & 0x02)); break;
  case JIT_GE: jit_internal_emit_cond_op_op(jit, op, (!(op->code & 0x04)) ? sparc_bge : sparc_bgeu, (op->code & 0x02)); break;
  case JIT_EQ: jit_internal_emit_cond_op_op(jit, op, sparc_be, (op->code & 0x02)); break;
  case JIT_NE: jit_internal_emit_cond_op_op(jit, op, sparc_bne, (op->code & 0x02)); break;
  case JIT_BLT: jit_internal_emit_branch_op(jit, op, (!(op->code & 0x04)) ? sparc_bl : sparc_blu, (op->code & 0x02)); break;
  case JIT_BGT: jit_internal_emit_branch_op(jit, op, (!(op->code & 0x04)) ? sparc_bg : sparc_bgu, (op->code & 0x02)); break;
  case JIT_BLE: jit_internal_emit_branch_op(jit, op, (!(op->code & 0x04)) ? sparc_ble : sparc_bleu, (op->code & 0x02)); break;
  case JIT_BGE: jit_internal_emit_branch_op(jit, op, (!(op->code & 0x04)) ? sparc_bge : sparc_bgeu, (op->code & 0x02)); break;
  case JIT_BEQ: jit_internal_emit_branch_op(jit, op, sparc_be, (op->code & 0x02)); break;
  case JIT_BNE: jit_internal_emit_branch_op(jit, op, sparc_bne, (op->code & 0x02)); break;
  case JIT_BMS: jit_internal_emit_branch_mask_op(jit, op, sparc_bne, (op->code & 0x02)); break;
  case JIT_BMC: jit_internal_emit_branch_mask_op(jit, op, sparc_be, (op->code & 0x02)); break;
  case JIT_BOADD: jit_internal_emit_op_and_overflow_branch(jit, op, JIT_ADD, (op->code & 0x02), 0); break;
  case JIT_BOSUB: jit_internal_emit_op_and_overflow_branch(jit, op, JIT_SUB, (op->code & 0x02), 0); break;
  case JIT_BNOADD: jit_internal_emit_op_and_overflow_branch(jit, op, JIT_ADD, (op->code & 0x02), 1); break;
  case JIT_BNOSUB: jit_internal_emit_op_and_overflow_branch(jit, op, JIT_SUB, (op->code & 0x02), 1); break;
  case JIT_CALL: jit_internal_emit_funcall(jit, op, (op->code & 0x02)); break;
  case JIT_PATCH: do {
    struct jit_op *target = (struct jit_op *) a1;
    switch (((jit_opcode) (target->code & 0xfff8))) {
     case JIT_REF_CODE:
     case JIT_REF_DATA:
      target->arg[1] = ((jit_value)jit->ip - (jit_value)jit->buf);
      break;
     case JIT_DATA_REF_CODE:
     case JIT_DATA_REF_DATA:
      target->arg[0] = ((jit_value)jit->ip - (jit_value)jit->buf);
      break;
     default: {
      long pa = ((struct jit_op *)a1)->patch_addr;
      do { long __p = ((long)(jit->ip)) >> 2; long __t = ((long)(jit->buf + pa)) >> 2; long __location = (__p - __t); jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(jit->buf + pa); if (__f->op == 0) { *(int *)(jit->buf + pa) &= ~(0x03fffff); *(int *)(jit->buf + pa) |= (0x03fffff & __location); } else { *(int *)(jit->buf + pa) &= ~(0x3fffffff); *(int *)(jit->buf + pa) |= (0x3fffffff & __location); } } while (0);;
     }
    }
   } while (0);
   break;
  case JIT_JMP:
   op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
   if (op->code & 0x01) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((sparc_g0)); __f->rs1 = (((a1))); __f->rs2 = (((sparc_g0))); __f->op3 = (56); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else do { jit_internal_sparc_format2b *__f = (jit_internal_sparc_format2b*)((jit->ip)); __f->op = 0; __f->a = (((0))); __f->cond = ((sparc_balways)); __f->op2 = (2); __f->disp = (((!jit_is_label(jit, (void *)(op->r_arg[0])) ? (op->r_arg[0]) : ((((long)jit->buf + (long)((jit_label *)(op->r_arg[0]))->pos - (long)jit->ip)) / 4)))); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_RET:
   if (!(op->code & 0x02) && (a1 != sparc_i0)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_i0))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   if ((op->code & 0x02)) do { if ((a1) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_i0)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(a1) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_i0))); __f->op2 = (4); __f->disp = ((((uint32_t)(a1))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(a1) >= -4096) && ((int32_t)(a1) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(a1))); __f->i = 1; __f->rd = (((sparc_i0))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_i0))); __f->op2 = (4); __f->disp = ((((uint32_t)(a1))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(a1)&0x3ff)); __f->i = 1; __f->rd = (((sparc_i0))); __f->rs1 = (((sparc_i0))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = ((8)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((sparc_i7)); __f->op3 = (56); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((sparc_g0)); __f->op3 = (61); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_PUTARG: jit_internal_funcall_put_arg(jit, op); break;
  case JIT_FPUTARG: jit_internal_funcall_fput_arg(jit, op); break;
  case JIT_GETARG: jit_internal_emit_get_arg(jit, op); break;
  case JIT_MSG:
     do { if ((a1) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_o0)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(a1) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_o0))); __f->op2 = (4); __f->disp = ((((uint32_t)(a1))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(a1) >= -4096) && ((int32_t)(a1) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(a1))); __f->i = 1; __f->rd = (((sparc_o0))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_o0))); __f->op2 = (4); __f->disp = ((((uint32_t)(a1))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(a1)&0x3ff)); __f->i = 1; __f->rd = (((sparc_o0))); __f->rs1 = (((sparc_o0))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } } while (0);
     if (!(op->code & 0x02)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((sparc_o1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
     do { jit_internal_sparc_format1 *__f = (jit_internal_sparc_format1*)((jit->ip)); __f->op = 1; __f->disp = ((unsigned int)(((unsigned int)(printf))) >> 2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
     break;
  case JIT_TRACE:
    break;
  case JIT_ALLOCA: break;
  case JIT_CODE_ALIGN: {
    int count = op->arg[0];
    assert(!(count % 4));
    while ((unsigned long)jit->ip % count) {
     if ((unsigned long)jit->ip % 4) {
      *jit->ip = 0;
      jit->ip++;
     }
            else do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = ((sparc_zero)); __f->op2 = (4); __f->disp = (((0)>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    }
   }
   break;
  case JIT_REF_CODE:
  case JIT_REF_DATA:
   op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
   do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((a1))); __f->op2 = (4); __f->disp = ((((uint32_t)(0xdeadbeef))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(0xdeadbeef)&0x3ff)); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0);
   break;
  case JIT_DATA_BYTE: break;
  case JIT_FULL_SPILL: break;
  default: found = 0;
 }
op_complete:
 if (found) return;
 switch (op->code) {
  case (JIT_MOV | 0x01): if (a1 != a2) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_MOV | 0x02): do { if ((a2) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((a1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)(a2) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((a1))); __f->op2 = (4); __f->disp = ((((uint32_t)(a2))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)(a2) >= -4096) && ((int32_t)(a2) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)(a2))); __f->i = 1; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((a1))); __f->op2 = (4); __f->disp = ((((uint32_t)(a2))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)(a2)&0x3ff)); __f->i = 1; __f->rd = (((a1))); __f->rs1 = (((a1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0); break;
  case JIT_PREPARE: jit_internal_funcall_prepare(jit, op, a1 + a2); break;
  case JIT_PROLOG:
   do {
    jit->current_func = op;
    struct jit_func_info * info = jit_current_func_info(jit);
    int stack_mem = 96;
    op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
    stack_mem += info->allocai_mem;
    stack_mem += info->gp_reg_count * (sizeof(void *));
    stack_mem += info->fp_reg_count * sizeof(double);
    stack_mem += info->float_arg_cnt * sizeof(double);
    stack_mem += jit_internal_space_for_outgoing_args(jit, op);
    stack_mem = jit_value_align(stack_mem, 16);
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((-stack_mem)); __f->i = 1; __f->rd = ((sparc_sp)); __f->rs1 = ((sparc_sp)); __f->op3 = (60); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } while (0);
   break;
  case JIT_RETVAL:
      if (a1 != sparc_o0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((sparc_o0))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
      break;
  case JIT_DECL_ARG: break;
  case JIT_LABEL: ((jit_label *)a1)->pos = ((jit_value)jit->ip - (jit_value)jit->buf); break;
  case (JIT_LD | 0x01 | 0x00):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (9); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (10); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LD | 0x01 | 0x04):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (1); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LD | 0x02 | 0x00):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (9); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (10); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LD | 0x02 | 0x04):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (1); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LDX | 0x02 | 0x00):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (9); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (10); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LDX | 0x02 | 0x04):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (1); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LDX | 0x01 | 0x00):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (9); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (10); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_LDX | 0x01 | 0x04):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (1); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (2); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_ST | 0x01):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a2)); __f->rs1 = ((sparc_g0)); __f->rs2 = ((a1)); __f->op3 = (5); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a2)); __f->rs1 = ((sparc_g0)); __f->rs2 = ((a1)); __f->op3 = (6); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a2)); __f->rs1 = ((sparc_g0)); __f->rs2 = ((a1)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_ST | 0x02):
    switch (op->arg_size) {
     case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((a2)); __f->op3 = (5); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((a2)); __f->op3 = (6); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((a2)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
     default: abort();
    } break;
  case (JIT_STX | 0x01):
   switch (op->arg_size) {
    case 1: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->rs2 = ((a1)); __f->op3 = (5); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    case 2: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->rs2 = ((a1)); __f->op3 = (6); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    case 4: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->rs2 = ((a1)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    default: abort();
   } break;
  case (JIT_STX | 0x02):
   switch (op->arg_size) {
    case 1: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->op3 = (5); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    case 2: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->op3 = (6); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    case 4: do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
    default: abort();
   } break;
  case (JIT_FMOV | 0x01):
   do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((a1 + 1)); __f->rs1 = ((0)); __f->rs2 = ((a2 + 1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_FMOV | 0x02):
   do { if (((long)&op->flt_imm) == 0) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((((jit->ip)))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = ((((sparc_g1)))); __f->rs1 = ((sparc_g0)); __f->rs2 = ((sparc_g0)); __f->op3 = (((0))|2); ((((jit->ip)))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((uint32_t)((long)&op->flt_imm) & 0x3ff) == 0) do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((long)&op->flt_imm))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else if (((int32_t)((long)&op->flt_imm) >= -4096) && ((int32_t)((long)&op->flt_imm) <= 4095)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((int32_t)((long)&op->flt_imm))); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = ((sparc_g0)); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); else do { do { jit_internal_sparc_format2a *__f = (jit_internal_sparc_format2a*)(((jit->ip))); __f->op = 0; __f->rd = (((sparc_g1))); __f->op2 = (4); __f->disp = ((((uint32_t)((long)&op->flt_imm))>>10)) & 0x3fffff; (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = (((uint32_t)((long)&op->flt_imm)&0x3ff)); __f->i = 1; __f->rd = (((sparc_g1))); __f->rs1 = (((sparc_g1))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); } while (0); } while (0);
   do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((sparc_g1)); __f->rs2 = ((sparc_g0)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_FADD | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_faddd_val)); __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FSUB | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fsubd_val)); __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FRSB | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fsubd_val)); __f->rd = ((a1)); __f->rs1 = ((a3)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FMUL | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmuld_val)); __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FDIV | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdivd_val)); __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FNEG | 0x01): do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fnegs_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case (JIT_FBLT | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fbl, a2, a3); break;
  case (JIT_FBGT | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fbg, a2, a3); break;
  case (JIT_FBLE | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fble, a2, a3); break;
  case (JIT_FBGE | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fbge, a2, a3); break;
  case (JIT_FBEQ | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fbe, a2, a3); break;
  case (JIT_FBNE | 0x01): jit_internal_emit_fpbranch_op(jit, op, sparc_fbne, a2, a3); break;
  case (JIT_TRUNC | 0x01):
   do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtoi_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_EXT | 0x01):
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((a2)); __f->rs1 = ((sparc_fp)); __f->op3 = (4); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((-8)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_fp)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fitod_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f30)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_FLOOR | 0x01): jit_internal_emit_sparc_floor(jit, a1, a2, 1); break;
  case (JIT_CEIL | 0x01): jit_internal_emit_sparc_floor(jit, a1, a2, 0); break;
  case (JIT_ROUND | 0x01): jit_internal_emit_sparc_round(jit, a1, a2); break;
  case (JIT_FRET | 0x01):
   if (op->arg_size == sizeof(float)) {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f0)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   } else {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((sparc_f0)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fmovs_val)); __f->rd = ((sparc_f1)); __f->rs1 = ((0)); __f->rs2 = ((a1 + 1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)(((jit->ip))); __f->op = (2); __f->imm = ((8)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((sparc_i7)); __f->op3 = (56); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (2); __f->imm = ((0)); __f->i = 1; __f->rd = ((sparc_g0)); __f->rs1 = ((sparc_g0)); __f->op3 = (61); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_FRETVAL):
   if (op->arg_size == sizeof(float)) do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((sparc_f0)); __f->rs1 = ((0)); __f->rs2 = ((sparc_f0)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case (JIT_FLD | 0x01):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((sparc_g0)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FLD | 0x02):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a2)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_g0)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FLDX | 0x01):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0); __f->i = 0; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->rs2 = ((a3)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FLDX | 0x02):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a3)); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((a2)); __f->op3 = (32); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fstod_val)); __f->rd = ((a1)); __f->rs1 = ((0)); __f->rs2 = ((a1)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FST | 0x01):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a2)); __f->rs1 = ((a1)); __f->rs2 = ((sparc_g0)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((sparc_f30)); __f->rs1 = ((a1)); __f->rs2 = ((sparc_g0)); __f->op3 = (36); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FST | 0x02):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((a2)); __f->rs1 = ((sparc_g0)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a2)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((sparc_g0)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FSTX | 0x01):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->rs2 = ((a1)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)((jit->ip)); __f->op = (3); __f->asi = (0x0); __f->i = 0; __f->rd = ((sparc_f30)); __f->rs1 = ((a2)); __f->rs2 = ((a1)); __f->op3 = (36); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_FSTX | 0x02):
   if (op->arg_size == sizeof(double)) do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((a3)); __f->rs1 = ((a2)); __f->op3 = (39); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else {
    do { jit_internal_sparc_format3c *__f = (jit_internal_sparc_format3c*)((jit->ip)); __f->op = (2); __f->opf = ((sparc_fdtos_val)); __f->rd = ((sparc_f30)); __f->rs1 = ((0)); __f->rs2 = ((a3)); __f->op3 = (52); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((a1)); __f->i = 1; __f->rd = ((sparc_f30)); __f->rs1 = ((a2)); __f->op3 = (36); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   }
   break;
  case (JIT_UREG): jit_internal_emit_ureg(jit, a1, a2); break;
  case (JIT_SYNCREG): jit_internal_emit_ureg(jit, a1, a2); break;
  case (JIT_LREG):
   if (JIT_REG(a2).spec == (3)) assert(0);
   if (JIT_REG(a2).type == (0))
    do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, a2))); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_fp)); __f->op3 = (0); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   else do { jit_internal_sparc_format3b *__f = (jit_internal_sparc_format3b*)((jit->ip)); __f->op = (3); __f->imm = ((jit_internal_GET_REG_POS(jit, a2))); __f->i = 1; __f->rd = ((a1)); __f->rs1 = ((sparc_fp)); __f->op3 = (35); ((jit->ip)) = (unsigned char *)((unsigned int*)__f + 1); } while (0);
   break;
  case JIT_RENAMEREG: do { jit_internal_sparc_format3a *__f = (jit_internal_sparc_format3a*)(((jit->ip))); __f->op = (2); __f->asi = (0); __f->i = 0; __f->rd = (((a1))); __f->rs1 = ((sparc_g0)); __f->rs2 = (((a2))); __f->op3 = (((0))|2); (((jit->ip))) = (unsigned char *)((unsigned int*)__f + 1); } while (0); break;
  case JIT_CODESTART: break;
  case JIT_NOP: break;
  default: printf("sparc: unknown operation (opcode: 0x%x)\n", ((jit_opcode) (op->code & 0xfff8)) >> 3);
 }
}
struct jit_reg_allocator * jit_reg_allocator_create()
{
 struct jit_reg_allocator * a = malloc(sizeof(struct jit_reg_allocator));
 a->gp_reg_cnt = 14;
 a->gp_regs = malloc(sizeof(jit_hw_reg) * (a->gp_reg_cnt + 1));
 int i = 0;
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i0, "i0", 1, 0, 11 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i1, "i1", 1, 0, 12 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i2, "i2", 1, 0, 13 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i3, "i3", 1, 0, 14 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i4, "i4", 1, 0, 15 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_i5, "i5", 1, 0, 16 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l0, "l0", 1, 0, 1 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l1, "l1", 1, 0, 2 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l2, "l2", 1, 0, 3 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l3, "l3", 1, 0, 4 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l4, "l4", 1, 0, 5 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l5, "l5", 1, 0, 6 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l6, "l6", 1, 0, 7 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_l7, "l7", 1, 0, 8 };
 a->gp_regs[i++] = (jit_hw_reg) { sparc_fp, "fp", 0, 0, 0 };
 a->fp_reg_cnt = 4;
 a->fp_regs = malloc(sizeof(jit_hw_reg) * a->fp_reg_cnt);
 i = 0;
 a->fp_regs[i++] = (jit_hw_reg) { sparc_f0, "f0", 0, 1, 1 };
 a->fp_regs[i++] = (jit_hw_reg) { sparc_f2, "f2", 0, 1, 2 };
 a->fp_regs[i++] = (jit_hw_reg) { sparc_f4, "f4", 0, 1, 3 };
 a->fp_regs[i++] = (jit_hw_reg) { sparc_f6, "f6", 0, 1, 4 };
 jit_hw_reg * reg_i7 = malloc(sizeof(jit_hw_reg));
 *reg_i7 = (jit_hw_reg) { sparc_i7, "iX", 1, 0, 0 };
 a->fp_reg = sparc_fp;
 a->ret_reg = NULL;
 a->fpret_reg = &(a->fp_regs[0]);
 a->gp_arg_reg_cnt = 6;
 a->gp_arg_regs = malloc(sizeof(jit_hw_reg *) * 6);
 for (int i = 0; i < 6; i++)
  a->gp_arg_regs[i] = &(a->gp_regs[i]);
 a->fp_arg_reg_cnt = 0;
 a->fp_arg_regs = NULL;
 return a;
}
static jit_hw_reg * jit_internal_rmap_is_associated(jit_rmap * rmap, int reg_id, int fp, jit_value * virt_reg);
static inline int jit_internal_bufprint(char *buf, const char *format, ...) {
 va_list ap;
 va_start(ap, format);
 int result = vsprintf(buf + strlen(buf), format, ap);
 va_end(ap);
 return result;
}
static void jit_internal_compiler_based_debugger(struct jit * jit)
{
 char obj_file_name[] = "myjitXXXXXX";
 int obj_file_fd = mkstemp(obj_file_name);
 char * cmd1_fmt = "gcc -x assembler -c -o %s -";
 char * cmd2_fmt = "objdump -d -M intel %s";
 char cmd1[strlen(cmd1_fmt) + strlen(obj_file_name) + 1];
 char cmd2[strlen(cmd2_fmt) + strlen(obj_file_name) + 1];
 sprintf(cmd1, cmd1_fmt, obj_file_name);
 FILE * f = popen(cmd1, "w");
 int size = jit->ip - jit->buf;
 fprintf (f, ".text\n.align 4\n.globl main\n.type main,@function\nmain:\n");
 for (int i = 0; i < size; i++)
  fprintf(f, ".byte %d\n", (unsigned int) jit->buf[i]);
 pclose(f);
 sprintf(cmd2, cmd2_fmt, obj_file_name);
 system(cmd2);
 close(obj_file_fd);
 unlink(obj_file_name);
}
typedef struct jit_disasm {
 char *indent_template;
 char *reg_template;
 char *freg_template;
 char *arg_template;
 char *farg_template;
 char *reg_fp_template;
 char *reg_out_template;
 char *reg_imm_template;
 char *reg_fimm_template;
 char *reg_unknown_template;
 char *label_template;
 char *label_forward_template;
 char *generic_addr_template;
 char *generic_value_template;
} jit_disasm;
struct jit_disasm jit_disasm_general = {
 .indent_template = "    ",
 .reg_template = "r%i",
 .freg_template = "fr%i",
 .arg_template = "arg%i",
 .farg_template = "farg%i",
 .reg_out_template = "out",
 .reg_fp_template = "fp",
 .reg_imm_template = "imm",
 .reg_fimm_template = "fimm",
 .reg_unknown_template = "(unknown reg.)",
 .label_template = "L%i",
 .label_forward_template = "L%i",
 .generic_addr_template = "<addr: 0x%lx>",
 .generic_value_template = "0x%lx",
};
struct jit_disasm jit_disasm_compilable = {
 .indent_template = "    ",
 .reg_template = "R(%i)",
 .freg_template = "FR(%i)",
 .arg_template = "arg(%i)",
 .farg_template = "farg(%i)",
 .reg_fp_template = "R_FP",
 .reg_out_template = "R_OUT",
 .reg_imm_template = "R_IMM",
 .reg_fimm_template = "FR_IMM",
 .reg_unknown_template = "(unknown reg.)",
 .label_template = "label_%03i",
 .label_forward_template = "/* label_%03i */ JIT_FORWARD",
 .generic_addr_template = "<addr: 0x%lx>",
 .generic_value_template = "%li",
};
char * jit_get_op_name(struct jit_op * op)
{
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_MOV: return "mov";
  case JIT_LD: return "ld";
  case JIT_LDX: return "ldx";
  case JIT_ST: return "st";
  case JIT_STX: return "stx";
  case JIT_JMP: return "jmp";
  case JIT_PATCH: return ".patch";
  case JIT_PREPARE: return "prepare";
  case JIT_PUTARG: return "putarg";
  case JIT_CALL: return "call";
  case JIT_RET: return "ret";
  case JIT_PROLOG: return "prolog";
  case JIT_GETARG: return "getarg";
  case JIT_RETVAL: return "retval";
  case JIT_ALLOCA: return "alloca";
  case JIT_DECL_ARG: return "declare_arg";
  case JIT_ADD: return "add";
  case JIT_ADDC: return "addc";
  case JIT_ADDX: return "addx";
  case JIT_SUB: return "sub";
  case JIT_SUBC: return "subc";
  case JIT_SUBX: return "subx";
  case JIT_RSB: return "rsb";
  case JIT_NEG: return "neg";
  case JIT_MUL: return "mul";
  case JIT_HMUL: return "hmul";
  case JIT_DIV: return "div";
  case JIT_MOD: return "mod";
  case JIT_OR: return "or";
  case JIT_XOR: return "xor";
  case JIT_AND: return "and";
  case JIT_LSH: return "lsh";
  case JIT_RSH: return "rsh";
  case JIT_NOT: return "not";
  case JIT_LT: return "lt";
  case JIT_LE: return "le";
  case JIT_GT: return "gt";
  case JIT_GE: return "ge";
  case JIT_EQ: return "eq";
  case JIT_NE: return "ne";
  case JIT_BLT: return "blt";
  case JIT_BLE: return "ble";
  case JIT_BGT: return "bgt";
  case JIT_BGE: return "bge";
  case JIT_BEQ: return "beq";
  case JIT_BNE: return "bne";
  case JIT_BMS: return "bms";
  case JIT_BMC: return "bmc";
  case JIT_BOADD: return "boadd";
  case JIT_BOSUB: return "bosub";
  case JIT_BNOADD:return "bnoadd";
  case JIT_BNOSUB:return "bnosub";
  case JIT_UREG: return ".ureg";
  case JIT_LREG: return ".lreg";
  case JIT_CODESTART: return ".code";
  case JIT_LABEL: return ".label";
  case JIT_SYNCREG: return ".syncreg";
  case JIT_RENAMEREG: return ".renamereg";
  case JIT_MSG: return "msg";
  case JIT_COMMENT: return ".comment";
  case JIT_NOP: return "nop";
  case JIT_CODE_ALIGN: return ".align";
  case JIT_DATA_BYTE: return ".byte";
  case JIT_DATA_REF_CODE: return ".ref_code";
  case JIT_DATA_REF_DATA: return ".ref_data";
  case JIT_REF_CODE: return "ref_code";
  case JIT_REF_DATA: return "ref_data";
  case JIT_FULL_SPILL: return ".full_spill";
  case JIT_TRACE: return ".trace";
  case JIT_FORCE_SPILL: return "jit_internal_force_spill";
  case JIT_FORCE_ASSOC: return "jit_internal_force_assoc";
  case JIT_FMOV: return "fmov";
  case JIT_FADD: return "fadd";
  case JIT_FSUB: return "fsub";
  case JIT_FRSB: return "frsb";
  case JIT_FMUL: return "fmul";
  case JIT_FDIV: return "fdiv";
  case JIT_FNEG: return "fneg";
  case JIT_FRETVAL: return "fretval";
  case JIT_FPUTARG: return "fputarg";
  case JIT_EXT: return "ext";
  case JIT_ROUND: return "round";
  case JIT_TRUNC: return "trunc";
  case JIT_FLOOR: return "floor";
  case JIT_CEIL: return "ceil";
  case JIT_FBLT: return "fblt";
  case JIT_FBLE: return "fble";
  case JIT_FBGT: return "fbgt";
  case JIT_FBGE: return "fbge";
  case JIT_FBEQ: return "fbeq";
  case JIT_FBNE: return "fbne";
  case JIT_FLD: return "fld";
  case JIT_FLDX: return "fldx";
  case JIT_FST: return "fst";
  case JIT_FSTX: return "fstx";
  case JIT_FRET: return "fret";
  default: return "(unknown)";
 }
}
void jit_get_reg_name(struct jit_disasm *disasm, char * r, int reg)
{
 if (reg == (jit_mkreg((0), (2), 0))) strcpy(r, disasm->reg_fp_template);
 else if (reg == (jit_mkreg((0), (2), 1))) strcpy(r, disasm->reg_out_template);
 else if (reg == (jit_mkreg((0), (1), 0))) strcpy(r, disasm->reg_imm_template);
 else if (reg == (jit_mkreg((1), (1), 0))) strcpy(r, disasm->reg_fimm_template);
 else {
  if (JIT_REG(reg).spec == (0)) {
   if (JIT_REG(reg).type == (0)) sprintf(r, disasm->reg_template, JIT_REG(reg).id);
   else sprintf(r, disasm->freg_template, JIT_REG(reg).id);
  }
  else if (JIT_REG(reg).spec == (3)) {
   if (JIT_REG(reg).type == (0)) sprintf(r, disasm->arg_template, JIT_REG(reg).id);
   else sprintf(r, disasm->farg_template, JIT_REG(reg).id);
  } else sprintf(r, "%s", disasm->reg_unknown_template);
 }
}
static void jit_internal_print_rmap_callback(jit_tree_key key, jit_tree_value value, void *disasm)
{
 char buf[256];
 jit_get_reg_name((struct jit_disasm *)disasm, buf, key);
 printf("%s=%s ", buf, ((jit_hw_reg *)value)->name);
}
static void jit_internal_print_reg_liveness_callback(jit_tree_key key, jit_tree_value value, void *disasm)
{
 char buf[256];
 jit_get_reg_name(disasm, buf, key);
 printf("%s ", buf);
}
static inline int jit_op_is_cflow(jit_op * op)
{
 if (((((jit_opcode) (op->code & 0xfff8)) == JIT_CALL) || (((jit_opcode) (op->code & 0xfff8)) == JIT_JMP)) && ((op->code & 0x02))) return 1;
 if (jit_internal_is_cond_branch_op(op)) return 1;
 return 0;
}
static jit_tree * jit_internal_prepare_labels(struct jit * jit)
{
 long x = 1;
 jit_tree * n = NULL;
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH) {
   n = jit_tree_insert(n, (long) op, (void *)x, NULL);
   n = jit_tree_insert(n, op->arg[0], (void *) -x, NULL);
   x++;
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) {
   n = jit_tree_insert(n, op->arg[0], (void *)x, NULL);
   x++;
  }
 }
 return n;
}
static inline void jit_internal_print_addr(struct jit_disasm *disasm, char *buf, jit_tree *labels, jit_op *op, int arg_pos)
{
 void *arg = (void *)op->arg[arg_pos];
 jit_tree *label_item = jit_tree_search(labels, (long) op);
 if (label_item) jit_internal_bufprint(buf, disasm->label_forward_template, - (long) label_item->value);
 else {
  label_item = jit_tree_search(labels, (long) arg);
  if (label_item) jit_internal_bufprint(buf, disasm->label_template, (long) label_item->value);
  else jit_internal_bufprint(buf, disasm->generic_addr_template, arg);
 }
}
static inline void jit_internal_print_arg(struct jit_disasm *disasm, char * buf, struct jit_op * op, int arg)
{
 long a = op->arg[arg - 1];
 if ((((op)->spec >> ((arg) - 1) * 2) & 0x03) == 0x02) jit_internal_bufprint(buf, disasm->generic_value_template, a);
 if (((((op)->spec >> ((arg) - 1) * 2) & 0x03) == 0x01) || ((((op)->spec >> ((arg) - 1) * 2) & 0x03) == 0x03)) {
  char value[256];
  jit_get_reg_name(disasm, value, a);
  strcat(buf, value);
 }
}
static inline void jit_internal_print_str(char * buf, char * str)
{
 strcat(buf, " \"");
 for (int i = 0; i < strlen(str); i++) {
  if (str[i] >= 32) {
   int s = strlen(buf);
   buf[s++] = str[i];
   buf[s] = '\0';
  } else {
   char xbuf[16];
   switch (str[i]) {
    case 9: strcpy(xbuf, "\\t"); break;
    case 10: strcpy(xbuf, "\\n"); break;
    case 13: strcpy(xbuf, "\\r"); break;
    default: sprintf(xbuf, "\\x%02x", str[i]);
   }
   strcat(buf, xbuf);
  }
 }
 strcat(buf, "\"");
}
static void jit_internal_print_args(struct jit_disasm *disasm, char *linebuf, jit_op *op, jit_tree *labels)
{
 for (int i = 1; i <= 3; i++) {
  if ((((op)->spec >> ((i) - 1) * 2) & 0x03) == 0x00) continue;
  strcat(linebuf, i == 1 ? " " : ", ");
  if ((i == 1) && jit_op_is_cflow(op)) jit_internal_print_addr(disasm, linebuf, labels, op, 0);
  else jit_internal_print_arg(disasm, linebuf, op, i);
 }
}
void jit_internal_print_full_op_name(char *linebuf, jit_op *op)
{
 char *op_name = jit_get_op_name(op);
 strcat(linebuf, op_name);
 if ((((jit_opcode) (op->code & 0xfff8)) == JIT_CALL) && ((op->code & 0x0007) & 0x02)) return;
 if ((op->code & 0x0007) & 0x02) strcat(linebuf, "i");
 if ((op->code & 0x0007) & 0x01) strcat(linebuf, "r");
 if ((op->code & 0x0007) & 0x04) strcat(linebuf, "_u");
}
static int jit_internal_print_load_op(struct jit_disasm *disasm, char *linebuf, jit_op *op)
{
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_LREG:
   strcat(linebuf, disasm->indent_template);
   strcat(linebuf, jit_get_op_name(op));
   while (strlen((linebuf)) < (13)) { strcat((linebuf), " "); };
   jit_get_reg_name(disasm, linebuf + strlen(linebuf), op->arg[1]);
   return 1;
  case JIT_UREG:
  case JIT_SYNCREG:
   strcat(linebuf, disasm->indent_template);
   strcat(linebuf, jit_get_op_name(op));
   while (strlen((linebuf)) < (13)) { strcat((linebuf), " "); };
   jit_get_reg_name(disasm, linebuf + strlen(linebuf), op->arg[0]);
   return 1;
  case JIT_RENAMEREG: {
    jit_value reg;
    jit_internal_rmap_is_associated(op->prev->regmap, op->arg[1], 0, &reg);
    strcat(linebuf, disasm->indent_template);
    strcat(linebuf, jit_get_op_name(op));
    strcat(linebuf, " ");
    while (strlen((linebuf)) < (13)) { strcat((linebuf), " "); };
    jit_get_reg_name(disasm, linebuf + strlen(linebuf), reg);
    return 1;
   }
  case JIT_FULL_SPILL:
   strcat(linebuf, disasm->indent_template);
   strcat(linebuf, jit_get_op_name(op));
   return 1;
  default:
   return 0;
 }
}
void jit_internal_print_comment(char *linebuf, jit_op *op)
{
 char *str = (char *)op->arg[0];
 jit_internal_bufprint(linebuf, "// ");
 for (int i = 0; i < strlen(str); i++) {
  if ((str[i] == '\r') || (str[i] == '\n')) jit_internal_bufprint(linebuf, "\n// ");
  else jit_internal_bufprint(linebuf, "%c", str[i]);
 }
}
int jit_internal_print_op(FILE *f, struct jit_disasm * disasm, struct jit_op *op, jit_tree *labels, int verbosity)
{
 char linebuf[(8192)];
 linebuf[0] = '\0';
 if ((((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) || (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH)) {
  jit_tree * lab = jit_tree_search(labels, (long)op->arg[0]);
  if (lab) {
   jit_internal_bufprint(linebuf, disasm->label_template, (((long)lab->value) < 0 ? - ((long)lab->value) : (long)lab->value));
   jit_internal_bufprint(linebuf, ":");
  }
  goto print;
 }
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_COMMENT) {
  jit_internal_print_comment(linebuf, op);
  goto print;
 }
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_TRACE) {
  strcat(linebuf, disasm->indent_template);
  strcat(linebuf, ".trace");
  goto print;
 }
 char * op_name = jit_get_op_name(op);
 if ((op_name[0] == '.') && (verbosity & (0x100))) {
  if (jit_internal_print_load_op(disasm, linebuf, op)) goto print;
 }
 strcat(linebuf, disasm->indent_template);
 if (op_name[0] == '.') {
  switch (((jit_opcode) (op->code & 0xfff8))) {
   case JIT_DATA_BYTE:
   case JIT_CODE_ALIGN:
    jit_internal_bufprint(linebuf, "%s ", op_name);
    while (strlen((linebuf)) < (13)) { strcat((linebuf), " "); };
    jit_internal_bufprint(linebuf, disasm->generic_value_template, op->arg[0]);
    goto print;
   case JIT_DATA_REF_CODE:
   case JIT_DATA_REF_DATA:
    jit_internal_bufprint(linebuf, "%s ", op_name);
    while (strlen((linebuf)) < (13)) { strcat((linebuf), " "); };
    jit_internal_print_addr(disasm, linebuf, labels, op, 0);
    goto print;
   default:
    goto print;
  }
 }
 jit_internal_print_full_op_name(linebuf, op);
 while (strlen((linebuf)) < (12)) { strcat((linebuf), " "); };
 if (op->arg_size == 1) strcat(linebuf, " (byte)");
 if (op->arg_size == 2) strcat(linebuf, " (word)");
 if (op->arg_size == 4) strcat(linebuf, " (dword)");
 if (op->arg_size == 8) strcat(linebuf, " (qword)");
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_PREPARE: break;
  case JIT_MSG:
   jit_internal_print_str(linebuf, (char *)op->arg[0]);
   if (!(op->code & 0x02)) strcat(linebuf, ", "), jit_internal_print_arg(disasm, linebuf, op, 2);
   break;
  case JIT_REF_CODE:
  case JIT_REF_DATA:
   strcat(linebuf, " ");
   jit_internal_print_arg(disasm, linebuf, op, 1);
   strcat(linebuf, ", ");
   jit_internal_print_addr(disasm, linebuf, labels, op, 1);
   break;
  case JIT_DECL_ARG:
   switch (op->arg[0]) {
    case JIT_SIGNED_NUM: strcat(linebuf, " integer"); break;
    case JIT_UNSIGNED_NUM: strcat(linebuf, " uns. integer"); break;
    case JIT_FLOAT_NUM: strcat(linebuf, " float"); break;
    case JIT_PTR: strcat(linebuf, " ptr"); break;
    default: assert(0);
   };
   strcat(linebuf, ", ");
   jit_internal_print_arg(disasm, linebuf, op, 2);
   break;
  default:
   jit_internal_print_args(disasm, linebuf, op, labels);
 }
print:
 fprintf(f, "%s", linebuf);
 return strlen(linebuf);
}
int jit_internal_print_op_compilable(struct jit_disasm *disasm, struct jit_op * op, jit_tree * labels)
{
 char linebuf[(8192)];
 linebuf[0] = '\0';
 jit_tree * lab = jit_tree_search(labels, (long)op);
 if (lab && ((long) lab->value > 0)) {
  jit_internal_bufprint(linebuf, "// ");
  jit_internal_bufprint(linebuf, disasm->label_template, (long)lab->value);
  jit_internal_bufprint(linebuf, ":\n");
 }
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_COMMENT) {
  jit_internal_print_comment(linebuf, op);
  goto direct_print;
 }
 strcat(linebuf, disasm->indent_template);
 if ((jit_op_is_cflow(op) && ((void *)op->arg[0] == (NULL)))
 || (((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_REF_DATA)
 || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_DATA))
  jit_internal_bufprint(linebuf, "jit_op * op_%li = ", (((unsigned long) (op)) >> 4));
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_LABEL: {
   jit_internal_bufprint(linebuf, "jit_label * ");
   jit_tree * lab = jit_tree_search(labels, (long)op->arg[0]);
   if (lab) jit_internal_bufprint(linebuf, disasm->label_template, (long) lab->value);
   jit_internal_bufprint(linebuf, " = jit_get_label(p");
   goto print;
  }
  case JIT_PATCH:
   jit_internal_bufprint(linebuf, "jit_patch  (p, op_%li", (((unsigned long) (op->arg[0])) >> 4));
   goto print;
  case JIT_DATA_BYTE:
   jit_internal_bufprint(linebuf, "jit_data_byte(p, ");
   jit_internal_bufprint(linebuf, disasm->generic_value_template, op->arg[0]);
   goto print;
  case JIT_REF_CODE:
  case JIT_REF_DATA:
   jit_internal_bufprint(linebuf, "jit_%s(p, ", jit_get_op_name(op));
   jit_internal_print_arg(disasm, linebuf, op, 1);
   strcat(linebuf, ", ");
   jit_internal_print_addr(disasm, linebuf, labels, op, 1);
   goto print;
  case JIT_DATA_REF_CODE:
  case JIT_DATA_REF_DATA:
   jit_internal_bufprint(linebuf, "jit_data_%s(p, ", jit_get_op_name(op) + 1);
   jit_internal_print_addr(disasm, linebuf, labels, op, 0);
   goto print;
  case JIT_CODE_ALIGN:
   jit_internal_bufprint(linebuf, "jit_code_align  (p, ");
   jit_internal_bufprint(linebuf, disasm->generic_value_template, op->arg[0]);
   goto print;
  case JIT_PREPARE:
   jit_internal_bufprint(linebuf, "jit_prepare(p");
   goto print;
  default:
   break;
 }
 if (jit_get_op_name(op)[0] == '.') goto direct_print;
 strcat(linebuf, "jit_");
 jit_internal_print_full_op_name(linebuf, op);
 while (strlen((linebuf)) < (15)) { strcat((linebuf), " "); };
 strcat(linebuf, "(p,");
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_MSG:
   jit_internal_print_str(linebuf, (char *)op->arg[0]);
   if (!(op->code & 0x02)) strcat(linebuf, ", "), jit_internal_print_arg(disasm, linebuf, op, 2);
   break;
  case JIT_DECL_ARG:
   switch (op->arg[0]) {
    case JIT_SIGNED_NUM: strcat(linebuf, "JIT_SIGNED_NUM"); break;
    case JIT_UNSIGNED_NUM: strcat(linebuf, "JIT_UNSIGNED_NUM"); break;
    case JIT_FLOAT_NUM: strcat(linebuf, "JIT_FLOAT_NUM"); break;
    case JIT_PTR: strcat(linebuf, "JIT_PTR"); break;
    default: assert(0);
   };
   strcat(linebuf, ", ");
   jit_internal_print_arg(disasm, linebuf, op, 2);
   break;
  default:
   jit_internal_print_args(disasm, linebuf, op, labels);
 }
 if (op->arg_size) jit_internal_bufprint(linebuf, ", %i", op->arg_size);
print:
 strcat(linebuf, ");");
direct_print:
 printf("%s", linebuf);
 return strlen(linebuf);
}
static void jit_dump_ops_compilable(struct jit *jit, jit_tree *labels)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  jit_internal_print_op_compilable(&jit_disasm_compilable, op, labels);
  printf("\n");
 }
}
static void jit_dump_ops_general(struct jit *jit, jit_tree *labels, int verbosity)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  int size = jit_internal_print_op(stdout, &jit_disasm_general, op, labels, verbosity);
  if (size == 0) return;
  for (; size < 35; size++)
   printf(" ");
  if ((verbosity & (0x400)) && (op->live_in) && (op->live_out)) {
   printf("In: ");
   jit_tree_walk(op->live_in->root, jit_internal_print_reg_liveness_callback, &jit_disasm_general);
   printf("\tOut: ");
   jit_tree_walk(op->live_out->root, jit_internal_print_reg_liveness_callback, &jit_disasm_general);
  }
  if ((verbosity & (0x200)) && (op->regmap)) {
   printf("\tAssoc: ");
   jit_tree_walk(op->regmap->map, jit_internal_print_rmap_callback, &jit_disasm_general);
  }
  printf("\n");
 }
}
static char *jit_internal_platform_id()
{
 return "sparc";
}
static inline void jit_internal_print_op_bytes(FILE *f, struct jit *jit, jit_op *op) {
 for (int i = 0; i < op->code_length; i++)
  fprintf(f, " %02x", jit->buf[op->code_offset + i]);
 fprintf(f, "\n.nl\n");
}
static FILE *jit_internal_open_disasm()
{
 int fds[2];
 pipe(fds);
 pid_t child = fork();
 if (child == 0) {
  close(fds[1]);
  dup2(fds[0], STDIN_FILENO);
  char *path;
  path = "./myjit-disasm";
  execlp(path, path, NULL);
  path = "myjit-disasm";
  execlp(path, path, NULL);
  path = getenv("MYJIT_DISASM");
  if (path) execlp(path, path, NULL);
  printf("myjit-disasm not found\n\n");
  printf("In order to list myjit operations along with the machine code, the MyJIT disassembler has to be present in the current directory or its path has to be specified in the MYJIT_DISASM environment variable.\nThe disassembler's source code can be found in the \"disasm/\" directory.\n\n");
  exit(1);
 }
 close(fds[0]);
 FILE * f = fdopen(fds[1], "w");
 return f;
}
static jit_op *jit_internal_print_combined_op(FILE *f, struct jit *jit, struct jit_op *op, jit_tree *labels)
{
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_BYTE) {
  fprintf(f, ".text\n%s.byte\n", jit_disasm_general.indent_template);
  fprintf(f, ".data\n");
  while (op && (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_BYTE)) {
   fprintf(f, "%02x ", (unsigned char) op->arg[0]);
   op = op->next;
  }
  fprintf(f, "\n");
  if (!op) return NULL;
  op = op->prev;
  return op;
 }
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_COMMENT) {
  fprintf(f, ".comment\n");
  jit_internal_print_op(f, &jit_disasm_general, op, labels, (0x100));
  fprintf(f, "\n");
  return op;
 }
 fprintf(f, ".text\n");
 jit_internal_print_op(f, &jit_disasm_general, op, labels, (0x100));
 fprintf(f, "\n");
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_CODE_ALIGN:
   if (op->next) {
    fprintf(f, "\n.nl\n");
    fprintf(f, ".addr=%lx\n", (unsigned long) (jit->buf + op->next->code_offset));
   }
   break;
  case JIT_DATA_REF_CODE:
  case JIT_DATA_REF_DATA:
   fprintf(f, ".data\n");
   jit_internal_print_op_bytes(f, jit, op);
   break;
  default:
   if (!op->code_length) break;
   fprintf(f, ".%s\n", jit_internal_platform_id());
   jit_internal_print_op_bytes(f, jit, op);
 }
 return op;
}
static void jit_dump_ops_combined(struct jit *jit, jit_tree *labels)
{
 FILE *f = jit_internal_open_disasm();
 fprintf(f, ".addr=%lx\n", (unsigned long)jit->buf);
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  op = jit_internal_print_combined_op(f, jit, op, labels);
  if (!op) break;
 }
 fclose(f);
 wait(NULL);
}
void jit_dump_ops(struct jit * jit, int verbosity)
{
 if (!(verbosity & ((0x02) | (0x08) | (0x04))))
  verbosity |= (0x01);
 jit_tree * labels = jit_internal_prepare_labels(jit);
 if (verbosity & (0x01)) jit_dump_ops_general(jit, labels, verbosity);
 if (verbosity & (0x02)) jit_internal_compiler_based_debugger(jit);
 if (verbosity & (0x08)) jit_dump_ops_compilable(jit, labels);
 if (verbosity & (0x04)) jit_dump_ops_combined(jit, labels);
 jit_tree_free(labels);
}
void jit_trace_op(struct jit *jit, jit_op *op, int verbosity)
{
 jit_tree * labels = jit_internal_prepare_labels(jit);
 if (verbosity & (0x01)) {
  jit_internal_print_op(stdout, &jit_disasm_general, op, labels, verbosity);
  printf("\n");
 }
 if (verbosity & (0x04)) {
  FILE *f = jit_internal_open_disasm();
  fprintf(f, "..addr=%lx\n", (unsigned long) op->code_offset);
  jit_internal_print_combined_op(f, jit, op, labels);
  fclose(f);
  wait(NULL);
 }
 jit_tree_free(labels);
}
void jit_trace_callback(struct jit *jit, jit_op *op, int verbosity, int trace)
{
 if (trace & (1)) jit_trace_op(jit, op->prev, verbosity);
 if (trace & (2)) jit_trace_op(jit, op->next, verbosity);
}
static void jit_dead_code_analysis(struct jit *jit, int remove_dead_code);
static inline void jit_expand_patches_and_labels(struct jit *jit);
static inline void jit_flw_analysis(struct jit *jit);
static inline void jit_prepare_reg_counts(struct jit *jit);
static inline void jit_prepare_arguments(struct jit *jit);
void jit_get_reg_name(struct jit_disasm *disasm, char * r, int reg);
static struct jit_disasm jit_debugging_disasm = {
 .indent_template = "    ",
 .reg_template = "r%i",
 .freg_template = "fr%i",
 .arg_template = "arg%i",
 .farg_template = "farg%i",
 .reg_out_template = "out",
 .reg_fp_template = "fp",
 .reg_imm_template = "imm",
 .reg_fimm_template = "fimm",
 .reg_unknown_template = "(unknown reg.)",
 .label_template = "<label>",
 .label_forward_template = "<label>",
 .generic_addr_template = "<addr: 0x%lx>",
 .generic_value_template = "0x%lx",
};
static void jit_internal_report_warning(struct jit *jit, jit_op *op, char *desc)
{
 fprintf(stdout, "%s at function `%s' (%s:%i)\n", desc, op->debug_info->function, op->debug_info->filename, op->debug_info->lineno);
 jit_internal_print_op(stdout, &jit_debugging_disasm, op, NULL, 0);
 fprintf(stdout, "\n");
}
static void jit_internal_append_msg(char *buf, char *format, ...)
{
 va_list ap;
 if (strlen(buf)) strcat(buf, ", ");
 va_start(ap, format);
 vsprintf(buf + strlen(buf), format, ap);
 va_end(ap);
}
static void jit_internal_cleanup(struct jit *jit)
{
 for (jit_op *op = jit_op_first(jit->ops); op; op = op->next) {
  if (op->live_in) {
   jit_set_free(op->live_in);
   op->live_in = NULL;
  }
  if (op->live_out) {
   jit_set_free(op->live_out);
   op->live_out = NULL;
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   if (op->arg[1]) {
    struct jit_func_info *info = (struct jit_func_info *)op->arg[1];
    free(info->args);
    info->args = NULL;
   }
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PREPARE) {
   op->arg[0] = 0;
   op->arg[1] = 0;
  }
 }
}
static int jit_internal_check_dead_code(jit_op *op, char *msg_buf)
{
 if (!op->in_use) {
  jit_internal_append_msg(msg_buf, "unreachable operation");
  return JIT_WARN_DEAD_CODE;
 }
 return 0;
}
static int jit_internal_check_missing_patches(jit_op *op, char *msg_buf)
{
 if ((((((jit_opcode) (op->code & 0xfff8)) == JIT_CALL) || (((jit_opcode) (op->code & 0xfff8)) == JIT_JMP)) && (op->code & 0x02)) || jit_internal_is_cond_branch_op(op)) {
  if ((op->arg[0] == (jit_value) (NULL)) && (op->jmp_addr == NULL)) {
   jit_internal_append_msg(msg_buf, "missing patch");
   return JIT_WARN_MISSING_PATCH;
  }
 }
 return 0;
}
static int jit_internal_check_op_without_effect(jit_op *op, char *msg_buf)
{
 jit_opcode code = ((jit_opcode) (op->code & 0xfff8));
 if ((code == JIT_ADDC) || (code == JIT_ADDX) || (code == JIT_SUBC) || (code == JIT_SUBX)
 || (code == JIT_BOADD) || (code == JIT_BOSUB) || (code == JIT_BNOADD) || (code == JIT_BNOSUB)) return 0;
 for (int i = 0; i < 3; i++) {
  if (((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x03) && (!jit_set_get(op->live_out, op->arg[i]))) {
   jit_internal_append_msg(msg_buf, "operation without effect");
   return JIT_WARN_OP_WITHOUT_EFFECT;
  }
 }
 return 0;
}
static void jit_internal_print_regs(jit_tree_key reg, jit_tree_value v, void *thunk)
{
 char buf[32];
 if (reg == (jit_mkreg((0), (2), 0))) return;
 jit_get_reg_name(&jit_debugging_disasm, buf, reg);
 strcat(thunk, " ");
 strcat(thunk, buf);
}
static int jit_internal_check_uninitialized_registers(jit_op *op, char *msg_buf)
{
 if (((jit_opcode) (op->code & 0xfff8)) != JIT_PROLOG) return 0;
 if (op->live_in->root != NULL) {
  char buf[4096];
  buf[0] = '\0';
  jit_tree_walk(op->live_in->root, jit_internal_print_regs, buf);
  if (strlen(buf)) {
   jit_internal_append_msg(msg_buf, "uninitialized register(s): %s", buf);
   return JIT_WARN_UNINITIALIZED_REG;
  }
 }
 return 0;
}
static int jit_internal_valid_size(int size) {
 switch (size) {
  case 1: case 2: case 4:
   return 1;
  default:
   return 0;
 }
}
static int jit_internal_valid_fsize(int size)
{
 return (size == 4) || (size == 8);
}
static int jit_internal_check_argument_sizes(jit_op *op, char *msg_buf)
{
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_LD: case JIT_LDX: case JIT_ST: case JIT_STX:
   if (jit_internal_valid_size(op->arg_size)) return 0;
   break;
  case JIT_FLD: case JIT_FLDX: case JIT_FST: case JIT_FSTX:
  case JIT_FPUTARG: case JIT_FRET: case JIT_FRETVAL:
   if (jit_internal_valid_fsize(op->arg_size)) return 0;
   break;
  case JIT_DECL_ARG:
   if (((op->arg[0] == JIT_SIGNED_NUM) || (op->arg[0] == JIT_UNSIGNED_NUM)) && jit_internal_valid_size(op->arg[1])) return 0;
   if ((op->arg[0] == JIT_FLOAT_NUM) && jit_internal_valid_fsize(op->arg[1])) return 0;
   if ((op->arg[0] == JIT_PTR) && (op->arg[1] == sizeof(void *))) return 0;
   break;
  default:
   return 0;
 }
 jit_internal_append_msg(msg_buf, "invalid data size");
 return JIT_WARN_INVALID_DATA_SIZE;
}
static int jit_internal_check_register_types(struct jit *jit, jit_op *op, char *msg_buf)
{
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_GETARG: {
   struct jit_func_info * info = jit_current_func_info(jit);
   if (info->args[op->arg[1]].type == JIT_FLOAT_NUM) {
    if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (1)))) return 0;
   } else {
    if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (0)))) return 0;
   }
   break;
  }
  case JIT_FST:
  case JIT_TRUNC:
  case JIT_CEIL:
  case JIT_ROUND:
  case JIT_FLOOR:
   if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (0))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (1)))) return 0;
   break;
  case JIT_EXT:
  case JIT_FLD:
   if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (1))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (0)))) return 0;
   break;
  case JIT_FLDX:
   if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (1))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (0))) && ((((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[3 - 1]).type == (0)))) return 0;
   break;
  case JIT_FSTX:
   if (((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (0))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (0))) && ((((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[3 - 1]).type == (1)))) return 0;
   break;
  case JIT_FORCE_SPILL:
  case JIT_FORCE_ASSOC:
   return 0;
  default:
   if (!op->fp && ((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (0))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (0))) && ((((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[3 - 1]).type == (0)))) return 0;
   if (op->fp && ((((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((1) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[1 - 1]).type == (1))) && ((((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((2) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[2 - 1]).type == (1))) && ((((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x01) && ((((op)->spec >> ((3) - 1) * 2) & 0x03) != 0x03)) || (JIT_REG(op->arg[3 - 1]).type == (1)))) return 0;
 }
 jit_internal_append_msg(msg_buf, "register type mismatch");
 return JIT_WARN_REGISTER_TYPE_MISMATCH;
}
static int jit_op_is_data_op(jit_op *op)
{
 while (op && ((((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) || (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH))) op = op->next;
 if (!op) return 0;
 jit_opcode code = ((jit_opcode) (op->code & 0xfff8));
 return ((code == JIT_DATA_BYTE) || (code == JIT_DATA_REF_CODE) || (code == JIT_DATA_REF_DATA));
}
static int jit_internal_check_data_alignment(jit_op *op, char *msg_buf)
{
 if (jit_op_is_data_op(op) || (((jit_opcode) (op->code & 0xfff8)) == JIT_CODE_ALIGN)) return 0;
 if ((((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) || (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH)) return 0;
 jit_op * prev = op->prev;
 while (prev) {
  if ((((jit_opcode) (prev->code & 0xfff8)) == JIT_LABEL) || (((jit_opcode) (prev->code & 0xfff8)) == JIT_PATCH))
   prev = prev->prev;
  else break;
 }
 if (jit_op_is_data_op(prev)) {
  jit_internal_append_msg(msg_buf, "instruction follows unaligned data block");
  return JIT_WARN_UNALIGNED_CODE;
 }
 return 0;
}
static int jit_internal_check_data_references(jit_op *op, char *msg_buf)
{
 if (((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_DATA) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_DATA)) && !jit_op_is_data_op(op->jmp_addr)) {
  jit_internal_append_msg(msg_buf, "invalid data reference");
  return JIT_WARN_INVALID_DATA_REFERENCE;
 }
 return 0;
}
static int jit_internal_check_code_references(jit_op *op, char *msg_buf)
{
 if (((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE)) && jit_op_is_data_op(op->jmp_addr)) {
  jit_internal_append_msg(msg_buf, "invalid code reference");
  return JIT_WARN_INVALID_CODE_REFERENCE;
 }
 return 0;
}
void jit_check_code(struct jit *jit, int warnings)
{
 char buf[8192];
 jit_expand_patches_and_labels(jit);
 jit_dead_code_analysis(jit, 0);
 jit_prepare_reg_counts(jit);
        jit_prepare_arguments(jit);
 jit_flw_analysis(jit);
 for (jit_op *op = jit_op_first(jit->ops); op; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) jit->current_func = op;
  if (!op->debug_info) continue;
  buf[0] = '\0';
  if (warnings & JIT_WARN_DEAD_CODE) op->debug_info->warnings |= jit_internal_check_dead_code(op, buf);
  if (warnings & JIT_WARN_MISSING_PATCH) op->debug_info->warnings |= jit_internal_check_missing_patches(op, buf);
  if (warnings & JIT_WARN_OP_WITHOUT_EFFECT) op->debug_info->warnings |= jit_internal_check_op_without_effect(op, buf);
  if (warnings & JIT_WARN_UNINITIALIZED_REG) op->debug_info->warnings |= jit_internal_check_uninitialized_registers(op, buf);
  if (warnings & JIT_WARN_INVALID_DATA_SIZE) op->debug_info->warnings |= jit_internal_check_argument_sizes(op, buf);
  if (warnings & JIT_WARN_REGISTER_TYPE_MISMATCH) op->debug_info->warnings |= jit_internal_check_register_types(jit, op, buf);
  if (warnings & JIT_WARN_UNALIGNED_CODE) op->debug_info->warnings |= jit_internal_check_data_alignment(op, buf);
  if (warnings & JIT_WARN_INVALID_DATA_REFERENCE) op->debug_info->warnings |= jit_internal_check_data_references(op, buf);
  if (warnings & JIT_WARN_INVALID_CODE_REFERENCE) op->debug_info->warnings |= jit_internal_check_code_references(op, buf);
  if (op->debug_info->warnings) jit_internal_report_warning(jit, op, buf);
 }
 jit_internal_cleanup(jit);
}
static inline void jit_flw_initialize(struct jit * jit)
{
 struct jit_func_info *func_info;
 jit_op * op = jit_op_first(jit->ops);
 while (op) {
  op->live_in = jit_set_new();
  op->live_out = jit_set_new();
  for (int i = 0; i < 3; i++)
   if ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01)
    jit_set_add(op->live_in, op->arg[i]);
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   func_info = (struct jit_func_info *)op->arg[1];
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_GETARG) {
   int arg_id = op->arg[1];
   if (func_info->args[arg_id].type != JIT_FLOAT_NUM) {
    jit_set_add(op->live_in, jit_mkreg((0), (3), arg_id));
   } else {
    jit_set_add(op->live_in, jit_mkreg((1), (3), arg_id));
    if (func_info->args[arg_id].overflow)
     jit_set_add(op->live_in, jit_mkreg_ex((1), (3), arg_id));
   }
  }
  op = op->next;
 }
}
static inline void jit_internal_flw_analyze_prolog(struct jit * jit, jit_op * op, struct jit_func_info * func_info)
{
 int assoc_gp = 0;
 int argcount = func_info->general_arg_cnt + func_info->float_arg_cnt;
 for (int j = 0; j < argcount; j++) {
  if (assoc_gp >= jit->reg_al->gp_arg_reg_cnt) break;
  if (func_info->args[j].type != JIT_FLOAT_NUM) {
   jit_set_remove(op->live_in, jit_mkreg((0), (3), j));
   assoc_gp++;
  } else {
   jit_set_remove(op->live_in, jit_mkreg((1), (3), j));
   assoc_gp++;
   if (func_info->args[j].size == sizeof(double)) {
    jit_set_remove(op->live_in, jit_mkreg_ex((1), (3), j));
    assoc_gp++;
   }
  }
 }
}
struct code_refs_cache {
 int size;
 jit_op **ops;
};
static inline void jit_internal_initialize_code_refs(struct code_refs_cache *code_refs, struct jit_func_info *func_info)
{
 jit_op *op = func_info->first_op->next;
 code_refs->size = 0;
 while (op && (((jit_opcode) (op->code & 0xfff8)) != JIT_PROLOG)) {
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE))
   code_refs->size++;
  op = op->next;
 }
 code_refs->ops = malloc(sizeof(jit_op *) * code_refs->size);
 op = func_info->first_op->next;
 int i = 0;
 while (op && (((jit_opcode) (op->code & 0xfff8)) != JIT_PROLOG)) {
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE))
   code_refs->ops[i++] = op;
  op = op->next;
 }
}
static inline int jit_internal_flw_analyze_op(struct jit * jit, jit_op * op, struct jit_func_info * func_info, int changed, struct code_refs_cache *code_refs)
{
 int live_out_size = jit_set_size(op->live_out);
 int live_in_size = jit_set_size(op->live_in);
 if (op->jmp_addr && (((jit_opcode) (op->code & 0xfff8)) != JIT_REF_CODE) && (((jit_opcode) (op->code & 0xfff8)) != JIT_DATA_REF_CODE))
  jit_set_addall(op->live_out, op->jmp_addr->live_in);
 if (op->code == (JIT_JMP | 0x01)) {
  if (code_refs->size < 0) jit_internal_initialize_code_refs(code_refs, func_info);
  for (int i = 0; i < code_refs->size; i++) {
   jit_set_addall(op->live_out, code_refs->ops[i]->jmp_addr->live_in);
  }
  goto skip;
 }
 if (op->code == (JIT_JMP | 0x02)) goto skip;
 if (op->next) jit_set_addall(op->live_out, op->next->live_in);
skip:
 jit_set_addall(op->live_in, op->live_out);
 for (int i = 0; i < 3; i++)
  if ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x03) jit_set_remove(op->live_in, op->arg[i]);
 for (int i = 0; i < 3; i++)
  if ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01) jit_set_add(op->live_in, op->arg[i]);
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) jit_internal_flw_analyze_prolog(jit, op, func_info);
 if (changed) return changed;
 if (live_out_size != jit_set_size(op->live_out)) return 1;
 if (live_in_size != jit_set_size(op->live_in)) return 1;
 return 0;
}
static inline void jit_internal_analyze_function(struct jit *jit, jit_op *first_op, jit_op *last_op)
{
 int changed;
 struct code_refs_cache code_refs = { -1, NULL };
 struct jit_func_info * func_info = (struct jit_func_info *)first_op->arg[1];
 do {
  changed = 0;
  jit_op * op = last_op;
  while (1) {
   changed |= jit_internal_flw_analyze_op(jit, op, func_info, changed, &code_refs);
   if (op == first_op) break;
   op = op->prev;
  }
 } while (changed);
 if (code_refs.ops) free(code_refs.ops);
}
static inline void jit_flw_analysis(struct jit * jit)
{
 jit_flw_initialize(jit);
 jit_op *op = jit_op_first(jit->ops);
 while (op) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   jit_op *first = op;
   while (1) {
    if ((op->next == NULL) || (((jit_opcode) (op->next->code & 0xfff8)) == JIT_PROLOG)) {
     jit_op *second = op;
     jit_internal_analyze_function(jit, first, second);
     break;
    }
    op = op->next;
   }
  }
  op = op->next;
 }
}
static inline void jit_internal_mark_livecode(jit_op *op)
{
 while (op) {
  if (op->in_use) return;
  op->in_use = 1;
  if (op->jmp_addr) jit_internal_mark_livecode(op->jmp_addr);
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_RET) return;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FRET) return;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_JMP) return;
  op = op->next;
 }
}
static void jit_dead_code_analysis(struct jit *jit, int remove_dead_code)
{
 for (jit_op *op = jit_op_first(jit->ops); op; op = op->next)
  op->in_use = 0;
 for (jit_op *op = jit_op_first(jit->ops); op; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) jit_internal_mark_livecode(op);
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE) jit_internal_mark_livecode(op->jmp_addr);
 }
 for (jit_op *op = jit_op_first(jit->ops); op; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_CODESTART) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_BYTE) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_DATA) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_CODE_ALIGN) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH) op->in_use = 1;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_COMMENT) op->in_use = 1;
 }
 if (!remove_dead_code) return;
 jit_op *op = jit_op_first(jit->ops);
 while (op) {
  if (!op->in_use) {
   if (((jit_opcode) (op->code & 0xfff8)) == JIT_FULL_SPILL) goto skip;
   jit_op *next = op->next;
   jit_op_delete(op);
   op = next;
   continue;
  }
skip:
  op = op->next;
 }
}
static inline void jit_internal_unload_reg(jit_op * op, jit_hw_reg * hreg, long virt_reg);
static inline void jit_internal_load_reg(struct jit_op * op, jit_hw_reg * hreg, long reg);
static inline jit_rmap * jit_internal_rmap_init()
{
 jit_rmap * res = malloc(sizeof(jit_rmap));
 res->map = NULL;
 return res;
}
jit_hw_reg * jit_internal_rmap_get(jit_rmap * rmap, jit_value reg)
{
 jit_tree * found = jit_tree_search(rmap->map, reg);
 if (found) return (jit_hw_reg *) found->value;
 return NULL;
}
static inline jit_hw_reg * jit_internal_rmap_is_associated_aux(jit_tree * n, int reg_id, int fp, jit_value * virt_reg)
{
 if (n == NULL) return NULL;
 jit_hw_reg * r = (jit_hw_reg *) n->value;
 if ((r->fp == fp) && (r->id == reg_id)) {
  if (virt_reg) *virt_reg = (jit_value) n->key;
  return r;
 }
 r = jit_internal_rmap_is_associated_aux(n->left, reg_id, fp, virt_reg);
 if (r) return r;
 else return jit_internal_rmap_is_associated_aux(n->right, reg_id, fp, virt_reg);
}
static jit_hw_reg * jit_internal_rmap_is_associated(jit_rmap * rmap, int reg_id, int fp, jit_value * virt_reg)
{
 return jit_internal_rmap_is_associated_aux(rmap->map, reg_id, fp, virt_reg);
}
static void jit_internal_rmap_assoc(jit_rmap * rmap, jit_value reg, jit_hw_reg * hreg)
{
 rmap->map = jit_tree_insert(rmap->map, reg, hreg, NULL);
}
static void jit_internal_rmap_unassoc(jit_rmap * rmap, jit_value reg)
{
 rmap->map = jit_tree_delete(rmap->map, reg, NULL);
}
static jit_rmap * jit_internal_rmap_clone(jit_rmap * rmap)
{
 jit_rmap * res = malloc(sizeof(jit_rmap));
 res->map = jit_tree_clone(rmap->map);
 return res;
}
static int jit_internal_rmap_subset(jit_op * op, jit_tree * current, jit_tree * target)
{
 if (current == NULL) return 1;
 jit_set * tgt_livein = op->jmp_addr->live_in;
 if (!jit_set_get(tgt_livein, current->key) && !jit_set_get(op->live_out, current->key)) goto skip;
 jit_tree * found = jit_tree_search(target, current->key);
 if ((!found) || (current->value != found->value)) return 0;
skip:
 return jit_internal_rmap_subset(op, current->left, target) && jit_internal_rmap_subset(op, current->right, target);
}
static int jit_internal_rmap_equal(jit_op * op, jit_rmap * current, jit_rmap * target)
{
 return jit_internal_rmap_subset(op, current->map, target->map) && jit_internal_rmap_subset(op, target->map, current->map);
}
static void jit_internal_rmap_sync_aux(jit_tree * current, jit_tree * target, jit_op * op, int mode)
{
 if (current == NULL) return;
 if ((mode == (2)) && (!jit_set_get(op->live_out, current->key))) goto skip;
 if ((mode == (1)) && (!jit_set_get(op->jmp_addr->live_in, current->key))) goto skip;
 jit_tree * found = jit_tree_search(target, current->key);
 int i = current->key;
 if ((!found) || (current->value != found->value)) {
  jit_hw_reg * hreg = (jit_hw_reg *) current->value;
  switch (mode) {
   case (1): jit_internal_unload_reg(op, hreg, i); break;
   case (2): jit_internal_load_reg(op, hreg, i); break;
   default: assert(0);
  }
 }
skip:
 jit_internal_rmap_sync_aux(current->left, target, op, mode);
 jit_internal_rmap_sync_aux(current->right, target, op, mode);
}
static void jit_internal_rmap_sync(jit_op * op, jit_rmap * current, jit_rmap * target, int mode)
{
 jit_internal_rmap_sync_aux(current->map, target->map, op, mode);
}
static int jit_internal_candidate_score(jit_op * op, jit_value virtreg, jit_hw_reg * hreg, int * spill, jit_value * associated_virtreg)
{
 int score = 0;
 score -= hreg->priority;
 jit_value x;
 int hw_associated = (jit_internal_rmap_is_associated(op->regmap, hreg->id, hreg->fp, &x) != NULL);
 int alive = 0;
 if (hw_associated) {
  alive = (jit_set_get(op->live_in, x) || jit_set_get(op->live_out, x));
 }
 if (!alive) score += 10000;
 *spill = 0;
 if (hw_associated) {
  score -= 100000;
  *spill = 1;
  *associated_virtreg = x;
  jit_tree * hint_node = jit_tree_search(op->allocator_hints, x);
  int is_to_be_used = (hint_node != NULL);
  if (!is_to_be_used) score += 50000;
  else {
   struct jit_allocator_hint * hint = (struct jit_allocator_hint *)hint_node->value;
   int used_in_steps = -(hint->last_pos - op->normalized_pos);
   if (hw_associated && (used_in_steps == 0)) return INT_MIN;
   else score += (used_in_steps * 5);
  }
 }
 return score;
}
static jit_hw_reg * jit_internal_rmap_spill_candidate(struct jit_reg_allocator * al, jit_op * op, jit_value virtreg, int * spill, jit_value * reg_to_spill, int callee_saved)
{
 jit_reg r = JIT_REG(virtreg);
 jit_hw_reg * regs;
 int reg_count;
 jit_hw_reg * result = NULL;
 int best_score = INT_MIN;
 if (r.type == (0)) {
  regs = al->gp_regs;
  reg_count = al->gp_reg_cnt;
 } else {
  regs = al->fp_regs;
  reg_count = al->fp_reg_cnt;
 }
 int sp = 0;
 for (int i = 0; i < reg_count; i++) {
  if (callee_saved && !regs[i].callee_saved) continue;
  jit_value assoc = 0;
  int score = jit_internal_candidate_score(op, virtreg, &(regs[i]), &sp, &assoc);
  if (score > best_score) {
   if (sp) {
    *reg_to_spill = assoc;
    *spill = sp;
   } else {
    *reg_to_spill = -1;
    *spill = 0;
   }
   result = &(regs[i]);
   best_score = score;
  }
 }
 return result;
}
void jit_internal_rmap_free(jit_rmap * regmap)
{
 if (!regmap) return;
 jit_tree_free(regmap->map);
 free(regmap);
}
static void jit_internal_insert_reg_op(int opcode, jit_op * op, jit_value r1, jit_value r2)
{
 jit_op * o = jit_op_new(opcode, (((0x00) << 4) | ((0x02) << 2) | (0x02)), r1, r2, 0, 0);
 o->r_arg[0] = o->arg[0];
 o->r_arg[1] = o->arg[1];
 jit_op_prepend(op, o);
}
static void jit_internal_unload_reg(jit_op * op, jit_hw_reg * hreg, jit_value virt_reg)
{
 jit_internal_insert_reg_op(JIT_UREG, op, virt_reg, hreg->id);
}
static void jit_internal_sync_reg(jit_op * op, jit_hw_reg * hreg, jit_value virt_reg)
{
 jit_internal_insert_reg_op(JIT_SYNCREG, op, virt_reg, hreg->id);
}
static void jit_internal_load_reg(jit_op * op, jit_hw_reg * hreg, jit_value reg)
{
 jit_internal_insert_reg_op(JIT_LREG, op, hreg->id, reg);
}
static void jit_internal_rename_reg(jit_op * op, int r1, int r2)
{
 jit_internal_insert_reg_op(JIT_RENAMEREG, op, r1, r2);
}
static jit_hw_reg * jit_internal_make_free_reg(struct jit_reg_allocator * al, jit_op * op, jit_value for_reg)
{
 int spill = 0;
 jit_value spill_candidate = -1;
 jit_hw_reg * hreg = jit_internal_rmap_spill_candidate(al, op, for_reg, &spill, &spill_candidate, 0);
 if (spill) {
  if (jit_set_get(op->live_in, spill_candidate))
   jit_internal_unload_reg(op, hreg, spill_candidate);
  jit_internal_rmap_unassoc(op->regmap, spill_candidate);
 }
 return hreg;
}
static void jit_internal_assign_regs_for_args(struct jit_reg_allocator * al, jit_op * op)
{
 int fp_arg_cnt = 0;
 struct jit_func_info * info = (struct jit_func_info *) op->arg[1];
 for (int i = 0; i < info->general_arg_cnt + info->float_arg_cnt; i++) {
  struct jit_inp_arg a = info->args[i];
  if (a.type == JIT_FLOAT_NUM) fp_arg_cnt += a.size / sizeof(float);
 }
 int assoc_gp_regs = 0;
 for (int i = 0; i < info->general_arg_cnt + info->float_arg_cnt; i++) {
  if (assoc_gp_regs >= al->gp_arg_reg_cnt) break;
  int isfp_arg = (info->args[i].type == JIT_FLOAT_NUM);
  if (!isfp_arg) {
   jit_internal_rmap_assoc(op->regmap, jit_mkreg((0), (3), i), al->gp_arg_regs[assoc_gp_regs]);
   assoc_gp_regs++;
  }
  if (isfp_arg) {
   jit_internal_rmap_assoc(op->regmap, jit_mkreg((1), (3), i), al->gp_arg_regs[assoc_gp_regs]);
   assoc_gp_regs++;
   if ((info->args[i].size == sizeof(double)) && (assoc_gp_regs < al->gp_reg_cnt)) {
    jit_value r = jit_mkreg_ex((1), (3), i);
    jit_internal_rmap_assoc(op->regmap, (int)r, al->gp_arg_regs[assoc_gp_regs]);
    assoc_gp_regs++;
   }
  }
 }
}
static void jit_internal_prepare_registers_for_call(struct jit_reg_allocator * al, jit_op * op)
{
 jit_value r, reg;
 jit_hw_reg * hreg = NULL;
 if (al->fpret_reg) {
  hreg = jit_internal_rmap_is_associated(op->regmap, al->fpret_reg->id, 1, &r);
  if (hreg) jit_internal_sync_reg(op, hreg, r);
 }
 int args = ((op->arg[0]) < (al->gp_arg_reg_cnt) ? (op->arg[0]) : (al->gp_arg_reg_cnt));
 for (int q = 0; q < args; q++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->gp_arg_regs[q]->id, 0, &reg);
  if (hreg) {
   if (jit_set_get(op->live_out, reg)) jit_internal_unload_reg(op, hreg, reg);
   jit_internal_rmap_unassoc(op->regmap, reg);
  }
 }
 args = ((op->arg[1]) < (al->fp_arg_reg_cnt) ? (op->arg[1]) : (al->fp_arg_reg_cnt));
 for (int q = 0; q < args; q++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->fp_arg_regs[q]->id, 1, &reg);
  if (hreg) {
   if ((hreg->id != al->fpret_reg->id) && jit_set_get(op->live_out, reg)) jit_internal_unload_reg(op, hreg, reg);
   jit_internal_rmap_unassoc(op->regmap, reg);
  }
 }
}
static int jit_internal_assign_ret_reg(jit_op * op, jit_hw_reg * ret_reg)
{
 jit_internal_rmap_assoc(op->regmap, op->arg[0], ret_reg);
 return 1;
}
static int jit_internal_assign_getarg(jit_op * op, struct jit_reg_allocator * al)
{
 int arg_id = op->arg[1];
 struct jit_inp_arg * arg = &(al->current_func_info->args[arg_id]);
 int reg_id = jit_mkreg(arg->type == JIT_FLOAT_NUM ? (1) : (0), (3), arg_id);
 if (!jit_set_get(op->live_out, reg_id)) {
  if (((arg->type != JIT_FLOAT_NUM) && (arg->size == (sizeof(void *))))
     ) {
   jit_hw_reg * hreg = jit_internal_rmap_get(op->regmap, reg_id);
   if (hreg) {
    jit_internal_rmap_unassoc(op->regmap, reg_id);
    jit_internal_rmap_assoc(op->regmap, op->arg[0], hreg);
    op->r_arg[0] = hreg->id;
    op->r_arg[1] = op->arg[1];
    op->code = JIT_NOP;
    return 1;
   }
  }
 }
 return 0;
}
static void jit_internal_spill_ret_retreg(jit_op * op, jit_hw_reg * ret_reg)
{
 jit_value r;
 if (ret_reg) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, ret_reg->id, ret_reg->fp, &r);
  if (hreg) jit_internal_rmap_unassoc(op->regmap, r);
 }
}
static int jit_internal_assign_jmp(jit_op * op, struct jit_reg_allocator * al)
{
 if (op->code == (JIT_JMP | 0x02)) return 0;
 jit_value reg;
 for (int i = 0; i < al->gp_reg_cnt; i++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->gp_regs[i].id, 0, &reg);
  if (hreg && jit_set_get(op->live_out, reg)) jit_internal_sync_reg(op, hreg, reg);
 }
 for (int i = 0; i < al->fp_reg_cnt; i++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->fp_regs[i].id, 1, &reg);
  if (hreg && jit_set_get(op->live_out, reg)) jit_internal_sync_reg(op, hreg, reg);
 }
 return 0;
}
static int jit_internal_assign_call(jit_op * op, struct jit_reg_allocator * al)
{
 jit_internal_spill_ret_retreg(op, al->ret_reg);
 jit_internal_spill_ret_retreg(op, al->fpret_reg);
 jit_value reg;
 for (int q = 0; q < al->fp_reg_cnt; q++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->fp_regs[q].id, 1, &reg);
  if (hreg) {
   jit_internal_unload_reg(op, hreg, reg);
   jit_internal_rmap_unassoc(op->regmap, reg);
  }
 }
 return 0;
}
static int jit_internal_spill_all_registers(jit_op *op, struct jit_reg_allocator * al)
{
 jit_value reg;
 for (int i = 0; i < al->gp_reg_cnt; i++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->gp_regs[i].id, 0, &reg);
  if (hreg && (jit_set_get(op->live_out, reg))) {
   if (op->in_use) jit_internal_unload_reg(op, hreg, reg);
   jit_internal_rmap_unassoc(op->regmap, reg);
  }
 }
 for (int i = 0; i < al->fp_reg_cnt; i++) {
  jit_hw_reg * hreg = jit_internal_rmap_is_associated(op->regmap, al->fp_regs[i].id, 1, &reg);
  if (hreg && (jit_set_get(op->live_out, reg))) {
   if (op->in_use) jit_internal_unload_reg(op, hreg, reg);
   jit_internal_rmap_unassoc(op->regmap, reg);
  }
 }
 return 1;
}
static int jit_internal_force_spill(jit_op *op)
{
 jit_value reg = op->arg[0];
 jit_hw_reg *hreg = jit_internal_rmap_get(op->regmap, reg);
 if (hreg) {
  jit_internal_unload_reg(op, hreg, reg);
  jit_internal_rmap_unassoc(op->regmap, reg);
 }
 return 1;
}
static int jit_internal_force_assoc(jit_op *op, struct jit_reg_allocator *al)
{
 jit_hw_reg *hreg = (op->arg[1] == 0 ? &al->gp_regs[op->arg[2]] : &al->fp_regs[op->arg[2]]);
 jit_internal_rmap_assoc(op->regmap, op->arg[0], hreg);
 jit_internal_load_reg(op, hreg, op->arg[0]);
 return 1;
}
static void jit_internal_associate_register_alias(struct jit_reg_allocator * al, jit_op * op, int i)
{
 if ((int)op->arg[i] == (int)(jit_mkreg((0), (2), 1))) op->r_arg[i] = al->ret_reg->id;
 else if ((int)op->arg[i] == (int)(jit_mkreg((0), (2), 0))) op->r_arg[i] = al->fp_reg;
 else assert(0);
}
static void jit_internal_associate_register(struct jit_reg_allocator * al, jit_op * op, int i)
{
 jit_hw_reg * reg = jit_internal_rmap_get(op->regmap, op->arg[i]);
 if (reg) op->r_arg[i] = reg->id;
 else {
  reg = jit_internal_make_free_reg(al, op, op->arg[i]);
  jit_internal_rmap_assoc(op->regmap, op->arg[i], reg);
  op->r_arg[i] = reg->id;
  if (jit_set_get(op->live_in, op->arg[i]))
   jit_internal_load_reg(op, jit_internal_rmap_get(op->regmap, op->arg[i]), op->arg[i]);
 }
}
static void jit_internal_assign_regs(struct jit * jit, struct jit_op * op)
{
 int i;
 int skip = 0;
 struct jit_reg_allocator * al = jit->reg_al;
 if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
  struct jit_func_info * info = (struct jit_func_info *) op->arg[1];
  al->current_func_info = info;
  jit_internal_assign_regs_for_args(al, op);
 } else {
  if (op->prev) {
   jit_internal_rmap_free(op->regmap);
   op->regmap = jit_internal_rmap_clone(op->prev->regmap);
  }
 }
 switch (((jit_opcode) (op->code & 0xfff8))) {
  case JIT_PREPARE: jit_internal_prepare_registers_for_call(al, op); break;
  case JIT_PUTARG: skip = 1; break;
  case JIT_FPUTARG: skip = 1; break;
  case JIT_FRETVAL: skip = jit_internal_assign_ret_reg(op, al->fpret_reg); break;
  case JIT_GETARG: skip = jit_internal_assign_getarg(op, al); break;
  case JIT_CALL: skip = jit_internal_assign_call(op, al); break;
  case JIT_JMP: skip = jit_internal_assign_jmp(op, al); break;
  case JIT_FULL_SPILL: skip = jit_internal_spill_all_registers(op, al); break;
  case JIT_FORCE_SPILL: skip = jit_internal_force_spill(op); break;
  case JIT_FORCE_ASSOC: skip = jit_internal_force_assoc(op, al); break;
  default: break;
 }
 if (skip) return;
 for (i = 0; i < 3; i++) {
  if (((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01) || ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x03)) {
   jit_reg virt_reg = JIT_REG(op->arg[i]);
   if (virt_reg.spec == (2)) jit_internal_associate_register_alias(al, op, i);
   else jit_internal_associate_register(al, op, i);
  } else if ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x02) {
   op->r_arg[i] = op->arg[i];
  }
 }
}
static void jit_internal_mark_calleesaved_regs(jit_tree * hint, jit_op * op)
{
 if (hint == NULL) return;
 struct jit_allocator_hint * h = (struct jit_allocator_hint *) hint->value;
 jit_value reg = (jit_value) hint->key;
 if (jit_set_get(op->live_out, reg)) h->should_be_calleesaved++;
 jit_internal_mark_calleesaved_regs(hint->left, op);
 jit_internal_mark_calleesaved_regs(hint->right, op);
}
static void jit_internal_hints_refcount_inc(jit_tree * hints);
void jit_collect_statistics(struct jit * jit)
{
 int i, j;
 int ops_from_return = 0;
 jit_tree * last_hints = NULL;
 for (jit_op * op = jit_op_last(jit->ops); op != NULL; op = op->prev) {
  jit_tree * new_hints = jit_tree_clone(last_hints);
  op->normalized_pos = ops_from_return;
  jit_value regs[3];
  int found_regs = 0;
  for (i = 0; i < 3; i++)
   if (((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01) || ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x03)) {
    int found = 0;
    jit_value reg = op->arg[i];
    for (j = 0; j < found_regs; j++) {
     if (regs[j] == reg) {
      found = 1;
      break;
     }
    }
    if (!found) regs[found_regs++] = reg;
   }
  for (i = 0; i < found_regs; i++) {
   jit_value reg = regs[i];
   jit_tree * hint = jit_tree_search(new_hints, reg);
   struct jit_allocator_hint * new_hint = malloc(sizeof(struct jit_allocator_hint));
   if (hint) memcpy(new_hint, hint->value, sizeof(struct jit_allocator_hint));
   else {
    new_hint->last_pos = 0;
    new_hint->should_be_calleesaved = 0;
    new_hint->should_be_eax = 0;
   }
   new_hint->refs = 0;
   new_hint->last_pos = ops_from_return;
   new_hints = jit_tree_insert(new_hints, reg, new_hint, NULL);
  }
  jit_internal_hints_refcount_inc(new_hints);
  op->allocator_hints = new_hints;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   last_hints = NULL;
   ops_from_return = 0;
  } else {
   last_hints = new_hints;
   ops_from_return++;
  }
 }
}
static void jit_internal_hints_refcount_inc(jit_tree * hints)
{
 if (hints == NULL) return;
 ((struct jit_allocator_hint*) hints->value)->refs++;
 jit_internal_hints_refcount_inc(hints->left);
 jit_internal_hints_refcount_inc(hints->right);
}
void jit_allocator_hints_free(jit_tree * hints)
{
 if (hints == NULL) return;
 jit_allocator_hints_free(hints->left);
 jit_allocator_hints_free(hints->right);
 int refs = --((struct jit_allocator_hint*) hints->value)->refs;
 if (refs == 0) free(hints->value);
 free(hints);
}
static inline void jit_internal_jump_adjustment(struct jit * jit, jit_op * op)
{
 if (op->code == (JIT_JMP | 0x02)) {
  jit_rmap * cur_regmap = op->regmap;
  jit_rmap * tgt_regmap = op->jmp_addr->regmap;
  jit_internal_rmap_sync(op, cur_regmap, tgt_regmap, (1));
  jit_internal_rmap_sync(op, tgt_regmap, cur_regmap, (2));
 }
}
static inline void jit_internal_branch_adjustment(struct jit * jit, jit_op * op)
{
 if (!jit_internal_is_cond_branch_op(op)) return;
 jit_rmap * cur_regmap = op->regmap;
 jit_rmap * tgt_regmap = op->jmp_addr->regmap;
 if (!jit_internal_rmap_equal(op, cur_regmap, tgt_regmap)) {
  switch (((jit_opcode) (op->code & 0xfff8))) {
   case JIT_BEQ: op->code = JIT_BNE | (op->code & 0x7); break;
   case JIT_BGT: op->code = JIT_BLE | (op->code & 0x7); break;
   case JIT_BGE: op->code = JIT_BLT | (op->code & 0x7); break;
   case JIT_BNE: op->code = JIT_BEQ | (op->code & 0x7); break;
   case JIT_BLT: op->code = JIT_BGE | (op->code & 0x7); break;
   case JIT_BLE: op->code = JIT_BGT | (op->code & 0x7); break;
   case JIT_BOADD: op->code = JIT_BNOADD | (op->code & 0x7); break;
   case JIT_BOSUB: op->code = JIT_BNOSUB | (op->code & 0x7); break;
   case JIT_BNOADD: op->code = JIT_BOADD | (op->code & 0x7); break;
   case JIT_BNOSUB: op->code = JIT_BOSUB | (op->code & 0x7); break;
   case JIT_FBEQ: op->code = JIT_FBNE | (op->code & 0x7); break;
   case JIT_FBGT: op->code = JIT_FBLE | (op->code & 0x7); break;
   case JIT_FBGE: op->code = JIT_FBLT | (op->code & 0x7); break;
   case JIT_FBNE: op->code = JIT_FBEQ | (op->code & 0x7); break;
   case JIT_FBLT: op->code = JIT_FBGE | (op->code & 0x7); break;
   case JIT_FBLE: op->code = JIT_FBGT | (op->code & 0x7); break;
   default: break;
  }
  jit_op * o = jit_op_new(JIT_JMP | 0x02, (((0x00) << 4) | ((0x00) << 2) | (0x02)), op->arg[0], 0, 0, 0);
  o->r_arg[0] = op->r_arg[0];
  o->regmap = jit_internal_rmap_clone(op->regmap);
  o->live_in = jit_set_clone(op->live_in);
  o->live_out = jit_set_clone(op->live_out);
  o->jmp_addr = op->jmp_addr;
  if (!jit_is_label(jit, (void *)op->r_arg[0])) {
   op->jmp_addr->arg[0] = (jit_value) o;
   op->jmp_addr->r_arg[0] = (jit_value) o;
  }
  jit_op_append(op, o);
  jit_op * o2 = jit_op_new(JIT_PATCH, (((0x00) << 4) | ((0x00) << 2) | (0x02)), (jit_value) op, 0, 0, 0);
  o2->r_arg[0] = o2->arg[0];
  jit_op_append(o, o2);
  op->arg[0] = (jit_value) o2;
  op->r_arg[0] = (jit_value) o2;
  op->jmp_addr = o2;
 }
}
void jit_assign_regs(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next)
  op->regmap = jit_internal_rmap_init();
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next)
  jit_internal_assign_regs(jit, op);
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next)
  jit_internal_branch_adjustment(jit, op);
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next)
  jit_internal_jump_adjustment(jit, op);
}
void jit_reg_allocator_free(struct jit_reg_allocator * a)
{
 if (a->fp_regs) free(a->fp_regs);
 free(a->gp_regs);
 if (a->fp_arg_regs) free(a->fp_arg_regs);
 if (a->gp_arg_regs) free(a->gp_arg_regs);
 free(a);
}
int jit_reg_in_use(jit_op * op, int reg, int fp)
{
 jit_value virt_reg;
 if (jit_internal_rmap_is_associated(op->regmap, reg, fp, &virt_reg)
 && ((jit_set_get(op->live_in, virt_reg) || (jit_set_get(op->live_out, virt_reg))))) return 1;
 else return 0;
}
jit_hw_reg * jit_get_unused_reg(struct jit_reg_allocator * al, jit_op * op, int fp)
{
 jit_hw_reg * regs;
 int reg_count;
 if (!fp) {
  regs = al->gp_regs;
  reg_count = al->gp_reg_cnt;
 } else {
  regs = al->fp_regs;
  reg_count = al->fp_reg_cnt;
 }
 for (int i = 0; i < reg_count; i++)
  if (!jit_reg_in_use(op, regs[i].id, fp)) return &(regs[i]);
 return NULL;
}
struct jit_op * jit_add_op(struct jit * jit, unsigned short code, unsigned char spec, long arg1, long arg2, long arg3, unsigned char arg_size, struct jit_debug_info *debug_info)
{
 struct jit_op * r = jit_op_new(code, spec, arg1, arg2, arg3, arg_size);
 r->debug_info = debug_info;
 jit_op_append(jit->last_op, r);
 jit->last_op = r;
 return r;
}
struct jit_op * jit_add_fop(struct jit * jit, unsigned short code, unsigned char spec, long arg1, long arg2, long arg3, double flt_imm, unsigned char arg_size, struct jit_debug_info *debug_info)
{
 struct jit_op * r = jit_add_op(jit, code, spec, arg1, arg2, arg3, arg_size, debug_info);
 r->fp = 1;
 r->flt_imm = flt_imm;
 return r;
}
struct jit_debug_info *jit_debug_info_new(const char *filename, const char *function, int lineno)
{
 struct jit_debug_info *r = malloc(sizeof(struct jit_debug_info));
 r->filename = filename;
 r->function = function;
 r->lineno = lineno;
 r->warnings = 0;
 return r;
}
struct jit * jit_init()
{
 struct jit * r = malloc(sizeof(struct jit));
 r->ops = jit_op_new(JIT_CODESTART, (((0x00) << 4) | ((0x00) << 2) | (0x00)), 0, 0, 0, 0);
 r->last_op = r->ops;
 r->optimizations = 0;
 r->buf = NULL;
 r->labels = NULL;
 r->reg_al = jit_reg_allocator_create();
 jit_enable_optimization(r, (0x04) | (0x01));
 return r;
}
jit_op *jit_add_prolog(struct jit * jit, void * func, struct jit_debug_info *debug_info)
{
        jit_op * op = jit_add_op(jit, JIT_PROLOG , (((0x00) << 4) | ((0x00) << 2) | (0x02)), (long)func, 0, 0, 0, NULL);
        struct jit_func_info * info = malloc(sizeof(struct jit_func_info));
        op->arg[1] = (long)info;
 op->debug_info = debug_info;
        jit->current_func = op;
 info->first_op = op;
        info->allocai_mem = 0;
        info->general_arg_cnt = 0;
        info->float_arg_cnt = 0;
 return op;
}
jit_label * jit_get_label(struct jit * jit)
{
        jit_label * r = malloc(sizeof(jit_label));
        jit_add_op(jit, JIT_LABEL, (((0x00) << 4) | ((0x00) << 2) | (0x02)), (long)r, 0, 0, 0, NULL);
        r->next = jit->labels;
        jit->labels = r;
        return r;
}
static int jit_imm_overflow(struct jit * jit, int signed_op, long value)
{
 unsigned long mask = ~((1UL << (12)) - 1);
 unsigned long high_bits = value & mask;
 if (signed_op) {
  if ((high_bits != 0) && (high_bits != mask)) return 1;
 } else {
  if (high_bits != 0) return 1;
 }
 return 0;
}
static void jit_correct_long_imms(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if (!(op->code & 0x02)) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_JMP) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_CALL) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_MOV) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PUTARG) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_MSG) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_COMMENT) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_DATA) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_REF_DATA) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FORCE_ASSOC) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_TRACE) continue;
  int imm_arg;
  for (int i = 1; i < 4; i++)
   if ((((op)->spec >> ((i) - 1) * 2) & 0x03) == 0x02) imm_arg = i - 1;
  long value = op->arg[imm_arg];
  if (jit_imm_overflow(jit, (!(op->code & 0x04)), value)) {
   jit_op * newop = jit_op_new(JIT_MOV | 0x02, (((0x00) << 4) | ((0x02) << 2) | (0x03)), (jit_mkreg((0), (1), 0)), value, 0, (sizeof(void *)));
   jit_op_prepend(op, newop);
   op->code &= ~(0x3);
   op->code |= 0x01;
   op->spec &= ~(0x3 << (2 * imm_arg));
   op->spec |= (0x01 << (2 * imm_arg));
   op->arg[imm_arg] = (jit_mkreg((0), (1), 0));
  }
 }
}
static inline void jit_correct_float_imms(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if (!(op->code & 0x02)) continue;
  if (!op->fp) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FMOV) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FPUTARG) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FLD) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FLDX) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FST) continue;
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_FSTX) continue;
  int imm_arg;
  for (int i = 1; i < 4; i++)
   if ((((op)->spec >> ((i) - 1) * 2) & 0x03) == 0x02) imm_arg = i - 1;
  jit_op * newop = jit_op_new(JIT_FMOV | 0x02, (((0x00) << 4) | ((0x02) << 2) | (0x03)), (jit_value) (jit_mkreg((1), (1), 0)), 0, 0, 0);
  newop->fp = 1;
  newop->flt_imm = op->flt_imm;
  jit_op_prepend(op, newop);
  op->code &= ~(0x3);
  op->code |= 0x01;
  op->spec &= ~(0x3 << (2 * imm_arg));
  op->spec |= (0x01 << (2 * imm_arg));
  op->arg[imm_arg] = (jit_mkreg((1), (1), 0));
 }
}
static inline void jit_expand_patches_and_labels(struct jit * jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PATCH) {
   ((jit_op *)(op->arg[0]))->jmp_addr = op;
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_LABEL) {
   ((jit_label *)(op->arg[0]))->op = op;
  }
  if ((((jit_opcode) (op->code & 0xfff8)) != JIT_LABEL) && (jit_is_label(jit, (void *)op->arg[0]))) {
   op->jmp_addr = ((jit_label *)(op->arg[0]))->op;
  }
  if ((((jit_opcode) (op->code & 0xfff8)) != JIT_LABEL) && (jit_is_label(jit, (void *)op->arg[1]))) {
   op->jmp_addr = ((jit_label *)(op->arg[1]))->op;
  }
 }
}
static inline void jit_prepare_reg_counts(struct jit * jit)
{
 int declared_args = 0;
 int last_gp = -1;
 int last_fp = -1;
 int gp_args = 0;
 int fp_args = 0;
 struct jit_func_info * info = NULL;
 jit_op * op = jit_op_first(jit->ops);
 while (1) {
  if (!op || (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG)) {
   if (info) {
    info->gp_reg_count = last_gp + 1;
    info->fp_reg_count = last_fp + 1;
    info->general_arg_cnt = gp_args;
    info->float_arg_cnt = fp_args;
    info->args = malloc(sizeof(struct jit_inp_arg) * declared_args);
   }
   if (op) {
    declared_args = 0;
    last_gp = -1;
    last_fp = -1;
    gp_args = 0;
    fp_args = 0;
    info = (struct jit_func_info *)op->arg[1];
   }
   if (!op) break;
  }
  for (int i = 0; i < 3; i++)
   if (((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x03) || ((((op)->spec >> ((i + 1) - 1) * 2) & 0x03) == 0x01)) {
    jit_reg r = JIT_REG(op->arg[i]);
    if ((r.type == (0)) && (r.id > last_gp)) last_gp = r.id;
    if ((r.type == (1)) && (r.id > last_fp)) last_fp = r.id;
   }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DECL_ARG) {
   declared_args++;
   if (op->arg[0] == JIT_FLOAT_NUM) fp_args++;
   else gp_args++;
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PREPARE) {
   jit_op * xop = op;
   while (1) {
    if (((jit_opcode) (op->next->code & 0xfff8)) == JIT_PUTARG) xop->arg[0]++;
    else if (((jit_opcode) (op->next->code & 0xfff8)) == JIT_FPUTARG) xop->arg[1]++;
    else {
     jit_opcode next_code = ((jit_opcode) (op->next->code & 0xfff8));
     if (next_code == JIT_CALL) break;
     if ((next_code != JIT_TRACE) && (next_code != JIT_CODE_ALIGN)
     && (next_code != JIT_UREG) && (next_code != JIT_LREG)
     && (next_code != JIT_RENAMEREG) && (next_code != JIT_SYNCREG))
     {
      printf("Garbage in the prepare-call block. Opcode: %x\n", next_code >> 3);
      abort();
     }
    }
    op = op->next;
   }
  }
  op = op->next;
 }
}
static inline void jit_prepare_arguments(struct jit * jit)
{
 jit_op * op = jit_op_first(jit->ops);
 struct jit_func_info * info = NULL;
 int gp_arg_pos = 0;
 int fp_arg_pos = 0;
 int argpos = 0;
 int phys_reg = 0;
 while (op) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG) {
   info = (struct jit_func_info *)op->arg[1];
   info->has_prolog = 1;
   gp_arg_pos = 0;
   fp_arg_pos = 0;
   argpos = 0;
   phys_reg = 0;
  }
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_DECL_ARG) {
   info->args[argpos].type = op->arg[0];
   info->args[argpos].size = op->arg[1];
   if (op->arg[0] == JIT_FLOAT_NUM) {
    info->args[argpos].gp_pos = gp_arg_pos;
    info->args[argpos].fp_pos = fp_arg_pos++;
   } else {
    info->args[argpos].gp_pos = gp_arg_pos++;
    info->args[argpos].fp_pos = fp_arg_pos;
   }
   jit_init_arg_params(jit, info, argpos, &phys_reg);
   argpos++;
  }
  op = op->next;
 }
}
static inline void jit_prepare_spills_on_jmpr_targets(struct jit *jit)
{
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next)
  if ((((jit_opcode) (op->code & 0xfff8)) == JIT_REF_CODE) || (((jit_opcode) (op->code & 0xfff8)) == JIT_DATA_REF_CODE)) {
   jit_op * newop = jit_op_new(JIT_FULL_SPILL | 0x02, (((0x00) << 4) | ((0x00) << 2) | (0x00)), 0, 0, 0, 0);
   jit_op_prepend(op->jmp_addr, newop);
  }
}
static inline void jit_buf_expand(struct jit * jit)
{
 long pos = jit->ip - jit->buf;
 jit->buf_capacity *= 2;
 jit->buf = realloc(jit->buf, jit->buf_capacity);
 jit->ip = jit->buf + pos;
}
void jit_generate_code(struct jit * jit)
{
 jit_expand_patches_and_labels(jit);
 jit_correct_long_imms(jit);
 jit_correct_float_imms(jit);
 jit_prepare_reg_counts(jit);
 jit_prepare_arguments(jit);
 jit_prepare_spills_on_jmpr_targets(jit);
 jit_dead_code_analysis(jit, 1);
 jit_flw_analysis(jit);
 if (jit->optimizations & (0x02)) jit_optimize_unused_assignments(jit);
 jit_collect_statistics(jit);
 jit_assign_regs(jit);
 jit->buf_capacity = (4096);
 jit->buf = malloc(jit->buf_capacity);
 jit->ip = jit->buf;
 for (struct jit_op * op = jit->ops; op != NULL; op = op->next) {
  if (jit->buf_capacity - (jit->ip - jit->buf) < (1024)) jit_buf_expand(jit);
  unsigned long offset_1 = (jit->ip - jit->buf);
  switch (((jit_opcode) (op->code & 0xfff8))) {
   case JIT_DATA_BYTE: *(jit->ip)++ = (unsigned char) op->arg[0]; break;
   case JIT_DATA_REF_CODE:
   case JIT_DATA_REF_DATA:
    op->patch_addr = ((jit_value)jit->ip - (jit_value)jit->buf);
    for (int i = 0; i < sizeof(void *); i++) {
     *jit->ip = 0;
     jit->ip++;
    }
    break;
   case JIT_FORCE_SPILL:
   case JIT_FORCE_ASSOC:
   case JIT_COMMENT:
    break;
   default: jit_gen_op(jit, op);
  }
  unsigned long offset_2 = (jit->ip - jit->buf);
  op->code_offset = offset_1;
  op->code_length = offset_2 - offset_1;
 }
 int code_size = jit->ip - jit->buf;
 void * mem;
 posix_memalign(&mem, sysconf(_SC_PAGE_SIZE), code_size);
 mprotect(mem, code_size, PROT_READ | PROT_EXEC | PROT_WRITE);
 memcpy(mem, jit->buf, code_size);
 free(jit->buf);
 long pos = jit->ip - jit->buf;
 jit->buf = mem;
 jit->ip = jit->buf + pos;
 jit_patch_external_calls(jit);
 jit_patch_local_addrs(jit);
 for (jit_op * op = jit_op_first(jit->ops); op != NULL; op = op->next) {
  if (((jit_opcode) (op->code & 0xfff8)) == JIT_PROLOG)
   *(void **)(op->arg[0]) = jit->buf + (long)op->patch_addr;
 }
}
void jit_trace(struct jit *jit, int verbosity)
{
 printf("jit_trace is not supported on this architecture\n");
}
static void jit_internal_free_ops(struct jit_op * op)
{
 if (op == NULL) return;
 jit_internal_free_ops(op->next);
 jit_free_op(op);
}
static void jit_internal_free_labels(jit_label * lab)
{
 if (lab == NULL) return;
 jit_internal_free_labels(lab->next);
 free(lab);
}
static int jit_internal_is_cond_branch_op(jit_op *op)
{
 jit_opcode code = ((jit_opcode) (op->code & 0xfff8));
 return (code == JIT_BLT) || (code == JIT_BLE) || (code == JIT_BGT)
 || (code == JIT_BGE) || (code == JIT_BEQ) || (code == JIT_BNE)
 || (code == JIT_FBLT) || (code == JIT_FBLE) || (code == JIT_FBGT)
 || (code == JIT_FBGE) || (code == JIT_FBEQ) || (code == JIT_FBNE)
 || (code == JIT_BOADD) || (code == JIT_BOSUB) || (code == JIT_BNOADD)
 || (code == JIT_BNOSUB);
}
void jit_enable_optimization(struct jit * jit, int opt)
{
 jit->optimizations |= opt;
}
void jit_disable_optimization(struct jit * jit, int opt)
{
 jit->optimizations &= ~opt;
}
void jit_free(struct jit * jit)
{
 jit_reg_allocator_free(jit->reg_al);
 jit_internal_free_ops(jit_op_first(jit->ops));
 jit_internal_free_labels(jit->labels);
 if (jit->buf) free(jit->buf);
 free(jit);
}
void jit_message(struct jit * j, char * s) {
  jit_add_op(j, JIT_MSG | 0x02, (((0x00) << 4) | ((0x00) << 2) | (0x02)), (jit_value)(s), 0, 0, 0, jit_debug_info_new("head.c", __func__, 19));
}
void jit_messager(struct jit * j, char * s, int i) {
  jit_add_op(j, JIT_MSG | 0x01, (((0x00) << 4) | ((0x01) << 2) | (0x02)), (jit_value)(s), (jit_mkreg((0), (0), (i))), 0, 0, jit_debug_info_new("head.c", __func__, 23));
}
