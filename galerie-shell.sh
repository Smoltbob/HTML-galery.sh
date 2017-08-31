#! /bin/sh

# Problèmes :
# * Index.html est généré dans le dossier courant au lieu d'être généré dans le dossier de destination.
# * Certaines miniatures ne sont pas générées.
# * Avec le mode verbeux, la première et dernière image ne sont pas prises en compte par la boucle qui gère les miniatures.
# * La génération de miniatures ne fonctionne pas si l'image a des espaces dans son nom.
# * Si le dossier source a des espaces dans son nom, aucune miniature n'est générée.
# * Si on enlève 2> /dev/null on a plein d'erreurs.
# * Attention aux guillemets avec les sous-shells
# * Autre solution :
# > (
# > if bidule; then
# >   echo gmic ...
# > fi
# > ) xargs ...
# En gros on écrit la commande et on la pipe à xargs.
# * Il n'y a pas d'erreur en cas d'option inconnue.
# * Un "shift" est oublié lors du parsing des arguments
# * On peut nommer le dossier de destination "--help", ce qui embête cd
# * On parse deux fois des arguments (dans galerie-shell.sh et dans galerie_main(). Il aurait été plus simple de passer des variables pré-traitées à galerie_main().

# Récupération du chemin absolu vers le répertoire contenant le
# script. $0 est le chemin (possiblement relatif) vers le script
# courant, "$(dirname "$0")" est le répertoire le contenant, et la
# combinaison de cd et pwd permet de récupérer un chemin absolu.
DIR=$(cd "$(dirname "$0")" && pwd)

# On demande au shell de lire le contenu de sub-script.sh Il n'y a pas
# de création de nouveau processus. Les définitions de fonctions de
# sub-script.sh seront visibles après cette ligne.
# La ligne de commentaire suivante sert uniquement à shellcheck (SC1090)
. "$DIR"/utilities.sh

# Paramètres : --source, --dest, --verb, --force, --help --index
source=""
dest=""
verb=""
index=""

# Affichage de l'aide si aucun paramètre n'est spécifié
if [ $# -eq 0 ]; then
    echo "Utilisation: galerie-shell"\
        "[--dest] [--source] [--verb] [--force] [--help] [--index]"
    exit 0
fi

# Parsing des paramètres
while [ $# -gt 0 ]; do
    case "$1" in
        "--source")
            # On regarde si la source existe
            # On réprime les erreurs de cd car si le dossier n'existe
            # car ce cas sera traité dans le else
            if [ -d "$(cd "$2" 2>/dev/null && pwd)" ]; then
                source="$(cd "$2" && pwd)"
                # On compte le nombre d'images dans le dossier source
                nbfich="$(find "$source"/*.[jJ][pP][gG] 2>/dev/null | wc -l)"
                if [ "$nbfich" = 0 ]; then
                    echo "Erreur: Le dossier ne contient pas d'images." >&2
                    exit 0
                fi
            else
                echo "Erreur: La source n'est pas un dossier." >&2
                exit 0
            fi
            ;;
        "--dest")
            # Option -p : crée l'arborescance si elle n'existe pas
            if [ "$2" = '' ]; then
              echo "Erreur: il manque le dossier dest (paramètre --dest)"
              exit 0
            else
              mkdir -p "$2"
              dest="$(cd "$2" && pwd)"
            fi
            ;;
        "--verb")
            verb="--verb"
            ;;
        "--force")
            force="--force"
            ;;
        "--index")
            # Adresse du dossier + nom du fichier, en absolu
            index="--index $(cd "$(dirname "$2")" && pwd)/$(basename "$2")"
            ;;
        "--n")
            case "$2" in
                # On utilise un case pour vérifier si le paramètre est correct
                ''|*[!0-9]*)
                    echo "Erreur: --n doit être suivi d'un chiffre." >&2
                    exit 0
                    ;;
                *)
                    n="--n $2"
                    ;;
            esac
            ;;
        "--help")
            echo "Utilisation: galerie-shell"\
                "[--dest] [--source] [--verb] [--force] [--help] [--index]"
            exit 0
            ;;
    esac
    shift
done

# Appel de galerie main, si les dossiers source et destination existent
if [ "$source" != "" ] && [ "$dest" != "" ]; then
    galerie_main --source "$source" --dest "$dest"\
        "$force" "$index" "$n" "$verb"
elif [ "$source" = "" ]; then
    echo "Erreur : il manque le dossier source (paramètre --source)." >&2
    exit 0
elif [ "$dest" = "" ]; then
    echo "Erreur : il manque le dossier destination (paramètre --dest)." >&2
    exit 0
fi
