use strict;
use warnings;
use Encode qw(decode encode);
use utf8;
binmode STDOUT, ":utf8";
use File::Basename;
use open qw( :std :encoding(UTF-8) );

##！ ＂ ＃ ＄ ％ ＆ ＇ （） ＊ ＋ ， － ． ／ ０ １ ２ ３ ４ ５ ６ ７ ８ ９ ： ； ＜ ＝ ＞ ？
#@＠ Ａ Ｂ Ｃ Ｄ Ｅ Ｆ Ｇ Ｈ Ｉ Ｊ Ｋ Ｌ Ｍ Ｎ Ｏ Ｐ Ｑ Ｒ Ｓ Ｔ Ｕ Ｖ Ｗ Ｘ Ｙ Ｚ ［ ＼ ］ ＾ ＿
#｀ ａ ｂ ｃ ｄ ｅ ｆ ｇ ｈ ｉ ｊ ｋ ｌ ｍ ｎ ｏ ｐ ｑ ｒ ｓ ｔ ｕ ｖ ｗ ｘ ｙ ｚ ｛ ｜ ｝ ～
#｟ ｠ ｡ ｢ ｣ ､ ･ ｦ ｧ ｨ ｩ ｪ ｫ ｬ ｭ ｮ ｯ ｰ ｱ ｲ ｳ ｴ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ﾝ ﾞ
#、 。 〃 〄 々 〆 〇 〈 〉《 》   〒 〓 〔 〕 〖 〗 〘 〙 〚 〛 〜 〝〞 〟 〠 〡 〢 〣 〤 〥 〦 〧 〨 〩 〪 〫 〬 〭 〮 〯 〰 〱 〲 〳 〴 〵 〶 〷 〸 〹 〺 〻 〼 〽 〾 〿
#「 」 『 』 【 】 []

##source data
my $source_data_reference_test_path = "./referenceFiles/Test_data";
my $source_data_reference_training_path = "./referenceFiles/Training_data";
#my $source_data_ocr_test_path = "./ocrFiles/Test_data";
my $source_data_ocr_test_path = "./ocrFiles/Test_data";
my $source_data_ocr_training_path = "./ocrFiles/Training_data";
##destination data
my $dest_data_reference_test_path = "./normalized_files/reference_files/Test_data";
my $dest_data_reference_training_path = "./normalized_files/reference_files/Training_data";
my $dest_data_ocr_test_path = "./normalized_files/ocr_files/Test_data";
my $dest_data_ocr_training_path = "./normalized_files/ocr_files/Training_data";
 
 
 #function to normalize data
sub normalize_data{
    
    my $data = $_[0];
    
    #Double Quotes
    $data =~ s/["〝〞ﾞ«»]/"/gm;
    #Apostrofes
    $data =~ s/[`]/'/gm;
    #virgulilla
    $data =~ s/~/〜/gm;
    #virgulilla
    $data =~ s/,/、/gm;
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
    

#⑩,69,2469
#⑪,64,246A
#⑫,52,246B
#⑬,42,246C
#⑭,29,246D
#⑮,24,246E
#⑯,18,246F
#⑰,9,2470
#⑱,7,2471
#⑲,3,2472
    #Mayus letters
    $data =~ tr/ABCDEFGHIJKLMNOPQRSTUVWXYZ/ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ/;
    #Minor letters
    $data =~ tr/abcdefghijkalmnopqrstuvwxyz/ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ/;
    #brackets
    $data =~ s/[\[〖]/［/gm;
    $data =~ s/[\]〗]/］/gm;
    #parethesis
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
    
    #$data =~ s/[Ｉ丨]/Ⅰ/gm;
    #$data =~ s/ＩＩ/ⅠⅠ/gm;
    #$data =~ s/ＩＩＩ/ⅠⅠⅠ/gm;
    
    $data =~ s/Ⅰ/Ｉ/gm;
    $data =~ s/Ⅱ/ＩＩ/gm;
    $data =~ s/Ⅲ/ＩＩＩ/gm;
    $data =~ s/[。。]/・/gm;
    $data =~ s/つ/っ/gm;
    $data =~ s/[\++]/＋/gm;
    
    
    
    $data =~ s/;/；/gm;
    $data =~ s/[:：]/：/gm;
    
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


