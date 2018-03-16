# Ubuntu 16.04 with SonarQube/GoLand scanning tools installed.
#    Barebones installation with GoLang,GoMetaLinter and Sonar-scanner installed and configured
# Creation Date: March 15, 2018
# Build image with:  

FROM ubuntu:16.04
MAINTAINER Dennis Christilaw (https://github.com/Talderon)

ENV HOME /root

# Add the hostname to the hosts file
RUN uhost=( $(cat /etc/hostname ) ) && \
    echo '127.0.0.1 '$uhost >> /etc/hosts

# Run updates to ensure the repo's are updated
RUN apt-get update -y && \
    apt-get upgrade -y

# Installs software in order to allow for independent vendor software sources, in particular the “add-apt-repository” command that is used elsewhere
# As well as come CLI Tools that are needed for various functions.
RUN apt-get install -y software-properties-common apt-transport-https ca-certificates curl software-properties-common make vim unzip

# Install Docker
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get update -y && \
    apt-get install docker-ce

# Install Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin/kubectl

# Install GoLang (1.10)
RUN wget https://dl.google.com/go/go1.10.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.10.linux-amd64.tar.gz && \
    mkdir -p $HOME/go_projects/{bin,src,pkg} && \
    mkdir -p /usr/local/sonar-scanner/bin && \
    rm -f /etc/environment && \
    printf '%s\n' 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/go/bin:/root/go_projects/bin:/usr/local:/usr/local/sonar-scanner/bin"' ' ' 'GOPATH=$HOME/go_projects' 'GOBIN=$GOPATH/bin' >/etc/environment && \
    source /etc/environment

# Install GoMetaLinter
RUN go get -u gopkg.in/alecthomas/gometalinter.v2 && \
    mv $HOME/go/bin/gometalinter.v2 $HOME/go/bin/gometalinter
    gometalinger --install

# Install Sonar-Scanner
RUN wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-3.0.3.778-linux.zip
    unzip sonar-scanner-cli-3.0.3.778-linux.zip -d /usr/local/
    mv /usr/local/sonar-scanner-3.0.3.778-linux /usr/local/sonar-scanner

# Cleans the local repository from retrieved package files	
RUN apt-get clean
