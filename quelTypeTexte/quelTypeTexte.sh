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
  #On insère des espaces avant et après chaque mot
  awk '{ print " "$0" "}' fichier3.tmp | sed -r '/^.{,6}$/d' >fichier4.tmp
  # On souhaite ne récupérer tous les verbes
  fgrep -o -f quelTypeTexte_src/verbes.txt fichier4.tmp > fichier5.tmp
  # On effectue un premier tri qui sert à faire fonctionner le uniq
  # On compte le nombre d'occurences de chaque mot (uniq -c)
  # On effectue un deuxième tri de façon à trier les mots par nombre d'occurences
  sort fichier5.tmp | uniq -c |sort -g > fichier6.tmp
  # On trie les mots par ordre décoissant de probabilités
  # On coupe le fichier de façon à ne récuper que les cent premiers mots sans le caractère espace
  #tac fichier6.tmp |head -101|tail -100 > fichier7.tmp
  # On supprime les nombres d'occurences de chaque mot de façon à ne récuperer que les mots
  tac fichier6.tmp | rev | cut -d' ' -f2 | rev | awk '{ print " "$0" "}' | head -20 > $1.qttex
  # On ajoute des espaces entre chaque mot, puis on créer un fichier final
  #awk '{ print " "$0" "}' fichier12.tmp > $1.qlang
  # On efface les fichiers temporaires
  # On retire les chiffres
  #sed "s+\D+ +g" fichier7.tmp > $1.qttex
  #rm *.tmp
  if [[ $# -gt 2 ]]
  then
    if [ $2 = "-save" ]
    then
      cat  $1.qttex > probaTypeTexte_src/$3.qttex
      echo $3 >> quelTypeTexte_src/listetypestextes
    fi
  fi
}

preparationAuTraitement $1 $2 $3

echo "">fichierTOUT
while read typetexte
do
   { ./probaTypeTexte.sh $1.qttex $typetexte | tr "\n" " "; echo $typetexte;} >> fichierTOUT
done < quelTypeTexte_src/listetypestextes
sort -n fichierTOUT | tac > fichier18.tmp
if [[ $# -gt 1 ]]
then
  if [ $2 = "-all" ]
  then
    cat fichier18.tmp | column
  else
    if [[ $# -gt 3 ]]; then
      if [[ $4 = "-all" ]]; then
        cat fichier18.tmp | column
      fi
    fi
  fi
else
  printf "Type : "
  cat fichier18.tmp | head -1 | cut -d' ' -f2| column
fi

rm -f fichierTOUT
rm -f *.tmp
