#!/usr/bin/perl
use strict;
use warnings;

###
# Purpose: MIPS32 Assembly Code Parser
# Creator: Yong Yang (yongyang@usc.edu)
# Date:    04/18/2015
###

# Format Control 
# Can be specified by in-line arguments
# -hex/binary 
# 	format of machine code, default binary
# -verbose
#   print assembly code, default disabled 
# -debug_mode
#   keep temporal file for debug
my $enable_verbose = 'false';
my $format_output  = 'binary';
my $debug_mode     = 'false';

# ISA Mask Hash Table
my %instSet = (
  "ADD"     => "00000000000000000000000000100000",
  "ADDI"    => "00100000000000000000000000000000",
  "AND"     => "00000000000000000000000000100100",
  "BEQ"     => "00010000000000000000000000000000",
  "BNE"     => "00010100000000000000000000000000",
  "CACHE"   => "10111100000000000000000000000000",
  "DIV"     => "00000000000000000000000000011011",
  "J"       => "00001000000000000000000000000000",
  "JAL"     => "00001100000000000000000000000000",
  "JR"      => "00000000000000000000000000001000",
  "LL"      => "11000000000000000000000000000000",
  "LW"      => "10001100000000000000000000000000",
  "MFHI"    => "00000000000000000000000000010000",
  "MFLO"    => "00000000000000000000000000010010",
  "MULT"    => "00000000000000000000000000011001",
  "OR"      => "00000000000000000000000000100101",
  "SC"      => "11100000000000000000000000000000",
  "SLT"     => "00000000000000000000000000101010",
  "SUB"     => "00000000000000000000000000100010",
  "SW"      => "10101100000000000000000000000000",
  "NOP"     => "00000000000000000000000000000000",
); 

# Thread Starting PC
my $inst_cache_size = 512; 
my %starting_pc = (
  "THREAD 0"   => "0",
  "THREAD 1"   => "128",
  "THREAD 2"   => "256",
  "THREAD 3"   => "384",
); 

main(@ARGV);

