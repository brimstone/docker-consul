FROM brimstone/ubuntu:14.04

CMD []

ENTRYPOINT ["/usr/bin/consul", "agent", "-server", "-data-dir=/consul", \
            "-client=0.0.0.0", "-ui-dir=/webui"]

EXPOSE 8500 8600/udp 8400 8300

ENV GOPATH /go

RUN apt-get update \
	&& dpkg -l | awk '/^ii/ {print $2}' > /tmp/dpkg.clean \
    && apt-get install -y --no-install-recommends git golang ca-certificates \
        build-essential ruby-sass ruby-uglifier\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists \

	&& go get -v github.com/brimstone/consul \
	&& mv $GOPATH/bin/consul /usr/bin/consul \

    && cd $GOPATH/src/github.com/brimstone/consul/ui \
	&& make dist \
	&& mv dist /webui \

	&& dpkg -l | awk '/^ii/ {print $2}' > /tmp/dpkg.dirty \
	&& apt-get remove --purge -y $(diff /tmp/dpkg.clean /tmp/dpkg.dirty | awk '/^>/ {print $2}') \
	&& rm /tmp/dpkg.* \
	&& rm -rf $GOPATH
