#!/bin/bash

#input file (given as an argument when running the script) 
i=res/pages.txt

#temporary html file to process
echo > temp.html
t=temp.html 

#output file
echo > res/data.xml
o=res/data.xml

echo '<xml>' >> $o

#iterate through the URLs in pages.txt 
while read p; do
	#use curl to download the html to the input file
	curl $p > $t

	echo '<poem>' >> $o
	echo '<author>' >> $o

	#find the line with the author name...
	#...and remove the surrounding html before writing to the output file
	awk '/By <a href="https:\/\/www.poetryfoundation.org\/poets\// {print}' $t | \
		sed 's/By <a[^>]*>//' | sed 's/<\/a>//' >> $o   
	
	echo '</author>' >> $o
	echo '<title>' >> $o

	#find the html on the line before the poem title and write the next line to the output file
	awk '/<h1 class="c-hdgSans c-hdgSans_2 c-mix-hdgSans_inline">/ {getline; print}' $t >> $o

	echo '</title>' >> $o
	echo '<text>' >> $o

	#find the poem body and split each <div> into its own line...
	#...remove the leftover html...
	#...replace the angle brackets with escape characters and remove carriage returns before writing to the output file
	awk '/<div style="text-indent: -1em; padding-left: 1em;">/ {split($0,a,"</div>")} END {for (i in a) {print a [i]}}' $t | \
		sed 's/<div style=\"text-indent: -1em; padding-left: 1em;\">//' | \
		sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | sed 's/\xe2\xa0//g' >> $o

	echo '</text>' >> $o
	echo '</poem>' >> $o

	sed -i 's/ *//' $o
done < $i

echo '</xml>' >> $o

#remove the input file now it's no longer needed
rm $t

