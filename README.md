# enrichment

- Open up a large instance on AWS
- SSH in and run `sudo apt-get install awscli`
- Run `aws configure` and set the Key ID and Access Key to the ones set by `s3://polar-fulldump`. Set region to `us-east-1`
- Make a folder to hold the new data `mkdir ~/polar-fulldump`
- Download the bucket to the instance via `aws s3 sync s3://polar-fulldump ~/polar-fulldump --quiet && echo Done`
