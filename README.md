rub
===

Free Pascal Implementation of the Rubikon
-----------------------------------------

2014-04-11 development started (crypto.pp started)

The URL https://sites.google.com/site/rubikcompression/home contains details of the method.
The repo is arranged into units so that others may find utility in the separate units.
Free Pascal was chosen as it's free, has a fast small IDE, and targets many systems.
I could have chosen C or Java, but these have either an oversize IDE or just aren't as fun to learn.
I understand the *fpc* is being developed to target the JVM and so Java is ruled out.
The C compiler is more of a pain to cross compile with too. So Pascal came to mind with such a good tool.

The Rubikon or rub is a data compression technique I developed over many years.
It started as a inv estigation into the subject of data compression, and had many non working avenues.
The first break through came in the concept of self partition mutual information.
This concept is not used in the Rubikon, but kept me thinking. I then developed a coding scheme
called Jaxon Modulation to further development of ideas of restrictions on the bit statistics.

After the Diamond algorithm came short by needing 2^55 order cycles to store a partial bit, I still continued.
The next break through was using the idea of a drift line. All after investigating topological structure
in linked lists, to come up with the name K Ring Technologies. I did find an algorithm which
improved on the Diamond algorithm, but this was still statistical compression as bit rebound
in compression was a problem. Eventually I discovered the Rubikon which had no rebound of information,
and so an upper limit on time per bit was now possible.

The next step was optimization of this, and building in encryption and signing into the design.
This project is the eventual result of the years of occasional to intense thought on the subject
of data compression.
