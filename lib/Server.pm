package Server;

use strict;
use warnings;
use utf8;
use Data::Dumper;
use feature qw/ say /;
use AnyEvent::Socket;
use AnyEvent::Handle;

sub new {
    my ($class) = @_;

    my $self = bless {
        ip => '127.0.0.1',
        port => 8089,
    },$class;

    $self;
}

sub run {
    my $self = shift;
    my @watchers = ();
    my $data = "";
    $self->{guard} = tcp_server $self->{ip}, $self->{port}, sub {
        my ($fh, $host, $port) = @_;
        my $handle; $handle = AnyEvent::Handle->new(
            fh => $fh,
            on_eof => sub{ $handle->destroy; }
        );
        $handle->push_read(line=> "\015\012\015\012", sub {
            my ($h,$l) = @_;
            $data .= $l;

            say "starting...";

            say "continue!";
            #$handle->destroy;
        });
        my $w;
        push @watchers, $w;
         $w = AnyEvent->timer(after => 5, cb => sub{ 
            say "timer done";
            $handle->push_write("the data is: " . $data . "\n\015\012\015\012");
            $handle->destroy;
            undef $w;
        });
        
    }, sub {
        my ($fh, $thishost, $thisport) = @_;
    };

    AE->cv->recv;   
}

1;