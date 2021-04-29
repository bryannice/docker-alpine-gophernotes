ARG STEP_1_IMAGE=alpine:3.13

FROM ${STEP_1_IMAGE} AS STEP_1

# Install Jupyter and gophernotes.
RUN set -x \
    # install python and dependencies
    && apk update \
    && apk --no-cache \
        --repository http://dl-4.alpinelinux.org/alpine/v3.13/community \
        --repository http://dl-4.alpinelinux.org/alpine/v3.13/main \
        --arch=x86_64 add \
        ca-certificates \
        python3-dev \
        su-exec \
        libffi-dev \
        gcc \
        git \
        py3-pyzmq \
        py3-pip \
        pkgconfig \
        zeromq-dev \
        musl-dev \
    && ln -s /usr/bin/python3.8 /usr/bin/python

## install Go
RUN apk --update-cache --allow-untrusted \
        --repository http://dl-4.alpinelinux.org/alpine/edge/community \
        --arch=x86_64 add \
        go

## jupyter notebook
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h \
    ### fix pyzmq to v16.0.2 as that is what is distributed with py3-zmq
    ### pin down the tornado and ipykernel to compatible versions
    && pip3 install jupyter notebook tornado ipykernel

## install gophernotes
RUN mkdir -p /go/src/github.com/gopherdata \
    && cd /go/src/github.com/gopherdata \
    && git clone https://github.com/gopherdata/gophernotes.git \
    && cd /go/src/github.com/gopherdata/gophernotes \
    && GOPATH=/go GO111MODULE=on go install . \
    && cp /go/bin/gophernotes /usr/local/bin/ \
    && mkdir -p ~/.local/share/jupyter/kernels/gophernotes \
    && cp -r ./kernel/* ~/.local/share/jupyter/kernels/gophernotes \
    && cd - \
    ## clean
    && find /usr/lib/python3.8 -name __pycache__ | xargs rm -r \
    && rm -rf \
        /root/.[acpw]* \
        ipaexg00301* \
    && rm -rf /var/cache/apk/*

# Set GOPATH.
ENV GOPATH /go

EXPOSE 8888
CMD [ "jupyter", "notebook", "--no-browser", "--allow-root", "--ip=0.0.0.0" ]