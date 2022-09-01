use strict;
use warnings;
use Encode;
use utf8;
use Encode qw(decode encode);
use Text::Levenshtein::XS qw/distance/;
#use esyl::esylio;
#binmode(STDOUT, ":utf8");


if ($#ARGV < 0 )
	{die "Formato de uso: \n05-diff-ref_ocr.pl <ref_file_name> <ocr_file_name>\n";}

my $ref_file_name = $ARGV[0];
my $ocr_file_name = $ARGV[1];

main($ref_file_name, $ocr_file_name);

sub main{
  my ($ref_file_name, $ocr_file_name) = @_;
  
  unless (-e $ref_file_name){
    die "File $ref_file_name does not exit.\n";
  }
  unless (-e $ref_file_name){
    die "File $ocr_file_name does not exit.\n";
  }
  
  #my $diff_text = `wdiff $ref_file_name $ocr_file_name --no-common`;
	my $diff_text = `wdiff $ref_file_name $ocr_file_name`;
  $diff_text = Encode::decode("utf-8", $diff_text, Encode::FB_CROAK);
  $diff_text =~ s/[ \t]//g;#Normalization
  my ($idx, $ref, $ocr, $count_ref, $count_ocr) = 0;
	
	open(SRC, '<', $ref_file_name) or die $!;
	open(DEST, '>', "./rest_wdiff_files/Test_data/archivo_053.txt") or die $!;
  while ($diff_text =~ m/\[\-((?:(?!\{\+|=====).)*)\-\]\s*\{\+((?:(?!\[\-).)*)\+\}/gs){
    ($ref, $ocr) = ($1, $2);
    #if ($idx == 46){
    #  print "";
    #}
    $count_ocr = () = ($ocr =~ m/(\+\}(?:(?!\+\}).)*\{\+)/gs);
    if ($count_ocr > 0){
      $ocr =~ s/\+\}(?:(?!\{\+).)*\{\+/\n/gs;#Removes all text between +} and {+
    }
    
    $count_ref = () = ($ref =~ m/(\n)/gs);
    $count_ocr = () = ($ocr =~ m/(\n)/gs);

    if ($count_ref != $count_ocr){#First attempt to insert missing line breaks
      #if ($idx >= 46){
      #  print "";
      #  print $idx, "\t", distance($ref, $ocr), "\n";
      #  print ">$ref\n>$ocr\n\n";
      #}
      ($ref, $ocr) = smithwaterman($ref, $ocr);
    }
    
    $count_ref = () = ($ref =~ m/(\n)/gs);
    $count_ocr = () = ($ocr =~ m/(\n)/gs);
		print ">$count_ref\n>$count_ocr\n\n";
		
    if ($count_ref != $count_ocr){#
      print "$count_ref != $count_ocr\n";
      $idx++;
      print $idx, "\t", distance($ref, $ocr), "\n";
      print ">$ref\n>$ocr\n\n";
      next;#Gives up of the current block alignment.
    }
		print DEST "$ref\n$ocr\n";
    #print $idx, "\t", distance($ref, $ocr), "\n";
    #print ">$ref\n>$ocr\n\n";
    $idx++;
  }
	
	
	close(SRC);
	close(DEST);
  print "";
}

sub write_output_data{
	
	my ($source_path) = ($_[0]);
	my ($dest_txt_path) = ($_[1]);
	my ($data_ref) = ($_[2]);
	my ($data_ocr) = ($_[3]);
	
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
		my $txt_file_clean = $dest_txt_path."/".$file_name.".txt";
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
				print DEST "$data_ref"."\n".$data_ocr."\n";
				#print DEST "$data_ocr";
			}
			close(SRC);
			close(DEST);
			print("Content copied successfully from source to destination file\n");
		}		
	}
}


