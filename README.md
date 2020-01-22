### Overview

Source code for my personal blog, hosted at https://www.opinionator.io

The static CSS and HTML are generated using Hugo https://gohugo.io/ and a slightly modified version of the Zzo theme https://github.com/zzossig/hugo-theme-zzo. As the Zzo theme being used for this website has been modified a bit, it's not synced up with the actual theme hosted on Github, and will gradually drift as changes to Hugo and Zzo are made.

This project was built using Hugo Version 0.62

### Deploying The Static Website to an Ubuntu Droplet on Digital Ocean

Resources

    - https://www.digitalocean.com/community/tutorials/how-to-install-nginx-on-ubuntu-18-04
    - https://gideonwolfe.com/posts/sysadmin/hugonginx/

    # This installs the latest version of Hugo and may eventually break.
    # `apt-get` installs an old version of Hugo that does not work with this repository, so snap
    # is being used instead.

    sudo apt-get update
    snap install hugo
    sudo apt-get install nginx

    # Make an exception for NGINX in our Firewall.

    sudo ufw allow 'Nginx Full'

    # Clone the repo into your home directory.

    cd ~
    git clone https://github.com/Seancarpenter/blog

    # Copy the deploy scripts to the /bin directory and make them executable.

    cp blog/deploy.sh /bin/deploy
    chmod +x /bin/deploy

    cp blog/deploy_nginx.sh /bin/deploy_nginx
    chmod +x /bin/deploy_nginx

    # Create the folder path that will ultimately store the static pages.

    sudo mkdir -p /var/www/opinionator.io/html

    # Assign the correct access rights to the folder.

    sudo chown -R $USER:$USER /var/www/opinionator.io/html
    sudo chmod -R 755 /var/www/opinionator.io

    # Copy the nginx configuration file for the website.

    cp ~/blog/blog.nginx /etc/nginx/sites-enabled/blog
    cp ~/blog/blog.nginx /etc/nginx/sites-available/blog

    # At this point, we can run and enable NGINX with the following commands:

    sudo systemctl start nginx
    sudo systemctl enable nginx

    # If you make any changes to the NGINX configuration file, just run:

    deploy_nginx

    # If you run into issues when trying to setup the nginx configuration, run the following to get an
    # error output.

    nginx -t

    # To deploy changes to the actual website, run:

    deploy

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

