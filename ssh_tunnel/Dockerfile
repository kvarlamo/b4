# sshd
#
# VERSION               0.0.2
# see https://docs.docker.com/engine/examples/running_ssh_service/

FROM ubuntu:14.04
MAINTAINER Sven Dowideit <SvenDowideit@docker.com>

RUN apt-get update && apt-get install -y openssh-server vim
RUN mkdir /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

CMD ["/usr/sbin/sshd", "-D"]
