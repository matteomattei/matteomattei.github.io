yui-compressor --type css public/css/hyde.css -o public/css/hyde.min.css
bundle exec jekyll build && rsync -v -rz --checksum --delete _site/ contabo:/var/www/vhosts/matteomattei.com/public_html/
ssh contabo chown web5002:web5002 -R /var/www/vhosts/matteomattei.com/public_html/
