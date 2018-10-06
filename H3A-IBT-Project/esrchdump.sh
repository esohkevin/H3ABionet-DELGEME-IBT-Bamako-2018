#!/bin/bash

# This function queries the pubmed database and returns total count of 
# articles affiliated to the various institutions
 
esearchdump() {
mkdir -p input output tempo
file1="tempo/*.txt"
qrmk() {
	for f
	  do
	    [ -e "$f" ] && rm "$f"
        done
       }
qrmk $file1

for country
     do
       esearch -db pubmed -query "$country[AFFL]" | \
        efetch -format uid | 
	 wc -l >> tempo/count1.txt
	  echo "$country" >> tempo/count2.txt
	 paste tempo/count2.txt tempo/count1.txt > output/count.txt
	esearch -db pubmed -query "$country[AFFL]" | 
       efetch -format xml >> tempo/$country.txt

# Extract PMIDS from all papers with first author affiliation containing corresponding country
#       xtract -input tempo/$country.txt -pattern PubmedArticle -PMID MedlineCitation/PMID \
#	 -block Affiliation -if Affiliation -position first -contains "$country" \
#	 -tab "\n" -element "&PMID" | 
#	 sort -n | uniq >> tempo/pmids$country.txt
#	 cat tempo/pmids$country.txt | xargs | sed 's/ /,/g' > tempo/pmids$country.txt 

done
xtract -input tempo/$country.txt -pattern PubmedArticle \
	-if Affiliation -position first -contains "$country" \
	-tab "\n" -element MedlineCitation/PMID |
	sort -n | uniq >> tempo/pmids$country.txt 
	cat tempo/pmids$country.txt | xargs | sed 's/ /,/g' > tempo/pmids$country.txt

# Fetch (download) the papers using the previously fetched pmids
for ID in "$(cat tempo/pmids$country.txt)"
   do 
	      efetch -db pubmed -id "$ID" -format xml >> output/pap$country.txt
done

        mv tempo/count.txt output
	mv tempo/pmids$country* input
	mv tempo/$country* input
}

