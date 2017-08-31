#! /bin/sh
# Génère la tête du fichier HTML
# Argument : le titre de la page
html_head () {
    echo "<!DOCTYPE html>
    <html>
    <head>
    <title>$1</title>
    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"
    html_style
    echo "</head>
    <body>"
}

# Génère un titre au format HTML
# Argument : le titre
html_title () {
    echo "<h1>$1</h1>"
}

# Génère la fin de la page HTML
html_tail () {
    echo "<div style=\"clear: both; text-align: center;\">
    <p>Cette page a été générée par un script</p>
    </div>
    </body>
    </html>"
}

# Génère le code css de la galerie
html_style () {
echo "<style type=\"text/css\">
body {
    background-color: #f1f6df;
}

.imgframe {
    float: left;
    background-color: white;
    border: dashed 1px #BBDDBB;
    margin: 1ex;
    padding: 1ex;
    text-align:center;
}

.image {
    margin: 1ex;
    border: solid 1px lightgrey;
}

.legend {
    font-style:italic;
    color: #002000;
}
</style>"
}

# Affiche des messages concernant l'exécution du code
# Si --mode vaut verb on affiche la chaîne passée en second paramètre
verbose () {
    while [ $# -gt 0 ]; do
        case "$1" in
            "--verb")
                echo "$2"
                ;;
         esac
         shift
    done
}

# Prend en premier argument un chemin vers une image
# L'image doit obligatoirement être au format jpeg
# Paramètres :  --dest, --force, --verb
generate_img_fragment () {
    # Variables
    pathimg=""
    dest=""
    force=0

    # Parsing des paramètres
    while [ $# -gt 0 ]; do
        case "$1" in 
            *.[jJ][pP][gG])
              pathimg=$(cd "$(dirname "$1")" && pwd)"/"$(basename "$1")
              ;;
            "--dest")
                mkdir -p "$2"
                dest="$(cd "$2" && pwd)"
                ;;
            "--force")
                force=1
                ;;
        esac
        shift
    done
    # Récupération des exif
    nom="$(basename "$pathimg")"
    exif="$(identify -verbose "$pathimg")"
    date="$(echo "$exif" | grep "exif:DateTime:"\
        | awk '{ split($2,a,":"); print a[3] "/" a[2] "/"  a[1] }')"
    
    # Création de la page HTML qui contiendra l'image haute résolution    
    page_html="$dest/html_$(basename "$pathimg")"
    
    # Génération du code HTML
    echo "<div class=\"imgframe\">"
    echo "<a href=\"$page_html.html\"><img class=\"image\"\
        src=\"$dest/small_$(basename "$pathimg")\"></a><br>"
    echo "<span class=\"legend\">Nom : $nom</span><br>"
    echo "<span class=\"legend\">Date : $date</span>"
    echo "</div>"
}

# Génère un fichier index.html dans le répertoire cible
# Pour chaque image du répertoire source :
# Si la vignette n'existe pas, la créer
# Générer le morceau html correspondant
# Paramètres :
# --source, --dest, --force, fichier, --n, --verb
galerie_main () {
    source=""
    dest=""
    force=0
    index=$(cd "$(dirname "$0")" && pwd)/index.html
    nbprocs=4
    verb=""

    while [ $# -ne 0 ]; do
        # Parsing des paramètres
        case "$1" in
            "--source")
                source="$2"
                ;;
            "--dest")
                dest="$2"
                ;;
             "--force")
                force=1
                ;;
             "--index")
                # Adresse du dossier + nom du fichier 
                index="$2"
                ;;
             "--n")
                nbprocs="$2"
                ;;
            "--verb")
                verb="--verb"
                ;;
        esac
        shift
    done
    
    # Infos verbose
    verbose "$verb" "Création de $index"    

    # Début de la page HTML
    (html_head "Galerie : projet Unix") > "$index"
    (html_title "Galerie d'images") >> "$index"
    
    # Si vignette n'existe pas OU force vaut 1
    # Il faut lister chaque image du dossier source
    # Ne boucler que sur les jpeg
    page_prec=""
    # On exporte les variables pour pouvoir les utiliser dans le sous-shell
    # de xargs
    
    # Infos verbose
    verbose "$verb" "Génération des miniatures..."
    export DEST="$dest"
    export VERB="$verb"
    export FORCE="$force"

    find "$source" -maxdepth 1 -name '*.[jJ][pP][gG]' -print0\
        | xargs -0 -n 1 -P "$nbprocs" -I {} sh -c\
        'if ! [ -e $DEST/small_$(basename "{}") ] ||
        [ $FORCE -eq 1 ]; then
             if [ $VERB = --verb ]; then
                echo Miniature... :  $DEST/small_$(basename "{}")
             fi;
             gmic {} -cubism , -resize 200,200 -output $DEST/small_$(basename "{}") ;
         fi' 2> /dev/null
    
    # Infos verbose
    verbose "$verb" "Miniatures générées. Génération des pages html individuelles"

    for image in "$source"/*.[jJ][pP][gG]; do
        
        # Infos verbose
        verbose "$verb" "Fragment html pour : $image"
        
        # Génération du fragment
        # Vérifier que tous les paramètres fonctionnent (force, index..)
        generate_img_fragment "$image" --dest "$dest" >> "$index"

        # Génération de la page HTML pour l'image haute résolution
        page_html="$dest"/html_"$(basename "$image")"
        html_head > "$page_html".html
        echo "<img src=\"$image\">" >> "$page_html".html

        # Ajout du bouton retour sur la page haute résolution
        echo "<a href=\"$index\"\
            class=\"button\">Retour</a>" >> "$page_html".html

        # Ajout des boutons suivant et précédant
        # Suivant : lien vers la page actuelle, dans la page précédente
        # Précédent : lien vers la page précédente, dans la page actuelle
        if [ "$page_prec" != "" ]; then
            echo "<a href=\"$page_prec.html\"\
                class=\"button\">Précédent</a>" >> "$page_html".html
            echo "<a href=\"$page_html.html\"\
                class=\"button\">Suivant</a>" >> "$page_prec".html
            html_tail >> "$page_prec".html  
        fi
        page_prec="$page_html"
    done
    html_tail >> "$page_prec".html
    
    # Infos verbose
    verbose "$verb" "Génération de la galerie terminée."

    # Fin du fichier index HTML
    html_tail >> "$index"
}
