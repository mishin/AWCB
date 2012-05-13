package ChatBot::Core::Message::Parser;

use 5.006;
use strict;
use warnings;
use Class::Struct;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Message::Parser - Perl extension for Chat-Bot 

=head1 SYNOPSIS

  use ChatBot::Core::Message::ChatRuParser;

=head1 DESCRIPTION

=cut

 sub new {
 	my $class = shift;
	my $self  = {};
	bless ($self, $class);
	$self->_init();
	return $self;
 }

 sub _init {
	my $self = shift;
	struct Message   => {
			 time    => '$',
		  	 user    => '$',
			 text    => '$',
			 channel => '$',
			 event   => '$',
			 orig	 => '$'
	};
	return;
 }

 sub parse {	
 	my ($self, $message) = @_;
	chomp $message;
	my $msg = Message->new;
	$msg->orig($message);
	if ($message =~ m/^'([^']+)'\s(u|s):\[(\d?\d:\d\d:\d\d?)\](.*)$/) {
		$msg->channel($1);
		$msg->time($3);
		if ($2 eq 'u') {
			$msg->event('users');
			my $text = $4;
			$text=~ s{^([^:]+):\(\)(.*)$}{$2};
			$msg->user($1);	
			$msg->text($text);
		}
		else {
			$msg->event('system');
			$msg->user('-SYS');
			$msg->text($4);
		}
	}
	else {
		my $error = sprintf "can't parse message:[%s]", $message;
		warn $error,"\n"; 
		$msg->user('-ERROR');
		$msg->text('-NOT PARSED');
	}
	
	return $msg;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmail.comE<gt>

=cut
