# Installing [VST](https://github.com/PrincetonUniversity/VST/) 

1. [Instructions for CS machines](#using-vst-on-csprincetonedu-machines)
2. [Instructions for Linux](#instructions-for-linux)
3. [Instructions for OS X](#instructions-for-os-x)


## Using VST on cs.princeton.edu machines

With a CS account at princeton, [you can ssh to the following machines](https://csguide.cs.princeton.edu/remote/ssh) with the `-X` option to enable X11 forwarding to be able to open windows:

    ssh -X username@cycles.cs.princeton.edu

You'll need to run Proof General instead of CoqIDE, because there's currently no CoqIDE installed on the cycles.cs machines.

You should add this to your .bash_profile (or profile for whatever shell you use):

    export PATH=/n/fs/sml/sharedvst/bin:$PATH

and this to your .emacs

    (load "/n/fs/sml/sharedvst/proofgeneral/generic/proof-site.el")

Then you'll get two commands: 

* "clightgen"  (for translating .c files into .v files) and
* "pg" for proofgeneral (which loads Compcert (as "compcert") and VST (as an empty dirpath)).

Next step is use this as a starting Makefile:

    FLAGS=-I /n/fs/sml/sharedvst/VST -R /n/fs/sml/sharedvst/CompCert-2.5 -as compcert
    
    all:myprogram.vo
    
    %.vo:%.v Makefile
    	coqc $(FLAGS) $<

and then the usual routine is to convert your .c file into a .v file, compile it with coq through make, and run proofgeneral on it:

    clightgen myprogram.c
    make myprogram.vo
    pg verif_myprogram.v

You can use the following files to get started
[Makefile](https://madiot.fr/vst/Makefile),
[myprogram.c](https://madiot.fr/vst/myprogram.c) and
[verif_myprogram.v](https://madiot.fr/vst/verif_myprogram.v) (this example is the list reversal program and its proof, taken from [here](https://raw.githubusercontent.com/PrincetonUniversity/VST/new_compcert/progs/verif_reverse.v)).

Signal problems to Jean-Marie Madiot (jmadiot at cs dot princeton ...).

## Instructions for Linux

Branch [new_compcert](https://github.com/PrincetonUniversity/VST/tree/new_compcert) with CompCert 2.5.

If you have already Coq 8.4pl5 or menhir >= 20140422, skip the corresponding sections.

Building times correspond to some 2015 laptop with 8 threads and 16 of RAM, which was still slower than the "cycles" machines at the Princeton CS department.  Building was roughly 3 times slower with a 2008 laptop with 2 threads and 4 G of RAM.

## Get opam (~5 minutes)

Opam is a package manager for ocaml programs.

You might not need opam! But if you do, try installing it from the standard repositories, then run `opam init`.  If `opam init` fails, uninstall it and then install it manually:

    wget https://github.com/ocaml/opam/releases/download/1.2.2/opam-full-1.2.2.tar.gz
    tar xf opam-full-1.2.2.tar.gz
    cd opam-full-1.2.2
    ./configure
    make lib-ext
    make -j
    sudo make install
    opam init

Say yes to modify your favorite .bashrc/.bash_profile file change if it's not the one you use).  Then the best is to open a new console to have opam ready.

Alternatively, run:

    eval `opam config env`

each time you want to use opam-installed packages.

### Get Coq 8.4pl5 (~5 minutes)

You'll need camlp5.  If you don't have it, you can use opam:

    opam install camlp5

Then standard installation process:

    wget https://coq.inria.fr/distrib/8.4pl5/files/coq-8.4pl5.tar.gz
    tar xf coq-8.4pl5.tar.gz
    cd coq-8.4pl5/
    ./configure
    make -j
    sudo make install

Build time is 15 minutes, 3 minutes with many cores.

### Get menhir version 20140422 (~1 minute)

With opam:

    opam install menhir -y

### Get and compile CompCert 2.5 (~10 minutes)

Go to some directory that will be your main VST directory

    wget http://compcert.inria.fr/release/compcert-2.5.tgz
    tar xf compcert-2.5.tgz
    cd CompCert-2.5
    ./configure ia32-linux

Now, we need clightgen, and for it we need a patch:

    mv exportclight/ExportClight.ml{,_bak}
    wget madiot.fr/ExportClight.ml -O exportclight/ExportClight.ml
    make -j
    make -j clightgen

Build time is 30 minutes, 7 minutes with many cores.

### Get and compile VST (~1 or 2 hours)

Go to your main VST directory where there is already CompCert.  This will create a VST directory next to "CompCert-2.5", that should be renamed to "compcert".

    mv CompCert-2.5 compcert
    git clone https://github.com/PrincetonUniversity/VST.git
    cd VST
    git checkout new_compcert
    make -j -k

If the Makefile rejects your version of Coq because it's too recent, you can try for example if you have 8.4pl6:

    sed -i 's/or-else 8.4pl5/or-else 8.4pl5 or-else 8.4pl6/' Makefile

Build time is 120 minutes, 50 minutes with many cores.

### Open proofgeneral/coqide

If you use proofgeneral you can now go to the directory "VST" inside your main VST directory, and run:

    ./pg

Then open your files from inside emacs.  Start with 'progs/verif_reverse.v' for an introduction.

For coqide, try using the _CoqProject file.  If it does not work, try using something of the form and give feedback:

    coqide -I msl -as msl -I sepcomp -as sepcomp -I veric -as veric -I floyd -as floyd -I progs -as progs -I sha -as sha -R compcert -as compcert YOURFILE.v




## Instructions for OS X

Branch [new_compcert](https://github.com/PrincetonUniversity/VST/tree/new_compcert) with CompCert 2.5.

If you have already Coq 8.4pl5 or menhir >= 20140422, skip the corresponding sections.

## Get [Homebrew](http://http://brew.sh/) (~5 minutes)

Run the following on your Terminal:

`ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

Now you have Homebrew, this is a big day for you.

### Get wget (~1 minute)

I use wget to download the packages that are not in Homebrew. If you don't have it, you can use hombrew:

    brew install wget

### Get Coq 8.4pl5 (~5 minutes)

You'll need camlp5.  If you don't have it, you can use hombrew:

    brew install camlp5

Then brew Coq:

    brew install coq


### Get menhir version 20140422 (~1 minute)

With homebrew:

    brew install menhir

### Get and compile CompCert 2.5 (~10 minutes)

Go to some directory that will be your main VST directory

    wget http://compcert.inria.fr/release/compcert-2.5.tgz
    tar xf compcert-2.5.tgz
    cd CompCert-2.5
    ./configure ia32-macosx

Now, we need clightgen, and for it we need a patch:

    mv exportclight/ExportClight.ml{,_bak}
    wget madiot.fr/ExportClight.ml -O exportclight/ExportClight.ml
    make -j
    make -j clightgen

Build time is 30 minutes, 7 minutes with many cores.

### Get and compile VST (~1 or 2 hours)

Go to your main VST directory where there is already CompCert.  This will create a VST directory next to "CompCert-2.5", that should be renamed to "compcert".

    mv CompCert-2.5 compcert
    git clone https://github.com/PrincetonUniversity/VST.git
    cd VST
    git checkout new_compcert
    make -j -k

### Set the coqpath

Add the following lines to your .emacs file:

`;VST coqpaths
(custom-set-variables '(coq-prog-args '(
"-R" "/Users/scuellar/Projects/compcert-2.5" "-as" "compcert" 
"-R" "/Users/scuellar/Projects/VST/msl" "-as" "msl"
"-R" "/Users/scuellar/Projects/VST/veric" "-as" "veric"
"-R" "/Users/scuellar/Projects/VST/floyd" "-as" "floyd"
"-R" "/Users/scuellar/Projects/VST/progs" "-as" "progs"
"-R" "/Users/scuellar/Projects/VST/sepcomp" "-as" "sepcomp"
))) `

`(setq coq-load-path '(("/Users/scuellar/Projects/compcert-2.5" "compcert")
                      ("/Users/scuellar/Projects/VST/msl" "msl")
                      ("/Users/scuellar/Projects/VST/veric" "veric")
                      ("/Users/scuellar/Projects/VST/floyd" "floyd")
                      ("/Users/scuellar/Projects/VST/progs" "progs")
                      ("/Users/scuellar/Projects/VST/sepcomp" "sepcomp") ))`


### Open a file

Open your files from inside emacs.  Start with 'progs/verif_reverse.v' for an introduction. Another good example is 'progs/verif_nest2.v'.