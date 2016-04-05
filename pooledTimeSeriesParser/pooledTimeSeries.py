import os
import subprocess

def runProcess(exe):
   p = subprocess.Popen(exe, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
   while(True):
     retcode = p.poll()
     line = p.stdout.readline()
     yield line
     if(retcode is not None):
       break

def get_filepaths(directory):
    for root, directories, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            print filepath
            command = 'java -classpath /Users/dhruvbhatia/Desktop/pooledTimeSeries/tika-app-1.12.jar org.apache.tika.cli.TikaCLI --config=/Users/dhruvbhatia/Desktop/pooledTimeSeries/tika-config.xml -J ' + filepath
            f = open('/Users/dhruvbhatia/Desktop/output/output_' + filename + '.json','w')
            for line in runProcess(command.split()):
                f.write(line)
            f.close()
get_filepaths("/Users/dhruvbhatia/Desktop/pooledTimeSeries/mp4/")
