# Configure Local Environment - Sonar-Scanner with Golang
###### Documentation By: Dennis Christilaw (https://github.com/Talderon)

## Purpose
This document will walk through how to install the needed apps on your local/dev environment to scan GoLang code with Sonar Scanner.

This document series is meant to help anyone that wants to perform code quality checks for GoLang with SonarQube running in Kubernetes. The server will have a Postgres SQL backend to store scan data. This will live in a persistent volume that this process creates.

The reason for this documentation series is that there are no complete set of docs on how to get SonarQube to work with GoLang. GoLang is not officially supported by SonarQube, so the process to get this working can be difficult as there are many moving parts to try and hit this moving target.  Since I was unable to find a complete set of documents that start from the beginning and go to the end in one place, I decided to get this together to help those that are wanting to do this, but find the lack of information daunting.

You will also install the correct plugins for the following functions:

Build Break when scan produced results that do not pass the quality gates (recommended)

SVG Badges to show in repositories that status of the quality checks (Optional)

## Prerequisites
You will need to have the following in order to complete this configuration:
1. A SonarQube Server Instance up and running with the required configuration. (You can use my other guide here: [README.md](https://github.com/Talderon/k8s-sonarqube/blob/master/README.md) that is a part of this repo.)
2. GoLang code to scan (I used this as an [EXAMPLE](https://github.com/ugik/GoBooks)).
3. Dev/Local machine with access to the internet to download files (or copy from remote location inside network)
4. Dev/local machine with GoLang installed

##### Note:
> This repo and documentation within works primarily with Kubernetes for the Sonar environment setup. You do NOT NEED to set it up this way in order for this part to work. This will work with any sonar environment that is configured properly (see [README.md](https://github.com/Talderon/k8s-sonarqube/blob/master/README.md) for required plugins and configuration needed on the server).

> This document will not cover fine tuning of Rules, Linters or anything else. This is just to get you up and running to check code with GoLang.

#### Install Go GoLang
Download the correct version from [HERE](https://golang.org/dl/)

Installation instructions for various OS's is [HERE](https://golang.org/doc/install)

> This is pretty straightforward, if you have questions, please ask.

> Code block to make it easier
```bash
wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz
tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz
mkdir -p /root/go_projects/{bin,src,pkg}
```

Verify that the GoLang Bin folder is in your path (edit path for your installed location)
```
/usr/local/go/bin
```

Create project directory (only if you did not use the code block above):
```
mkdir -p ~/go_projects/{bin,src,pkg}
```

Add the following lines to your profile (varied depending on OS) - you can put them at the end of the file

> For MAC/Ubuntu, edit/create .bash_profile

```
export PATH=$PATH:/usr/local/go/bin

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
> You can read more about GoMetaLinter [HERE](https://github.com/alecthomas/gometalinter)

Once GoLang is installed, you can install and configure GoMetaLinter using the following steps:

> Be sure to update the paths to the proer directory (normally your $HOME directory)
1. Install GoMetaLinter:
```
go get -u gopkg.in/alecthomas/gometalinter.v2
```
2. Rename the directory:
```
mv /home/<<user>>/go/bin/gometalinter.v2 /home/<<user>>/go/bin/gometalinter
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
The following code block will install the Sonar-Scanner and modify the sonar-scanner.properties file to point to your SonarQube Server

> You will need to have the SonarQuber server URL (e.g. HTTP://IP-Address:Port/sonar)

```bash
apt install -y unzip
wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip
unzip sonar-scanner-cli-3.0.3.778-linux.zip -d /usr/local/
mv /usr/local/sonar-scanner-3.0.3.778-linux /usr/local/sonar-scanner
sed -i '100s#go_projects/bin#go_projects/bin:/usr/local/sonar-scanner/bin#' .bashrc && source .bashrc
read -p "What is the SonarQube URL? (Full url with http://ip_add:port/sonar) >> " surl
rm /usr/local/sonar-scanner/conf/sonar-scanner.properties
printf '%s\n' '#----- Default SonarQube server' 'sonar.host.url='${surl} ' ' '#----- Default source code encoding' '#sonar.sourceEncoding=UTF-8' >/usr/local/sonar-scanner/conf/sonar-scanner.properties
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

If you cloned the repo given earlier, it includes a sample project config file, you can use the following code block to create/modify easily:
```bash
cp sonar-project.properties.sample sonar-project.properties
echo "Enter your Project Key and press enter:"
read pjkey
echo "Enter your Project Name and press enter:"
read pjname
sed -i~ -e "s/my:project/${pjkey}/g" sonar-project.properties
sed -i~ -e "s/My_project/${pjname}/g" sonar-project.properties
```

## Run the Scan

### Code Scanning

##### Linting

> Instead of golint, we are using the GoMetaLinter. The meta-linter runs many popular linting tools (which ones are configured in the .gometalinter.json file, though we are using the default settings).
```bash
gometalinter –checkstyle > report.xml
```

##### Coverage

Install the code coverage tools:
```bash
go get github.com/axw/gocov/...
go get github.com/AlekSi/gocov-xml
```

For most projects you would create the coverage using:
```bash
go test ./... -coverprofile c.out # requires go 1.10
# in c.out -- replace absolute paths with a relative path, ex: ./
gocov convert c.out |  gocov-xml > coverage.xml
```
For some projects make test-coverage will generate the test coverage locally under test/coverage.. With the report at index.html. It also copies that file to coverage.xml at the root for use by the pipeline.

The CI/CD Pipeline calls the same file.

The exact command you will use will depend on the project. Some projects require you to run the Makefile with arguments that run specific tests.

##### Unit Tests

For most projects you'd do go test. For some will use make test.
