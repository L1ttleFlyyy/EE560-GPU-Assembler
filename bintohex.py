import sys

if len(sys.argv) < 2:
	print("usage: python bintohex.py [binary file]")
	exit(0)

filename = sys.argv[1]

with open(filename, 'r') as f:
	for line in f:
		num = int(line, 2)
		print(hex(num))

