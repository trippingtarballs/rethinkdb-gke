# rethinkdb-gke

This project is to build a simple rethinkdb Docker image suitable for running a rethinkdb cluster on [Google Container Engine](https://cloud.google.com/container-engine/) with [Kubernetes](http://kubernetes.io/).

At present the resulting Docker image can be found at [rbose85/rethinkdb-gke](https://registry.hub.docker.com/u/rbose85/rethinkdb-gke/).

The project is made up of two parts;

 * `docker-image` – from which the docker image is created.
 * `configuration` – all things pertaining to kubernetes.

`docker-image/Dockerfile` heeds the suggested `Dockerfile` [best practices](https://docs.docker.com/articles/dockerfile_best-practices/#example) in implementing an `entrypoint`.

## How To Use

Launch each file in numerical order in `configuration`. Use the `kubectl create -f <file>.json` command to do so.
