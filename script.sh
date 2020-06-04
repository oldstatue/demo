#!/bin/bash

#TODO
#move all sed cleanup to a single pass at the end

#input file 
i=input.html

#output file 
echo > log.xml
o=log.xml

echo '<xml>' >> $o

#iterate through the URLs in pages.txt 
while read p; do

	curl $p > $i

	echo '<poem>' >> $o

	echo '<author>' >> $o
	#awk '/By <a href="https:\/\/www.poetryfoundation.org\/poets\// {split($0,a,"<*a*>")} END {print a [2]}' $i | sed 's/<\/a//' >> $o
	awk '/By <a href="https:\/\/www.poetryfoundation.org\/poets\// {print}' $i | sed 's/By <a[^>]*>//g' | sed 's/<\/a>//' | sed 's/\xc2\xa0//g' >> $o

	echo '</author>' >> $o

	echo '<title>' >> $o

	awk '/<h1 class="c-hdgSans c-hdgSans_2 c-mix-hdgSans_inline">/ {getline; print}' $i >> $o

	echo '</title>' >> $o
	echo '<text>' >> $o

	awk '/<div style="text-indent: -1em; padding-left: 1em;">/ {split($0,a,"</div>")} END {for (i in a) {print a [i]}}' $i | \
		sed 's/<div style=\"text-indent: -1em; padding-left: 1em;\">//' | \
		sed 's/</\&lt;/g' | sed 's/>/\&gt;/g' | \
		sed 's/\xc2\xa0//g' | \
		sed 's/\r//g'  >> $o

	echo '</text>' >> $o
	echo '</poem>' >> $o

done < pages.txt

echo '</xml>' >> $o

#remove the input file now it's no longer needed
rm $i

