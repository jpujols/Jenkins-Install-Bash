#!/bin/bash
#
CWD=`pwd`

#Preparing the environment
sudo yum -y install mlocate \
vim \
wget \
curl \
openssl
ant \
epel-release \

#Removing by default java binaries
sudo yum remove -y java

# Let's now install Jenkins:
sudo wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo yum upgrade

# Add required dependencies for the jenkins package
sudo yum install java-11-openjdk
sudo yum install jenkins
sudo systemctl daemon-reload

# Let's start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins
sudo systemctl status jenkins

# Jenkins runs on port 8080 by default. Let's make sure port 8080 is open:
YOURPORT=8080
PERM="--permanent"
SERV="$PERM --service=jenkins"

firewall-cmd $PERM --new-service=jenkins
firewall-cmd $SERV --set-short="Jenkins ports"
firewall-cmd $SERV --set-description="Jenkins port exceptions"
firewall-cmd $SERV --add-port=$YOURPORT/tcp
firewall-cmd $PERM --add-service=jenkins
firewall-cmd --zone=public --add-service=http --permanent
firewall-cmd --reload


# Let's make sure that git is installed since Jenkins will need this
sudo yum install -y gitm

# Lastly, let's install the plugins needed in Jenkins to connect to Github and get a fairly well-running Jenkins installation:
cd /var/lib/jenkins/plugins
sudo rm -R -f ant
sudo rm -R -f credentials
sudo rm -R -f deploy
sudo rm -R -f git-client
sudo rm -R -f git
sudo rm -R -f github-api
sudo rm -R -f github-oauth
sudo rm -R -f github
sudo rm -R -f gcal
sudo rm -R -f google-oauth-plugin
sudo rm -R -f greenballs
sudo rm -R -f javadoc
sudo rm -R -f ldap
sudo rm -R -f mailer 
sudo rm -R -f mapdb-api
sudo rm -R -f maven-plugin
sudo rm -R -f external-monitor-job
sudo rm -R -f oauth-credentials
sudo rm -R -f pam-auth
sudo rm -R -f scm-api
sudo rm -R -f ssh-agent
sudo rm -R -f ssh-credentials
sudo rm -R -f ssh-slaves
sudo rm -R -f subversion
sudo rm -R -f translation
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin ant
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin credentials
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin deploy
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin git-client
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin git
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin github-api
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin github-oauth
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin github
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin gcal
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin google-oauth-plugin
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin greenballs
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin javadoc
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin ldap
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin mailer
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin mapdb-api
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin maven-plugin
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin external-monitor-job
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin oauth-credentials
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin pam-auth
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin scm-api
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin ssh-agent
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin ssh-credentials
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin ssh-slaves
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin subversion
sudo java -jar $CWD/jenkins-cli.jar -s http://localhost:8080/ install-plugin translation

# Be sure to change ownership of all of these downloaded plugins to jenkins:jenkins
sudo chown jenkins:jenkins *.hpi
sudo chown jenkins:jenkins *.jpi

# Restart Jenkins to implement the new plugins:
cd $CWD

# Let's start Jenkins
sudo java -jar jenkins-cli.jar -s http://localhost:8080 safe-restart

# Update the 'locate' database:
sudo updatedb

echo ""
echo "Finished with setup"
echo ""
echo "You can visit your Jenkins installation at the following address (substitute 'localhost' if necessary):"
echo "  http://localhost:8080"
echo ""
echo "Although Jenkins should be installed at this point, it hasn't been secured. See this link:"
echo "https://wiki.jenkins-ci.org/display/JENKINS/Standard+Security+Setup"
echo "Additional documentation: https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos"
echo ""

