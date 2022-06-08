FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y wget gnupg2 python3-pip sshpass git openssh-client unzip && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean
    
RUN python3 -m pip install --upgrade pip cffi && \
    pip install ansible==5.8.0 && \
    pip install jmespath && \
    pip install --upgrade pywinrm && \
    rm -rf /root/.cache/pip

RUN wget https://cache.agilebits.com/dist/1P/op2/pkg/v2.3.1/op_linux_amd64_v2.3.1.zip && \
    unzip op_linux_amd64_v2.3.1.zip -d /usr/local/bin/ && \
    rm -rf op_linux_amd64_v2.3.1.zip

RUN mkdir /ansible && \
    mkdir -p /etc/ansible && \
    echo 'localhost' > /etc/ansible/hosts

COPY . /ansible

WORKDIR /ansible

ENTRYPOINT [ "ansible-playbook", "site.yml" ]
CMD [ "--version" ]
