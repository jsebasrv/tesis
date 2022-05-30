/* fgetwc example */
#include <stdio.h>
#include <wchar.h>
#include <stdlib.h>
#include <locale.h>
#include <string.h>
int main (int arc, char **argv)
{
  setlocale(LC_ALL, "en_US.UTF-8");
  FILE * fin;
  FILE * fout;
  wint_t wc;
  wchar_t string[100] = L"日本";
  wchar_t string2[100];

  mbstowcs (string2, argv[1], strlen(argv[1])+1);
  wprintf(L"Argument[1]=%ls: length: %d\n", string2, wcslen(string2));

  fin=fopen ("in.txt","r");
  fout=fopen("out.txt","w");
  while((wc=fgetwc(fin))!=WEOF){
        //fprintf(fout, "%d", wc);//Prints numbers to the file
        fputwc( wc, fout);//Prints the utf8 string to the file
        //wprintf(L"%ls",L"日本語");//Prints utf string to stdio
         wprintf(L"%C",wc);
        // work with: "wc"
  }
  fclose(fin);
  fclose(fout);
  printf("File has been created...\n");

//
    //setlocale(LC_ALL, "");
    wprintf (L"Enter a string to replace %ls: ",string);
    scanf("%ls",string);

    wprintf(L"String Entered: %ls: length: %d\n", string, wcslen(string));

  return 0;
}

/*

https://pubs.opengroup.org/onlinepubs/7908799/xshix.html
https://www.unix.com/man-page/opensolaris/3head/wchar.h/

strlen	wcslen
strcpy	wcscpy
strncpy	wcsncpy
printf	wprintf
isupper(char)	iswupper(wint_t wc)
tolower(char)	towlower(wint_t wc)
int isalpha(char)	int iswalpha(wint_t wc);
fprintf(f stream, char *)	fwprintf(fstream, wchar_t)  

https://www.gnu.org/software/libc/manual/html_node/Converting-Strings.html
mbstowcs (Pattern_wc, Pattern, strlen(Pattern)+1);
*/
