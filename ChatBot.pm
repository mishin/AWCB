package ChatBot;

use 5.006;
use strict;
use warnings;
use ChatBot::Chat;
use ChatBot::Core; 					

our @ISA = ("ChatBot::Core");
our $VERSION = '0.01';

=head1 NAME

ChatBot - Perl extension for Chat-Bot 

=head1 SYNOPSIS

  use ChatBot;

  my $chat = ChatBot->new("/path/to/config/file");
  while (1) {
		last if ($chat->get_new_message eq 'close');
  }

=head1 DESCRIPTION

=cut 

 sub logout {
	my $self = shift;
	$self->{MESSAGE}->logout;
	return;
 }

1;
__END__

=head2 Завершение работы системы

ХХХ В разработке

=head1 AUTHOR

Novogodcev Cyrill E<lt>cynovg@gmail.comE<gt>

=head1 SEE ALSO

L<ChatBot::Core>

=cut
