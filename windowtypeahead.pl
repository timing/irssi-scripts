use strict;
use Irssi;
use Data::Dumper;

my $lastkey = 0;
my $goto = 0;

sub key_pressed {
	my $key = shift;
	if( $key == 103 and $lastkey == 27 ){
		$goto = 1;
		return 1;
	}
	if( $goto == 1 ){
		my $input = Irssi::parse_special("\$L");
		my $numOfMatches = 0;
		my $matchedWindow;
		for my $window( Irssi::windows ){
			#print Dumper($window);			
			my $windowname = $window->{active}->{visible_name};
			#$windowname =~ s/#|&//g;

			if( $windowname =~ /\Q$input\E/i ){ # lowercase match
				$matchedWindow = $windowname;
				$numOfMatches++;
			}
		}
		if( $numOfMatches == 1 ){
			$goto = 0;
			Irssi::command("WINDOW GOTO $matchedWindow");
			Irssi::signal_emit('gui key pressed', 21); # clear line
		}

	}
	$lastkey = $key;

}

Irssi::signal_add_last('gui key pressed', 'key_pressed');
