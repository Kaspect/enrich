# enrichment

- Open up a `r3.8xlarge` large instance on AWS running `Ubuntu Linux x64`, with `800GB SSD Storage`.
- SSH in and run `sudo apt-get -y install awscli`
- Run `aws configure` and set the Key ID and Access Key to the ones set by `s3://polar-fulldump`. Set region to `us-east-1`
- Add this to `~/.aws/config` so it'll run a little faster.
```
s3 =
  max_concurrent_requests = 50
  multipart_threshold = 128MB
  ```
- Make a folder to hold the new data `mkdir ~/polar-fulldump`
- Download the bucket to the instance via `aws s3 sync s3://polar-fulldump ~/polar-fulldump --quiet && echo Done`
