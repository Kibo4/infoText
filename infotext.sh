#!/bin/bash
	cd quelleLangue
	./quelleLangue.bash ../$1
	if [ `./quelleLangue.bash ../$1` = 'Langue_fr' ]
	then
	cd ../quelTypeTexte
	  ./quelTypeTexte.sh ../$1
	  fi
