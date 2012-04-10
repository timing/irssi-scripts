use strict;
use Irssi::TextUI;
use Time::HiRes;

# SETTINGS:
# [Log]
# typingspeedlog_file
# The path to the logfile. For example: /home/dude/typingspeed.log
#
# Changelog:
# 
# 2007-11-11 (version 0.2.5)
# * File logging! Thanks to the three lines of code from Jeroen van Nieuwenhuizen (http://www.jeroen.se/blog/).
#
# 2007-11-10 (version 0.2)
# * Fix: Changed from Irssi::timeout to Time::HiRes. Irssi::timeout leaks memory. Thanks to Bas Zoetekouw for the solution. (no blog)

use vars qw($VERSION %IRSSI);
$VERSION = '0.2.5';
%IRSSI = (
    authors     => 'Tijmen Ruizendaal',
    contact     => 'tijmen.ruizendaal@gmail.com',
    name        => 'typingspeed.pl',
    description => 'Adds a statusbar item (typing_speed) which shows the number of chars per minute in the last message',
    license     => 'GPLv2',
    url         => 'http://the-timing.nl',
    changed     => '2007-11-11'
);

my $length;
my $chars_per_minute;

my $seconds;

Irssi::signal_add_last 'gui key pressed' => sub {
    my $key = shift;
    if($key == 10){
	$seconds = Time::HiRes::gettimeofday() - $seconds;
	if($seconds != 0){
		$chars_per_minute = int((($length-1)*60)/$seconds);
		Irssi::statusbar_items_redraw('typing_speed');
		if (Irssi::settings_get_str('typingspeedlog_file') ne '' && $chars_per_minute > 0 && $chars_per_minute < 1000 ) {
			my $filename = Irssi::settings_get_str('typingspeedlog_file');
			open (F,">>$filename") ;
			print F time()." ".$chars_per_minute."\n" ;
			close F ;
		}
	}	
	$seconds=0;
    }else{
	my $width = 0;
	my $padChar = "";
	$length = Irssi::parse_special ( "\$[-!$width$padChar]\@L" );
    }
    if($length == 1){
	$seconds = Time::HiRes::gettimeofday();
    }elsif($length == 0){
	$seconds=0;
    }
};

sub typing_speed {
    my ($item, $get_size_only) = @_;
    $item->default_handler($get_size_only, "{sb chars/minute: $chars_per_minute}", undef, 1);
}

Irssi::settings_add_str("log","typingspeedlog_file",'');
Irssi::statusbar_item_register('typing_speed', undef, 'typing_speed');
Irssi::statusbars_recreate_items();
