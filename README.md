# RTOHam Docker Project

This project sets up a docker image for the rtoham.com website.

To set up a new built image, you'll need to:

1. Copy the `/home/docker/rtoham.com/uploads/` directory in the docker container to the `rtoham.com/uploads` directory. `sudo docker cp <container-id>:/home/docker/rtoham.com/uploads rtoham.com` (Well, it will be running on a remote server, but something along those lines.)
2. Make sure you have a valid `settings.py` file in the `rtoham.com` directory.
3. Run `sudo docker build -t="rtoham/app:v<number>`.
