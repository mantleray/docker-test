# This Dockerfile is used to build an image containing basic stuff to be used as a Jenkins slave build node.
FROM ubuntu:trusty
MAINTAINER Ervin Varga <ervin.varga@gmail.com>

# In case you need proxy
#RUN echo 'Acquire::http::Proxy "http://127.0.0.1:8080";' >> /etc/apt/apt.conf

# Add locales after locale-gen as needed
# Upgrade packages on image
# Preparations for sshd
RUN locale-gen en_US.UTF-8 &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q upgrade -y -o Dpkg::Options::="--force-confnew" --no-install-recommends &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openssh-server &&\
    apt-get -q autoremove &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin &&\
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
    mkdir -p /var/run/sshd

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV JENKINS_HOME /home/jenkins

# Install JDK 8 (latest edition)
RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common &&\
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jre-headless &&\
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin

RUN apt-get update
RUN apt-get install -y --no-install-recommends wget \
    git \
    unzip


RUN wget https://releases.hashicorp.com/packer/1.0.2/packer_1.0.2_linux_amd64.zip
RUN unzip packer_1.0.2_linux_amd64.zip -d /usr/local/bin
RUN rm -f packer_1.0.2_linux_amd64.zip

# Set user jenkins to the image
#RUN useradd -m -d /home/jenkins -s /bin/sh jenkins &&\
#    echo "jenkins:jenkins" | chpasswd

RUN useradd -m -d /home/jenkins -s /bin/sh jenkins

RUN mkdir "$JENKINS_HOME"/.ssh
COPY files/authorized_keys  "$JENKINS_HOME"/.ssh/
RUN chown -R jenkins:jenkins "$JENKINS_HOME"
RUN chmod 600 "$JENKINS_HOME"/.ssh/authorized_keys
RUN chmod 700 "$JENKINS_HOME"/.ssh

# Standard SSH port
EXPOSE 22

# Default command
CMD ["/usr/sbin/sshd", "-D"]
