# -*- coding: utf-8 -*-
"""
Created on Fri Oct 29 14:23:46 2021

@author: HP
"""

import csv

with open ('Input.csv','r') as csv_file:
    csv_reader = csv.reader(csv_file)
    print(csv_reader)
    next(csv_reader)
    for line in csv_reader:
        print(line)
    