sub main {
  my $opcode;
  my $rd;
  my $rs;
  my $rt;
  my $offset;
  my $target;
  my $mask;
  my $inst;
  my $pc = 0;
  my $new_pc;
  my @inst_stream; 
  my @original_insts;
  my %jump_addr; # store branch or jump target address
  
# Profile source assembly code 
# Check syntax and get jump/branch target address
# Profile required because target calling can be either forward or backward
  open WR_ASM_PROFILE, '>', "asm_profile.temp"
    or die "Can't write 'asm_profile.temp': $!";
  foreach my $src (<STDIN>) {
	$src =~ /^\s*$/ and next; # skip empty line
    if ($src =~ /^;\s*(THREAD\s\d)\s*$/) {
	  if ($pc > $starting_pc{$1}) {
	    print WR_ASM_PROFILE "\; Warning: Instruction Overflow\n";
	  }
	  $pc = $starting_pc{$1};
	  print WR_ASM_PROFILE $src . "\n";
	  next;
	}
	$src =~ /^\s*;/ and next; # skip comment line (begin with ;) 
	chomp $src;
    my @subparts = split /\s+/, $src;
	if ($subparts[0] =~ /(\S+):/) {
	  if (exists $jump_addr{$1}) {
	    print WR_ASM_PROFILE "\; Warning: Found Multiple Target Address Tag\n";
	  }
	  $jump_addr{$1} = $pc;	  
	} else {
	  unless (exists $instSet{$subparts[0]}) {
	    print WR_ASM_PROFILE "\; Warining: Found Unvalid Instruction\n";
	  }
	}
	
	$pc++;
	$src =~ s/;(.*)$//;
	print WR_ASM_PROFILE $src . "\n";
  }
  close WR_ASM_PROFILE;
  
  $pc = 0;
  open RD_ASM_PROFILE, '<', "asm_profile.temp"
    or die "Can't read 'asm_profile.temp': $!";
  foreach my $line (<RD_ASM_PROFILE>) {
    $line =~ /^\s*$/ and next; # skip empty line
	if ($line =~ /^;\s*(THREAD\s*\d)\s*$/) {
	  $new_pc = $starting_pc{$1};
	  while ($pc < $new_pc) {
		  push @inst_stream, $instSet{"NOP"};
	      push @original_insts, "Insert NOPs after thread ends";
		  $pc++;
	  }
	  next;
	}
	$line =~ /^\s*;/ and next; # skip comment line (begin with ;)
    chomp $line;
    my @fields = split /\s+/, $line;
	if ($fields[0] =~ /(\S+):/) {
	  $jump_addr{$1} = $pc;
      shift @fields;	  
	}
	$fields[0] =~ /^([A-Z]+)/i;
	$opcode = $1; 
	
	if (exists $instSet{$opcode}) {
	  if ($opcode =~ /^(ADD|SUB|AND|OR|MULT|DIV|SLT)$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rd = sprintf("%05b", $1);
		$fields[2] =~ /\$(\d+)/;
		$rs = sprintf("%05b", $1);
		$fields[3] =~ /\$(\d+)/;
		$rt = sprintf("%05b", $1);
		$inst = "000000" . $rs . $rt . $rd. "00000000000"; 
	  } 
	  
	  elsif ($opcode =~ /^ADDI$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rt = sprintf("%05b", $1);
		$fields[2] =~ /\$(\d+)/;
		$rs = sprintf("%05b", $1);
		$fields[3] =~ /(\d+)/;
		$offset = sprintf("%016b", $1);
		$inst = "000000" . $rs . $rt . $offset;
	  }
	  
	  elsif ($opcode =~ /^(BEQ|BNE)$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rt = sprintf("%05b", $1);
		$fields[2] =~ /\$(\d+)/;
		$rs = sprintf("%05b", $1);
		$fields[3] =~ /(\S+)/;
		if (exists $jump_addr{$1}) {
      	  $target = $jump_addr{$1};
		}
		$offset = $target - $pc - 1;
		$offset = (unpack "B16", reverse(pack "s", $offset));
		$inst = "000000" . $rs . $rt . $offset;
	  }
	  
	  elsif ($opcode =~ /^(LL|LW|SC|SW)$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rt = sprintf("%05b", $1);
		$fields[2] =~ /(\d+)\(\$(\d+)\)/;
		$offset = sprintf("%016b", $1);
		$rs = sprintf("%05b", $2);
		$inst = "000000" . $rs . $rt . $offset; 
	  }
	  
	  elsif ($opcode =~ /^CACHE$/i) {
	    $fields[1] =~ /((0|1){5})/;
      	$rt = $1;
		$fields[2] =~ /(\d+)\(\$(\d+)\)/;
		$offset = sprintf("%016b", $1);
		$rs = sprintf("%05b", $2);
		$inst = "000000" . $rs . $rt . $offset; 
	  }
	  
	  elsif ($opcode =~ /^(JAL|J)$/i) {
	    $fields[1] =~ /(\S+)/;
		if (exists $jump_addr{$1}) {
      	  $target = $jump_addr{$1};
		}
		$target = sprintf("%026b", $target);
		$inst = "000000" . $target; 
	  }
	  
	  elsif ($opcode =~ /^JR$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rs = sprintf("%05b", $1);
		$inst = "000000" . $rs . "000000000000000000000"; 
	  }
	  
	  elsif ($opcode =~ /^(MFHI|MFLO)$/i) {
	    $fields[1] =~ /\$(\d+)/;
      	$rd = sprintf("%05b", $1);
		$inst = "00000000000" . $rd . "0000000000000000"; 
	  }
	  
	  elsif ($opcode =~ /^NOP$/i) {
		$inst = "00000000000000000000000000000000"; 
	  }	
      
      $mask = $instSet{$opcode};
	  $inst = $inst | $mask;	  
	} else {
	  $inst = "11111100000000000000000000000000"; # parse invalid inst into special NOP 
	}
	
	push @inst_stream, $inst;
	push @original_insts, $line;
    $pc++;
  }
  # fill the remaining inst cache space with NOPs
  while ($pc < $inst_cache_size) {
    push @inst_stream, $instSet{"NOP"};
	push @original_insts, "Insert NOPs after thread ends";
    $pc++;
  }
  close RD_ASM_PROFILE;
  
  foreach my $arg (@ARGV) {
    if ($arg =~ /-(v|verbose|V)/i) {
	  $enable_verbose = 'true';
	}
	if ($arg =~ /-(b|binary|B)/i) {
	  $format_output = 'b';
	}
	if ($arg =~ /-(h|hex|H)/i) {
	  $format_output = 'h';
	}
	if ($arg =~ /-(d|debug|D)/i) {
	  $debug_mode = 'true';
	}
	# arg: -s means pure hex code to be sent via uut
	if ($arg =~ /-S|special|s/i) {
	  $format_output = 's';
	}
	# arg: -p means pkg file
	if ($arg =~ /-P|pkg|p/i) {
	  $format_output = 'p';
	}
}
  
  # if ($format_output ne 's') {
	# # what is it doing here?? -- Jizhe
    # foreach $inst (@inst_stream) {
      # if ($format_output eq 'h') {
	  # $inst = sprintf("%08X", unpack("N", pack("B32", $inst)));
      # }
	
      # if ($enable_verbose eq 'true') {
	  # my $comment = shift @original_insts;
          # print $inst . " # " . $comment . "\n";
      # }
      # else {
	  # print $inst . "\n";
      # }
    # }
  # }
  
# Modified by Jizhe to add the option to output pure hex code or pkg file code
# sorry for writing such ugly code
for my $index (0..($inst_cache_size/4-1)) {
  $inst = sprintf("%08X", unpack("N", pack("B32", $inst_stream[3])));
  if ($format_output eq 'p') { print "X\"" . $inst . "_";}
  if ($format_output eq 's') { print $inst;}
 print "\n";
  $inst = sprintf("%08X", unpack("N", pack("B32", $inst_stream[2])));
  if ($format_output eq 'p') { print $inst . "_";}
  if ($format_output eq 's') { print $inst;}
 print "\n";
  $inst = sprintf("%08X", unpack("N", pack("B32", $inst_stream[1])));
  if ($format_output eq 'p') { print $inst . "_";}
  if ($format_output eq 's') { print $inst;}
print "\n";
  $inst = sprintf("%08X", unpack("N", pack("B32", $inst_stream[0])));
  if ($format_output eq 'p') { 
	my $comma = ',';
	if ($index eq 127) {$comma = '';}
	print $inst . "\"" . $comma . " -- Loc ";
}
  if ($format_output eq 's') { print $inst;}
  
  shift @inst_stream;shift @inst_stream;
  shift @inst_stream;shift @inst_stream;
  my $loc_index = $index*4+4;
  --$loc_index; if ($format_output eq 'p') {print $loc_index . ", ";}
  --$loc_index; if ($format_output eq 'p') {print $loc_index . ", ";}
  --$loc_index; if ($format_output eq 'p') {print $loc_index . ", ";}
  --$loc_index; if ($format_output eq 'p') {print $loc_index;}
  print "\n";
}
  
  # if($debug_mode eq 'false') {
    # system("rm asm_profile.temp");
  # }
}
