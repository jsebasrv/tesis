use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;


##Getting txt file 
my $source_file = '/home/ubuntu/Desktop/Trabajo-de-Titulacion/jp_corpus/Training_data/archivo_(3)_out.txt';
my $destination_file = '/home/ubuntu/Desktop/Trabajo-de-Titulacion/pdf-created/prueba.tex';
my $scripToGeneratePdfFromLatex = '/home/ubuntu/Desktop/Trabajo-de-Titulacion/pdf-created/generatePdfFromLatex.sh';

my $destination_path = '/home/ubuntu/Desktop/Trabajo-de-Titulacion/pdf-created/';

q{
#open source file for reading
open(SRC, '<', $source_file) or die $!;

#open source file for writing
open(DES, '>', $destination_file) or die $!;


print("Copying content from source to destination file...\n");

my @line;

##Setting open and close commands in latex to generate latex file
my $header_latex_file = "\\documentclass{article} \n\\usepackage{hyperref}\n\\usepackage{CJKutf8}\n\\begin{document}\n\\begin{CJK}{UTF8}{min}\n";
my $footer_latex_file = "\\end{CJK}\n\\end{document}";

#Writing first lines into latex file
print DES $header_latex_file;

##reading file line by line and matching with the REGEX
## saving data into an array
while(<SRC>){
   if(m/\t.*/){
      @line=$_=~m/\t.*/gm;
      print DES "\\\\".$line[0];
   }
}


#writing last lines into latex file
print DES $footer_latex_file;

close(SRC);
close(DES);

print("Content copied successfully from source to destination file\n");

#print `$scripToGeneratePdfFromLatex`;

};

##Reading directory

sub open_dir{
	my ($path) = ($_[0]);
	opendir(DIR, $path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		$file = $path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ..
	  if( -d $file){
			open_dir($file,my $hash);
		}else{
	   		print $file."\n";
        #open source file for reading
        open(SRC, '<', $file) or die $!;
    
        $file =~ s/\..*$/.tex/;
        $destination_file = $file;
		print $destination_file."\n";
        #open source file for writing
        open(DES, '>', $destination_file) or die $!;
        print("Copying content from source to destination file...\n");

        my @line;
        
        ##Setting open and close commands in latex to generate latex file
        my $header_latex_file = "\\documentclass[8pt]{extreport} \n\\usepackage{hyperref}\n\\usepackage{CJKutf8}\n\\begin{document}\n\\begin{CJK}{UTF8}{min}\n";
        my $footer_latex_file = "\\end{CJK}\n\\end{document}";
        
        #Writing first lines into latex file
        print DES $header_latex_file;
        
        ##reading file line by line and matching with the REGEX
        ## saving data into an array
        while(<SRC>){
           if(m/\t.*/){
              @line=$_=~m/\t.*/gm;
              print DES "\\\\".$line[0];
           }
        }
        
        
        #writing last lines into latex file
        print DES $footer_latex_file;
        
        close(SRC);
        close(DES);
        
        print("Content copied successfully from source to destination file\n");
        
		}		
	}
}

open_dir('/home/ubuntu/Desktop/Trabajo-de-Titulacion/jp_corpus/Training_data');

