#! /bin/bash
sudo apt update
sudo apt install zip unzip -y
sudo apt install openjdk-8-jdk -y

wget https://github.com/delta-io/delta-sharing/releases/download/v1.1.0/delta-sharing-server-1.1.0.zip
sudo unzip delta-sharing-server-1.1.0.zip

cd delta-sharing-server-1.1.0/conf
cat > delta-sharing-server.yaml <<EOF
# The format version of this config file
version: 1
# Config shares/schemas/tables to share
shares:
- name: "palantir-share"
  schemas:
  - name: "default"
    tables:
    - name: "palantir"
      location: "s3a://${palantir_dataset}"
      id: "s3a://${palantir_dataset_rid}"
# Set the hostname that the server will use
host: "localhost"
# Set the port that the server will listen on. Note: using ports below 1024 
# may require a privileged user in some operating systems.
port: 8080
# Set the URL prefix for the REST APIs
endpoint: "/delta-sharing"
# Set the timeout of S3 presigned URL in seconds
preSignedUrlTimeoutSeconds: 3600
# How many tables to cache in the server
deltaTableCacheSize: 10
# Whether we can accept working with a stale version of the table. This is useful when sharing
# static tables that will never be changed.
stalenessAcceptable: false
# Whether to evaluate user-provided `predicateHints`
evaluatePredicateHints: false
# The data recipient access token
authorization:
  bearerToken: "${bearer_token}"
EOF

%{ if data_provider == "palantir" }
cat > core-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>
<configuration>
  <property>
    <name>fs.s3a.access.key</name>
    <value>${palantir_access_key_id}</value>
  </property>
  <property>
    <name>fs.s3a.secret.key</name>
    <value>${palantir_secret_access_key}</value>
  </property>
  <property>
    <name>fs.s3a.endpoint</name>
    <value>${palantir_endpoint}</value>
  </property>
  <property>
    <name>fs.s3a.region</name>
    <value>${palantir_region}</value>
  </property>
  <property>
    <name>fs.s3a.paging.maximum</name>
    <value>500</value>
  </property>
  <property>
    <name>fs.s3a.path.style.access</name>
    <value>true</value>
  </property>
</configuration>
EOF
%{ endif }

cd ..
./bin/delta-sharing-server --config conf/delta-sharing-server.yaml