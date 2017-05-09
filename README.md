# Project duo

The goal of this project is to read the data from the electricity meter in SZDIY Hackspace and send the data to a server, so we can know how much energy we use every day.

At beginning we should just read the kilowatt hour [kWh] data. As the projects growing, we should also read other data as well.

## The Name

duo is the Pinyin of the Chinese character 度(read as duó), which means "to estimate", this character has another pronunciation which is dù, it is the unit of electricity in Chinese. So we choose it as the project name.

## Hardware

The present hardware is designed with gEDA (http://www.geda-project.org/).

The configuration is an ESP8266 with a RS-485 Transceiver.

## Firmware

The firmware is powered by esp-open-rtos, before building set the enviornment variable 'ESP_OPEN_RTOS' to the absolute path of the esp-open-rtos directory.

The electricity meter supports the DL/T645-2007 protocol. But we only need to read some interesting data such as the total kWh data.

## Firmware Over-The-Air (FOTA)

It will be very convenient to have this function. The developers can sit at home and upgrade/debug/play with the firmware.

## Server Side
