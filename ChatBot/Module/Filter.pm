package ChatBot::Module::Filter;

use 5.006;
use strict;
use warnings;
use ChatBot::Module;
use Data::Dumper;

our @ISA = ("ChatBot::Module");
our $VERSION = '0.01';

=head1 NAME

ChatBot::Module::Filter - Perl extension for Chat-Bot

=head1 SYNOPSIS

  use ChatBot::Module::Filter;

=head1 DESCRIPTION

Stub documentation for ChatBot::Module::Filter, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub
unedited.

=cut

my $bad_words = qq{(привет|спасибо|здравствуй|пожалуйста|гы)};

 sub _init {
	my $self = shift;
	$self->{NAME} = 'Filter';
	return;
 }
 
 sub go {
	my ($self, $obj) = @_;
	my $message_text = $obj->message_text;
	$message_text =~ s/([,.!?:()]+)/ /g;
	$message_text =~ s/\s{2,}/ /g;
	if ($message_text =~ $bad_words) {
		my $res = sprintf "%s: *dont", $obj->message_autor;
		return $res;
	}
	return;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut
