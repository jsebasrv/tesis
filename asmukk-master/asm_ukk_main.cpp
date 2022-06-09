#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <wchar.h>
#include <string.h>
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

int read_string(FILE *fp, std::string &s) {
  char ch;

  while ((ch=fgetc(fp))!=EOF) {
    if (ch=='\n') { break; }
    s += ch;
  }
  if ((ch==EOF) && (errno!=0)) { return -1; }

  return s.length();
}

void recive_files(char argumento[]){
  char delimitador[] = " ";
  int i=0;
  char *token = strtok(argumento, delimitador);
  char *files[2];
  if(token != NULL){
      while(token != NULL){
          // Sólo en la primera pasamos la cadena; en las siguientes pasamos NULL
          printf("Token: %s\n", token);
          files[i] = token;
          printf("este es el numero de iterador: %d y el file %s\n",i,files[i]);
          token = strtok(NULL, delimitador);
          i++;
      }
  }
  
  printf("Proceso de lectura de archivos linea a linea \n");
  FILE *archivo_original = fopen(files[0], "r"); // Modo lectura
  char bufer_original[1000];         // Aquí vamos a ir almacenando cada línea
  
  FILE *archivo_ocr = fopen(files[1], "r"); // Modo lectura
  char bufer_ocr[1000];         // Aquí vamos a ir almacenando cada línea
  
  if(archivo_original == NULL){
    printf("El archivo original no puede abrirse.");
    exit(1);
  }
  
  //sacar el numero de lineas de ambos archivos
  //un if para validar que tengan la misma cantidad de lineas
  
  //Leer linea a linea los archivos
  while (fgets(bufer_original, 1000, archivo_original))
  {
      // Aquí, justo ahora, tenemos ya la línea. Le vamos a remover el salto
      strtok(bufer_original, "\n");
      // La imprimimos, pero realmente podríamos hacer cualquier otra cosa
      printf("La línea es: '%s'\n", bufer_original);
        k = read_string(bufer_original, a);
        if (k<0) { perror("error reading first string"); exit(1); }
      
        //a_s = (wchar_t *)(a.c_str());
        //b_s = (wchar_t *)(b.c_str());
  }
  
  if(archivo_ocr == NULL){
    printf("El archivo  ocr no puede abrirse.");
    exit(1);
  }
  
  while (fgets(bufer_ocr, 1000, archivo_ocr))
  {
      // Aquí, justo ahora, tenemos ya la línea. Le vamos a remover el salto
      strtok(bufer_ocr, "\n");
      // La imprimimos, pero realmente podríamos hacer cualquier otra cosa
      printf("La línea es: '%s'\n", bufer_ocr);
      
      /*k = read_string(bufer_ocr, b);
      if (k<0) { perror("error reading second string"); exit(1); }
      //b_s = (wchar_t *)(b.c_str());*/
  }
  
  fclose(archivo_original);
  fclose(archivo_ocr);
  //sino mando un error
  //return 0;
}


int main(int argc, char **argv) {
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

  while ((ch=getopt(argc, argv, "m:f:g:hSi:T"))!=-1) switch(ch) {
    case 'm':
      mismatch_cost = atoi(optarg);
      break;
    case 'i':
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
    case 'f':
      reference_file = optarg;
      recive_files(reference_file);
      break;
    case 'h':
    default:
      show_help();
      exit(0);
  }

  if ((!input_fn) && (isatty(fileno(stdin))>0)) {
    show_help();
    exit(0);
  }

  if (input_fn) {
    if ((ifp = fopen(input_fn, "r"))==NULL) {
      perror(input_fn);
      show_help();
      exit(errno);
    }
  }

  if ((mismatch_cost<0) || (gap_cost<0)) {
    fprintf(stderr, "Mismatch cost (-m) and gap cost (-g) must both be non-zero\n");
    show_help();
    exit(1);
  }

  k = read_string(ifp, a);
  if (k<0) { perror("error reading first string"); exit(1); }
  k = read_string(ifp, b);
  if (k<0) { perror("error reading second string"); exit(1); }

  a_s = (wchar_t *)(a.c_str());
  b_s = (wchar_t *)(b.c_str());

  if (threshold>0) {
    score = sa_align_ukk2(NULL, NULL, a_s, b_s, threshold, mismatch_cost, gap_cost, gap_char);
    printf("%d\n", score);
  } else {

    if (print_align_sequence) {
      score = asm_ukk_align2(&X, &Y, a_s, b_s, mismatch_cost, gap_cost, gap_char);
      if (score>=0) {
        printf("%d\n%s\n%s\n", score, X, Y);
      } else {
        printf("%d\n", score);
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
