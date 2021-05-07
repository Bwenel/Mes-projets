#!/bin/bash
read -p "Quel est votre note ? " note
case "$note" in
   1[6-9] | 20)
	echo 'Vous avez une très bonne moyenne'
	;;
   1[4-5])
	echo 'Vous avez une bonne moyenne'
	;;
   1[2-3])
	echo 'Vous avez une assez bonne moyenne'
	;;
   1[0-1])
	echo 'Vous avez une mauvaise moyenne'
	;;
   [0-9])
	echo 'Vous êtes bon pour redoubler'
	;;
esac
