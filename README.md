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
- Wait a long time:
![s3_to_instance](https://cloud.githubusercontent.com/assets/4623063/13813354/59dbe0fe-eb81-11e5-8b7e-12c927ee8d61.gif)


Get the file sizes:
http://unix.stackexchange.com/questions/185764/how-do-i-get-the-size-of-a-directory-on-the-command-line
`du -sch` within the folder.


# install Grobid
```
wget https://github.com/kermitt2/grobid/archive/grobid-parent-0.4.0.zip
sudo apt-get -y install unzip
unzip grobid-grobid-parent-0.4.0.zip
sudo apt-get -y install maven2
cd grobid-grobid-parent-0.4.0/grobid-core/target/
mvn clean install
```

Add the following dependency in pom:
```
<plugin>
  <groupId>org.mortbay.jetty</groupId>
  <artifactId>maven-jetty-plugin</artifactId>
  <version>6.0.1</version>
</plugin>
```
