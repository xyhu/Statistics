infile = open(filename, "r")


# strip off the empty space
# removes characters from the start and end of a string only
# line here is of type 'str'
line = line.strip()
# stip off the 0's at the start and the end of a string
line = line.strip('0')

# Use str.replace() to remove text from everywhere in the string:
# remove the comma sign
line = line.replace(',', '')

# For a set of characters use a regular expression:

import re
line = '2015-09-24T00:02:39Z'
# don't forget the [], inside the [] are the things you want to replace/remove
re.sub(r'[TZ]', '', line)



# remove \n, \r, |, ", &nbsp
cleanll = line.replace('\n', '').replace('"', '').replace('|', '').replace('&nbsp;','').replace('\r', ' ')
    
# cleaning more: remove non-ascii characters and numbers, and punctuations and white spaces
# split into a list of words
t1 = re.sub(r'[^\x00-\x7F]+|[0-9]+','', cleanll)
t2 = re.split('[\W]+', t1)
t3 = [x for x in t2 if x != '']





#### read in the topic term prob for tagging prediction as dictionary
topic_term_dict2 = []
with open('topic_term_dict.csv', 'r') as inputfile:
	reader = csv.DictReader(inputfile)
	for row in reader:
		topic_term_dict2.append(dict((x, float(row[x])) for x in row))


'''
Sum values with the same key - the document count for 100 topics
1. converting every element of the list - a dict into Counter
A Counter is a dict subclass for counting hashable objects. It is an unordered 
collection where elements are stored as dictionary keys and their counts are 
stored as dictionary values.
2. sum over the same key values
reduce: Apply function of two arguments cumulatively to the items of iterable, 
from left to right, so as to reduce the iterable to a single value. 
The functools module is for higher-order functions: functions that act on or 
return other functions. In general, any callable object can be treated as a 
function for the purposes of this module

running time for funtools.reduce is 51.3021259307861 seconds
running time for reduce is 49.8769261837005 seconds

therefore, there is no major different between functools.reduce and reduce at
least for this particular case
'''
tt = map(collections.Counter, topic_prob_dict)
#import time
#start_time = time.time()
#tt2 = functools.reduce(operator.add, tt)
#time.time() - start_time

#start_time = time.time()
tt2 = reduce(operator.add, tt)
#time.time() - start_time




with open(fileName) as f:
        for line in f:
            texts.append(cleanDoc(line))
        





        