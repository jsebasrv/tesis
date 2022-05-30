#ifndef ASM_UKK_H
#define ASM_UKK_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>

#define ASM_UKK_MISMATCH 3
#define ASM_UKK_GAP 2

int asm_ukk_score(wchar_t *, wchar_t *);
int asm_ukk_score2(wchar_t *, wchar_t *, int, int);
int asm_ukk_score3(wchar_t *a, wchar_t *b, int (*score_func)(wchar_t,wchar_t));

int asm_ukk_align(wchar_t **, wchar_t **, wchar_t *, wchar_t *);
int asm_ukk_align2(wchar_t **X, wchar_t **Y, wchar_t *a, wchar_t *b, int mismatch, int gap, wchar_t gap_char);
int asm_ukk_align3(wchar_t **X, wchar_t **Y, wchar_t *a, wchar_t *b, int (*score_func)(wchar_t, wchar_t), wchar_t gap_char);


int sa_align_ukk(wchar_t **, wchar_t **, wchar_t *, wchar_t *, int);
int sa_align_ukk2(wchar_t **, wchar_t **, wchar_t *, wchar_t *, int, int, int, wchar_t);
int sa_align_ukk3(wchar_t **X, wchar_t **Y, wchar_t *a, wchar_t *b, int threshold, int (*score_func)(wchar_t, wchar_t), wchar_t gap_char);

#endif
