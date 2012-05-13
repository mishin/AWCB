package ChatBot::Core::Message::Sender;

use 5.006;
use strict;
use warnings;
use Net::HTTP;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Message::Sender - Perl extension for Chat-Bot

=head1 SYNOPSIS

  use ChatBot::Core::Message::Sender;

=head1 DESCRIPTION

Stub documentation for ChatBot::Core::Message::Sender, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub unedited.

=cut
my $reqnum = 1;

 sub new {
	my ($proto, $data) = @_;
	my $class = ref($proto) || $proto;
	my $self  = {
		NAME  => $data->{name},
		PSWD  => $data->{passwd}
	};
	bless ($self, $class);
	$self->{PROXY} = $data->{proxy} if (defined $data->{proxy});
	return $self;
 }

 sub _init {
	my ($self, $channel) = @_;
	$self->{CHANNEL} = $channel;
	return $self;
 }

 sub send_message {
	my ($self, $message) = @_;
	chomp $message;
	$message =~ s/\s/%20/g;
	my $host = "chat.chat.ru";
	my $url = 
		sprintf "/newmsg_t?username=%s&passwd=%s&channel=%s&msgtext=%s&reqnum=%d",
			$self->{NAME},
			$self->{PSWD},
			$self->{CHANNEL},
			$message,
			$reqnum;
	if ($self->{PROXY}) {
		$url  = $host."/".$url;
		$host = $self->{PROXY};
	}
	my $s = Net::HTTP->new(Host=> $host);
	$s->write_request(GET=>$url, 'User-Agent'=>"Mozilla/5.0");
	my ($code, $mess, %h) = $s->read_response_headers;
	$reqnum++
	}

 sub logout {
	my $self = shift;
	my $url = 
		sprintf "/logoff?username=%s&passwd=%s", 
				$self->{NAME}, $self->{PSWD};
	my $host = 'chat.chat.ru';
	if ($self->{PROXY}) {
		$url = $host."/".$url;
		$host = $self->{PROXY};
	}
	my $s = Net::HTTP->new(Host=> $host);
	$s->write_request(GET=>$url, 'User-Agent'=>"Mozilla/5.0");
	my ($code, $mess, %h) = $s->read_response_headers;
	return;	
 }
1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut
