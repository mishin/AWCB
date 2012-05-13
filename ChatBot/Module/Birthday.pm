package ChatBot::Module::Birthday;

use 5.006;
use strict;
use warnings;
use XML::Simple;
use ChatBot::Module;

our @ISA = ("ChatBot::Module");
our $VERSION = '0.01';

=head1 NAME

ChatBot::Module::Birthday - Perl extension for  Chat-Bot

=head1 SYNOPSIS

  use ChatBot::Module::Birthday;

=head1 DESCRIPTION

Stub documentation for ChatBot::Module::Birthday, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub
unedited.

=cut

my $need_config = 'yes';
my (%users, $current_date, @text);

 sub _init {
	my ($self, $cfg) = @_;
	$self->{NAME} = 'Birthday';
	if ($cfg && $need_config) {
		read_cfg($cfg);
	}
	return;
 }

 sub go {
	my ($self, $obj) = @_;
	read_cfg() if (get_current_date() ne $current_date);
	my $who;
	if ($obj->message_autor eq '-SYS' &&
			$obj->message_text =~ /^([^ ]+)\sприходит на канал/) {
	    $who = $1;
	}
	else {
	    $who = $obj->message_autor;
	}
	return undef unless defined $users{lc($who)};
	my $res = sprintf $text[0], $who;
	delete $users{lc($who)};
	return $res;
 }

 sub read_cfg {
	my $file = shift;
	$current_date = get_current_date();
	my $date = unpack ("A6", $current_date);
	my $cfg  = XMLin($file, KeyAttr=>'man');
	foreach my $text (@{$cfg->{text}}) {
		push @text, $text;
	}
	foreach my $record (@{$cfg->{man}}) {	
		next unless ($record->{date}=~/^$date/);
		$users{lc($record->{name})}++;	
	}
	$need_config = undef;
	};

 sub  get_current_date {
	my ($day, $month, $year) = (localtime)[3,4,5];
	my $res = sprintf "%02d-%02d-%02d", $day, $month+1, $year+1900;
	return $res;
	}

1;
__END__

=head1 AUTHOR

Cyrill Novogorodcev, E<lt>cynovg@gmail.comE<gt>

=cut
