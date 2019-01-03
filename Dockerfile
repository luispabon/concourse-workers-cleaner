FROM alpine:latest 

RUN apk update \                                                                                                                                                                                                                        
    && apk --no-cache add ca-certificates wget \                                                                                                                                                                                                      
    && update-ca-certificates \
    && wget https://github.com/concourse/concourse/releases/download/v4.2.2/fly_linux_amd64 -O /usr/bin/fly \
    && chmod +x /usr/bin/fly
    
COPY entrypoint.sh /entrypoint
COPY cleaner.sh /concourse/workers-cleaner.sh

ENV PATH="/concourse/bin:${PATH}" 

WORKDIR /concourse

ENTRYPOINT ["/entrypoint"]
