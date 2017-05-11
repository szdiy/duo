#!/bin/bash

read proc < .pid_duo
kill -9 $proc
