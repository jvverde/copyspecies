#!/usr/bin/perl

use strict;
use File::Copy;
use File::Path;
use Encode qw(decode);

$\ = "\n";
$, =",\t";
my $current = shift @ARGV || '.';
binmode(STDOUT, ":utf8");

#Search for dirs (= species names) under Sel subdirs and copy them to $current/ALL/speciesname


#my %files = map {s/[^0-9]+(?=\.)//; ($_ => 1)} grep {/\.jpg/i} grep { -f $_} readdir DIR;
sub search_dir{
  my $dir = shift;
  #print "search $dir";
  eval{
    opendir DIR, $dir or die qq|"Não foi possivel abrir o directorio $dir"| ;
    my @dirs = grep {!/^\.\.?$/} grep {-d "$dir/$_"} map {decode("utf8",$_)} readdir DIR;
    foreach my $sdir (@dirs){

      if ($sdir =~ /Sel/i){
        copy_dirs("$dir/$sdir")
      }else{
        search_dir("$dir/$sdir")
      }
    }
  };
}

sub copy_dirs{
  my $dir = shift; 
  eval{ 
    opendir DIR, $dir or die qq|"Não foi possivel abrir o directorio $dir"| ;
    my @species = grep {!/^\.\.?$/} grep {-d "$dir/$_"} map {decode("utf8",$_)} readdir DIR;
    foreach my $species (@species){
      my $new = "$current/ALL/$species";
      my $err = undef;
      -d $new or mkpath($new, {
        verbose => 3,
        error => \$err,
      });

      if ($err and @$err) {
        for my $diag (@$err) {
          my ($file, $message) = %$diag;
          if ($file eq '') {
            print "Erro: $message\n";
          }else {
            print "Problemas ao criar o directório $file: $message\n";
          }
        }
      }elsif(!$err){
        #print "copy $dir/$species to $new";
        eval{
          opendir DIR, "$dir/$species" or die qq|"Não foi possivel abrir o directorio $dir/$species"| ;
          my @files = map {decode("utf8",$_)} grep {/\.jpg$/i} readdir DIR;
          my $base = substr $dir, 1 + length $current;
          $base =~ s/\//_/g;
          foreach my $file (@files){
            my $name = "${base}_$file";
            -e "$new/$name" or eval {
              copy "$dir/$species/$file", "$new/$name";
              print "copy $dir/$species/$file to $new/$name";
            };
          }
        };
      }
    }
  };
}

search_dir($current);
