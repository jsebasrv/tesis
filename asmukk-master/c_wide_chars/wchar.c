#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <locale.h>
#include <wchar.h>

int main(void)
{
  setlocale(LC_ALL, "en_US.UTF-8");

  //Dynamic memory allocation for wide characters
  wchar_t * src;
  src = (wchar_t *) malloc(sizeof(wchar_t) * 2 + 1);// + 1 to accommodate for the null terminator
  src[0] = L'漢';
  src[1] = L'字';
  src[2] = '\0';

  wprintf(L"src=%ls has len=%d\n", src, wcslen(src));

  //Allocation of a fixed size string - The stablished size cannot change from here on.
  wchar_t dst[wcslen(src) + 1]; // + 1 to accommodate for the null terminator

  wcscpy(dst, src);
  wprintf(L"dst=%ls\n", dst);

  free(src);

  //Allocation of a fixed size string - The stablished size cannot change from here on.
  wchar_t *hiraganas = L"あいうえお";
  wprintf(L"hiraganas=%ls has len=%d\n", hiraganas,  wcslen(hiraganas));

  return 0;
}

/*
Código fuente de la implementación en C del algoritmo de Ukkonen: https://github.com/abeconnelly/asmukk

Cambiar el código C para realizar los siguientes ajustes:

1 - Admitir por linea de comando la inclusión opcional de un parámetro -f que, si está presente, requiere 2 nombres de archivos: <corpus1> y <corpus2>. Si el -f no está presente, el programa debe siguir recibiendo el par de cadenas a alinear vía linea de comando, como ya lo hace por defecto.

Ambos archivos obtenidos a partir del parámetro -f  deben ser de texto plano (.txt), codificados en utf-8, y con una oración o párrafo completo en cada fila. Ambos deben tener la misma cantidad de filas para poder realizar la alineación a nivel de fila. Si no tienen la misma cantidad de filas, se debe abortar la ejecución indicando el motivo.

El resultado de la alineación debe ser guardado en 2 archivos de mismo nombre que los archivos de entrada, pero con extensión .align en la misma carpeta.

Lea una fila de cada archivo de entrada y envíe el par de cadenas a la función alineadora del algoritmo. El resultado de la alineación se va almacenando en los respectivos archivos de salida .align. Repita el procedimiento hasta culminar la alineación e indique al usuario si el proceso culminó éxitosamente, informándole los nombres de los archivos de salida generados.



2 - Habilitar el programa para trabajar con codificación UTF-8.

En lugar de usar el tipo char, usar wchar_t. Realizar todas las transformaciones necesarias a lo largo de los códigos para cambiar a las funciones que trabajan con caracteres wide.
Se adjunta un código básico del uso de las librerías <locale.h> y <wchar.h> como ejemplo para iniciar.

Se debe garantizar a lo largo de todo el código de que cada caracter wide tenga tamaño (length) igual a 1 para que el algoritmo de Ukkonen funcione correctamente
con caracteres especiales (letras tildadas o caracteres de otros idiomas), considerando a cada uno como 1 unidad.

Enlaces para referencias al uso de la librería <wchar.h>.

https://en.cppreference.com/w/cpp/string/wide

https://www.ibm.com/docs/en/i/7.2?topic=lf-fwprintf-format-data-as-wide-characters-write-stream

https://stackoverflow.com/questions/54346259/cant-read-and-echo-back-unicode-input-in-c

https://newbedev.com/displaying-wide-chars-with-printf
*/
