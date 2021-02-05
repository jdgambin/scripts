#!/bin/bash
echo "Initialising $(date +%H:%M:%S)"
filename="file"
echo -e "$SHELL\n" > $filename
# Each user in a separated line too
for line in $(cut -d":" -f1 /etc/passwd)
do
	echo -e "$line\n" >> $filename
done
echo -e "$(pwd)\n" >> $filename
echo -e "$(whoami)\n" >> $filename
echo "Data saved in the file: $filename"
echo "Number of words: $(cat $filename | wc -m)"
echo "Number of lines in the file: $(cat $filename | wc -l)"
echo "Number of characters in the file: $(cat $filename | wc -c)"
echo "Count of pattern 'file' in the file: $(cat $filename | grep -c file)"
read -p "Introduce a file name: " filename1
for line in $(cat $filename1)
do
	case $line in
	# Using regex with sed it deletes ";" and "," from the email ID
	*.net*) [[ -e dotnet_emails.txt ]] || echo "List of .net domains:" > dotnet_emails.txt ; echo "$line" | sed -e "s/[;,]//g" >> dotnet_emails.txt ;;
	*.org*) [[ -e dotorg_emails.txt ]] || echo "List of .org domains:" > dotorg_emails.txt ; echo "$line" | sed -e "s/[;,]//g" >> dotorg_emails.txt ;;
	*.com*) [[ -e dotorg_emails.txt ]] || echo "List of .com domains:" > dotcom_emails.txt ; echo "$line" | sed -e "s/[;,]//g" >> dotcom_emails.txt ;;
	*) [[ -e rest_of_emails.txt ]] || echo "Leftover emails list:" > rest_of_emails.txt ; echo "$line" | sed -e "s/[;,]//g" >> rest_of_emails.txt ;;
	esac
done
echo "All task completed $(date +%H:%M:%S)"
exit 1