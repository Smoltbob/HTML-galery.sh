#! /bin/bash
# We need bash for $RANDOM

if [ "$1" != "" ]; then
    target=$1
else
    target=image.png
fi	

# Dummy sample text
dummy_text () {
    cat <<EOF
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus non
erat in diam hendrerit malesuada vel in justo. Donec augue metus,
dapibus eu laoreet vitae, suscipit quis erat. Etiam id dolor eu sapien
aliquam blandit eget eget risus. Proin id dolor nec diam vulputate
interdum. Integer tempus, neque venenatis sodales molestie, massa ante
adipiscing dolor, vel rutrum mauris velit ut nulla. Maecenas commodo
tellus sed leo volutpat sollicitudin. Vestibulum volutpat libero ac
quam accumsan gravida pulvinar lectus accumsan. Etiam venenatis, nibh
sit amet commodo convallis, risus augue elementum eros, ac mollis nunc
felis a odio. In at erat non velit scelerisque commodo convallis in
ante. Donec sit amet leo in tellus suscipit feugiat eu nec libero.
Curabitur sed hendrerit erat. Donec at justo eu elit volutpat
tincidunt. Donec ipsum purus, consectetur vel varius sit amet,
pharetra in mauris.
EOF
}

# Light background
bg=$(printf "#%02x%02x%02x" $((RANDOM % 100 + 155)) $((RANDOM % 100 + 155)) $((RANDOM % 100 + 155)))
# Dark text
fg=$(printf "#%02x%02x%02x" $((RANDOM % 155)) $((RANDOM % 155)) $((RANDOM % 155)))

dummy_text | convert -background "$bg" -fill "$fg" \
    -pointsize 36 \
    -page 800x600 \
    -flatten \
    text:- "$target"

echo "$target created"
