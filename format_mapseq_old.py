#!/usr/bin/env python
import sys
import os

for line in open(sys.argv[1], "r"):
	line = line.strip("\n")
	if line[0]=="#":
		if "OTU ID" in line:
			taxa = line.split("\t")
			taxa[1] = os.path.basename(sys.argv[1]).split(".tsv")[0]
			print ("\t".join(taxa))
		else:
			print (line)
	else:
		taxonomy = line.split()[2].split(";")
		if len(taxonomy)>1:
			if taxonomy[1].split("__")[-1]=="":
				taxonomy[1] = taxonomy[0].replace("sk__", "k__")
		for n,tax in enumerate(taxonomy):
			if tax.split("__")[-1]=="":
				taxonomy=taxonomy[:n]
		print ("%s\t%s\t%s" % (line.split()[0], line.split()[1], ";".join(taxonomy)))
