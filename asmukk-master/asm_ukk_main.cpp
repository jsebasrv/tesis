#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <wchar.h>
#include <string.h>
#include <locale.h>
#include <string>


extern "C" {
#include "asm_ukk.h"
}

void show_help(void) {
  printf("usage:\n");
  printf("  [-i inputfile]        Specify input file explicitely (instead of reading from stdin)\n");
  printf("  [-m mismatch_cost]    Cost of mismatched character (must be positive, default %d)\n", ASM_UKK_MISMATCH);
  printf("  [-g gap_cost]         Cost of gap (must be positive, default %d)\n", ASM_UKK_GAP);
  printf("  [-c gap_char]         Gap character (default '-')\n");
  printf("  [-T threshold]        Set threshold score.  Report -1 if threshold is exceeded\n");
  printf("  [-S]                  Do not print aligned sequence\n");
  printf("  [-h]                  Help (this screen)\n");
  printf("  [-f]                  Insert reference file and ocr file\n");
}

std::size_t read_string(FILE *fp, wchar_t* &s) {
  wint_t ch;

  while ((ch=fgetwc(fp))!=WEOF) {
    wprintf(L"wc = %ls\n", ch);
    if (ch=='}') { break; }
    else if(ch==']'){ break; }
    s += ch;
  }
  if ((ch==WEOF) && (errno!=0)) { return -1; }
  wprintf(L"The file contains %d characters.\n",wcslen(s));
  return wcslen(s);
}

int main(int argc, char **argv) {
  setlocale(LC_ALL, "en_US.UTF-8");
  int k;
  char ch;
  char *input_fn = NULL;
  
  for(int i=0;i<argc;i++){
    printf("argumento %d : %s \n",i, argv[i]);
  }
  
  wchar_t* a,*b;
  wchar_t *X, *Y;
  wchar_t *a_s, *b_s;
  char gap_char = '-';

  int print_align_sequence=1;
  int mismatch_cost=ASM_UKK_MISMATCH, gap_cost=ASM_UKK_GAP;
  int score=-1;
  int threshold = -1;

  FILE *ifp = stdin;
  char *reference_file = "";
  char files[2];

  while ((ch=getopt(argc, argv, "m:g:hSi:T"))!=-1) switch(ch) {
    case 'm':
      mismatch_cost = atoi(optarg);
      break;
    case 'i':
      printf("%s",optarg);
      input_fn = strdup(optarg);
      break;
    case 'g':
      gap_cost = atoi(optarg);
      break;
    case 'c':
      gap_char = optarg[0];
      break;
    case 'T':
      threshold = atoi(optarg);
      break;
    case 'S':
      print_align_sequence=0;
      break;
    case 'h':
    default:
      show_help();
      exit(0);
  }

  printf("first if");
  if ((!input_fn) && (isatty(fileno(stdin))>0)) {
    show_help();
    exit(0);
  }

  printf("second if");
  if (input_fn) {
    if ((ifp = fopen(input_fn, "r"))==NULL) {
      perror(input_fn);
      show_help();
      exit(errno);
    }
  }

  printf("third if");
  if ((mismatch_cost<0) || (gap_cost<0)) {
    fprintf(stderr, "Mismatch cost (-m) and gap cost (-g) must both be non-zero\n");
    show_help();
    exit(1);
  }
  
  printf("about to read file");
  k = read_string(ifp, a);
  if (k<0) { perror("error reading first string"); exit(1); }
  k = read_string(ifp, b);
  if (k<0) { perror("error reading second string"); exit(1); }

  a_s = (wchar_t *)(a);
  b_s = (wchar_t *)(b);

  if (threshold>0) {
    score = sa_align_ukk2(NULL, NULL, a_s, b_s, threshold, mismatch_cost, gap_cost, gap_char);
    printf("%d\n", score);
  } else {

    printf("Align Sequence: %d\n", print_align_sequence);
    if (print_align_sequence) {
      score = asm_ukk_align2(&X, &Y, a_s, b_s, mismatch_cost, gap_cost, gap_char);
      if (score>=0) {
        printf("Aqui: %d\n%s\n%s\n", score, X, Y);
      } else {
        printf("Aca: %d\n", score);
      }

      if (X) { free(X); }
      if (Y) { free(Y); }
    } else {
      score = asm_ukk_align2(NULL, NULL, a_s, b_s, mismatch_cost, gap_cost, gap_char);
      printf("%d\n", score);
    }
  }
  return 0;
}
