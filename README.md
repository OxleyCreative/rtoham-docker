# RTOHam Docker Project

This project sets up a docker image for the rtoham.com website.

To set up a new built image, you'll need to:

1. Make sure you have a valid `settings.py` file in the `rtoham.com` directory.
2. Run `sudo docker build -t="rtoham/web:v<number>"`.

## Running with MySQL Container

To run the container using a MySQL docker container, you will need to run some steps like the following:

### Run the MySQL Container

You can run the [official MySQL docker image](https://registry.hub.docker.com/_/mysql/) using a command like the following:

```
sudo docker run --name rtoham-db -e MYSQL_ROOT_PASSWORD=replace-me -e MYSQL_USER=rtoham -e MYSQL_PASSWORD=replace-me -e MYSQL_DATABASE=rtoham -d mysql
```

This will run a container named "rtoham-db" with the environment variables needed for the image. The environment variable values will need to match up with the settings in settings.py like this:


```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': os.getenv('MYSQL_ENV_MYSQL_DATABASE'),
        'USER': os.getenv('MYSQL_ENV_MYSQL_USER'),
        'PASSWORD': os.getenv('MYSQL_ENV_MYSQL_PASSWORD'),
        'HOST': os.getenv('MYSQL_PORT_3306_TCP_ADDR'),
        'PORT': os.getenv('MYSQL_PORT_3306_TCP_PORT'),
    }
}
```

### Load Backed-up Data

You will need to load data into the container from a back-up using a command like the following:

```
sudo docker run -v /path/to/backup-dir:/var/rtoham/db-backups --link rtoham-db:mysql --rm mysql sh -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -u"$MYSQL_ENV_MYSQL_USER" -p"$MYSQL_ENV_MYSQL_PASSWORD" < /var/rtoham/db-backups/backup-file.sql'
```

This will run a new container that is linked to the MySQL container that we ran earlier. It has a volume mounted from the host (`/path/to/backup-dir`) to the container (`/var/rtoham/db-backups`). We use the data back-up within the mounted volume to populate the database.

Database back-ups can be created in a similar manner, like so:

```
sudo docker run -v /var/rtoham/db-backups:/var/rtoham/db-backups --link rtoham-db:mysql --rm mysql sh -c 'exec mysqldump -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -u"$MYSQL_ENV_MYSQL_USER" -p"$MYSQL_ENV_MYSQL_PASSWORD" "$MYSQL_ENV_MYSQL_DATABASE" > /var/rtoham/db-backups/rtoham_prod-2018-03-27.sql'
```

### Run the Web App Container

Finally, we have a database all set up and we're ready to run the web application using a command like this:

```
sudo docker run -d --name rtoham-web --link rtoham-db:mysql -e RTOHAM_SECRET_KEY=replace-me -P -v /path/to/uploads:/var/uploads -v /path/to/logs:/var/rtoham/app-logs rtoham/web:vX.X.X
```

### Deploying to Production

Tag the current version of the code:

```
git tag x.x.x
```

Push the tags:

```
git push --tags
```

Run the deploy script:

```
./deploy.sh user@hostname x.x.x some-random-key
```
