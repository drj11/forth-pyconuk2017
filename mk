mkdir -p outpng
mkdir -p pdf
for svg in slide/[0-9]*.svg
do
    outpng=$(basename "$svg" .svg).png
    outpdf=$(basename "$svg" .svg).pdf
    inkscape --export-background=white --export-png "outpng/${outpng}" "${svg}"
    inkscape --export-pdf "pdf/${outpdf}" "${svg}"
done
pdfunite pdf/*.pdf $(basename "$PWD").pdf
