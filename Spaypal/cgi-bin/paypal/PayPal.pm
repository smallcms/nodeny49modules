package Business::PayPal;

use 5.6.1;
use strict;
use warnings;

our $VERSION = '0.04';

use Net::SSLeay 1.14;
use Digest::MD5 qw(md5_hex);
#use CGI;

our $Cert = <<CERT;
-----BEGIN CERTIFICATE-----
MIIGSzCCBTOgAwIBAgIQLjOHT2/i1B7T//819qTJGDANBgkqhkiG9w0BAQUFADCB
ujELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2Ug
YXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykwNjE0MDIGA1UEAxMr
VmVyaVNpZ24gQ2xhc3MgMyBFeHRlbmRlZCBWYWxpZGF0aW9uIFNTTCBDQTAeFw0x
MTAzMjMwMDAwMDBaFw0xMzA0MDEyMzU5NTlaMIIBDzETMBEGCysGAQQBgjc8AgED
EwJVUzEZMBcGCysGAQQBgjc8AgECEwhEZWxhd2FyZTEdMBsGA1UEDxMUUHJpdmF0
ZSBPcmdhbml6YXRpb24xEDAOBgNVBAUTBzMwMTQyNjcxCzAJBgNVBAYTAlVTMRMw
EQYDVQQRFAo5NTEzMS0yMDIxMRMwEQYDVQQIEwpDYWxpZm9ybmlhMREwDwYDVQQH
FAhTYW4gSm9zZTEWMBQGA1UECRQNMjIxMSBOIDFzdCBTdDEVMBMGA1UEChQMUGF5
UGFsLCBJbmMuMRowGAYDVQQLFBFQYXlQYWwgUHJvZHVjdGlvbjEXMBUGA1UEAxQO
d3d3LnBheXBhbC5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCd
szetUP2zRUbaN1vHuX9WV2mMq0IIVQ5NX2kpFCwBYc4vwW/CHiMr+dgs8lDduCfH
5uxhyRxKtJa6GElIIiP8qFB5HFWf1uUgoDPC1he4HaxUkowCnVEqjEowOy9R9Cr4
yyrmqmMEDccVsx4d3dOY2JF1FrLDHT7qH/GCBnyYw+nZJ88ci6HqnVJiNM+NX/D/
d7Y3r3V1bp7y1DaJwK/z/uMwNCC+lcM59w+nwAvLutgCW6WitFHMB+HpSsOSJlIZ
ydpj0Ox+javRR1FIdhRUFMK4wwcbD8PvULi1gM+sYsJIzP0mHDlhWRIDImG1zmy2
x7ZLp0HA5WayjI5aSn9fAgMBAAGjggHzMIIB7zAJBgNVHRMEAjAAMB0GA1UdDgQW
BBQxqt0MVbSO4lWE5aB52xc8nEq5RTALBgNVHQ8EBAMCBaAwQgYDVR0fBDswOTA3
oDWgM4YxaHR0cDovL0VWU2VjdXJlLWNybC52ZXJpc2lnbi5jb20vRVZTZWN1cmUy
MDA2LmNybDBEBgNVHSAEPTA7MDkGC2CGSAGG+EUBBxcGMCowKAYIKwYBBQUHAgEW
HGh0dHBzOi8vd3d3LnZlcmlzaWduLmNvbS9ycGEwHQYDVR0lBBYwFAYIKwYBBQUH
AwEGCCsGAQUFBwMCMB8GA1UdIwQYMBaAFPyKULqeuSVae1WFT5UAY4/pWGtDMHwG
CCsGAQUFBwEBBHAwbjAtBggrBgEFBQcwAYYhaHR0cDovL0VWU2VjdXJlLW9jc3Au
dmVyaXNpZ24uY29tMD0GCCsGAQUFBzAChjFodHRwOi8vRVZTZWN1cmUtYWlhLnZl
cmlzaWduLmNvbS9FVlNlY3VyZTIwMDYuY2VyMG4GCCsGAQUFBwEMBGIwYKFeoFww
WjBYMFYWCWltYWdlL2dpZjAhMB8wBwYFKw4DAhoEFEtruSiWBgy70FI4mymsSweL
IQUYMCYWJGh0dHA6Ly9sb2dvLnZlcmlzaWduLmNvbS92c2xvZ28xLmdpZjANBgkq
hkiG9w0BAQUFAAOCAQEAisdjAvky8ehg4A0J3ED6+yR0BU77cqtrLUKqzaLcLL/B
wuj8gErM8LLaWMGM/FJcoNEUgSkMI3/Qr1YXtXFvdqo3urqMhi/SsuUJU85Gnoxr
Vr0rWoBqOOnmcsVEgtYeusK0sQbxq5JlE1eq9xqYZrKuOuA/8JS1V7Ss1iFrtA5i
pwotaEK3k5NEJOQh9/Zm+fy1vZfUyyX+iVSlmyFHC4bzu2DlzZln3UzjBJeXoEfe
YjQyLpdUhUhuPslV1qs+Bmi6O+e6htDHvD05wUaRzk6vsPcEQ3EqsPbdpLgejb5p
9YDR12XLZeQjO1uiunCsJkDIf9/5Mqpu57pw8v1QNA==
-----END CERTIFICATE-----
CERT
chomp($Cert);

