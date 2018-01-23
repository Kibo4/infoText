echo "">Tmp
for elem in $1/* ; do
	cat $elem >> Tmp
done
./quelTypeTexte.sh Tmp -save $2