sub smithwaterman{
  my ($seq1, $seq2) = @_;
  
  # scoring scheme
  my $MATCH     =  1; # +1 for letters that match
  my $MISMATCH = -1; # -1 for letters that mismatch
  my $GAP       = -1; # -1 for any gap
  
  # initialization
  my @matrix;
  $matrix[0][0]{score}   = 0;
  $matrix[0][0]{pointer} = "none";
  for(my $j = 1; $j <= length($seq1); $j++) {
    $matrix[0][$j]{score}   = 0;
    $matrix[0][$j]{pointer} = "none";
  }
  for (my $i = 1; $i <= length($seq2); $i++) {
    $matrix[$i][0]{score}   = 0;
    $matrix[$i][0]{pointer} = "none";
  }
  
  # fill
  my $max_i     = 0;
  my $max_j     = 0;
  my $max_score = 0;
  
  
  for(my $i = 1; $i <= length($seq2); $i++) {
    for(my $j = 1; $j <= length($seq1); $j++) {
      my ($diagonal_score, $left_score, $up_score);
      
      # calculate match score
      my $letter1 = substr($seq1, $j-1, 1);
      my $letter2 = substr($seq2, $i-1, 1);      
      if ($letter1 eq $letter2) {
        $diagonal_score = $matrix[$i-1][$j-1]{score} + $MATCH;
      }else{
        $diagonal_score = $matrix[$i-1][$j-1]{score} + $MISMATCH;
      }
      
      # calculate gap scores
      $up_score   = $matrix[$i-1][$j]{score} + $GAP;
      $left_score = $matrix[$i][$j-1]{score} + $GAP;
      
      if ($diagonal_score <= 0 and $up_score <= 0 and $left_score <= 0) {
        $matrix[$i][$j]{score}   = 0;
        $matrix[$i][$j]{pointer} = "none";
        next; # terminate this iteration of the loop
      }
  
        
      # choose best score
      if ($diagonal_score >= $up_score) {
        if ($diagonal_score >= $left_score) {
          $matrix[$i][$j]{score}   = $diagonal_score;
          $matrix[$i][$j]{pointer} = "diagonal";
        }else{
          $matrix[$i][$j]{score}   = $left_score;
          $matrix[$i][$j]{pointer} = "left";
        }
      }else{
        if ($up_score >= $left_score) {
          $matrix[$i][$j]{score}   = $up_score;
          $matrix[$i][$j]{pointer} = "up";
        }else{
          $matrix[$i][$j]{score}   = $left_score;
          $matrix[$i][$j]{pointer} = "left";
        }
      }
        
      # set maximum score
      if ($matrix[$i][$j]{score} > $max_score) {
        $max_i     = $i;
        $max_j     = $j;
        $max_score = $matrix[$i][$j]{score};
      }
    }
  }
  
  # trace-back
 
  my $align1 = "";
  my $align2 = "";
 
  my $j = $max_j;
  my $i = $max_i;
  
  while (1) {
   last if $matrix[$i][$j]{pointer} eq "none";
   
   if ($matrix[$i][$j]{pointer} eq "diagonal") {
      $align1 .= substr($seq1, $j-1, 1);
      $align2 .= substr($seq2, $i-1, 1);
      $i--; $j--;
    }elsif ($matrix[$i][$j]{pointer} eq "left") {
      #print "'", substr($seq1, $j-1, 1), "'\n";
      $align1 .= substr($seq1, $j-1, 1);
      if (substr($seq1, $j-1, 1) eq "\n"){
        $align2 .= "\n";
      }else{
        #$align2 .= "-";
      }
      $j--;
    }elsif ($matrix[$i][$j]{pointer} eq "up") {
      #print "'", substr($seq2, $i-1, 1), "'\n";
      if (substr($seq2, $i-1, 1) eq "\n"){
        $align1 .= "\n";
      }else{
        #$align1 .= "-";
      }
      $align2 .= substr($seq2, $i-1, 1);
      $i--;
    }  
  }

  $align1 = reverse $align1;
  $align2 = reverse $align2;  
  return ($align1, $align2);
}