our $Certcontent = <<CERTCONTENT;
Subject Name: /1.3.6.1.4.1.311.60.2.1.3=US/1.3.6.1.4.1.311.60.2.1.2=Delaware/businessCategory=Private Organization/serialNumber=3014267/C=US/postalCode=95131-2021/ST=California/L=San Jose/street=2211 N 1st St/O=PayPal, Inc./OU=PayPal Production/CN=www.paypal.com
Issuer  Name: /C=US/O=VeriSign, Inc./OU=VeriSign Trust Network/OU=Terms of use at https://www.verisign.com/rpa (c)06/CN=VeriSign Class 3 Extended Validation SSL CA
CERTCONTENT
chomp($Certcontent);


# creates new PayPal object.  Assigns an id if none is provided.
sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {
        id => undef,
        address => 'https://www.paypal.com/cgi-bin/webscr',
        @_,
    };
    bless $self, $class;
    $self->{id} = md5_hex(rand()) unless $self->{id};
    return $self;
}

# returns current PayPal id
sub id {
    my $self = shift;
    return $self->{id};
}

# takes a reference to a hash of name value pairs, such as from a CGI query
# object, which should contain all the name value pairs which have been
# posted to the script by PayPal's Instant Payment Notification
# posts that data back to PayPal, checking if the ssl certificate matches,
# and returns success or failure, and the reason.
sub ipnvalidate {
    my $self = shift;
    my $query = shift;
    $$query{cmd} = '_notify-validate';
    my $id = $self->{id};
    my ($succ, $reason) = $self->postpaypal($query); 
    return (wantarray ? ($id, $reason) : $id)
        if $succ;
    return (wantarray ? (undef, $reason) : undef);
}

