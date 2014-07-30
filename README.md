## ElasticBeanstalk SQS Worker to Docker dispatcher

AWS provide an elasticbeanstalk worker node type, which pops jobs from an SQS queue and POSTs the JSON to a local web server.  This enables easy, auto-scaling background jobs using a normal web stack.

AWS also provide a docker-based elasticbeanstalk solution stack.

This project simply accepts the jobs from the queue and passes those arguments on to the local docker server.  

### Deploying

The simplest way is to use the aws-elasticbeanstalk console and upload a Dockerrun.aws.json file like the following:

```javascript
{
  "AWSEBDockerrunVersion": "1",
  "Volumes": [
    {
      "HostDirectory": "/var/run/docker.sock",
      "ContainerDirectory": "/docker.sock"
    }
  ],
  "Image": {
    "Name": "rayh/eb-sqs-docker-dispatch",
    "Update": "true"
  },
  "Ports": [
    {
      "ContainerPort": "80"
    }
  ],
  "Logging": "/app/log"
}

```

This will fetch the latest build from the docker hub and deploy it into ElasticBeanstalk.  The docker.sock mapping is needed to be able to spawn new containers, and the logging directive tells EB where to capture logs from.

Once deployed, you may need to change the IAM role to have SQS read permissions, but otherwise it should Just Work.

You can now issue jobs to the SQS queue using the same format as the Docker Remote API create container endpoint - [https://docs.docker.com/reference/api/docker_remote_api_v1.13/]
