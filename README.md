# Casino-API

## Introduction

This is a [Docker](https://www.docker.com) windows setup to run a simple api with [ASP NET Core](https://docs.microsoft.com/en-us/aspnet/core/), [Web Deploy](https://www.iis.net/downloads/microsoft/web-deploy) and [IIS](https://www.iis.net).

## Technologies

- [Amazon Web Service](https://aws.amazon.com), for hosting, scaling, and managing deployments of containerized application.
- [Cloud Formation](https://aws.amazon.com), for managing Infrastucture As a Code of AWS resources.
- [Docker](https://www.docker.com), for building a production-ready environment of windows machines.
- [NGINX](https://www.nginx.com), for assemblying a NGINX configuration file (nginx.conf).


## How to run

 1 - Build Casino Api Dockerfile
```
$ ./build.ps1
```

2 - Run Casino Web Api
```
$ ./run.ps1
```
3 - Build NGINX Dockerfile

```
$ cd nginx
$ ./build-nginx.ps1
```
4 - Run NGINX container

```
$ ./run-nginx.ps1
```
5 - Open a browser

```
http://localhost:8080/api/players
````

```
$ http://localhost:8080/api/games
```
## Tests

* This structure was tested on a windows server 2019 machine. 
* CloudFormation is optional, but testable running create.sh <taskName> <configuration.yaml> <parameter.json>
