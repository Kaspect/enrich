import os
import subprocess
import json

def runProcess(exe):
   p = subprocess.Popen(exe, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
   while(True):
     retcode = p.poll()
     line = p.stdout.readline()
     yield line
     if(retcode is not None):
       break

def get_filepaths(directory):
    finalList = []
    for root, directories, files in os.walk(directory):
        for filename in files:
            filepath = os.path.join(root, filename)
            print filepath
            command = 'java -classpath /Users/dhruvbhatia/Desktop/pooledTimeSeries/tika-app-1.12.jar org.apache.tika.cli.TikaCLI --config=/Users/dhruvbhatia/Desktop/pooledTimeSeries/tika-config.xml -J ' + filepath
            list = []
            for line in runProcess(command.split()):
                list.append(line)
            finalList.append(list)
    f = open('/Users/dhruvbhatia/Desktop/output.json','w')
    data = json.dumps(finalList)
    
    f.write(data)
    f.close()

get_filepaths("/Users/dhruvbhatia/Desktop/pooledTimeSeries/mp4/")
