# Docker-Jmeter

The idea of this image is give a machine to execute the tests without install a lot of stuff in your test machine.  
Here you will need only docker.

---
## Usage

If the image is available in [Docker hub](https://hub.docker.com/repository/docker/macielbombonato/docker-jmeter) you will only need to execute the `docker-compose.yml` file.

Otherwise you will need to execute locally the `build-image.sh`

---
## Configuration

Open `docker-compose.yml` file and change theses variables:

### Environment variables    
- PROPS_PATH=user.properties
- JMX_FILE=YourTestPlan.jmx
- JTL_FILE=YourTestResult.jtl
- RUN_TEST=true
- MERGE_RESULTS=false
- REPORT_FOLDER=report
- HEAP=-Xms2g -Xmx2g -XX:MaxMetaspaceSize=256m

### Volumes  
- /your/jmx/location:/opt/jmx
- /your/result/location:/opt/results

---
## How it works
  
### Volumes
On the JMX volume folder you will haver your JMX file (in case you haver more than one, you must to use the environment varila JMX_FILE to specify the right file), the user.properties file (same way, need to specify the name in the environment variable PROPS_PATH) and your input data folder (with your CSV files).  
  
This will the base to run your tests, so, all configuration of your properties file will to be used on this test run.   
  
On the results folder the image will place all results and logs files generated during the tests.  
When the test finish it will generate the report of your test execution.

### Environment variables    

#### RUN_TEST
If you change it, the image will only generate the report of the test execution.  
  
#### MERGE_RESULTS
You can use this image to generate report, but, imagine that you executed the test plan in a lot of machines, so, if you set this variable as `true` and put all `JTL` files in the result folder, the image will generate a new file with the name setted in `JTL_FILE`variable and generate the report using this file.  
  
#### REPORT_FOLDER
The default value is `report`. Change it to have different reports, for example.  
  