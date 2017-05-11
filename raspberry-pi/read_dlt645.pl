#!/usr/bin/perl
#
# This is the perl version

use strict;
use warnings;
use Device::SerialPort;
use LWP::UserAgent;

#
# decode the frame
#
sub decode_dlt645 {

}

# encode dlt645
#
# The format of the frame
# cmd2 = "\xfe\xfe\xfe\xfe" . encode_dlt645("\xaa\xaa\xaa\xaa\xaa\xaa", 0x13, 0, "")
sub encode_dlt645 {
    # Get passed arguments
    my ($addr, $ctl, $lens, $data_tag) = @_;

    my $data_tag_2 = "";
    # my $lens_data = length($data_tag);
    foreach $byte (split //, $data_tag) {
        $data_tag_2 .= chr((ord($byte) + 0x33));
    }

    my $s1 = "\x68" . $addr . "\x68" . chr($ctl) . chr($lens) . $data_tag_2;

    # calculate checksum
    my $cs = 0;
    foreach $byte (split //, $s1) {
        $cs += (ord($byte));
    }
    $cs = $cs % 256;
    $s1 = $s1 . chr($cs);
    # add tail
    $s1 = $s1 . "\x16";

    return $s1;
}


#
# get the address
#
sub dlt645_get_addr {

    my $cmd2 = "\xfe\xfe\xfe\xfe" . encode_dlt645("\xaa\xaa\xaa\xaa\xaa\xaa", 0x13, 0, '');

}

#
# remove prefix "fe"
#
sub dlt645_rm_fe {

}

#
# read data
#
sub dlt645_read_data {

}

#
# read time
#
sub dlt645_read_time {

}


my $port = Device::SerialPort->new("/dev/ttyUSB0");
$port->databits(8);
$port->baudrate(2400);
$port->parity("even");
$port->stopbits(1);



