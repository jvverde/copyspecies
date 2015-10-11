#!/usr/bin/perl

use strict;
use File::Copy;
use File::Path;
use Encode qw(decode);

$\ = "\n";
$, =",\t";
my $current = shift @ARGV || '.';
binmode(STDOUT, ":utf8");



#my %files = map {s/[^0-9]+(?=\.)//; ($_ => 1)} grep {/\.jpg/i} grep { -f $_} readdir DIR;
sub search_dir{
  my $dir = shift;
  print "search $dir";
  eval{
    opendir DIR, $dir or die qq|"Não foi possivel abrir o directorio $dir"| ;
    my @dirs = map {decode("utf8",$_)} grep {!/\.jpg$|\.bkit\.me\.files$/i} grep {!/^\.\.?$/} readdir DIR;
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
    my @species = map {decode("utf8",$_)} grep {!/\.jpg$|\.bkit\.me\.files$/i} grep {!/^\.\.?$/} readdir DIR;
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
       print "copy $dir/$species to $new";
       eval{
        opendir DIR, "$dir/$species" or die qq|"Não foi possivel abrir o directorio $dir/$species"| ;
        my @files = map {decode("utf8",$_)} grep {/\.jpg$/i} readdir DIR;
        my $base = substr $dir, 1 + length $current;
        $base =~ s/\//_/g;
        foreach my $file (@files){
          my $name = "${base}_$file";
          eval{
            copy "$dir/$species/$file", "$new/$name";
            print "copy $dir/$species/$file to $new/$name";
          } 
        }
       }
      }
    }
  };
}

search_dir($current);




# use strict;
# use File::Copy;
# use File::Path;	
# $\ = "\n";
# $, ="\t=>\t";
# my $dir = shift @ARGV || '.';
# my $orig = "$dir/../../original";

# opendir DIR, $dir or warn qq|'Não foi possivel abrir o directorio corrente'|;

# #my %files = map {s/[^0-9]+(?=\.)//; ($_ => 1)} grep {/\.jpg/i} grep { -f $_} readdir DIR;
# my %files = map {s/[^0-9]+(?=\.)//; ($_ => 1)} grep {/\.jpg$/i} readdir DIR;
# my $err;
# -d $orig or mkpath($orig, {
# 	verbose => 3,
# 	error => \$err,
# });

# if ($err and @$err) {
# 	for my $diag (@$err) {
# 		my ($file, $message) = %$diag;
# 		if ($file eq '') {
# 			print "Erro: $message\n";
# 		}else {
# 			print "Problemas ao criar o directório $file: $message\n";
# 		}
# 	}
# }

# foreach (keys %files){
# 	my $f1 = "$dir/../../$_";
# 	my $f2 = $f1;
# 	my $d1 = "$orig/$_";
# 	print qq|$f1 => $d1|;
# 	move($f1,$d1);
# 	$f2 =~ s/\.jpg$/\.NEF/i;
# 	my $d2 = $d1;
# 	$d2 =~ s/\.jpg$/\.NEF/i;
# 	print qq|$f2 => $d2|;
# 	move($f2, $d2);
# }
