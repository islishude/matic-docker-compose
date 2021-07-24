FROM golang:1.16.6-buster as builder
RUN apt-get update && apt-get install -y build-essential git
WORKDIR /bor
RUN git clone --branch v0.2.6 --depth 1 https://github.com/maticnetwork/bor .
RUN make bor-all
WORKDIR /heimdall
RUN git clone --branch v0.2.1-mainnet --depth 1 https://github.com/maticnetwork/heimdall.git .
RUN make install

FROM debian:buster as heimdall
COPY --from=builder /go/bin/heimdalld /usr/local/bin/
COPY /heimdall.sh /usr/local/bin/
ENV ETH_RPC_URL=https://mainnet.infura.io/v3/5fe41449643c4ba48953a97f19898ca1
ENTRYPOINT [ "heimdall.sh" ]

FROM debian:buster as bor
COPY --from=builder /go/bin/bootnode /go/bin/bor /usr/local/bin/
COPY /bor.sh /usr/local/bin/
VOLUME [ "/data" ]
EXPOSE 30003 8545
ENTRYPOINT [ "bor.sh" ]
