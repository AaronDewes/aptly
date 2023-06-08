FROM debian:bookworm AS builder

RUN apt-get update && apt-get install -y --no-install-recommends devscripts equivs gnupg wget

RUN wget http://molior.info/archive-keyring.asc -q -O- | gpg --dearmor | tee "/etc/apt/trusted.gpg.d/molior.gpg" >/dev/null
RUN echo "deb http://molior.info/1.4/bullseye stable main" > /etc/apt/sources.list.d/molior.list

RUN apt-get update

WORKDIR /aptly

COPY debian ./debian
        
# Install the build dependencies
RUN mk-build-deps -i -r -t "apt-get -y --no-install-recommends"

COPY . .

# Build the package
RUN debuild -us -uc -b

FROM debian:bookworm-slim

COPY --from=builder /aptly/*.deb /tmp/

RUN apt-get update \
    && apt-get install -y wget gnupg1 nginx-light apg apache2-utils \
    && apt-get install -y --no-install-recommends /tmp/*.deb \
    && rm -rf /var/lib/apt/lists/* && rm -rf /tmp/*.deb

