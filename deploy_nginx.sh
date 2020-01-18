cd ~
if [ -d "blog" ]; then
    rm -rf "blog"
fi
git clone https://github.com/Seancarpenter/blog
cp ~/Blog/blog.nginx /etc/nginx/sites-enabled/blog
cp ~/Blog/blog.nginx /etc/nginx/sites-available/blog
sudo service nginx restart
