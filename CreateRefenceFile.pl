use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;
use open qw( :std :encoding(UTF-8) );


##Getting .txt data files 
my $source_file_trainig_data = './jp_corpus/Training_data';
my $source_file_test_data = './jp_corpus/Test_data';
##Writing  .txt clean files 
my $des_file_trainig_data = './referenceFiles/Training_data';
my $des_file_test_data = './referenceFiles/Test_data';


sub create_refence_file{
	my ($source_path) = ($_[0]);
	my ($dest_txt_path) = ($_[1]);
	
	opendir(DIR, $source_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		##getting filename
		my $temp_filename = $file;
		##split file from extention
		my $regex = qr/\..*/mp;
		my $subst = '';
		my $file_name = $temp_filename =~ s/$regex//rg;
		##setting name for reference files
		my $txt_file_clean = $dest_txt_path."/".$file_name.".ref";
		print $txt_file_clean."\n";
		print $file_name."\n";
		$file = $source_path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ...
		if( -d $file){
			open_dir($file,my $hash);
		} else{
			##printing file path from source (j_courpus) 
	   	print $file."\n";
			##Open files from source to read and reference to write
			open(SRC, '<', $file) or die $!;
			open(DEST, '>', $txt_file_clean) or die $!;
			## Cleaning data
			## reading file line by line and matching with the REGEX
			## saving data into an array
			my $line;
			my $file_content = '';
			while (<SRC>) {
				$line = $_;
				$line =~ s/^\w+\t|\s*$//gm;
				$line =~ s/[ 　]//gm;
				
				next if ($line =~/^\s*$/);
				
				$file_content.="$line\n";
			}
			
			##awk -F "\t" '{print $2}' archivo_052_out.txt | sort | uniq | wc -l
			
			my $regex = '^(.*)(\r?\n\1)+$';
			$file_content =~ s/$regex/$1/gm;
			$file_content =~ s/^\S{1}$//gm;
			
			my $clean_txt_file = $file_content;
			print DEST "$clean_txt_file";
			close(SRC);
			close(DEST);
			print("Content copied successfully from source to destination file\n");
		}		
	}
}

#Creating reference training data files
#create_refence_file($source_file_trainig_data,$des_file_trainig_data);
#Creating reference test data files
create_refence_file($source_file_test_data,$des_file_test_data);