# this method should not normally be used unless you need to test, or if
# you are overriding the behaviour of ipnvalidate.  It takes a reference
# to a hash containing the query, posts to PayPal with the data, and returns
# success or failure, as well as PayPal's response.
sub postpaypal {
    my $self = shift;
    my $address = $self->{address};
    my $query = shift; # reference to hash containing name value pairs
    my ($site, $port, $path);

    #following code splits an url into site, port and path components
    my @address = split /:\/\//, $address, 2;
    @address = split /(?=\/)/, $address[1], 2;
    if ($address[0] =~ /:/) {
        ($site, $port) = split /:/, $address[0];
    }
    else {
        ($site, $port) = ($address[0], '443');
    }
    $path = $address[1];
    my ($page, 
        $response, 
        $headers, 
        $ppcert, 
        ) = Net::SSLeay::post_https3($site, 
                                         $port, 
                                         $path, 
                                         '', 
                                         Net::SSLeay::make_form(%$query));


    my $ppx509 = Net::SSLeay::PEM_get_string_X509($ppcert);
    my $ppcertcontent =
    'Subject Name: '
        . Net::SSLeay::X509_NAME_oneline(
               Net::SSLeay::X509_get_subject_name($ppcert))
            . "\nIssuer  Name: "
                . Net::SSLeay::X509_NAME_oneline(
                       Net::SSLeay::X509_get_issuer_name($ppcert))
                    . "\n";

    chomp $ppx509;
    chomp $ppcertcontent;
    return (wantarray ? (undef, "PayPal cert failed to match: $ppx509\n$Cert") : undef)  
        unless $Cert eq $ppx509;
    return (wantarray ? (undef, "PayPal cert contents failed to match $ppcertcontent") : undef)        unless $ppcertcontent eq "$Certcontent";
    return (wantarray ? (undef, 'PayPal says transaction INVALID') : undef)
        if $page eq 'INVALID';
    return (wantarray ? (1, 'PayPal says transaction VERIFIED') : 1)
        if $page eq 'VERIFIED';
    warn "Bad stuff happened\n$page";
    return (wantarray ? (undef, "Bad stuff happened") :undef);
}

 

1;

=head1 NAME

Business::PayPal - Perl extension for automating PayPal transactions

=head1 ABSTRACT

Business::PayPal makes the automation of PayPal transactions as simple
as doing credit card transactions through a regular processor.  It includes
methods for creating PayPal buttons and for validating the Instant Payment
Notification that is sent when PayPal processes a payment.

=head1 SYNOPSIS

  To generate a PayPal button for use on your site
  Include something like the following in your CGI

  use Business::PayPal;
  my $paypal = Business::PayPal->new;
  my $button = $paypal->button(
      business => 'dr@dursec.com',
      item_name => 'CanSecWest Registration Example',
      return => 'http://www.cansecwest.com/return.cgi',
      cancel_return => 'http://www.cansecwest.com/cancel.cgi',
      amount => '1600.00',
      quantity => 1,
      notify_url => http://www.cansecwest.com/ipn.cgi
  );
  my $id = $paypal->id;

  #store $id somewhere so we can get it back again later
  #store current context with $id
  #Apache::Session works well for this
  #print button to the browser
  #note, button is a CGI form, enclosed in <form></form> tags



  To validate the Instant Payment Notification from PayPal for the 
  button used above include something like the following in your 
  'notify_url' CGI.

  use CGI;
  my $query = new CGI;
  my %query = $query->Vars;
  my $id = $query{custom};
  my $paypal = Business::PayPal->new(id => $id);
  my ($txnstatus, $reason) = $paypal->ipnvalidate(\%query);
  die "PayPal failed: $reason" unless $txnstatus;
  my $money = $query{payment_gross};
  my $paystatus = $query{payment_status};
  
  #check if paystatus eq 'Completed'
  #check if $money is the ammount you expected
  #save payment status information to store as $id


  To tell the user if their payment succeeded or not, use something like
  the following in the CGI pointed to by the 'return' parameter in your
  PayPal button.

  use CGI;
  my $query = new CGI;
  my $id = $query{custom};

  #get payment status from store for $id
  #return payment status to customer


=head1 DESCRIPTION

=head1 MAINTAINER

phred, E<lt>fred@redhotpenguin.comE<gt>

=head1 AUTHOR

mock, E<lt>mock@obscurity.orgE<gt>

=head1 LICENSE

Copyright (c) 2010, phred E<lt>fred@redhotpenguin.comE<gt>. All rights reserved.

Copyright (c) 2002, mock E<lt>mock@obscurity.orgE<gt>.  All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
