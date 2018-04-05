#!/bin/bash

# Massimo Re Ferre' massimo@it20.info

###########################################################
###########              USER INPUTS            ###########
###########################################################
# variables UI component
# The YELB_APPSERVER_ENDPOINT variable is used to configure the IP/FQDN that NGINX will be proxying to.
# it essentially points back to the same host (NGINX) that serves the html5/angular binaries and that also acts as a proxy to the yelb-appserver
# the true meaning of the YELB_APPSERVER_ENDPOINT variable is when you want to decouple the shipping of the html5/angular binaries (e.g off of S3)
# from the yelb-appserver end-point (e.g. API Gatway) in a serverless deployment 
export YELB_APPSERVER_ENDPOINT="${YELB_APPSERVER_ENDPOINT:-<localhost}"
###########################################################
###########           END OF USER INPUTS        ###########
###########################################################

###########################################################
## DO NOT TOUCH THESE UNLESS YOU KNOW WHAT YOU ARE DOING ##
###########################################################
export NGINX_CONF="/etc/nginx/conf.d/default.conf" 
export NGINX_MAIN="/etc/nginx/nginx.conf"  
export LOG_OUTPUT="/yelb-setup.log"
###########################################################
###########                                     ###########
###########################################################

###########################################################
###########            CORE HOUSEKEEPING        ###########
###########################################################
export HOMEDIR="/yelb-setup"
yum update -y 
yum install -y git
if [ ! -d $HOMEDIR ]; then
    mkdir $HOMEDIR
    cd $HOMEDIR
    git clone http://github.com/mreferre/yelb
fi 
###########################################################

cd $HOMEDIR
cd yelb/yelb-ui
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. ~/.nvm/nvm.sh
nvm install 6.11.5
nvm install --lts
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
. ~/.nvm/nvm.sh
npm install -g @angular/cli

cd $HOMEDIR
cd yelb/yelb-ui
git clone https://github.com/vmware/clarity-seed.git
cd ./clarity-seed
git checkout -b f3250ee26ceb847f61bb167a90dc957edf6e7f43
cd ..
cp ./clarity-seed-newfiles/src/index.html ./clarity-seed/src/index.html
cp ./clarity-seed-newfiles/src/styles.css ./clarity-seed/src/styles.css
cp ./clarity-seed-newfiles/src/app/app* ./clarity-seed/src/app
cp ./clarity-seed-newfiles/src/environments/env* ./clarity-seed/src/environments
cp ./clarity-seed-newfiles/package.json ./clarity-seed/package.json
cp ./clarity-seed-newfiles/angular-cli.json ./clarity-seed/.angular-cli.json
rm -r ./clarity-seed/src/app/home
rm -r ./clarity-seed/src/app/about
# hack to replace a string with the actual app server endpoint in the proxy configuration
# this is due to the fact that angular environments can't work with system variables
# see here for more context:  https://github.com/angular/angular-cli/issues/4419
sed -i "s/YELB_APPSERVER_ENDPOINT/$YELB_APPSERVER_ENDPOINT/" ./clarity-seed/src/environments/environment.custom.ts
# end of angular custom environment hack 
# note this hack is not even used for now given we are compiling the angular app with the "prod" flag
# the prod flag keeps the browser pointing back to the same origin (i.e. nginx)
# the custom flag should be used when you need to have the browser point to a different target that isn't the origin
# e.g. in a serverless deployment where the Angular UI is deployed on an S3 bucket and the yelb-appserver logic is exposed through an API Gateway 
cd ./clarity-seed/src
npm install  
sudo mkdir /custom
sudo chmod 777 /custom
ng build --environment=prod --output-path=/custom/dist/

cd $HOMEDIR
cd yelb/yelb-ui
sudo yum install -y nginx
echo "server {" | sudo tee $NGINX_CONF > /dev/null 
echo "    listen       80;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    server_name  localhost;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    location /api {" | sudo tee -a $NGINX_CONF > /dev/null
echo "       proxy_pass http://"$YELB_APPSERVER_ENDPOINT":4567/api;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    }" | sudo tee -a $NGINX_CONF > /dev/null
echo "" | sudo tee -a $NGINX_CONF > /dev/null
echo "    access_log  /var/log/nginx/host.access.log  main;" | sudo tee -a $NGINX_CONF > /dev/null
echo "" | sudo tee -a $NGINX_CONF > /dev/null
echo "    location / {" | sudo tee -a $NGINX_CONF > /dev/null
echo "        root   /custom/dist;" | sudo tee -a $NGINX_CONF > /dev/null
echo "        index  index.html index.htm;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    }" | sudo tee -a $NGINX_CONF > /dev/null
echo "" | sudo tee -a $NGINX_CONF > /dev/null
echo "    error_page   500 502 503 504  /50x.html;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    location = /50x.html {" | sudo tee -a $NGINX_CONF > /dev/null
echo "        root   "$HOMEDIR"/yelb/yelb-ui/clarity-seed/src/custom/dist;" | sudo tee -a $NGINX_CONF > /dev/null
echo "    }" | sudo tee -a $NGINX_CONF > /dev/null
echo "}" | sudo tee -a $NGINX_CONF > /dev/null
sudo rm $NGINX_MAIN
echo "user  nginx;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "worker_processes  1;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "" | sudo tee -a $NGINX_MAIN > /dev/null
echo "error_log  /var/log/nginx/error.log warn;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "pid        /var/run/nginx.pid;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "" | sudo tee -a $NGINX_MAIN > /dev/null
echo "events {" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    worker_connections  1024;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "}" | sudo tee -a $NGINX_MAIN > /dev/null
echo "" | sudo tee -a $NGINX_MAIN > /dev/null
echo "http {" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    include       /etc/nginx/mime.types;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    default_type  application/octet-stream;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '" | sudo tee -a $NGINX_MAIN > /dev/null
echo "                      '\$status \$body_bytes_sent "\$http_referer" '" | sudo tee -a $NGINX_MAIN > /dev/null
echo "                      '"\$http_user_agent" "\$http_x_forwarded_for"';" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    access_log  /var/log/nginx/access.log  main;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    sendfile        on;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    keepalive_timeout  65;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "    include /etc/nginx/conf.d/*.conf;" | sudo tee -a $NGINX_MAIN > /dev/null
echo "}" | sudo tee -a $NGINX_MAIN > /dev/null
chkconfig nginx on
service nginx start

