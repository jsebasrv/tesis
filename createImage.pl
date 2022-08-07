use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;
use open qw( :std :encoding(UTF-8) );

##Writing  .txt clean files 
my $source_file_training_data = './normalized_files/reference_files/Training_data';
my $source_file_test_data = './normalized_files/reference_files/Test_data';
##Path to save .tex data files
my $destination_trainig_data_latex_path = './LaTex_created_files/Training_data';
my $destination_test_data_latex_path = './LaTex_created_files/Test_data';
##Path to save .pdf training data files
my $destination_trainig_data_pdf_path = './pdf_created_files/Training_data';
my $destination_test_data_pdf_path = './pdf_created_files/Test_data';
##Path to save .pdf training data files
my $destination_trainig_data_images_path = './images/Training_data/';
my $destination_test_data_images_path = './images/Test_data/';

my $scripToGeneratePdfFromLatex = "./generatePdfFromLatex.sh";


sub init_process{
	#write_latex($_[0],$_[1]);
	#write_pdf($_[1],$_[2]);
	create_image($_[2],$_[3]);
}

##Funciton to create LaTex files from txt files
sub write_latex{
	my ($source_path) = ($_[0]);
	my ($dest_latex_path) = ($_[1]);
	
	print $source_path."\n";
	
	opendir(DIR, $source_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		##getting filename
		my $temp_filename = $file;
		##split file from extention
		my $regex = qr/\..*/mp;
		my $file_name = $temp_filename =~ s/$regex//rg;
		$file = $source_path.'/'.$file; #path absoluto del fichero o directorio
		#next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ...
		if( -d $file){
			open_dir($file,my $hash);
		} else{
			##printing file path from source (j_courpus) 
			print $file."\n";
			##Open files from source to read and reference to write
			open(SRC, '<', $file) or die $!;
			##setting name for LaTex files
			$temp_filename =~ s/\..*$/.tex/;
			my $temp_path = $dest_latex_path."/".$temp_filename;
			print $temp_path."\n";
			## Cleaning data
			## reading file line by line and matching with the REGEX
			## saving data into an array
			my $line;
			my $file_content = '';
			while (<SRC>) {
				$line = $_;
				
				next if ($line =~/^\s*$/);
				#my $newLine = latex_escape($line);
				$file_content.="${line}";
			}
			
			##awk -F "\t" '{print $2}' archivo_052_out.txt | sort | uniq | wc -l
			
			$file_content =~ s/$/\\\\/gm;
			
			$file_content =~ s/([\[])/\\lbrack /gm;
			$file_content =~ s/([\]])/\\rbrack /gm;
			
			
			#open LaTex file for writing
			open(DES, '>', $temp_path) or die $!;
			print("Copying content from source to destination file...\n");
			##Setting open and close commands in latex to generate latex file #\n\\usepackage[sfdefault]{noto}\n\\usepackage[T1]{fontenc}\n\\usepackage{hyperref}
			my $header_latex_file = "\\documentclass[10pt]{extreport}\n\\usepackage{pdflscape}\n\\renewcommand{\\baselinestretch}{2}\n\\usepackage{geometry}\n\\geometry{a4paper,left=08mm,top=10mm,right=08mm,bottom=10mm}\n\\usepackage{kotex}\n\\begin{document}\n\\setlength{\\parindent}{0cm}\n\\pagenumbering{gobble}\n";#\n\\begin{landscape}
			my $footer_latex_file = "\n\\end{document}\n\\clearpage\\end{CJK*}";#\\end{landscape}
			#Writing first lines into latex file
			print DES $header_latex_file;
		
			##$file_content =~ s/$regex/$1\n/g;
			print DES "$file_content";

			#writing last lines into latex file
			print DES $footer_latex_file;
			
			close(SRC);
			close(DES);
			print("Content copied successfully from source to destination file\n");
		}		
	}
	print "Already finished";
}

sub latex_escape {
  my $paragraph = shift;
  # Replace a \ with $\backslash$
  # This is made more complicated because the dollars will be escaped
  # by the subsequent replacement. Easiest to add \backslash
  # now and then add the dollars
  $paragraph =~ s/\\/\\backslash/g;
  # Must be done after escape of \ since this command adds latex escapes
  # Replace characters that can be escaped
  $paragraph =~ s/([\$\#&%_{}])/\\$1/g;
  # Replace ^ characters with \^{} so that $^F works okay
  $paragraph =~ s/(\^)/\\$1\{\}/g;
  # Replace tilde (~) with \texttt{\~{}}
  $paragraph =~ s/~/\\texttt\{\\~\{\}\}/g;
  # Now add the dollars around each \backslash
  $paragraph =~ s/(\\backslash)/\$$1\$/g;

  return $paragraph;
}

#function to write pdf from latex files
sub write_pdf{
	
	my ($source_latex_path) = ($_[0]);
	#my ($source_latex_path) = "./LaTex_created_files/test_data_issues/prueba";
	my ($dest_pdf_path) = ($_[1]);
	
	opendir(DIR, $source_latex_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		print $file."\n";
		$file = $source_latex_path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ...
		if( -d $file){
			open_dir($file,my $hash);
		} else{
	   	print $file."\n";
			
			print ("Creating Pdf files...\n");
			print $dest_pdf_path."\n";
			my $create_pdf_command = "pdflatex -output-directory='$dest_pdf_path' $file"; #
			print `$create_pdf_command`;
			print ("Pdf file created.\n");
			#delete files with .out .log .aux extension
			my $delete_other_files = "rm $dest_pdf_path/*.aux $dest_pdf_path/*.out $dest_pdf_path/*.log";
			print `$delete_other_files`;
		}
	}
	print "PDF create files process Already finished";
}

sub create_image{
	
	my ($source_pdf_path) = ($_[0]);
	my ($dest_images_path) = ($_[1]);
	print ("Creating image files...\n");
	
	opendir(DIR, $source_pdf_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		print $file."\n";
		my $file_name = $file =~ s/\..*//rg;
		
		$file = $source_pdf_path.'/'.$file; #path absoluto del fichero o directorio
		
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ..
		if( -d $file){
			open_dir($file,my $hash);
		} else{
	   	print $file."\n";
			
			my $directory = $dest_images_path.$file_name.'/';
			print "**************directory******************\n". $directory;
			
			my $create_images_command =
				"gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dJPEGQ=80 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r400x400 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=$directory$file_name%03d.jpg $file -c quit";
				
			unless(mkdir $directory) {
				print `$create_images_command`;
			} else{
				print `$create_images_command`;
			}
		}		
	}
	print "Images already created";
}

#Calling functions to created from test and training data
init_process($source_file_test_data, $destination_test_data_latex_path,$destination_test_data_pdf_path,$destination_test_data_images_path);
#init_process($source_file_trainig_data,$destination_trainig_data_latex_path,$destination_trainig_data_pdf_path,$destination_trainig_data_images_path,$des_file_trainig_data);