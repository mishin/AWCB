package ChatBot::Core::Queue;

use 5.006;
use strict;
use warnings;

our $VERSION = '0.01';

=head1 NAME

ChatBot::Core::Queue - Perl extension for Chat-Bot 

=head1 SYNOPSIS

  use ChatBot::Core::Queue;

	my $qu = ChatBot::Core::Queue->new('one');
	for ($qu->first; $qu->is_done; $qu->next) {
		printf "current %s\n", $qu->get_current;
	}

	my @line = ('one', 'two', 'three');
	my $qu = ChatBot::Core::Queue->new(\@line);
		for ($qu->first; $qu->is_done; $qu->next) {
		printf "current %s\n", $qu->get_current;
	}

	my %hash = ('1'=>'one', '3'=>'two', '2'=>'three');
	my $qu = ChatBot::Core::Queue->new(\%hash);
	for ($qu->first; $qu->is_done; $qu->next) {
		printf "current %s\n", $qu->get_current;
	}

=head1 DESCRIPTION

Этот модуль предназначен для создания очереди. В момент создания (или инициализации) он получает в качестве параметра набор, в данном случае модулей, которую помещает их в определенно последовательности. В данный момент предусмотрены три последовательности: скаляр, массив и хэш.
 Есои в качестве параметра был передан скаляр, то создается очередь с один элементом.
 Если в качестве параметра была передана ссылка на массив, то созданная очередь распределяется в порядке нахождения элементов в массиве. 
 Если в качестве параметра была переданна ссылка на хэш то созданная очередь распределяется в порядке при котором идексом служит ключь, а элементом - его значение.
 Очередь передвигается в одном направлении и возвратиться назад нельзя.

=head1 CONSTRUCTOR

=over 4

=item new ($scalar|$hash_ref|$array_ref)

Этот конструктор принимает в качестве параметра одно из трех возможных значений. Это либо скаляр, либо ссылка на массив, либо ссылка на хэш. После инициализации возвращается объект "очередь" методы которого рассмотрены ниже.

=back

=cut

 sub new {
 	my $proto = shift;
	my $class = ref($proto) || $proto;
	my $self  = {
		INDEX => undef,
		QUEUE =>[],
		MAXINDEX => undef
		};
	bless ($self, $class);
	$self->_init(@_) if @_;
	return $self;
 }

 sub _init {
	my ($self, $list) = @_;
	if (ref($list) eq 'ARRAY') {
		$self->{MAXINDEX} = @$list;
		push @{$self->{QUEUE}}, @$list;
	}
	elsif (ref($list) eq 'HASH') {
		my $index;
		foreach my $index (sort {$a<=>$b} keys %$list) {
			push @{$self->{QUEUE}}, $list->{$index};
			$self->{MAXINDEX} = @{$self->{QUEUE}};
		}
	}
	elsif (!ref($list)) {
		$self->{MAXINDEX} = 1;
		push @{$self->{QUEUE}}, $list;
	}
	else {
		print "wrong!\n";
	}
 }

=head2 METHODS

=over 4

=item first

Этот метод устанавливает внутренний индекс на первый элемент очереди.

=cut

 sub first {
	my $self = shift;
	$self->{INDEX} = 0;
	return $self;
 }

=item next

Этот метод перемещает внутренний индекс к следующему элементу очереди.

=cut

 sub next {
	my $self = shift;
	$self->{INDEX}++;
	return $self;
 }

=item  is_done 

Этот метод предназначен для проверки достижения окончания очереди. В случае, если очередь достигла своего последнего элемента возвращается значение undef, в противном случае возвращается значение 'true'.

=cut

 sub is_done {
	my $self = shift;
	return if ($self->{INDEX} == $self->{MAXINDEX});
	return 'true';
 }

=item get_current

Этот метод возвращает текущий элемент из очереди.

=back

=cut 

 sub get_current {
	my $self = shift;
	return $self->{QUEUE}->[$self->{INDEX}];
 }

1;
__END__

=head1 AUTHOR

Novgorodcev Cyrill, E<lt>cynovg@gmail.comE<gt>

=cut
