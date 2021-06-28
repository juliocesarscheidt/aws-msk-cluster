# AWS Kafka Cluster as Code

This project is intended to create a Kafka Cluster on AWS as code

```bash
export STAGE="development"
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"

export AWS_BACKEND_BUCKET_NAME="kafka-cluster-backend-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n1)"

export KAFKA_LOGS_BUCKET_NAME="kafka-cluster-$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n1)"

make init

make apply
```
