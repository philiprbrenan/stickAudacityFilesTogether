# Stick Audacity files together

## Synopsis

Reads a selection of .au files (from Audacity) and concatenates them into one
or more .wav files.

## Linux Installation

Download the single standalone Perl script
[stickAudacityFilesTogether.pl](https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl)
to any convenient folder.

### Perl

You might need to install Perl:

[http://www.perl.org](http://www.perl.org)

You might need to install the following Perl modules:

    cpan install Data::Dump File::Glob File::Path

### Sox

You might need to install Sox:

[https://sourceforge.net/projects/sox/files/sox/](https://sourceforge.net/projects/sox/files/sox/)

## Windows Installation Notes

If you are working on Windows you will might need to install the following
items:

[sound exchange](https://sourceforge.net/projects/sox/files/sox/14.4.2/sox-14.4.2-win32.exe/download)

[perl](http://strawberryperl.com/download/5.24.0.1/strawberry-perl-5.24.0.1-64bit.msi)

[text editor](http://download.geany.org/geany-1.29_setup.exe)

Then create a convenient folder with no blanks anywhere in its name and save
the following file into it:

[stickAudacityFilesTogether.pl](https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl)

## Configuration

Using an editor change the lines in the **User configuration** section in
[stickAudacityFilesTogether.pl](https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl)
to select the files you want to process, the number of files to be joined at a
time and whether a restart of a prior run should be performed.

## Execution

From the command line, execute:

    perl stickAudacityFilesTogether.pl
