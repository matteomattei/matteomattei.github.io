yui-compressor --type css public/css/hyde.css -o public/css/hyde.min.css
jekyll build && rsync -v -rz --checksum --delete _site/ web1.chip2bit.com:/var/www/matteomattei.com/public_html/
ssh web1.chip2bit.com chown web5000:web5000 -R /var/www/matteomattei.com/public_html/
