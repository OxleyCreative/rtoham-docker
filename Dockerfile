FROM ubuntu:trusty

MAINTAINER xonev

# Update packages
RUN echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates main restricted" | tee -a /etc/apt/sources.list.d/trusty-updates.list
RUN apt-get update

RUN apt-get install -y python python-dev python-setuptools python-software-properties
RUN apt-get install -y libmysqlclient-dev
RUN apt-get install -y supervisor

# add nginx stable ppa
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:nginx/stable
# update packages after adding nginx repository
RUN apt-get update
# install latest stable nginx
RUN apt-get install -y nginx
# install libjpeg for Pillow
RUN apt-get install -y libjpeg8-dev


# install pip
RUN easy_install pip

# install uwsgi now because it takes a little while
RUN pip install uwsgi

ADD . /home/docker/

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /home/docker/nginx-app.conf /etc/nginx/sites-enabled/
RUN ln -s /home/docker/supervisor-app.conf /etc/supervisor/conf.d/

RUN pip install -r /home/docker/rtoham.com/requirements.txt
RUN RTOHAM_SECRET_KEY="temp-key" python /home/docker/rtoham.com/manage.py collectstatic --noinput

EXPOSE 8080
CMD ["supervisord", "--nodaemon", "--logfile=/var/app-logs/supervisord.log", "--childlogdir=/var/app-logs"]
