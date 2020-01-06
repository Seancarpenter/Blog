### Overview

Source code for my personal blog, hosted at http://www.seancarpenter.io

To fetch the this repo and associated submodules (such as the zzo theme), call:

    git clone --recurse-submodules https://github.com/Seancarpenter/Blog

The static CSS and HTML are generated using Hugo https://gohugo.io/ and a slightly modified version of the Zzo theme https://github.com/zzossig/hugo-theme-zzo. As the Zzo theme being used for this website has been modified a bit, it's not synced up with the actual theme hosted on Github, and will gradually drift as changes to Hugo and Zzo are made.

This project was built using Hugo Version 0.62

### Deploying The Static Website to an Ubuntu Droplet on Digital Ocean

Resources

    - https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
    - https://gideonwolfe.com/posts/sysadmin/hugonginx/

    sudo apt-get update

    # This installs the latest version of Hugo and may eventually break.
    # `apt-get` installs an old version of Hugo that does not work with this repository, so snap
    # is being used instead.

    snap install hugo

    sudo apt-get install nginx

    # Make an exception for NGINX in our Firewall.
    sudo ufw allow 'Nginx Full'

    # Clone the repo into your home directory.
    cd ~
    git clone https://github.com/Seancarpenter/Blog

    # Generate the actual static site inside of the blog repo.
    cd Blog/blog
    hugo

    # Copy the site to your /var/www directory.
    sudo mkdir -p /var/www/seancarpenter.io/html
    cp Blog/blog /var/www/seancarpenter.io/html/blog

    # Assign the correct access rights to the folder.
    sudo chown -R $USER:$USER /var/www/seancarpenter.io/html
    sudo chmod -R 755 /var/www/seancarpenter.io

    # Create the nginx configuration file for the website.
    cd /etc/nginx/sites-available/
    cp default blog
    vim blog

    # Edit your nginx server configuration to match the contents in blog.nginx

    # To enable this site, we need to create a symlink the site into sites-enabled. Use absolute filepaths to avoid symlink confusion.

    sudo rm /etc/nginx/sites-enabled/default
    sudo ln -s /etc/nginx/sites-available/blog /etc/nginx/sites-enabled/blog

    # At this point, we can run and enable NGINX with the following commands:

    sudo systemctl start nginx
    sudo systemctl enable nginx

    # If you make any changes to the NGINX configuration file, you will need to refresh NGINX after doing so by running:

    sudo service nginx restart

### Setting up SSL through Certbot and Letsencrypt

    # First you'll need to run these instructions to download certbot.

    sudo apt-get update
    sudo apt-get install software-properties-common
    sudo add-apt-repository universe
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update

    # Then you'll need to install it
    sudo apt-get install certbot python-certbot-nginx

    # Lastly, register your certbot and automatically update your Nginx configuration with the SSL Certification Information.
    sudo certbot --nginx
