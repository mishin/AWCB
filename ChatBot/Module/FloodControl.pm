package ChatBot::Module::FloodControl;

use 5.006;
use strict;
use warnings;
use ChatBot::Module;

our @ISA = ("ChatBot::Module");
our $VERSION = '0.01';

=head1 NAME

ChatBot::Module::FloodControl - Perl extension for Chat-Bot 

=head1 SYNOPSIS

  use ChatBot::Module::FloodControl;

=head1 DESCRIPTION

Stub documentation for ChatBot::Module::FloodControl, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub
unedited.

=cut

my $result = "/mu 300 %s флуд";

 sub _init {
	my $self = shift;
	$self->{NAME} = 'Flood Control';
	return;
 }

 sub go {
	my ($self, $obj) = @_;
	return if ($obj->message_autor eq '-SYS');
	my $last = $self->{USER}->{lc($obj->message_autor)}->[-1];		
	$self->{USER}->{lc($obj->message_autor)} = undef 
		unless ($last && $last eq $obj->message_text);
	push @{$self->{USER}->{lc($obj->message_autor)}}, $obj->message_text;
	my $index = @{$self->{USER}->{lc($obj->message_autor)}};
	my $res  = undef;
	$res = sprintf $result, $obj->message_autor if ($index >= 3);
	return $res if (defined $res);
	return;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novogorodcev, E<lt>cynovg@gmail.comE<gt>

=cut
