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
my $project  = 'testProject';                                                   # Audacity project name so we can find files to stick together - CHECK THIS VALUE
my $audacity = '/home/phil/z/z/Fiverr/audacity/';                               # Folder containing Audacity project - CHECK THIS VALUE

my $rate     = 22050;                                                           # Recording rate - CHECK THIS VALUE
   $rate     = 44100;
my $channels = 2;                                                               # Number of channels = - CHECK THIS VALUE - it should be 1 for mono or 2 for stereo which means that pairs of files will be merged before being concatenated - if you get it wrong your recording will come out at the wrong speed

if ($^O !~ /linux/i)                                                            # Windows user defaults
 {$project  = 'ab2016';
  $audacity = 'C:/Users/Sawan/Desktop/';
  $channels = 2;
 }

# The following fields are probably ok
my $numberOfFilesToConcatenate = 100;                                           # Up to this many files will be concatenated at a time to form an output file
my $restartAtBlock             = 1;                                             # In the event that something goes wrong, we can restart at a specific output file, counting from 1 as the first block

# The following fields should be ok as set
my $home     = $audacity.$project.'/';                                          # Folder containing audacity project
my $in       = $home.$project.'_data';                                          # Audacity folder containing sound files
my $out      = $home.'out/';                                                    # Output directory
my $tmp      = $home.'tmp/';                                                    # Temporary file directory

my $version  =  '2017.01.20';
# User configuration end

use warnings FATAL => qw(all);
use strict;
use File::Glob qw(:bsd_glob);
use Data::Dump qw(dump);
use File::Path qw(make_path);

say STDERR "Stick Audacity files together $version\n",
"Scanning   \"$in\" for .au files\n",
"Writing to \"$out\"\n",
"Rate=$rate hz, channels=$channels";

if (1)                                                                          # Check for sox
 {my $s = qx(sox --version 2>&1);
  $s =~ /SoX/ or die "Please install Sox as it does not seem to be present";
 }
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
  make_path($_) for $out, $tmp;
  say STDERR "Processing $nFiles .au files from: $in in blocks of $n";

  my @f = ([]);                                                                 # Blocks of files to convert
  for(1..@files)                                                                # Block files
   {push @f, [] if !@f  or scalar(@{$f[-1]}) >= $n;                             # Add new block
    push @{$f[-1]}, $files[$_-1];                                               # Add file to latest block
   }

  my $N = @f;
  for(1..@f)                                                                    # Convert and concatenate each block of input files
   {next if $_ < $restartAtBlock;                                               # Restart if necessary
    my @f = @{$f[$_-1]};                                                        # Input file block

    if ($channels == 2)                                                         # Merge channels if necessary
     {if (@f % 2)
       {warn "Odd number of files in block and stereo merge requested, last file has been duplicated";
        push @f, $f[-2];
       }
      my @F;
      while(@f)                                                                 # Each pair of files
       {my $f1 = shift @f;
        my $f2 = shift @f;
        my $t = $tmp.sprintf("%08d.wav", scalar(@F)+1);                         # Temporary output file name
        unlink $t;
        my $c = "sox --combine merge -b 32  -c 1 -e floating-point -r $rate -L  $f1 $f2 $t";
        say STDERR $c;                                                          # Command
        say STDERR qx($c);                                                      # Execute
        if ($!)
         {say STDERR "Error during sox merge: $!";
         }
        else {push @F, $t}                                                      # Save merged file
       }
      @f = @F;                                                                  # Merged files to be concatenated
     }

    my $f = join ' ', @f;                                                       # Input file block joined together
    my $o = $out.sprintf("%08d.wav", $_);                                       # Output file name
    unlink $o;
    say STDERR " $_/$N";
    my $c = "sox -b 32  -c $channels -e floating-point -r $rate -L  $f $o";     # Convert and concatenate
    say STDERR $c;                                                              # Command
    say STDERR qx($c);                                                          # Execute
    if ($!)
     {say STDERR "Error during sox concatenate: $!";
     }
   }
  say STDERR "SUCCESS: $N output files in:\n  $out";
  exit 0                                                                        # Success
 }
else                                                                            # No input files
 {say STDERR "FAIL: Unable to find any .au files under folder:\n$in";
  exit 1                                                                        # Error
 }
