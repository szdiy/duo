#!/usr/bin/python

#---------------------------------------------------------------------------------------------
# read MH-Z14A CO2 sensor
#
# The code base is from https://github.com/alpacagh/MHZ14-CO2-Logger

# ----------------------
# 2017-09-24
# Atommann
#
#
#---------------------------------------------------------------------------------------------
import time
import sys
import serial
import argparse
import httplib

defaultPort = '/dev/ttyUSB0'

class MHZ14AReader:
    """
    Simple sensor communication class.
    No calibration method provided to avoid accidental sensor bricking (calibrating to wrong levels)
    """

    _requestSequence = [0xff, 0x01, 0x86, 0x00, 0x00, 0x00, 0x00, 0x00, 0x79]
    """
    https://www.google.com/#q=MH-Z14A+datasheet+pdf
    """

    def __init__(self, port, open_connection=True):
        """
        :param string port: path to tty
        :param bool open_connection: should port be opened immediately
        """
        self.port = port
        """TTY name"""
        self.link = None
        """Connection with sensor"""
        if open_connection:
            self.connect()

    def connect(self):
        """
        Open tty connection to sensor
        """
        if self.link is not None:
            self.disconnect()
        self.link = serial.Serial(self.port,
                                  9600,
                                  bytesize=serial.EIGHTBITS,
                                  parity=serial.PARITY_NONE,
                                  stopbits=serial.STOPBITS_ONE,
                                  dsrdtr=True,
                                  timeout=5,
                                  interCharTimeout=0.1)


    def disconnect(self):
        """
        Terminate sensor connection
        """
        if self.link:
            self.link.close()

    def _send_data_request(self):
        """
        Send data request control sequence
        """
        for byte in self._requestSequence:
            self.link.write(chr(byte))

    def get_status(self):
        """
        Read data from sensor
        :return {ppm}|None:
        """
        self._send_data_request()
        response = self.link.read(9)
        if len(response) == 9:
            return {"ppm": ord(response[2]) * 0xff + ord(response[3])}
        return None


#-------------------------
# main
#-------------------------
if __name__ == '__main__':

    parser = argparse.ArgumentParser(description='Read data from MH-Z14A CO2 sensor.')
    parser.add_argument('tty', default=defaultPort, help='tty port to connect', type=str, nargs='?')
    parser.add_argument('timeout', default=10, help='timeout between requests', type=int, nargs='?')
    parser.add_argument('--single', action='store_true', help='single measure')
    parser.add_argument('--quiet', '-q', action='store_true', help='be quiet')
    args = parser.parse_args()
    port = args.tty
    timeout = args.timeout
    if args.single:
        timeout = 0

    conn = MHZ14AReader(port)
    if not args.quiet:
        sys.stderr.write("Connected to %s\n" % conn.link.name)

    while True:
        status = conn.get_status()
        time_stamp = time.time()
        if status:
            print "%s\t%d" % (time.strftime("%Y-%m-%d %H:%M:%S"), status["ppm"])
        else:
            print "No data received"

        sys.stdout.flush()

        web_url = "https://api.szdiy.org/duo/upload?node=002&co2_ppm=" + str(status["ppm"]) + "&time=" + str(time_stamp)
        print web_url
        #"""
        c = httplib.HTTPSConnection("api.szdiy.org")
        c.request("GET", web_url)
        response = c.getresponse()
        print response.status, response.reason
        data = response.read()
        print data
        #"""

        if timeout != 0:
            time.sleep(timeout)
        else:
            break
    conn.disconnect()

