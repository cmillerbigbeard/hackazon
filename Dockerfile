FROM debian
MAINTAINER Chris Miller <millerch@gmail.com>
RUN apt-get update
RUN apt-get -y upgrade
RUN apt-get -y install software-properties-common ca-certificates lsb-release apt-transport-https wget gnupg2
RUN sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
RUN wget -qO - https://packages.sury.org/php/apt.gpg | apt-key add - 
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install nano default-mysql-client sudo tcpdump default-mysql-server xml-core apache2 php5.6 php5.6-xml php5.6-bcmath php5.6-mbstring pip libreoffice-sdbc-hsqldb libdbd-mysql-perl libapache2-mod-php5.6 pwgen python-setuptools vim-tiny php5.6-imagick php5.6-mysql php5.6-gd php5.6-ldap supervisor unzip

# setup hackazon
ADD ./scripts/start.sh /start.sh
ADD ./scripts/passwordHash.php /passwordHash.php
ADD ./scripts/foreground.sh /etc/apache2/foreground.sh
ADD ./configs/supervisord.conf /etc/supervisord.conf
ADD ./configs/000-default.conf /etc/apache2/sites-available/000-default.conf
RUN rm -rf /var/www/
ADD https://github.com/rapid7/hackazon/archive/master.zip /hackazon-master.zip
RUN unzip /hackazon-master.zip -d hackazon
RUN mkdir /var/www/
RUN mv /hackazon/hackazon-master/ /var/www/hackazon
RUN cp /var/www/hackazon/assets/config/db.sample.php /var/www/hackazon/assets/config/db.php
RUN cp /var/www/hackazon/assets/config/email.sample.php /var/www/hackazon/assets/config/email.php
ADD ./configs/parameters.php /var/www/hackazon/assets/config/parameters.php
ADD ./configs/rest.php /var/www/hackazon/assets/config/rest.php
ADD ./configs/createdb.sql /var/www/hackazon/database/createdb.sql
RUN chown -R www-data:www-data /var/www/
RUN chown -R www-data:www-data /var/www/hackazon/web/products_pictures/
RUN chown -R www-data:www-data /var/www/hackazon/web/upload
RUN chown -R www-data:www-data /var/www/hackazon/assets/config
RUN chmod 755 /start.sh
RUN chmod 755 /etc/apache2/foreground.sh
RUN a2enmod rewrite 
RUN service apache2 restart

EXPOSE 80
CMD ["/bin/bash", "/start.sh"]
