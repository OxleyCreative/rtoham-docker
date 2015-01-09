if [ "$#" -ne 2 ]; then
  echo "Usage: ./run-deploy.sh tag secret-key"
  exit 0
fi

TAG=$1
SECRET_KEY=$2

set -v
cd /var/rtoham/app
git fetch
git checkout $TAG
git submodule update
sudo docker build -t="rtoham/web:v$TAG" .
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ]; then
  echo "docker build failed"
  exit $EXIT_CODE
fi
sudo docker kill rtoham-web
if [ $? -eq 0 ]; then
  sudo docker rm rtoham-web
fi
sudo docker run -d --name rtoham-web --link rtoham-db:mysql -e RTOHAM_SECRET_KEY="$SECRET_KEY" -p 80:8080 -v /var/rtoham/uploads:/var/uploads -v /var/rtoham/app-logs:/var/app-logs "rtoham/web:v$TAG"
