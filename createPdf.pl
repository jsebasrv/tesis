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
my $scripToGeneratePdfFromLatex = "./generatePdfFromLatex.sh";
##Path to save .tex training data files
my $destination_trainig_data_latex_path = './LaTex_created_files/Training_data';
##Path to save .tex test data files
my $destination_test_data_latex_path = './LaTex_created_files/Test_data';
##Path to save .pdf training data files
my $destination_trainig_data_pdf_path = './pdf_created_files/Training_data/';
##Path to save .pdf test data files
my $destination_test_data_pdf_path = './pdf_created_files/Test_data/';
##Path to save .pdf training data files
my $destination_trainig_data_images_path = './images/Training_data/';
##Path to save .pdf training data files
my $destination_test_data_images_path = './images/Test_data/';

##Funciton to create LaTex files from txt files
sub open_dir{
	my ($source_path) = ($_[0]);
	print $source_path."******************\n";
	my ($dest_latex_path) = ($_[1]);
	print $dest_latex_path."******************\n";
	my ($dest_pdf_path) = ($_[2]);
	print $dest_pdf_path."******************\n";
	my ($dest_images_path) = ($_[3]);
	print $dest_images_path."******************\n";
	opendir(DIR, $source_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		my $temp_filename = $file;
		my $regex = qr/\..*/mp;
		my $subst = '';
		my $file_name = $temp_filename =~ s/$regex/$subst/rg;
		print $file_name."\n";
		$file = $source_path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ..
	  if( -d $file){
			open_dir($file,my $hash);
		}else{
	   		print $file."\n";
        #open source file for reading
        open(SRC, '<', $file) or die $!;
    
        $temp_filename =~ s/\..*$/.tex/;
        my $temp_path = $dest_latex_path."/".$temp_filename;
		print $temp_path."\n";
        #open source file for writing
        open(DES, '>', $temp_path) or die $!;
        print("Copying content from source to destination file...\n");

        my @line;
        
        ##Setting open and close commands in latex to generate latex file
        my $header_latex_file = "\\documentclass[8pt]{extreport} \n\\usepackage{hyperref}\n\\usepackage{CJKutf8}\n\\begin{document}\n\\begin{CJK*}{UTF8}{min}\n";
        my $footer_latex_file = "\\clearpage\\end{CJK*}\n\\end{document}";
        
        #Writing first lines into latex file
        print DES $header_latex_file;
        
        ##reading file line by line and matching with the REGEX
        ## saving data into an array
        while(<SRC>){
           if(m/.+/mg){
				my $regex = qr/[^\W]+\t/mp;
				my $subst = '';
				$_=~s/$regex/ $subst/;
				
				my $reg = qr/$/mp;
				my $subs = '';
				
				my $result = $_ =~ s/$reg/$subs/r;
				my $newresult = $result; # . "\\\\"
				
				print DES $newresult;
           }
        }
        #writing last lines into latex file
        print DES $footer_latex_file;
        
        close(SRC);
        close(DES);
        
        print("Content copied successfully from source to destination file\n");
		
		print ("Creating Pdf files...\n");
		my $create_pdf_command = "pdflatex -output-directory='$dest_pdf_path' $temp_path";
		print `$create_pdf_command`;
		print ("Pdf file created.\n");
		
		print ("Creating image files...\n");
		
		my $directory = $dest_images_path.$file_name.'/';
		print "**************directory******************\n". $directory;
    
		unless(mkdir $directory) {
			die "Unable to create $directory\n";
		}
		
		my $create_images_command = "gs -dQuiet -dSAFER -dNOPROMT -dMaxBitmap=500000000 -dAlignToPixels=0 -dGridFitTT=2 -sDEVICE=jpeg -r300x300 -dNOPAUSE -dBATCH -sDEVICE=jpeg -dDEVICEHEIGHT=500 -dTextAlphaBits=4 -dGraphicsAlphaBits=4 -sOutputFile=$directory$file_name%03d.jpg $dest_pdf_path/$file_name.pdf -c quit";
		print `$create_images_command`;
		}		
	}
	print "Already finished";
}

##Calling functions to created from test and training data
open_dir($source_file_test_data, $destination_test_data_latex_path,$destination_test_data_pdf_path,$destination_test_data_images_path);
open_dir($source_file_trainig_data,$destination_trainig_data_latex_path,$destination_trainig_data_pdf_path,$destination_trainig_data_images_path);


#print `$scripToGeneratePdfFromLatex`;


