#!/bin/bash
# Run this from the VPS to sync the live version of the website with the master branch.
cd ~
if [ -d "Blog" ]; then
    rm -rf "Blog"
fi
git clone https://github.com/Seancarpenter/Blog
cd ~/Blog/blog
hugo
cp -r ~/Blog/blog/ /var/www/seancarpenter.io/html/
cd ~

