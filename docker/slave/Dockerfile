FROM net-docker-registry.adm.netways.de:5000/jenkins-slave

COPY ./files/. /

RUN chown -R jenkins.jenkins /home/jenkins \
 && chmod -R g=,o= /home/jenkins/.ssh
