# this is a scratch image intended to be a shared base install for multi-stage
# docker installs, ie: COPY sydz/et-pure /et .
# or even: COPY sydz/et-pure /et/etmain/pak0.pk3 .
FROM alpine:latest as downloader

# download the linux installer from splashdamage
# it's wrapped in an installer so we'll extract it from the binary with 7zip
RUN apk update && apk add wget p7zip
RUN mkdir /build
WORKDIR /build
RUN wget https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip
RUN 7z x et260b.x86_full.zip et260b.x86_keygen_V03.run && \
    7z x et260b.x86_keygen_V03.run et260b.x86_keygen_V03 && \
    7z x et260b.x86_keygen_V03 -o./et
# clean up a little
WORKDIR et
RUN rm -rf ET.xpm etkey.run etkey.sh makekey openurl.sh setup.sh CHANGES README \
    setup.data etmain/video/etintro.roq && mkdir external

# docker will want to try CMD during build and we won't have a shell
# so we'll build a basic splash static compiled against musl just to satisfy it
FROM ekidd/rust-musl-builder:latest as builder
ADD --chown=rust:rust . ./
RUN cargo build --release && strip target/x86_64-unknown-linux-musl/release/splash

# merge it down into a single folder
FROM builder as merge
COPY --from=downloader /build/et /et
COPY --from=builder --chmod=755 /home/rust/src/target/x86_64-unknown-linux-musl/release/splash /et/external/splash

# create our scratch image with no dependencies
FROM scratch as pure
COPY --from=merge /et /et
CMD ["/et/external/splash"]
