#!/usr/bin/python

#---------------------------------------------------------------------------------------------
# read_dlt645 v01 -- a tool to test dlt645 meter through IR reader
# BSD license is applied to this code
#
# Copyright by Aixi Wang (aixi.wang@hotmail.com)
#
# ----------------------
# 2017-05-07
# Atommann
#
# The code is from https://github.com/aixiwang/python_dlt645
# It is used to read the data from the electricity meter and send them to szdiy server
# via the HTTP GET or POST method
#
# Prototyping purpose, the plan is to run this code on a Raspberry pi thus web developer
# can get the real data!
# In the mean time, the firmware coder can write code for ESP8266 and the hardware designer
# can make the hardware. When everything is ready we then switch to ESP8266.
# ----------------------
#
#---------------------------------------------------------------------------------------------
import serial
import sys,time
import httplib
import urllib

SERIAL_TIMEOUT_CNT = 10
#-------------------------
# decode_dlt645
#-------------------------
def decode_dlt645(data):
    print 'decode_dlt645 hex_str:',data.encode('hex')
    if ord(data[0]) != 0x68:
        print 'decode_dlt645 fail 1'
        return -1,'',''
    if ord(data[7]) != 0x68:
        print 'decode_dlt645 fail 2'
        return -1,'','',''
    
    # check length
    len_1 = len(data)
    # there are at lease 12 bytes of data
    if  len_1 < 12:
        print 'decode_dlt645 fail 3'
        return -1,'','',''
    
    # lent_2 is the total length
    len_2 = ord(data[9]) + 12
    if len_1 != len_2:
        print 'decode_dlt645 fail 4'    
        return -1,'','',''
    
    # check tail 0x16
    if ord(data[len_2-1]) != 0x16:
        print 'decode_dlt645 fail 5'    
        return -1,'','',''
    
    # check checksum
    cs = 0
    for i in xrange(0,len_2-2):
        #print hex(ord(data[i]))
        cs += ord(data[i])
        
    #print 'cs 1:',hex(cs)
    cs = cs % 256
    #print 'cs 2:',hex(cs)
    
    if cs != ord(data[len_2-2]):
        print 'decode_dlt645 fail 6'    
        return -1,'','',''    
   
    # extract data (sub 0x33)
    if ord(data[9]) > 0:
        d_out = ''
        for i in xrange(10,10+ord(data[9])):
            d_out += chr(ord(data[i])-0x33)
    else:
        d_out = ''
        
    return 0, data[1:7],d_out,ord(data[8])

# atommann
# data[1:7] : is the address
# d_out     : the data we want
# data[8]   : control code

#-------------------------
# encode_dlt645
#------------------------- 
def encode_dlt645(addr,ctl,lens,data_tag):

    data_tag_2 = ''
    lens_data = len(data_tag)
    for i in xrange(0,lens_data):
        data_tag_2 += chr(ord(data_tag[i])+0x33)
    

    s1 = '\x68' + addr + '\x68' + chr(ctl) + chr(lens) + data_tag_2

    
    
    # caculate cs
    cs = 0
    len_1 = len(s1)
    #print len_1
    for i in xrange(0,len_1):
        cs += ord(s1[i])
    cs = cs % 256
    s1 = s1 + chr(cs)
    # add tail
    s1 = s1 + '\x16'

    
    
    print 'encode_dlt645 hex_str:',s1.encode('hex')
    return s1
    
