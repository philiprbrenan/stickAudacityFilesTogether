# Stick Audacity files together

## Synopsis

Reads a selection of .au files (from Audacity) and concatenates them into one
or more .wav files.

## Installation

Download this single standalone Perl script to any convenient folder.

### Perl

You might need to install Perl:

[http://www.perl.org](http://www.perl.org)

You might need to install the following Perl modules:

    cpan install Data::Dump File::Glob File::Path

### Sox

You might need to install Sox:

[https://sourceforge.net/projects/sox/files/sox/](https://sourceforge.net/projects/sox/files/sox/)

## Configuration

Using an editor change the lines in the **User configuration** section below to
select the files you want to process, the number of files to be joined at a
time and whether a restart of a prior run should be performed.

## Execution

From the command line, execute:

perl stickAudacityFilesTogether.pl
