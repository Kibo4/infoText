#!/bin/bash

function preparationAuTraitement(){
  # Ce script permet de transformer n'importe quel fichier texte en fichier tratable par notre scripte de reconnaissance de langue
  # On prend le fichier texte à traiter en entrée
  # On le convertit en UTF-8
  iconv -f ISO-8859-1 -t UTF-8 $1 -o fichier0.tmp
  # On convertit les fins de ligne en fins de ligne UNIX
  # On convertit tout en minuscules
  awk '{print $0}' fichier0.tmp | awk '{print tolower($0)}'>fichier1.tmp
  # On retire les caractères ne faisant pas partie de l'alphabet (?,! /;§$*%$£...)
  sed "s+\W+ +g" fichier1.tmp > fichier2.tmp
  # On insère un saut de ligne entre chaque mot de façon à avoir un mot par ligne
  tr " " "\012" < fichier2.tmp > fichier3.tmp
  # On effectue un premier tri qui sert à faire fonctionner le uniq
  # On compte le nombre d'occurences de chaque mot (uniq -c)
  # On effectue un deuxième tri de façon à trier les mots par nombre d'occurences
  sort fichier3.tmp | uniq -c |sort -g | sed -r '/^.{,10}$/d' > fichier4.tmp
  # On trie les mots par ordre décoissant de probabilités
  # On coupe le fichier de façon à ne récuper que les cent premiers mots sans le caractère espace
  tac fichier4.tmp |head -101|tail -100 > fichier5.tmp
  # On supprime les nombres d'occurences de chaque mot de façon à ne récuperer que les mots
  cut -d' ' -f2- fichier5.tmp > fichier6.tmp
  # On ajoute des espaces entre chaque mot, puis on créer un fichier final
  awk '{ print " "$0" "}' fichier6.tmp > $1.qlang
  # On efface les fichiers temporaires
  rm *.tmp
}

preparationAuTraitement $1

echo "">fichierTOUT
while read langue
do
   { ./probaLangue.sh $1.qlang $langue | tr "\n" " "; echo $langue;} >> fichierTOUT
done < quelleLangue_src/listeLangues

sort -n fichierTOUT | tac > fichier18.tmp
if [[ $# -eq 2 ]]
then
  if [ $2 = "-all" ]
  then
    cat fichier18.tmp | column
  fi
else
    printf "Langue_"
  cat fichier18.tmp | head -1 | cut -d' ' -f2| column
fi
rm -f fichierTOUT
rm -f *.qlang
rm -f *tmp
