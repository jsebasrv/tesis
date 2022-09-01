#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <wchar.h>
#include <locale.h>
#include <string>
#include <codecvt>


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


std::wstring to_wide (const std::string &multi) {
  return std::wstring_convert<codecvt_<wchar_t, char, mbstate_t>> {}
      .from_bytes (multi);
}
  
std::size_t read_string(FILE *fp, std::string &s) {
  wint_t ch;
  
  std::wstring cha = to_wide(s);
  
  const wchar_t* result = cha.c_str();

  result = (wchar_t *) malloc(sizeof(wchar_t) * 2 + 1);
  int i=0;
  
  if (NULL == (fp = fopen("pruebaUkkn.txt", "r"))) {         
      printf("Unable to open: \"pruebaUkkn.txt\"\n");             
      exit(1);                                                
  }
  
  errno = 0;                                                 
  while (WEOF != (ch = fgetwc(fp))){
    if (EILSEQ == errno) {                                     
       printf("An invalid wide character was encountered.\n"); 
       exit(1);                                                
    }
    result+= ch;
  }
  wprintf(L"%ls len=%d\n", result, sizeof(s));

  fclose(fp);                                            
  return ch;
  
  /*wprintf(L"%ls and len is: %d\n", s, sizeof(s)); 
  
  if ((ch==WEOF) && (errno!=0)) { return -1; }
  return sizeof(s);*/
}

int main(int argc, char **argv) {
  setlocale(LC_ALL, "");
  int k;
  char ch;
  char *input_fn = NULL;
  
  for(int i=0;i<argc;i++){
    printf("argumento %d : %s \n",i, argv[i]);
  }
  
  std::string a, b;
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
      printf("Estoy entrando aqui\n");
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

  printf("first if\n");
  if ((!input_fn) && (isatty(fileno(stdin))>0)) {
    show_help();
    exit(0);
  }

  printf("second if\n");
  if (input_fn) {
    if ((ifp = fopen(input_fn, "r"))==NULL) {
      perror(input_fn);
      show_help();
      exit(errno);
    }
  }

  printf("third if\n");
  if ((mismatch_cost<0) || (gap_cost<0)) {
    fprintf(stderr, "Mismatch cost (-m) and gap cost (-g) must both be non-zero\n");
    show_help();
    exit(1);
  }
  
  printf("about to read file\n");
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
