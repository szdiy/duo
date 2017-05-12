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
    # get passed arguments
    my ($data) = @_;
    my @data_array = split (//, $data);


    if(ord(@data_array[0]) != 0x68) {
        print "decode_dlt645 fails 1";
        return -1, "","","";
    }
    if(ord(@data_array[7]) != 0x68) {
        print "decode_dlt645 fails 2";
        return -1, "","","";
    }
    
    my $len_1 = length($data);
    if ($len_1 < 12) {
        print "decode_dlt645 fail 3";
        return -1, "","","";
    }

    my $len_2 = ord(@data_array[9]) + 12;
    if ($len_1 != $len_2) {
        print "decode_dlt645 fail 4";
        return -1, "","","";
    }

    # check tail 0x16
    if (ord(@data_array[$len_2 - 1]) != 0x16) {
        print "decode_dlt645 fail 5";
        return -1, "","","";
    }

    # check checksum
    my $cs = 0;
    for (my $i = 0; $i < ($len_2 - 2); $i++) {
        $cs += ord(@data_array[$i]);
    }

    $cs = $cs % 256;
    #printf "%x", $cs;
    if ($cs != ord(@data_array[$len_2 -2])) {
        print "decode_dlt645 fail 6";
        return -1, "","","";
    }

    my $d_out = "";
    # extract data (sub 0x33)
    if (ord(@data_array[9]) > 0) {
        for (my $i = 10; $i < (10 + ord(@data_array[9])); $i++) {
            #print $i, "\n";
            #printf "%x\n", ord(@data_array[$i]);
            $d_out .= chr(ord(@data_array[$i]) - 0x33);
        }
    } else {
        $d_out = "";
    }

    my $addr = substr($data, 1, 6);

    # seq: retcode, addr, data, ctl
    return (0, $addr, $d_out, ord(@data_array[8]));
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



