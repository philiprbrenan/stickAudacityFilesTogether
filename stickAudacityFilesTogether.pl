#!/usr/bin/perl
#-------------------------------------------------------------------------------
# Stick Audacity files together and convert them to .wav
# Philip R Brenan at gmail dot com, Appa Apps Ltd, 2016
#-------------------------------------------------------------------------------

=pod

=head1 Stick Audacity files together

=head2 Synopsis

Reads a selection of .au files (from Audacity) and concatenates them into one
or more .wav files.

=head2 Linux Installation

Download the single standalone Perl script
L<stickAudacityFilesTogether.pl|https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl>
to any convenient folder.

=head3 Perl

You might need to install Perl:

L<http://www.perl.org>

You might need to install the following Perl modules:

 cpan install Data::Dump File::Glob File::Path

=head3 Sox

You might need to install Sox:

L<https://sourceforge.net/projects/sox/files/sox/>

=head2 Windows Installation Notes

If you are working on Windows you might need to install the following items:

L<sound exchange|https://sourceforge.net/projects/sox/files/sox/14.4.2/sox-14.4.2-win32.exe/download>

L<perl|http://strawberryperl.com/download/5.24.0.1/strawberry-perl-5.24.0.1-64bit.msi>

L<text editor|http://download.geany.org/geany-1.29_setup.exe>

Then create a convenient folder with no blanks anywhere in its name and save
the following file into it:

L<stickAudacityFilesTogether.pl|https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl>

=head2 Configuration

Using an editor change the lines in the B<User configuration> section in
L<stickAudacityFilesTogether.pl|https://github.com/philiprbrenan/stickAudacityFilesTogether/blob/master/stickAudacityFilesTogether.pl>
to select the files you want to process, the number of files to be joined at a
time and whether a restart of a prior run should be performed.

=head2 Execution

From the command line, execute:

  perl stickAudacityFilesTogether.pl

=cut

# User configuration start
my $project  = 'testProject';                                                   # Audacity project name so we can find files to stick together
my $home     = '/home/phil/z/Fiverr/'.$project.'/';                             # Folder containing Audacity project
my $in       = $home.$project.'_data';                                          # Audacity folder containing sound files - default computed from above two lines should be ok
my $out      = $home.'out/';                                                    # Output directory
my $rate     = 22050;                                                           # Recording rate
   $rate     = 44100;                                                           # Recording rate
my $channels = 1;                                                               # Number of channels
my $numberOfFilesToConcatenate = 1000;                                          # Up to this many files will be concatenated at a time to form an output file
my $restartAtBlock             = 1;                                             # In the event that something goes wrong, we can restart at a specific output file, counting from 1 as the first block
# User configuration end

use warnings FATAL => qw(all);
use strict;
use File::Glob qw(:bsd_glob);
use Data::Dump qw(dump);
use File::Path qw(make_path);
                                                                                # .au files
my @files = map  {$_->[0]}
            sort {$a->[1] <=> $b->[1]}
            map  {[$_, [stat($_)]->[9]]}
            bsd_glob("$in/*/*/*.au");

for(bsd_glob("$out/*.wav"))                                                     # Clear output directory .wav files that match the expected format
 {if (my ($n) = /(\d+)\.wav\Z/)
   {if ($n >= $restartAtBlock)
     {say STDERR "Delete output file $_";
      unlink $_
     }
   }
  else
   {say STDERR "Ignoring unknown file $_";
   }
 }

if (my $nFiles = scalar(@files))                                                # Number of files
 {my $n = $numberOfFilesToConcatenate;                                          # Up to this many files will be concatenated at a time to form an output file
  make_path($out);
  say STDERR "Processing $nFiles .au files from: $in in blocks of $n";

  my @f = ([]);                                                                 # Blocks of files to convert
  for(1..@files)                                                                # Block files
   {push @f, [] if !@f  or scalar(@{$f[-1]}) >= $n;                             # Add new block
    push @{$f[-1]}, $files[$_-1];                                               # Add file to latest block
   }

  my $N = @f;
  for(1..@f)                                                                    # Convert and concatenate each block of input files
   {next if $_ < $restartAtBlock;                                               # Restart if necessary
    my $f = join ' ', @{$f[$_-1]};                                              # Input file block
    my $o = $out.sprintf("%08d.wav", $_);                                       # Output file name
    unlink $o;
    say STDERR " $_/$N";
    say STDERR qx(sox -b 32  -c $channels -e floating-point -r $rate -L  $f $o);# Convert and concatenate
   }
  say STDERR "$N output files in:\n$out";
  exit 0                                                                        # Success
 }
else                                                                            # No input files
 {say STDERR "Unable to find any .au files under folder:\n$in";
  exit 1                                                                        # Error
 }
