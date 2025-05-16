#ifndef DEF_H
#define DEF_H

#define T_EXIT         256
#define T_EOF          257
#define T_IF           258
#define T_THEN         259
#define T_ELSE_IF      260
#define T_ELSE         261
#define T_END_IF       262
#define T_SWITCH       263
#define T_SELECT       264
#define T_CASE         265
#define T_END_CASE     266
#define T_BREAK        267
#define T_DEFAULT      268
#define T_END_SWITCH   269
#define T_WHILE        270
#define T_LOOP         271
#define T_END_WHILE    272
#define T_DO           273

#define T_NUM          300
#define T_ID           301

#define T_EQ           310
#define T_GT           311
#define T_LT           312
#define T_GTE          313
#define T_LTE          314
#define T_NEQ          315
#define T_NGT          316
#define T_NLT          317
#define T_TB           318 // Toggle boolean

#define T_RELOP        319

// I declare that every error will be in range [500-599] until I need more!
#define T_ERROR        500
#define T_INV_ID_ERROR 501

#endif