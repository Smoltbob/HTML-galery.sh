#! /bin/sh

# Test de la galerie avec des paramètres erronés
# NotaBene : la première erreur fait sortir du script

HERE=$(cd "$(dirname "$0")" && pwd)
# chemin absolu du répertoire courant

PATH="$HERE/..:$PATH"
# $PATH contient désormais le répertoire parent

rm -fr *source
# on supprime tous les répertoire se terminant par source
mkdir -p source

rm -fr *dest
mkdir -p dest

cd "$HERE"

make-img.sh source/image1.jpg
make-img.sh source/image2.jpg

rm -f ../index.html

echo "AUCUN PARAMETRE :"
galerie-shell.sh

echo "PAS DE PARAMETRE SOURCE :"
galerie-shell.sh --dest dest

echo "PAS DE DOSSIER SOURCE :"
galerie-shell.sh --source

echo "PARAMETRE DE PARALLELISATION INVALIDE :"
galerie-shell.sh --dest dest --source source --n bla

if [ -f ../index.html ]
then
    echo "Now run 'firefox ../index.html' to check the result"
else
    echo "ERROR: ../index.html was not generated"
fi
