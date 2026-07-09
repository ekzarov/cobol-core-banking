FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnucobol make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY *.CBL *.CPY ./
COPY ACCOUNTS.DAT ./

RUN cobc -m INIT-DB.CBL \
    && cobc -m TRANS-PROC.CBL \
    && cobc -m REPORT-GEN.CBL \
    && cobc -x BANK-MAIN.CBL

ENV COB_LIBRARY_PATH=/app

CMD ["./BANK-MAIN"]
