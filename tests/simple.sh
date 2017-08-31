#! /bin/sh

# Test très simple qui teste galerie-shell avec :
# Répertoire source :
#  - chemin relatif
#  - pas de caractères spéciaux dans les noms de fichiers/répertoires
#  - contient des images, et uniquement des images.
# Répertoire destination :
#  - existant avant le lancement du script, vide.
#  - chemin relatif
#  - pas de caractères spéciaux dans les noms de fichiers/répertoires

HERE=$(cd "$(dirname "$0")" && pwd)
# normalement pointe vers le répertoire test
PATH="$HERE/..:$PATH"
# ATTENTION : test doit être dans un répertoire qui contient galerie-shell
# et utilities.sh

rm -fr source dest
mkdir -p source dest

make-img.sh source/image1.jpg
make-img.sh source/image2.jpg

rm -f ../index.html

galerie-shell.sh --source source --dest dest

if [ -f "$HERE"/../index.html ]
then
    echo "Now run 'firefox ../index.html' to check the result"
else
    echo "ERROR: dest/index.html was not generated"
fi
