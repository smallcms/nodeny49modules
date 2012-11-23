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
MIIGUzCCBTugAwIBAgIQQcO4g86BppQ1JLIKmUw/VDANBgkqhkiG9w0BAQUFADCB
ujELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlTaWduLCBJbmMuMR8wHQYDVQQL
ExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTswOQYDVQQLEzJUZXJtcyBvZiB1c2Ug
YXQgaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYSAoYykwNjE0MDIGA1UEAxMr
VmVyaVNpZ24gQ2xhc3MgMyBFeHRlbmRlZCBWYWxpZGF0aW9uIFNTTCBDQTAeFw0x
MTA5MDEwMDAwMDBaFw0xMzA5MzAyMzU5NTlaMIIBFzETMBEGCysGAQQBgjc8AgED
EwJVUzEZMBcGCysGAQQBgjc8AgECEwhEZWxhd2FyZTEdMBsGA1UEDxMUUHJpdmF0
ZSBPcmdhbml6YXRpb24xEDAOBgNVBAUTBzMwMTQyNjcxCzAJBgNVBAYTAlVTMRMw
EQYDVQQRFAo5NTEzMS0yMDIxMRMwEQYDVQQIEwpDYWxpZm9ybmlhMREwDwYDVQQH
FAhTYW4gSm9zZTEWMBQGA1UECRQNMjIxMSBOIDFzdCBTdDEVMBMGA1UEChQMUGF5
UGFsLCBJbmMuMRowGAYDVQQLFBFQYXlQYWwgUHJvZHVjdGlvbjEfMB0GA1UEAxQW
d3d3LnNhbmRib3gucGF5cGFsLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC
AQoCggEBAOgLoTxH7wR+fQFXznItNcPuPDKQhdUIWLRvG2uMDQDeolaPF4L5Dvn5
yazgycHMjYBxinH02Sc7k69OqFDCiOiLpIpRLsVCqTZUixIHmsZP6gPMYsYm6a+C
cvpOnqYQ02XE+CIWjN92cK5BKBebtPc9us0MtcPAnuU8Pyp4l7OdLNukjDgXuxZ3
rbnKKb7Z/3kkmzQTeshNWbDLYcgUR2OiibD/lsQpcoYtlPcsXcA+R+HAaYIY3JXc
U2q7RwxCK19kSRcuxKdNNV+/RjBL3Ttbf0LLMiqjWgKpAWpRUjfu08tl7vxR6SCl
aRzoJwnQDwosBtT8I8OiZ8sldmc4btkCAwEAAaOCAfMwggHvMAkGA1UdEwQCMAAw
HQYDVR0OBBYEFE/LQp+SfkYxbltojftEGXrE7GTQMAsGA1UdDwQEAwIFoDBCBgNV
HR8EOzA5MDegNaAzhjFodHRwOi8vRVZTZWN1cmUtY3JsLnZlcmlzaWduLmNvbS9F
VlNlY3VyZTIwMDYuY3JsMEQGA1UdIAQ9MDswOQYLYIZIAYb4RQEHFwYwKjAoBggr
BgEFBQcCARYcaHR0cHM6Ly93d3cudmVyaXNpZ24uY29tL3JwYTAdBgNVHSUEFjAU
BggrBgEFBQcDAQYIKwYBBQUHAwIwHwYDVR0jBBgwFoAU/IpQup65JVp7VYVPlQBj
j+lYa0MwfAYIKwYBBQUHAQEEcDBuMC0GCCsGAQUFBzABhiFodHRwOi8vRVZTZWN1
cmUtb2NzcC52ZXJpc2lnbi5jb20wPQYIKwYBBQUHMAKGMWh0dHA6Ly9FVlNlY3Vy
ZS1haWEudmVyaXNpZ24uY29tL0VWU2VjdXJlMjAwNi5jZXIwbgYIKwYBBQUHAQwE
YjBgoV6gXDBaMFgwVhYJaW1hZ2UvZ2lmMCEwHzAHBgUrDgMCGgQUS2u5KJYGDLvQ
UjibKaxLB4shBRgwJhYkaHR0cDovL2xvZ28udmVyaXNpZ24uY29tL3ZzbG9nbzEu
Z2lmMA0GCSqGSIb3DQEBBQUAA4IBAQAoyJqVjD1/73TyA0GU8Q2hTuTWrUxCE/Cv
D7b3zgR3GXjri0V+V0/+DoczFjn/SKxi6gDWvhH7uylPMiTMPcLDlp8ulgQycxeF
YxgxgcNn37ztw4f2XV/U9N5MRJrrtj5Sr4kAzEk6jPORgh1XfklgPgb1k/mJWWZw
l1AksZwbxMp/adNq1+gyfG65cIgVMiLXYYMr+UJXwey+/e6GVcOhLdEiKmxT6u3M
lsQPBEHGmGM3WDRpCqb7lBPMXP9GkNBfF36IVOu7jzgP69prSKjICk2fPC1+ktAF
KUmGOOMrAuewXyJ8wRuRjbtPikYdApAnHjd7quQWApwUJyOCKr99
-----END CERTIFICATE-----
CERT
chomp($Cert);

our $Certcontent = <<CERTCONTENT;
Subject Name: /1.3.6.1.4.1.311.60.2.1.3=US/1.3.6.1.4.1.311.60.2.1.2=Delaware/businessCategory=Private Organization/serialNumber=3014267/C=US/postalCode=95131-2021/ST=California/L=San Jose/street=2211 N 1st St/O=PayPal, Inc./OU=PayPal Production/CN=www.sandbox.paypal.com
Issuer  Name: /C=US/O=VeriSign, Inc./OU=VeriSign Trust Network/OU=Terms of use at https://www.verisign.com/rpa (c)06/CN=VeriSign Class 3 Extended Validation SSL CA
CERTCONTENT
chomp($Certcontent);


# creates new PayPal object.  Assigns an id if none is provided.
sub new {
    my $invocant = shift;
    my $class = ref($invocant) || $invocant;
    my $self = {
        id => undef,
        address => 'https://www.sandbox.paypal.com/cgi-bin/webscr',
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
