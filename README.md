rub
===

Free Pascal Implementation of the Rubikon
-----------------------------------------

  * 2014-04-11 development and crypto.pas started.
  * 2014-04-17 modulo.pas and crypto.pas compile, not tested, .gitignore added, sorter and bwts still in Java.
  * 2014-04-20 lzw in bwts.pas with full dictionary optimization wrote. happy easter.
  * 2014-04-21 settled on a command line structure
  * 2014-04-22 improved CLI structure
  * 2014-05-01 added CRC option to CLI spec

*rub [ifile [ [-i <.inc>] [-h] [-j] [-f] [-x] [-p] [-b] [-l <.txt>] [-g] [-s] [-c <.rub>] [-s] [-r]
                [-k [-r] [-g] [-s <.rub>] [-c] [-s <.rub>] [-l <.txt>] [-b] [-p] [-x] [-j] [-h] [-k] ] ] ofile]*

The rub utility works as a block pipe between two files. The -k option reverses the pipe operations, and
the second -k normalizes this back. The above command line then does have an error, in the optional
terminal -k not being used before -i and the like. The option order is not too important (except -k),
but it will change what is done. Consult the rub.pas source file for more information. The sequence of
files for the options is fixed, although the options may be combined like *-ihbl <.inc> <.txt>* for
the sake of efficiency.

The URL https://sites.google.com/site/rubikcompression/home contains details of the method.
The repo is arranged into units so that others may find utility in the separate units.
Free Pascal was chosen as it's free, has a fast small IDE, and targets many systems.
I could have chosen C or Java, but these have either an oversize IDE or just aren't as fun to learn.
I understand the *fpc* is being developed to target the JVM and so Java is ruled out.
The C compiler is more of a pain to cross compile with too. So Pascal came to mind with such a good tool.

The Rubikon or rub is a data compression technique I developed over many years.
It started as an investigation into the subject of data compression, and had many non working avenues.
The first break through came in the concept of self partition mutual information.
This concept is not used in the Rubikon, but kept me thinking. I then developed a coding scheme
called Jaxon Modulation to further development of ideas of restrictions on the bit statistics.

After the Diamond algorithm came short by needing 2^55 order cycles to store a partial bit, I still continued.
The next break through was using the idea of a bit time drift line. All after investigating topological structure
in linked lists, whose only persistant result was to come up with the name K Ring Technologies. I did find an algorithm which
improved on the Diamond algorithm, but this was still statistical compression as bit rebound
in this compression was a problem. Eventually I discovered this Rubikon which had no rebound of information,
and so an upper limit on time per bit was now possible with certainty.

The next step was optimization, and building in encryption and signing into the design.
This project is the eventual result of the years of occasional to intense thought on the subject
of data compression. Although the Rubikon is simple in some ways, it is not obvious.
The engineering of reversable determinism with a split in possibilities of forward motion is
the name of the game. To take a rare event, and make it rarer still based on choice,
while keeping and detecting that choice in the reversal of process steps.

As a consequence of the implementation method, and because such things are good in standards,
an encryption unit is provided. This unit is independant of rub, and feel free to use it.
The encryption supports RSA upto 4096 bit keys, but do be warned that not many checks are performed
on the security of the key to cryptanalysis. For variety the ElGamal encryption method over a cyclic modulo group is also
included. There is little need for the multi-precision library to extend beyond 4096 bits. (1 disk sector)

The production aim was a single binary file which is used from the command line. There are no plans
to extend this project beyond this design goal. I may do other projects based on this one, but they
maybe paid for software. This is a project about a usable command line binary. Something perhaps
to be improved by a script wrapper, which would never be in this project. The secret key for
encryption is *my.secret*, while the public key is called *my.rub*, and they are both by default
in the *~/.rub* directory. To be honest I don't give a flying about Windoze, so won't be giving a flying about 
this Unix biased implementation.

Pascal (structure) -> Java (security) -> C (speedsifics) -> ASM (ISA)

But are we there yet? Units included are

  * modulo - 4096 bit cyclic group arithmetic - not the fastest as fixed size
  * crypto - RSA and ElGamal encryption - encryption blend feature
  * rubutil - utilities for rub
  * rub - the main rub unit
  * sorter - a quick sorter unit
  * bwts - a BWT Scottified processing unit

For commentary on how Free Pascal differs from regular Pascal see:
https://sites.google.com/site/programinglanguagefea/other-language-designs/pascal
