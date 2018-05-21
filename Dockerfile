FROM python:3.6

RUN apt-get update && apt-get install -y bash jq 
RUN pip install awscli --upgrade

WORKDIR /opt/public_scripts/

ADD . .

ENV ENVIRONMENT test

ENTRYPOINT ["/bin/bash"]
