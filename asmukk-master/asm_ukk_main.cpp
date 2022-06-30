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
  wchar_t ch;

  while ((ch=fgetc(fp))!=EOF) {
    if (ch=='\n') { break; }
    s += ch;
  }
  /*setlocale(LC_ALL, "ja_JP.UTF8");
  printf("Estoy aqui: %lc\n", s);*/
  if ((ch==EOF) && (errno!=0)) { return -1; }
  return s.length();
}

void exec_algorithm(FILE *fp, FILE *fp2, std::string &s, std::string &s1, int k, int print_align_sequence, wchar_t* &a_s, wchar_t* &b_s, wchar_t *X, wchar_t *Y, char gap_char,
                    int mismatch_cost, int gap_cost,int score, int threshold ){
  k = read_string(fp, s);
  if (k<0) { perror("error reading first string"); exit(1); }
  k = read_string(fp2, s1);
  if (k<0) { perror("error reading second string"); exit(1); }

  a_s = (wchar_t *)(s.c_str());
  b_s = (wchar_t *)(s1.c_str());

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
}


void recive_files(char argumento[],std::string &s, std::string &s1, int k, int print_align_sequence, wchar_t* &a_s, wchar_t* &b_s, wchar_t *X, wchar_t *Y, char gap_char,
                    int mismatch_cost, int gap_cost,int score, int threshold ){
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
  char bufer_original[300];         // Aquí vamos a ir almacenando cada línea
  
  FILE *archivo_ocr = fopen(files[1], "r"); // Modo lectura
  char bufer_ocr[300];         // Aquí vamos a ir almacenando cada línea
  int count_lines_reference_file = 0;
  int count_lines_ocr_file = 0;
  
  //check if files are null
  if(archivo_original == NULL || archivo_ocr == NULL){
    printf("El archivo original o el archivo OCR no pueden abrirse.");
    exit(1);
  }
  
  /*if(archivo_ocr == NULL){
    printf("El archivo  ocr no puede abrirse.");
    exit(1);
  }*/
  char *n1,*n2;
  while(1){
    n1=fgets(bufer_original,sizeof(bufer_original),archivo_original);
    n2=fgets(bufer_ocr,sizeof(bufer_original),archivo_ocr);
    printf("N1: %d\nN2: %d\n",strlen(n1),strlen(n2));
    //printf("N2: %d\n",strlen(n2));
    /*if((n1==NULL)||(n2==NULL))
    {
        break;
    }*/
    printf("%s\n%s\n",bufer_original,bufer_ocr);
    exec_algorithm(archivo_original,archivo_ocr,s,s1,k,print_align_sequence,a_s,b_s,X,Y,gap_char,mismatch_cost,gap_cost,score,threshold);
  }
  /*
  //Read files line by line
  while (fgets(bufer_original, 300, archivo_original))
  {
    count_lines_reference_file += 1;
    // Aquí, justo ahora, tenemos ya la línea. Le vamos a remover el salto
    strtok(bufer_original, "\n");
    // La imprimimos, pero realmente podríamos hacer cualquier otra cosa
    //printf("'%d' '%s'\n",count_lines_reference_file bufer_original);
    k = sizeof(bufer_original);
    printf("el valor de la cadena es: %d\n",k);
    if (k<0) { perror("error reading first string"); exit(1); }
  }
  
  while (fgets(bufer_ocr, 300, archivo_ocr))
  {
    count_lines_ocr_file += 1;
    // Aquí, justo ahora, tenemos ya la línea. Le vamos a remover el salto
    strtok(bufer_ocr, "\n");
    // La imprimimos, pero realmente podríamos hacer cualquier otra cosa
    printf("La línea es: '%s'\n", bufer_ocr);
  }
    //sacar el numero de lineas de ambos archivos
  //un if para validar que tengan la misma cantidad de lineas
  */
  
  fclose(archivo_original);
  fclose(archivo_ocr);
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
      recive_files(reference_file,a,b,k,print_align_sequence,a_s,b_s,X,Y,gap_char,mismatch_cost,gap_cost,score,threshold);
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
   //execution of align algorithm
  exec_algorithm(ifp,ifp,a,b,k,print_align_sequence,a_s,b_s,X,Y,gap_char,mismatch_cost,gap_cost,score,threshold);
  return 0;
}
