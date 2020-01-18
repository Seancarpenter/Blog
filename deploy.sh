#!/bin/bash
# Run this from the VPS to sync the live version of the website with the master branch.
cd ~
if [ -d "blog" ]; then
    rm -rf "blog"
fi
git clone https://github.com/Seancarpenter/blog
cd ~/blog/blog
hugo
cp -r ~/Blog/blog/ /var/www/seancarpenter.io/html/
cd ~
