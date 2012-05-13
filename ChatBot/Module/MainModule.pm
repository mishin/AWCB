package ChatBot::Module::MainModule;

use 5.006;
use strict;
use warnings;
use ChatBot::Module;

our @ISA = ("ChatBot::Module");
our $VERSION = '0.01';

=head1 NAME

ChatBot::Module::MainModule - Perl extension for blah blah blah 

=head1 SYNOPSIS

  use ChatBot::Module::MainModule;

=head1 DESCRIPTION

=cut

 sub _init {
	my $self = shift;
	$self->{NAME} = 'main module';
	return $self;
 }
 
 sub start {
 	my ($self, $obj) = @_;
	printf "get new message %s\n", $obj->message_text;
	return ;
 }

1;
__END__

=head1 AUTHOR

A. U. Thor, E<lt>a.u.thor@a.galaxy.far.far.awayE<gt>

=head1 SEE ALSO

L<perl>.

=cut
