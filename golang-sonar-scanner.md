# Configure Local Environment - Sonar-Scanner with Golang
###### Documentation By: Dennis Christilaw (https://github.com/Talderon)

## Purpose
This document will walk through how to install the needed apps on your local/dev environment to scan GoLang code with Sonar Scanner.

#### Coming Soon ####
I will add to this document to include Unit Testing and Code Coverage for SonarQube and GoLang!

## Prerequisites
You will need to have the following in order to complete this configuration:
1. A SonarQube Server Instance up and running with the required configuration. (You can use my other guild here: README.md that is a part of this repo.)
2. GoLang code to scan (I used this as an example: https://github.com/ugik/GoBooks).
3. Dev/Local machine with access to the internet to download files (or copy from remote location inside network)
4. Dev/local machine with GoLang installed

##### Note:
> This repo and documentation within works primarily with Kubernetes for the Sonar environment setup. You do NOT NEED to set it up this way in order for this part to work. This will work with any sonar environment that is configured properly (see README.md for required plugins and configuration needed on the server).

> This document will not cover fine tuning of Rules, Linters or anything else. This is just to get you up and running to check code with GoLang.

#### Install Go GoLang
Download the correct version from here: https://golang.org/dl/

Installation instructions for various OS's is here: https://golang.org/doc/install

> This is pretty straightforward, if you have questions, please ask.

Verify that the GoLang Bin folder is in your path (edit path for your installed location)
```
/usr/local/go/bin
```

Create project directory:
```
mkdir -p ~/go_projects/{bin,src,pkg}
```

Add the following lines to your profile (varied depending on OS) - you can put them at the end of the file

> For MAC, CentOS/RedHat or Ubuntu Including Bash for Windows 10), add/create .bash_profile

```
export GOPATH="$HOME/go_projects"
export GOBIN="$GOPATH/bin"
```

Source the file with the paths and updates
```
source ~/.bash_profile
```

Verify your install:
```
$ go version
go version go1.10 darwin/amd64
```

#### Install GoMetaLinter
> You can read more about GoMetaLinter at: https://github.com/alecthomas/gometalinter

Once GoLang is installed, you can install and configure GoMetaLinter using the following steps:
1. Install GoMetaLinter:
```
go get -u gopkg.in/alecthomas/gometalinter.v2
```
2. Rename the directory:
```
mv /home/<<user>>/go/bin/gometalinter.v2 /home/'user'/go/bin/gometalinter
```
3. Verify that /home/'user'/go/bin is in the path (you may have to restart the shell or source the file where $PATH is defined)
```
echo $Path
```
4. Install default linters into GoMetaLinter:
```
gometalinger --install
```

#### Install Sonar-Scanner
Location of installation files and instructions are here: https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

Once installed, you will need to configure the scanner to know where the server is:
```
vi <install_directory>/conf/sonar-scanner.properties
```
Update the Default SonarQube Server to the correct value. Example below:
```
#Configure here general information about the environment, such as SonarQube DB details for example
#No information about specific project should appear here

#----- Default SonarQube server
sonar.host.url=http://10.145.85.140:31862/sonar

#----- Default source code encoding
#sonar.sourceEncoding=UTF-8
```
> Be sure to make sure it is the FULL URL to the UI. In the case above '/sonar' is where the web app lives. If you run into issues, this is something to check and verify.

#### Configure your project
EACH project that you want to scan, MUST HAVE a Sonar Scanner config file somwhere in your repo directory structure. It does not need to be in root of the project, but if it is not, some additional configuration details will change (they will be included).

Put the configuration file in your repo. Sample:
```bash
# must be unique in a given SonarQube instance
sonar.projectKey=my:project
# this is the name and version displayed in the SonarQube UI. Was mandatory prior to SonarQube 6.1.
sonar.projectName=My_project
sonar.projectVersion=1.0
# GoLint report path, default value is report.xml
sonar.golint.reportPath=report.xml
# Cobertura like coverage report path, default value is coverage.xml
sonar.coverage.reportPath=coverage.xml
# if you want disabled the DTD verification for a proxy problem for example, true by default
sonar.coverage.dtdVerification=false
# JUnit like test report, default value is test.xml
sonar.test.reportPath=test.xml
# Path is relative to the sonar-project.properties file. Replace "\" by "/" on Windows.
# This property is optional if sonar.modules is set.
sonar.sources=.
# Encoding of the source code. Default is default system encoding
#sonar.sourceEncoding=UTF-8
```
> If you put the config file in 'project_root/scanner', then your 'sonar.sources=' will be 'sonar.sources=../' because the code starts at the project root folder.

#### Run the Scan
This is the first part to get the scanner report
```
gometalinter --checkstyle > report.xml
```

#### Coverage Report

> Coming Soon

#### Send your test results to SonarQube
Once everything has been completed, all you need to do to scan and get the data to the server is:
```
<<<<<<< HEAD
sonar-scanner
=======
gometalinter > report.xml
>>>>>>> d42a71ac4d886099ae7bf929cc256d3c437aee32
```
This will create the report.xml that the GoLang plugin is expecting.

To upload this to the SonarQube server, just run sonar-scanner where the report.xml lives.

The project should appear in your SonarQube GUI and once the analysis is complete, your data will show up for you to validate.

<<<<<<< HEAD







# Scratch
##### Temporary Placeholder for expanding the documentation

#### Install coveragte tools to GoLang
```
go get golang.org/x/tools/cmd/cover
```
#### Install SemVer
```
go get github.com/blang/semver
```
