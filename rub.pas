program rub;
        (* this is the rub command line utility *)

        (*

        rub [ifile [ [-i <.inc>] [-h] [-j] [-f] [-x] [-p] [-b] [-l <.txt>] [-g] [-s] [-c <.rub>] [-s] [-r]
                [-k [-r] [-g] [-s <.rub>] [-c] [-s <.rub>] [-l <.txt>] [-b] [-p] [-x] [-j] [-h] [-k] ] ] ofile]

        *)

        (* the command line options follow a pipe structure from ifile to ofile without the repeats of inverse function

                -i include file of operations (list of switches and files, one round per line)
                -x add some meta information to be able to recover exact size of files
                -p add some CRC polynomial check information
                -h hex encode/decode
                -j more cryptic hex
                -f flip backwards file read (polarity of option inverted by -r on compress, no direct inverse)
                -b compress/deompress using bwts/zrle entropic method
                -l lzw compress/decompress using large dictionary (-r option reduces dictionary size) "key?"
                -g flip key from rsa to elgamal
                -s digital signature
                -c encrypt using public keyfile
                -r the rubikon (do perform rubikon compression, has to be this way for pipe test)
                -k carries out the pipe function inversion (inverse operation until next -k)

        and no other command options are supported. invalid command options displays help, and informs standard error. *)

        (* the -k option starts the inversion of the process. the options -c and -s may need the other persons
        public key. the -c option uses full stream crypto and not just crypto of a 128 bit shared archive key. *)

        uses rubutil;
begin

end.