#-------------------------
# dlt645_get_addr
#-------------------------    
def dlt645_get_addr(serial):
    #print 'dlt645_get_addr ...'
    try:
        #cmd2 = '\xfe\xfe\xfe\xfe\x68\xaa\xaa\xaa\xaa\xaa\xaa\x68\x13\x00\xdf\x16'
        cmd2 = '\xfe\xfe\xfe\xfe' + encode_dlt645('\xaa\xaa\xaa\xaa\xaa\xaa',0x13,0,'')
        # Control Code 0x13 = read address
        # 0: There is no following data in this frame

        serial.write(cmd2)
        time.sleep(0.5)
        resp = ''
        c = ''
        i = 0
        while c != '\x16' and i < SERIAL_TIMEOUT_CNT:
            c = serial.read(1)
            if len(c) > 0:
                resp += c
            else:
                print '.'
                i += 1
        
        if i >= SERIAL_TIMEOUT_CNT:
            return -1,0
        
        resp1 = dlt_645_rm_fe(resp)

        #print 'resp1:',resp1.encode('hex')

        ret,addr,data,ctl = decode_dlt645(resp1)
        if ret == 0:
            return ret,addr
            
        
    except:
        print 'dlt645_get_addr exception!'
        return -1,''
        
#-------------------------
# dlt_645_rm_fe
#-------------------------         
def dlt_645_rm_fe(s):
    n = s.find('\x68')
    if n > 0:
        return s[n:]
    else:
        return ''
    
#-------------------------
# dlt645_read_data
#-------------------------    
def dlt645_read_data(serial,addr,data_tag):
    #print 'dlt645_read_data ...'
    try:
        cmd2 = '\xfe\xfe\xfe\xfe' + encode_dlt645(addr,0x11,4,data_tag)
        serial.write(cmd2)
        time.sleep(0.5)
        resp = ''
        c = ''
        i = 0
        while c != '\x16' and i < SERIAL_TIMEOUT_CNT:
            c = serial.read(1)
            if len(c) > 0:
                resp += c
            else:
                print '.'
                i += 1
            
        if i >= SERIAL_TIMEOUT_CNT:
            return -1,0
            
        resp1 = dlt_645_rm_fe(resp)    
        ret,addr,data,ctl = decode_dlt645(resp1)
        #print data.encode('hex')
        # BCD to decimal
        if ret == 0 and len(data) >= 8:
            i = ord(data[7])/16 *10000000
            i += ord(data[7])%16 *1000000

            i += ord(data[6])/16  *100000
            i += ord(data[6])%16   *10000
            
            i += ord(data[5])/16    *1000
            i += ord(data[5])%16     *100

            i += ord(data[4])/16      *10
            i += ord(data[4])%16
     
            return ret,i
        else:
            return -1,0
    except:
        print 'dlt645_read_data exception!'
        return -1,0

#-------------------------
# dlt645_read_time
#
# The time is encoded in 3 bytes (BCD)
#-------------------------    
def dlt645_read_time(serial,addr,data_tag):
    #print 'dlt645_read_time ...'
    try:
        cmd2 = '\xfe\xfe\xfe\xfe' + encode_dlt645(addr,0x11,4,data_tag)
        serial.write(cmd2)
        time.sleep(0.5)
        resp = ''
        c = ''
        i = 0
        while c != '\x16' and i < SERIAL_TIMEOUT_CNT:
            c = serial.read(1)
            if len(c) > 0:
                resp += c
            else:
                print '.'
                i += 1
            
        if i >= SERIAL_TIMEOUT_CNT:
            return -1,0
            
        resp1 = dlt_645_rm_fe(resp)    
        ret,addr,data,ctl = decode_dlt645(resp1)
        #print data.encode('hex')
        # need to convert to Unix time stamp
        if ret == 0 and len(data) >= 7:
            list1 =  list(bcd2digits(data[4:7]))
            str1 = ''.join(str(e) for e in list1)
            return ret,str1
        else:
            return -1,0
    except:
        print 'dlt645_read_data exception!'
        return -1,0


#-------------------------
# convert a BCD string to digits
#-------------------------       
def bcd2digits(chars):
    for char in chars:
        char = ord(char)
        for val in ((char >> 4, char & 0xF)):
            if val == 0xF:
                return
            yield val


