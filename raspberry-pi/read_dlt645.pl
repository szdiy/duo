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


#
# encode dlt645
#
sub encode_dlt645 {

}

#
# get the address
#
sub dlt645_get_addr {

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



