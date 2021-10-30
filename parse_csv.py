# -*- coding: utf-8 -*-
"""
Created on Fri Oct 27 14:23:46 2021
@author: Priyanka Bekal, Sreeja Boyina, Sreeja Poreddy, Suvarna Latha Pamidimukkala
Title: Check Point 1 - parsing an input file

This program is used to parse throuh an input file (csv) defined by the user
and display the data read through the file.

csv module is used to implement the functionality decribed above.
"""
        
# importing csv module
import csv

# input file name
InputFileName = "input.csv"

# reading csv file
with open(InputFileName, 'r') as CsvFile:
    # creating a csv reader object which will iterate over lines in the given input csv file
    CsvReader = csv.reader(CsvFile) # delimiter = ','
    
    # print the heading of each column
    title = next(CsvReader)
    print(title[0], title[1], title[2])

    # using for loop to print data from each line using reader object
    for line in CsvReader:
        print(line[0], '\t', '\t', line[1], '\t', '\t', line[2])
    