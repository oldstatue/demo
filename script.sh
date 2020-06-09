#!/bin/bash

#input file 
i=input.html

#output file 
echo > res/data.xml
o=res/data.xml

echo '<xml>' >> $o

#iterate through the URLs in pages.txt 
while read p; do

	#use curl to download the html to the input file
	curl $p > $i

	echo '<poem>' >> $o
	echo '<author>' >> $o

	#find the line with the author name...
	#...remove the surrounding html...
	#...and replace the angle brackets with escape characters before writing to the output file
	awk '/By <a href="https:\/\/www.poetryfoundation.org\/poets\// {print}' $i | \
		sed 's/By <a[^>]*>//g' | \
		sed 's/<\/a>//' | sed 's/\xc2\xa0//g' >> $o

	echo '</author>' >> $o
	echo '<title>' >> $o

	#find the html on the line before the poem title and write the next line to the output file
	awk '/<h1 class="c-hdgSans c-hdgSans_2 c-mix-hdgSans_inline">/ {getline; print}' $i >> $o

	echo '</title>' >> $o
	echo '<text>' >> $o

	#find the poem body and split each <div> into its own line...
	#...remove the leftover html...
	#...replace the angle brackets with escape characters...
	#...and remove new line and carriage return special characters before writing to the output file
	awk '/<div style="text-indent: -1em; padding-left: 1em;">/ {split($0,a,"</div>")} END {for (i in a) {print a [i]}}' $i | \
		sed 's/<div style=\"text-indent: -1em; padding-left: 1em;\">//' | \
		sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | \
		sed 's/\xc2\xa0//g' | \sed 's/\r//g'  >> $o

	echo '</text>' >> $o
	echo '</poem>' >> $o

done < res/pages.txt

echo '</xml>' >> $o

#remove the input file now it's no longer needed
rm $i

