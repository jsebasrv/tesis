use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;


##Getting .txt data files 
my $source_file_trainig_data = './jp_corpus/Training_data';
my $source_file_test_data = './jp_corpus/Test_data';
##Writing  .txt clean files 
my $des_file_trainig_data = './txts/Training_data';
my $des_file_test_data = './txts/Test_data';
##Path to save .tex data files
my $destination_trainig_data_latex_path = './LaTex_created_files/Training_data';
my $destination_test_data_latex_path = './LaTex_created_files/Test_data';
##Path to save .pdf training data files
my $destination_trainig_data_pdf_path = './pdf_created_files/Training_data/';
my $destination_test_data_pdf_path = './pdf_created_files/Test_data/';
##Path to save .pdf training data files
my $destination_trainig_data_images_path = './images/Training_data/';
my $destination_test_data_images_path = './images/Test_data/';

my $scripToGeneratePdfFromLatex = "./generatePdfFromLatex.sh";


sub init_process{
	write_latex($_[0],$_[1],$_[4]);
	#write_pdf($_[1],$_[2]);
	#create_image($_[2],$_[3]);
}
##Funciton to create LaTex files from txt files
sub write_latex{
	my ($source_path) = ($_[0]);
	my ($dest_latex_path) = ($_[1]);
	my ($dest_txt_path) = ($_[2]);
	
	opendir(DIR, $source_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		my $temp_filename = $file;
		my $txt_file_clean = $dest_txt_path."/".$file;
		print $txt_file_clean."\n";
		my $regex = qr/\..*/mp;
		my $subst = '';
		my $file_name = $temp_filename =~ s/$regex/$subst/rg;
		print $file_name."\n";
		$file = $source_path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ...
		if( -d $file){
			open_dir($file,my $hash);
		} else{
	   	print $file."\n";
			open(SRC, '<', $file) or die $!;
			
			
			open(DEST, '>', $txt_file_clean) or die $!;
		
			$temp_filename =~ s/\..*$/.tex/;
			my $temp_path = $dest_latex_path."/".$temp_filename;
			print $temp_path."\n";
			#open source file for writing
			open(DES, '>', $temp_path) or die $!;
			print("Copying content from source to destination file...\n");
			##Setting open and close commands in latex to generate latex file
			my $header_latex_file = "\\documentclass[8pt]{extreport} \n\\usepackage{hyperref}\n\\usepackage{CJKutf8}\n\\begin{document}\n\\setlength{\\parindent}{0px}\n\\pagenumbering{gobble}\n\\begin{CJK*}{UTF8}{min}\n";
			my $footer_latex_file = "\\clearpage\\end{CJK*}\n\\end{document}";
			#Writing first lines into latex file
			print DES $header_latex_file;
			
			##reading file line by line and matching with the REGEX
			## saving data into an array
			
			my $line;
			my $file_content = '';
			while (<SRC>) {
				$line = $_;
				$line =~ s/^\w+\t|\s*$//g;
				$line =~ s/ //gm;
				
				next if ($line =~/^\s*$/);
				my $newLine = latex_escape($line);
				
				$file_content.="${newLine}\\\\\n";
				#print DES "$newLine\\\\\n";
			}
			
			my $regex = qr/^(.*)$((?:\r?\n.*)*?)^(\1)$(\r?)\n?/mp;
			if ($file_content =~ /$regex/g) {
        $file_content =~ s/$regex/$1$2/g;
      }
			
			$file_content =~ s/$regex/$1\n/g;
			my $clean_txt_file =$file_content;
			$clean_txt_file =~ s/\\\\/''/mg;
			print DEST "$clean_txt_file";
			print DES "$file_content";
			#writing last lines into latex file
			print DES $footer_latex_file;
			close(SRC);
			close(DES);
			close(DEST);
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
  
  $paragraph =~ s/([\[])/{[}/g;
  $paragraph =~ s/([\]])/{]}/g;
	$paragraph =~ tr/①②③④⑤⑥⑦⑧⑨/123456789/;
	$paragraph =~ s/⑩/10/;
	$paragraph =~ s/⑪/11/;
	$paragraph =~ s/⑫/12/;
	$paragraph =~ s/⑬/13/;
	$paragraph =~ s/⑭/14/;
	$paragraph =~ s/⑮/15/;
	$paragraph =~ s/⑯/16/;
	$paragraph =~ s/⑰/17/;
	$paragraph =~ s/⑱/18/;
	$paragraph =~ s/⑲/19/;

  return $paragraph;
}

#function to write pdf from latex files
sub write_pdf{
	
	my ($source_latex_path) = ($_[0]);
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
			my $create_pdf_command = "pdflatex -output-directory='$dest_pdf_path' $file";
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
				"gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=$directory$file_name%03d.jpg $file -c quit";
				
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
init_process($source_file_test_data, $destination_test_data_latex_path,$destination_test_data_pdf_path,$destination_test_data_images_path,$des_file_test_data);
init_process($source_file_trainig_data,$destination_trainig_data_latex_path,$destination_trainig_data_pdf_path,$destination_trainig_data_images_path,$des_file_trainig_data);