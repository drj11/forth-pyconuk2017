mkdir -p outpng
for svg in slide/[0-9]*.svg
do
    outfile=$(basename "$svg" .svg).png
    inkscape --export-background=white --export-png "outpng/${outfile}" "${svg}"
done
