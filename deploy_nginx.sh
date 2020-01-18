cd ~
if [ -d "blog" ]; then
    rm -rf "blog"
fi
git clone https://github.com/Seancarpenter/blog
cp ~/blog/blog.nginx /etc/nginx/sites-enabled/blog
cp ~/blog/blog.nginx /etc/nginx/sites-available/blog
sudo service nginx restart
