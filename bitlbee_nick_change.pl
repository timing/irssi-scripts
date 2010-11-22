use strict;
use Data::Dumper;
use vars qw($VERSION %IRSSI);

$VERSION = '1.3';
%IRSSI = (
	authors		=> 'Tijmen "timing" Ruizendaal',
	contact		=> 'tijmen.ruizendaal@gmail.com',
	name		=> 'BitlBee_nick_change',
	description 	=> 'Shows an IM nickchange in an Irssi way. (in a query and in the bitlbee channel).',
	license		=> 'GPLv2',
	url		=> 'http://the-timing.nl/stuff/irssi-bitlbee',
	changed		=> '2010-07-28'
);

my $bitlbee_server; # server object
my @control_channels; # mostly: &bitlbee, &facebook etc.
init();

sub init { # if script is loaded after connect
	my @servers = Irssi::servers();
	foreach my $server(@servers) {
		if( $server->isupport('NETWORK') eq 'BitlBee' ){
			$bitlbee_server = $server;
			my @channels = $server->channels();
			foreach my $channel(@channels) {
				if( $channel->{mode} =~ /C/ ){
					push @control_channels, $channel->{name} unless (grep $_ eq $channel->{name}, @control_channels);
				}
			}
		}
	}
}
# if connect after script is loaded
Irssi::signal_add_last('event 005' => sub {
	my( $server ) = @_;
	if( $server->isupport('NETWORK') eq 'BitlBee' ){
		$bitlbee_server = $server;
	}
});
# if new control channel is synced after script is loaded
Irssi::signal_add_last('channel sync' => sub {
	my( $channel ) = @_;
	if( $channel->{mode} =~ /C/ && $channel->{server}->{tag} eq $bitlbee_server->{tag} ){
		push @control_channels, $channel->{name} unless (grep $_ eq $channel->{name}, @control_channels);
	}
});

# BEGIN bitlbee_nick_change.pl

sub event_notice {
	my ($server, $msg, $nick, $address, $target) = @_;
	if( $server->{tag} eq $bitlbee_server->{tag} && $msg =~ /User.*changed name to/) {
		#print "$server, $msg, $nick, $address, $target)";
		my $parsed = $msg;
		$parsed =~ s/.* - User `(.*)' changed name to `(.*)'/$1,$2/;
		my($target_nick, $friendly_name) = split(/,/, $parsed, 2);

		# find window based on nick
		my $window = $server->window_find_item($target_nick);	
		if ($window) {
			$window->printformat(MSGLEVEL_CRAP, 'nick_change', $target_nick, 'changed name to `'.$friendly_name.'`');
			Irssi::signal_stop();
			return;
		}
		# find window based on target
		$window = $server->window_find_item($target);
		if( $window ) {
			$window->printformat(MSGLEVEL_CRAP, 'nick_change', $target_nick, 'changed name to `'.$friendly_name.'`');
			Irssi::signal_stop();
		}
	}		
};

Irssi::signal_add_last('message public', 'event_notice');
Irssi::theme_register(['nick_change', '{channick_hilight $0} $1']);

# END bitbee_nick_change.pl
