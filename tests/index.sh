#! /bin/sh

# Teste galerie-shell avec :
# Répertoire source :
#  - chemin relatif
#  - caractère spécial dans le noms des fichiers et du répertoire
#  - contient des images, et uniquement des images.
# Répertoire destination :
#  - potentiellement existant avant de lancer le script
#  - chemin relatif
#  - caractère spécial dans le nom du répertoire

HERE=$(cd "$(dirname "$0")" && pwd)
# chemin absolu du répertoire courant

PATH="$HERE/..:$PATH"
# $PATH contient désormais le répertoire parent

rm -fr ./*source
# on supprime tous les répertoire se terminant par source
mkdir -p source

rm -fr ./*dest
mkdir -p dest

cd "$HERE"

make-img.sh source/image1.jpg
make-img.sh source/image2.jpg
# création des images avec un caractère spécial dans le nom

galerie-shell --dest dest --source source --index index/index.html


if [ -f index/index.html ]
then
    echo "Now run 'firefox ../index.html' to check the result"
else
    echo "ERROR: ../index.html was not generated"
fi
