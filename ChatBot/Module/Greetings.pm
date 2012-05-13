package ChatBot::Module::Greetings;

use 5.006;
use strict;
use warnings;
use Class::Struct;
use XML::Simple;
use ChatBot::Module;

our @ISA = ("ChatBot::Module");
our $VERSION = '0.01';

struct ( user => {
		nick => '$',
		sex  => '$',
		name => '$'
		});

=head1 NAME

ChatBot::Module::Greetings - Perl extension for Chat-Bot

=head1 SYNOPSIS

  use ChatBot::Module::Greetings;

=head1 DESCRIPTION

Stub documentation for ChatBot::Module::Greetings, created by h2xs. It looks like the author of the extension was negligent enough to leave the stub
unedited.

=cut

my $need_config = 'yes';
my (%users, %greetings);

my $read_cfg = sub {
	my $file = shift;
	my $cfgs  = XMLin($file);
	foreach my $type (keys %$cfgs) {
		my $cfg = $cfgs->{$type};
		if ($type eq 'greeting') {
			foreach my $greeting (@$cfg) {
				push @{$greetings{lc($greeting->{type})}}, 
						$greeting->{content};
			}
		}
		else {
			foreach my $guest (@$cfg) {
				my $user = new user;
				my @names;
				$user->sex($type);
				$user->nick($guest->{nick});
				foreach my $name (@{$guest->{name}}) {
					push @names, $name;
				}
				$user->name(\@names);
				$users{lc($user->nick)}=$user;
			}
		}
	}
	$need_config = undef;
 };

 sub _init {
	my ($self, $cfg) = @_;
	$self->{NAME} = 'Greetings';
	if ($cfg && $need_config) {
		$read_cfg->($cfg);
	}
	return; 
 }

 sub go {
	my ($self, $obj) = @_;
	return unless ($obj->message_autor eq '-SYS' &&
			$obj->message_text =~ /^([^ ]+)\sприходит на канал/);
	my $who   = $1;
	my $namei = int(rand(3));
	my $name  = $users{lc($who)}?$users{lc($who)}->name->[$namei]:$who;
	my $type  = $users{lc($who)}?$users{lc($who)}->sex:'default';
	my $typei = int(rand(3));
	my $text  = $greetings{$type}->[$typei];
	my $res = sprintf $text, $name;
	return $res if ($type ne 'default' || 
			 			$typei == $namei); 
	return;
 }

1;
__END__

=head1 AUTHOR

Cyrill Novgorodcev, E<lt>cynovg@gmai.comE<gt>

=cut
