# Docker-Jmeter

The idea of this image is give a machine to execute the tests without install a lot of stuff in your test machine.  
Here you will need only docker.

## Usage

If the image is available in [Docker hub](https://hub.docker.com/repository/docker/macielbombonato/docker-jmeter) you will only need to execute the `docker-compose.yml` file.

Otherwise you will need to execute locally the `build-image.sh`

## Configuration

Open `docker-compose.yml` file and change theses variables:

### Environment variables    
- PROPS_PATH=user.properties
- JMX_FILE=YourTestPlan.jmx
- RUN_TEST=true

### Volumes  
- /your/jmx/location:/opt/jmx
- /your/result/location:/opt/results

## How it works

### Volumes

On the JMX volume folder you will haver your JMX file (in case you haver more than one, you must to use the environment varila JMX_FILE to specify the right file), the user.properties file (same way, need to specify the name in the environment variable PROPS_PATH) and your input data folder (with your CSV files).  
  
This will the base to run your tests, so, all configuration of your properties file will to be used on this test run.   
  
On the results folder the image will place all results and logs files generated during the tests.  
When the test finish it will generate the report of your test execution.

### Environment variables    

Additionally you have the `RUN_TEST` variable.  
If you change it value, the image will only the config information to generate the report of the test execution.  