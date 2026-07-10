ARG DEBIAN_DIST=bookworm
FROM debian:bookworm

ARG DEBIAN_DIST
ARG k9s_VERSION
ARG BUILD_VERSION
ARG FULL_VERSION
ARG ARCH
ARG K9S_RELEASE

RUN mkdir -p /output/usr/bin
RUN mkdir -p /output/usr/share/doc/k9s
RUN mkdir -p /output/DEBIAN

COPY ${K9S_RELEASE}/k9s /output/usr/bin/k9s
COPY output/DEBIAN/control /output/DEBIAN/
COPY output/DEBIAN/postinst /output/DEBIAN/postinst
RUN chmod 755 /output/DEBIAN/postinst
COPY output/copyright /output/usr/share/doc/k9s/
COPY output/changelog.Debian /output/usr/share/doc/k9s/
COPY output/README.md /output/usr/share/doc/k9s/

RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/usr/share/doc/k9s/changelog.Debian
RUN sed -i "s/FULL_VERSION/$FULL_VERSION/" /output/usr/share/doc/k9s/changelog.Debian
RUN sed -i "s/DIST/$DEBIAN_DIST/" /output/DEBIAN/control
RUN sed -i "s/k9s_VERSION/$k9s_VERSION/" /output/DEBIAN/control
RUN sed -i "s/BUILD_VERSION/$BUILD_VERSION/" /output/DEBIAN/control
RUN sed -i "s/SUPPORTED_ARCHITECTURES/$ARCH/" /output/DEBIAN/control

RUN dpkg-deb --build /output /k9s_${FULL_VERSION}.deb
