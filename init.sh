#!/bin/bash
apt-get update -y
apt-get install nginx -y
systemctl enable nginx
systemctl start nginx

echo "<html><body><h1>Hello World from Leafny!</h1></body></html>" > /var/www/html/index.html
