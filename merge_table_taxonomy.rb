#!/usr/bin/env ruby
# Qiime2: Merging several DADA2 denoised run feature tables and representative sequences for Qiime version 2017.12
# Feature tables must be name *_table.qza and representative sequences *_rep-seqs.qza
# V1.00 Written by Gisle Vestergaard
# Edited by Alex Paterson 2020

require 'pp'
require 'optparse'

tables = []
seqs   = []

table = `ls -d */*/*/* | grep _OTU.qza`
table.each_line do |line|
  line.chomp!
  tables << line
end

seq = `ls -d */*/*/* | grep _OTU.taxonomy.qza`
seq.each_line do |line|
  line.chomp!
  seqs << line
end 

system 'qiime feature-table merge --i-tables ' + tables.each {|x| x}.join(" --i-tables ") + ' --o-merged-table merged_table.qza' 
system 'qiime feature-table merge-taxa --i-data ' + seqs.each {|x| x}.join(" --i-data ") + ' --o-merged-data merged_taxonomy.qza' 
