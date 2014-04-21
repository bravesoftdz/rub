program rub;
        (* this is the rub command line utility *)

        (*

rub ifile [[-h] [-f] [-b] [-l] [-s] [-c <.rub>] [-v] [-r]] [[-k] [-r] [-v <.rub>] [-c] [-s <.rub>] [-l] [-b] [-h]] ofile

        *)

        (* the command line options follow a pipe structure from ifile to ofile without the repeats of inverse function

                -h hex encode/decode
                -f flip backwards file read (polarity of option inverted by -r on compress)
                -b compress/deompress using bwts/zrle entropic method
                -l lzw compress/decompress using large dictionary (-r option reduces dictionary size)
                -s digital signature
                -c encrypt using public keyfile
                -v digital post signature for vouching of content
                -r the rubikon (do perform rubikon compression, has to be this way for pipe test)
                -k carries out the pipe function inversion

        and no other command options are supported. invalid command options displays help, and informs standard error. *)

        (* the -k option starts the inversion of the process. the options -c -v -s may need the other persons
        public key. the -c option uses full stream crypto and not just crypto of a 128 bit shared archive key. *)

        uses rubutil;
begin

end.
