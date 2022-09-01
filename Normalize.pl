#!/user/bin/perl
use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;
use open qw( :std :encoding(UTF-8) );

##！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？
#@＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿
#｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～
#｟｠｡｢｣､･ｦｧｨｩｪｫｬｭｮｯｰｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝﾞ
#、。〃〄々〆〇〈〉《》〒〓〔〕〖〗〘〙〚〛〜〝〞〟〠〡〢〣〤〥〦〧〨〩〪〭〮〯〫〬〰〱〲〳〴〵〶〷〸〹〺〻〼〽〾〿
#「」『』【】[]

##source data
my $source_data_reference_test_path = "./referenceFiles/Test_data";
my $source_data_reference_training_path = "./referenceFiles/Training_data";
my $source_data_ocr_test_path = "/home/srueda/tesis/OCRs/Test_data";
my $source_data_ocr_training_path = "/home/srueda/tesis/OCRs/Training_data";
##destination data
my $dest_data_reference_test_path = "./normalized_files/reference_files/Test_data";
my $dest_data_reference_training_path = "./normalized_files/reference_files/Training_data";
my $dest_data_ocr_test_path = "./normalized_files/ocr_files/Test_data";
my $dest_data_ocr_training_path = "./normalized_files/ocr_files/Training_data";
 
 
 #function to normalize data
sub normalize_data{
    
    my $data = $_[0];
    
    #Double Quotes
    $data =~ s/["〝〞ﾞ«»”]/"/gm;
    #Apostrofes
    $data =~ s/[`]/'/gm;
    #virgulilla
    $data =~ s/[~～〜]/〜/gm;
    #virgulilla
    $data =~ s/[,、，]/，/gm;
    #Numbers
    $data =~ tr/0123456789/０１２３４５６７８９/;
    $data =~ tr/①②③④⑤⑥⑦⑧⑨/１２３４５６７８９/;
    
    $data =~ s/⑩/１０/gm;
    $data =~ s/⑩/１１/gm;
    $data =~ s/⑩/１２/gm;
    $data =~ s/⑩/１３/gm;
    $data =~ s/⑩/１４/gm;
    $data =~ s/⑩/１５/gm;
    $data =~ s/⑩/１６/gm;
    $data =~ s/⑩/１７/gm;
    $data =~ s/⑩/１８/gm;
    $data =~ s/⑩/１９/gm;
    
    #Mayus letters
    $data =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ/ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/;
    #Minor letters
    $data =~ tr/abcdefghijklmnopqrstuvwxyz/ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ/;
    #special Chars
    $data =~ tr/#\$\%\&\*\+\/<=>@/＃＄％＆＊＋／＜＝＞＠/;
    #brackets
    $data =~ s/[\[〖〔]/［/gm;
    $data =~ s/[\]〗}〕]/］/gm;
    #parenthesis
    $data =~ s/[(｟]/（/gm;
    $data =~ s/[)｠]/）/gm;
    
    #Question marks
    $data =~ s/!/！/gm;
    $data =~ s/\?/？/gm;
    $data =~ s/\.../…/gm;
    $data =~ s/・・・/…/gm;
    $data =~ s/⁴/４/gm;
    $data =~ s/[-‐一ー－―—]/―/gm;
    
    $data =~ s/[Ｉ丨]/Ⅰ/gm;
    $data =~ s/ＩＩ/ⅠⅠ/gm;
    $data =~ s/ＩＩＩ/ⅠⅠⅠ/gm;
    
    $data =~ s/Ⅰ/Ｉ/gm;
    $data =~ s/Ⅱ/ＩＩ/gm;
    $data =~ s/Ⅲ/ＩＩＩ/gm;
    $data =~ s/[。。]/・/gm;
    $data =~ s/つ/っ/gm;
    $data =~ s/[\++]/＋/gm;
    
    $data =~ s/_/＿/gm;
    $data =~ s/{(＿+)}/［$1］/gm;
    
    $data =~ s/;/；/gm;
    $data =~ s/[:：]/：/gm;
    $data =~ s/\t//gm;
    
    $data =~ s/(^\s*$)\n|\r//gm;
    
    $data =~ s/[ 　]//gm;
    
    return $data;
}

#getting files
sub get_file{
    my ($source_data_path) = $_[0];
    my ($dest_data_path) = ($_[1]);
    
    opendir(DIR, $source_data_path) or die $!; #se abre el directorio
	my @files = grep(!/^\./,readdir(DIR));
	closedir(DIR);
	foreach my $file (@files){
		##getting filename
		my $temp_filename = $file;
        
		$file = $source_data_path.'/'.$file; #path absoluto del fichero o directorio
		next unless( -f $file or -d $file ); #se rechazan pipes, links, etc ...
		if( -d $file){
			open_dir($file,my $hash);
		} else{
			##printing file path from source (reference or ocr files not normalized) 
            print $file."\n";
			##Open files from source to read and reference to write
			open(SRC, '<', $file) or die $!;
			
            my $data = '';
            while (<SRC>) {
                #reading line by line
                $data .= $_; #saving every line into a string
            }
            
            close(SRC);
            #Normalization of files
            my $normalized_data = normalize_data($data);
            print $dest_data_path."\n";
            my $dest_file = $dest_data_path."/".$temp_filename;
            print $dest_file."\n";
            open(DES, '>', $dest_file) or die $!;
            print DES "$normalized_data";
			close(DES);
			print("Contents of file successfully standardized\n");
		}		
	}
}

get_file($source_data_reference_test_path,$dest_data_reference_test_path);
#get_file($source_data_reference_training_path, $dest_data_reference_training_path);
get_file($source_data_ocr_test_path, $dest_data_ocr_test_path);
#get_file($source_data_ocr_training_path, $dest_data_ocr_training_path);


