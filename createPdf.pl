use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;


##Getting txt training data files 
my $source_file_trainig_data = './jp_corpus/Training_data';
##Getting txt test data files 
my $source_file_test_data = './jp_corpus/Test_data';
my $scripToGeneratePdfFromLatex = 'generatePdfFromLatex.sh';
##Path to save .tex training data files
my $destination_trainig_data_path = './LaTex-created_files/Training_data';
##Path to save .tex test data files
my $destination_test_data_path = './LaTex-created_files/Test_data';

##Funciton to create LaTex files from txt files
sub open_dir{
	my ($path) = ($_[0]);
	my ($dest_path) = ($_[1]);
	opendir(DIR, $path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		my $temp_filename = $file;
		print $temp_filename."\n";
		$file = $path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ..
	  if(-d $file){
			open_dir($file,my $hash);
		}else{
	   		print $file."\n";
			#open source file for reading
			open(SRC, '<', $file) or die $!;
		
			$temp_filename =~ s/\..*$/.tex/;
			print $temp_filename."*****************\n";
			my $temp_path = $dest_path."/".$temp_filename;
			print $temp_path."\n";
			#open source file for writing
			open(DES, '>', $temp_path) or die $!;
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
				  print DES $line[0]."\\\\";
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

##Calling functions to created from test and training data
open_dir($source_file_trainig_data,$destination_trainig_data_path);
open_dir($source_file_test_data, $destination_test_data_path);

