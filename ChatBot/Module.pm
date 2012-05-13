package ChatBot::Module;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Module - Perl extension for ChatBot 

=head1 SYNOPSIS

  use ChatBot::Module;

=head1 DESCRIPTION

=head1 CONSTRUCTOR

=over 4

=item new ()

=back

=cut

 sub new {
	my $prot  = shift;
	my $class = ref($prot) || $prot;
	my $access = shift;
	my $self  = {
		NAME   => undef,
		ACCESS => $access
		}; 
	bless ($self, $class);
	$self->_init(@_);
	return $self;
 }

 sub _init {
	return; #abstract
 }

=head1 METHODS

=over 4

=item name 

Return module name.

=cut 

 sub name {
 	my $self = shift;
	return $self->{NAME};
 }

=item access 

Return access-level.

=cut

 sub access {
	my $self = shift;
	return $self->{ACCESS};
 }

=item go

=back

=cut

 sub go {
	my ($self, $obj) = @_;
	return $self->start($obj);
 }

1;
__END__

=head1 AUTHOR

Novgorodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=cut
