FROM ubuntu:noble AS deb

RUN apt-get update && apt-get install -y python3 pipx
ENV PATH="/root/.local/bin:$PATH"
RUN pipx install --include-deps ansible

WORKDIR /ansible

CMD [ "ansible-playbook", "setup.yml" ]
