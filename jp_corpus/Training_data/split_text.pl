use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;
use open qw( :std :encoding(UTF-8) );

my $file_name = $ARGV[0];
#my $file_name = "./archivo_001_out.txt";

split_files($file_name);

sub split_files{
    my $count = 0;
    my ($file) = $_[0];
    
    print("Estoy aqui\n");
    
    open my $rfh,'<',$file or die "unable to open file : $! \n";
    
    my $filecount=0;
    my $wfh;
    while(<$rfh>){
        if(($.-1) % 8000 == 0){
               close($wfh) if($wfh);
               open($wfh, '>', sprintf("archivo_26_%03d_out.txt", ++$filecount)) or die $!;
            }
       print $wfh "$_";
    }
    close($rfh);
}