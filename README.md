# CRE Stack on Docker



## Building the Images

Since none of these images are in dockerhub - you will need to build each of these images before you can use them. This will only need to be performed once. There are 8 images. Before building however - you will need to download the settings folder from the `cre-release` bucket and place a copy of that folder in each of the following directories:

- gateway
- manager
- streams
- webapp

After adding the settings folder to those locations run the following to build the images.


_Compiler_
```bash
cd compile
docker build -t rpmer .
```

_Neo4j_
```bash
cd neo
docker build -t va-neo .
```

_Kafka/Zookeeer_
```bash
cd neo
docker build -t va-zk .
```

_Mysql_
```bash
cd mysql
docker build -t va-mysql .
```


_Streams_
```bash
cd streams
docker build -t va-streams .
```

_Gateway_
```bash
cd streams
docker build -t va-streams .
```

_Manager_
```bash
cd streams
docker build -t va-manager .
```

_Webapp_
```bash
cd webapp
docker build -t va-webapp .
```

Now you should have all the images built and avilable to you in docker.  Run `docker images` to verify.



## Compiling the apps

With the exception of neo4j, kafka/zookeeper, and mysql - These images are setup to run from code compiled on your local filesystem. This is to enable you to develop locally and run in docker.  However - the images need the rpm to install & run within the container. If you're running on a linux system that has `rpm-build` then you're good to go - Just run `gradle rpm` and you're good.   For the rest of us - we have that `rpmer` image that you just built. It will build the rpm on your local filesystem. 

This is how to do that:

`docker run --rm -v /path/to/your/code/volume-analytics:/code -v ~/.gradle:/root/.gradle rpmer`

Here's what that does:
1. `--rm` will remove the container after you're done.  You don't need to keep it around unless you want to - but to me its just extra clutter.
2. `-v /path/to/your/code/volume-analytics:/code` this is mapping your local repository for volume-analytics to the `/code` directory on the container.  IT MUST map to `/code` for this to work.
3. `-v ~/.gradle:/root/.gradle` maps your local gradle cache to the container's root cache location.  This isn't strictly necessary - but it's useful so you don't have to downoad all of the dependencies again within the container.
4. `rpmer` tells docker to use the `rpmer` image.  The main command that will run in this container is `gradle clean rpm`. And since you mounted your local repository to the container - it will build & place the rpm files on your local filesystem when it's complete.


__Do the above steps for both volume-analytics repo as well as cre repo__


## Running the stack!

Now that you've got all your images & rpms - it's time to run the stack!  This is accomplished using `docker-compose`. However you will need to edit the `docker-compose.yml` file for your local system. Namely - it requires mapping local volumes again to specific containers.  

These are the locations where you will need to edit to whatever your local paths is:

1. Manager: You will need to map your local volume-analytics repository to `/va` on the container
2. Streams: You will need to map your local volume-analytics repository to `/va` on the container **AND** your local cre repository to `/code`
3. Webapp: You will need to map your local cre repository to `/code` on the container.

Don't change anything else in the docker-compose.yml file or things will not work. Also don't modify the `env` file.

Here's the super complicated command to start all of these containers and run the stack:

`docker-compose up`

That should start everything up and you should see all of the different container's logs all mashed together beautifully in colorful mess. 

To stop the stack just Ctrl-C.

If you want to start the same stack again later - just run `docker-compose start` and then `docker-compose stop` to stop later.   If you want to completely tear down the stack to start from fresh use `docker-compose down`.


## Using the stack

Once everything is up an running.  You can access all the services on `localhost`.  Here are the ports for the different web facing apps:

1. Neo4j: http://localhost:7474
2. Manager: https://localhost:8883
3. WebApp: https://localhost:9009


## Developing with docker

When I'm developing on the webapp for example and I still want to have the rest of the stack running.  I'll just comment out the `webapp` portion of docker-compose.yml and start it up like normal.  Then I'll just develop & run (gradle bootRun) cre-web locally - but just put in the correct application properties to point to the correct urls for neo & manager (the localhost ports).  
