program rub;
        (* this is the rub command line utility *)

        (*     rub infile [-b] [-h] [-z num] [-m] [-s] [-e <.rub>] [-v] [-r] [-a] [-d] [-c] [-m] [-z num] [-h] outfile     *)

        (* the command line options follow a pipe structure. from infile to outfile without the repeats
        they are as follows and (i) indicates REMOVAL of a feature from the pipe by the option:
                -b backwards file read 9polarity of option inverted by -r)
                -h (i) hex encode/decode
                -z compress/deompress using fast entropic method
                -m (i) 4096 bit encrypt/decrypt of stream (encyption of the rubikon still happens even if stream encryption is disabled by -m)
                -s digital signature
                -e encrypt using public keyfile (all public key facilitation needs this option)
                -v digital post signature for vouching of content
                -r the rubikon (do perform rubikon compression, has to be this way for pipe test)
                -a pre decrypt voucher authentication
                -d decrypt using your private keyfile (all private key options need this)
                -c check digital signature
        and no other command options are supported. invalid command options displays help, and informs standard error. *)

        uses rubutil;
begin

end.
