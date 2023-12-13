FROM debian:bookworm-slim

WORKDIR /

COPY "docker/texlive.profile" /texlive.profile

# See also https://github.com/reitzig/texlive-docker
RUN apt-get update && \
  apt-get install -qy --no-install-recommends  \
    wget ca-certificates perl \
    ghostscript \
  && wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz \
  && tar -xzf install-tl-unx.tar.gz \
  && rm install-tl-unx.tar.gz \
  && mv install-tl-* install-tl \
  && tlversion=$(cat install-tl/release-texlive.txt | head -n 1 | awk '{ print $5 }') \
  && mkdir -p /usr/local/texlive/${tlversion}/bin \
  && ( cd install-tl \
         && tlversion=$(cat release-texlive.txt | head -n 1 | awk '{ print $5 }') \
         && sed -i "s/\${tlversion}/${tlversion}/g" /texlive.profile \
         && ./install-tl -profile /texlive.profile \
      ) \
  && rm -rf install-tl \
  && tlmgr version | tail -n 1 > version \
  && echo "Installed on $(date)" >> version \
  && apt-get remove -y wget ca-certificates perl  \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /var/cache/apt/ \
