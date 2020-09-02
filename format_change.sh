#!/bin/bash

#format_mapseq_old.py is a script to convert the taxonomy from Mapseq to Qiime (clean_file)
#use format_mapseq_old_HPC.py for python3

for dir in ./*/*/*ssu*; 
	do
		echo $dir
		for file in $dir/S*_FASTQ_SSU_OTU.tsv;
			do echo "Input file: $file"
			filename="$(basename $file)"
			filename_no_ext="$(basename $file .tsv)"
			echo "Basename (without extension): $filename_no_ext"
			if [ -f "$dir/clean_$filename" ]; then
				echo "Clean file exists. Doing nothing"
			else
				echo "Clean file does not exist. Using python script to parse and clean"
				python format_mapseq_old.py "$file" > "$dir/clean_$filename"
			fi
			sed s/\taxid/\ /g "$dir/clean_$filename" > "$dir/new_$filename"
			echo "Using Biom to convert to OTU table"
			biom convert -i $dir/new_$filename -o $dir/${filename_no_ext}_steph.biom --table-type="OTU table" --process-obs-metadata taxonomy --to-hdf5
			#We need to import the biom files as Qiime2 artifacts, importing otu table and taxonomy separately for each file, here the otu tables
			#to import multiple biom files in qiime2 artifact otu tables
			echo "Importing file: $dir/${filename_no_ext}_steph.biom to qiime2 as Frequency Table"
			qiime tools import --input-path $dir/${filename_no_ext}_steph.biom --type 'FeatureTable[Frequency]' --input-format BIOMV210Format --output-path $dir/${filename_no_ext}.qza
			#to import multiple biom files in qiime2 artifact taxonomies
			echo "Importing file: $dir/${filename_no_ext}_steph.biom to qiime2 as Taxonomy Table"
			qiime tools import --input-path $dir/${filename_no_ext}_steph.biom --type "FeatureData[Taxonomy]" --input-format BIOMV210Format --output-path $dir/${filename_no_ext}.taxonomy.qza
		done	
	done	
			
#You can use the following script to merge all the otu_table in one file and all the taxonomies in one file
echo "Running Ruby script to merge all studies"
ruby merge_table_taxonomy.rb

#Now you can finally convert qiime2 artifact file .qza in biom file, to be imported in Phyloseq R or in Calypso
#to convert the merged otu_table
echo "Exporting merged OTU.qza to readable OTU table"
qiime tools export   --input-path merged_table.qza   --output-path merged_otu_table_qiime2
#to convert the merged taxonomy
echo "Exporting merged taxonomy.qza to readable Taxonomy table"
qiime tools export   --input-path merged_taxonomy.qza   --output-path merged_taxonomy_qiime2

#You have to change the first line of taxonomy.tsv (i.e. the header) to this:  #OTUID   taxonomy
sed  's/Feature ID/#OTUID/g' merged_taxonomy_qiime2/taxonomy.tsv > merged_taxonomy_qiime2/biom-taxonomy.tsv

echo "All done, enjoy a coffee"

