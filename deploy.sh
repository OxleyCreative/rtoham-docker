if [ "$#" -ne 3 ]; then
  echo "Usage: ./deploy.sh user@host tag secret-key"
  exit 0
fi

USER_HOST=$1
TAG=$2
SECRET_KEY=$3

scp run-deploy.sh $USER_HOST:/home/rtoham/bin/run-deploy.sh
ssh $USER_HOST "chmod +x ~/bin/run-deploy.sh && /home/rtoham/bin/run-deploy.sh $TAG $SECRET_KEY"
