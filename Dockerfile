FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

Label name="Vigor4 Ubuntu" \
         author="James Christensen <jchriste@jcvi.org>" \
         vendor="JCVI" \
         license="GPLv3" \
         build-date="20190204"

RUN apt-get update && apt-get -y install \
    exonerate \
    git \
    maven \
    openjdk-11-jre-headless  \
    unzip \
    && rm -rf /var/lib/apt/lists/*

RUN useradd --inactive -1 --create-home --comment "Vigor4"  --shell /bin/bash  vigor4
USER vigor4
WORKDIR /home/vigor4
RUN git clone https://github.com/JCVenterInstitute/VIGOR4.git vigor4-repo   \
        && git clone https://github.com/JCVenterInstitute/VIGOR_DB vigor-db-repo  \
        && mkdir /home/vigor4/vigor4-installs  \
        && cd vigor4-repo  \
        && mvn package  \
        && (find  target -maxdepth 1 -name 'vigor-4*.zip' | xargs unzip -d /home/vigor4/vigor4-installs)  \
        && cd /home/vigor4  \
        && (ls -tr1 /home/vigor4/vigor4-installs/ | tail -n1) \
        && (ls -tr1 /home/vigor4/vigor4-installs/ | tail -n1 | xargs -I{} ln -s /home/vigor4/vigor4-installs/{} /home/vigor4/vigor4 ) \
        && (echo  "\nreference_database_path=/home/vigor4/vigor-db-repo/Reference_DBs/\nexonerate_path=/usr/bin/exonerate\ntemporary_directory=/tmp\n" > /home/vigor4/vigor4/config/vigor.ini) \
        && (echo  "\n(echo \$PATH| grep -q /home/vigor4/vigor4/bin) || PATH=\$PATH:/home/vigor4/vigor4/bin" >> /home/vigor4/.bashrc)
        
