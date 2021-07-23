FROM golang:1.16.6-alpine as builder
RUN apk add --no-cache gcc musl-dev linux-headers git make
WORKDIR /bor
RUN git clone --branch v0.2.6 --depth 1 https://github.com/maticnetwork/bor .
RUN make bor-all
WORKDIR /heimdall
RUN git clone --branch v0.2.1-mainnet --depth 1 https://github.com/maticnetwork/heimdall.git .
RUN make install


FROM alpine:3.14 as heimdall
COPY --from=builder /go/bin/{heimdalld,heimdallcli,bridge}  /usr/local/bin/
COPY /heimdall.sh /usr/local/bin/
ENV ETH_RPC_URL=https://mainnet.infura.io/v3/5fe41449643c4ba48953a97f19898ca1
ENTRYPOINT [ "heimdall.sh" ]

FROM alpine:3.14 as bor
COPY --from=builder /go/bin/{bootnode,bor} /usr/local/bin/
COPY /bor.sh /usr/local/bin/
VOLUME [ "/data" ]
EXPOSE 30003 8545
ENTRYPOINT [ "bor.sh" ]
