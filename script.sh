#!/bin/bash

#input file 
i=input.html

#output file 
o=log.xml

echo '<xml>' >> $o

#iterate through the URLs in pages.txt 
while read p; do

	curl $p > $i

	echo '<poem>' >> $o
	echo '<title>' >> $o

	awk '/<h1 class="c-hdgSans c-hdgSans_2 c-mix-hdgSans_inline">/ {getline; print}' $i >> $o

	echo '</title>' >> $o
	echo '<text>' >> $o

	awk '/<div style="text-indent: -1em; padding-left: 1em;">/ {split($0,a,"</div>")} END {for (i in a) {print a [i]}}' $i | \
		sed 's/<div style=\"text-indent: -1em; padding-left: 1em;\">//' | sed 's/</\&lt;/' | sed 's/>/\&gt;/' | sed 's/^M//' >> $o

	echo '</text>' >> $o
	echo '</poem>' >> $o

done < pages.txt

echo '</xml>' >> $o

#remove the input file now it's no longer needed
rm $i

