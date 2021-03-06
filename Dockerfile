FROM golang:1.16.6-alpine as builder
RUN apk add --no-cache gcc musl-dev linux-headers git make
WORKDIR /bor
ARG BOR_VERSION=v0.2.6
RUN git clone --branch ${BOR_VERSION} --depth 1 https://github.com/maticnetwork/bor .
RUN make bor-all
WORKDIR /heimdall
ARG HEIMDALL_VERSION=v0.2.1-mainnet
RUN git clone --branch ${HEIMDALL_VERSION} --depth 1 https://github.com/maticnetwork/heimdall.git .
RUN make install

FROM alpine:3.14 as heimdall
COPY --from=builder /go/bin/heimdalld /usr/local/bin/
COPY /heimdall.sh /usr/local/bin/
ENTRYPOINT [ "heimdall.sh" ]

FROM alpine:3.14 as bridge
COPY --from=builder /go/bin/bridge /usr/local/bin/
ENTRYPOINT [ "bridge" ]

FROM alpine:3.14 as bor
COPY --from=builder /go/bin/bootnode /go/bin/bor /usr/local/bin/
COPY /bor.sh /usr/local/bin/
VOLUME [ "/data" ]
EXPOSE 30003 8545
ENTRYPOINT [ "bor.sh" ]
