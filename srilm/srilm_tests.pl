use strict;
use warnings;
use utf8;
use srilm;
use 5.010;

#Comandos de entrenamiento del modelo de lenguaje.
#ngram-count -text corpus.txt -write-vocab corpus.vocab
#ngram-count -order 2 -text corpus.txt  -write corpus.count
#ngram-count -read corpus.count -order 2 -lm corpus.lm -addsmooth 0


#Loading transition model
my $lm = srilm::initLM(5);

my $lm_file_name = "corpus.lm";

srilm::readLM($lm, $lm_file_name);

my $consulta = "en esta Línea calle acompana altura";

my $log_prob = srilm::getNgramProb($lm, $consulta, 6);

print $log_prob,"\n";

print "P($consulta)=" . (10**$log_prob), "\n";

#Ejercicio: Desarrollar un programa que recibe palabras iniciales de una
#oración y prediga las probabilidades de las palabras siguientes.
#Mostrar el listado de palabras más probables al inicio junto con sus respectivas probabilidades.
#Considere el caso del input que se realiza en el Google.
#Probar el modelo de lenguaje generado con bigramas y trigramas.
#bigramas: se toma como contexto solo la palabra anterior.
#trigramas: se toma como contexto las 2 palabras anteriores.
#Revisar las diapositivas de las clases anteriores para entender cómo calcular la probabilidad
#de la secuencia de palabras anteriores en una oración usando modelos estocásticos.

#Arreglos asociativos (Hash)

my %bigram_dict = ();
my %trigram_dict = ();
open(FH, '<', $lm_file_name) or die $!;
    
    
while(<FH>){
  chomp;
  my $line = $_;
  
  if ($line =~ /^-?\d(?:\.\d+)?\t([a-zA-Z<>]+) ([a-zA-Z<\/>]+)$/gm){  #^-?\d(?:\.\d+)?\t([a-zA-Z<>]+ [a-zA-Z<\/>]+)(\t-?\d(?:\.\d+)?)?$  Estoy es para cuando tengo los numeros
    my $palabra1 = $1;
    my $palabra2 = $2;
    $bigram_dict{$palabra1}->{$palabra2} = 0;
  }elsif($line =~ /^-?\d(?:\.\d+)?\t([a-zA-Z<>]+) ([a-zA-Z]+) ([a-zA-Z<\/>]+)$/gm){  #^-?\d(?:\.\d+)?\t([a-zA-Z<>]+ [a-zA-Z<\/>]+)(\t-?\d(?:\.\d+)?)?$  Estoy es para cuando tengo los numeros
    my $palabra1 = $1;
    my $palabra2 = $2;
    my $palabra3 = $3;
    $trigram_dict{$palabra1.' '.$palabra2}->{$palabra3} = 0;
  }
  
}
close(FH);

print "Ingrese una cadena de entrada:";

my $ingreso = <>;
$ingreso =~ s/\n//;
print $ingreso, "\n";
my %porcentajes=();

if (exists $bigram_dict{$ingreso}){
  for my $palabra_siguiente (keys %{$bigram_dict{$ingreso}}){
    $log_prob = srilm::getNgramProb($lm, "$ingreso $palabra_siguiente", 2);
    print "P($palabra_siguiente|$ingreso)=" . (10**$log_prob), "\n";
    $porcentajes{$palabra_siguiente} = 10**$log_prob;
  }
}elsif(exists $trigram_dict{$ingreso}){
  for my $palabra_siguiente (keys %{$trigram_dict{$ingreso}}){
    $log_prob = srilm::getNgramProb($lm, "$ingreso $palabra_siguiente", 3);
    print "P($palabra_siguiente|$ingreso)=" . (10**$log_prob), "\n";
    $porcentajes{$palabra_siguiente} = 10**$log_prob;
  }
}

foreach my $k (reverse sort { $porcentajes{$a} <=> $porcentajes{$b} } keys %porcentajes) {
    printf "%-8s %s\n", $k, $porcentajes{$k};
}


print "";
