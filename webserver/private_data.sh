#! bin/bash
yum update -y
yum install -y httpd 
echo "hello idris private $(hostname)" > /var/www/html/index.html
systemctl start httpd
systemctl enable httpd