#! /bin/sh

# Test de la galerie avec un nombre quelconque de "petites" images
# permet de générer un "grand" nombre de vignettes


HERE=$(cd "$(dirname "$0")" && pwd)
PATH="$HERE/..:$PATH"

rm -fr *source *dest
mkdir -p source dest

usage () {
    cat << EOF
Utilisation: $(basename "$0") [options]
Options: --help          Ce message d'aide
         --images        Nombre d'images à générer
EOF
}

while test $# -ne 0; do
    case "$1" in
        "--help"|"-h")
            usage
            exit 0
            ;;
        "--images")
            shift; nb="$1"
            ;;
        *)
            echo "Argument non reconnu : $1"
            usage
            exit 1
            ;;
    esac
    shift
done


for i in $(seq 1 "$nb"); do
  make-img.sh source/image"$i".jpg
done

rm -f ../index.html
# Début du chronométrage
temps="$(time galerie-shell.sh --source source --dest dest)"

if [ -f ../index.html ]
then
    echo "Now run 'firefox ../index.html' to check the result"
else
    echo "ERROR: ../index.html was not generated"
fi

echo "[TEST] : Terminé."
echo $temps