#-------------------------
# read_dlt645_once
#-------------------------       
def read_dlt645_once(serial_port,baud_rate):
    try:
        serialport_baud = baud_rate
        serialport_path = serial_port
        s = serial.Serial(serialport_path,serialport_baud,parity=serial.PARITY_EVEN,timeout=0.1)
        #print s
    
    except:
        print 'init serial error!'
        return -1,0,0,0
    
    # get meter data, unit : 0.01 kWh

    retcode,addr = dlt645_get_addr(s)
    print retcode,addr.encode('hex')
    if retcode < 0:
        print 'get addr error'
        return -1,0,0,0
        
    print '-----------------------------------'
    retcode,data = dlt645_read_data(s,addr,'\x00\x00\x00\x00')
    print retcode,data
    if retcode == 0:
        f1 = data/100.0
        print 'total kWh:',f1
    else:
        return -1,0,0,0
        
    retcode,data = dlt645_read_data(s,addr,'\x00\x01\x00\x00')
    #print retcode,data
    if retcode == 0:
        f2 = data/100.0
        print 'ping kWh:',f2
    else:
        return -1,0,0,0
    retcode,data = dlt645_read_data(s,addr,'\x00\x02\x00\x00')
    #print retcode,data
    if retcode == 0:
        f3 = data/100.0
        print 'gu kWh:',f3
    else:
        return -1,0,0,0
   
    s.close()

    return 0,f1,f2,f3
    
#-------------------------
# main
#-------------------------
if __name__ == '__main__':
    #ret,f1,f2,f3 = read_dlt645_once('/dev/ttyUSB0',2400)
    #print ret,f1,f2,f3

    try:
        serialport_baud = int(sys.argv[1])
        serialport_path = sys.argv[2]
        s = serial.Serial(serialport_path,serialport_baud,parity=serial.PARITY_EVEN,timeout=0.1)
        #print s
        
    except:
        print 'init serial error!'
        sys.exit(-1)
    
    
    # get meter data, unit : 0.01 kWh
    # get meter addr
    retcode,addr = dlt645_get_addr(s)
    #print retcode,addr
    if retcode < 0:
        print 'get addr error'
            
    print '-----------------------------------'
    retcode,data = dlt645_read_data(s,addr,'\x00\x00\x00\x00')
    #print retcode,data
    if retcode == 0:
        total_kwh = data/100.0
        print 'total kWh:',total_kwh
    else:
        print 'read error!'

    # read date
    retcode,data = dlt645_read_data(s,addr,'\x01\x01\x00\x04')
    #print retcode,data
    if retcode == 0:
        #print 'Date:',data
        date_str = str(data)
        time_str = '20' + date_str[0:2] + '-' + date_str[2:4] + '-' + date_str[4:6] + ' '
    else:
        print 'read error!'


    # read time    
    retcode,data_str = dlt645_read_time(s,addr,'\x02\x01\x00\x04')
    s.close()
    #print retcode, data_str
    if retcode == 0:
        time_str = time_str + data_str[4:6] + ':' + data_str[2:4] + ':' + data_str[0:2]
    else:
        print 'read error!'

    #print time_str

    time_stamp = time.mktime(time.strptime(time_str, '%Y-%m-%d %H:%M:%S'))
    #print time_stamp

    # The API format
    #https://api.szdiy.org/duo/upload?node=<node_id>&total=&time=

    #curl -X POST -H "Authorization: Token xxx" -d 'total=5120.38&time=1506602753.0' "https://api.szdiy.org/duo/device/001/power"
 
    #web_url = "https://api.szdiy.org/duo/";
    #web_url = "https://api.szdiy.org/duo/upload?node=001&"

    token = "" # put your token here
    headers = {"Content-type": "application/x-www-form-urlencoded", "Authorization": "Token {}".format(token)}
    web_url = "https://api.szdiy.org/duo/device/001/power"
    #params = "total=" + str(total_kwh) + "&time=" + str(time_stamp)
    params = urllib.urlencode({'total': total_kwh, 'time': time_stamp})

    print params

    # + str(total_kwh) + "&time=" + str(time_stamp)
    print web_url
    c = httplib.HTTPSConnection("api.szdiy.org")
    #c.request("GET", web_url)
    c.request("POST", web_url, params, headers)
    response = c.getresponse()
    print response.status, response.reason
    data = response.read()
    print data

