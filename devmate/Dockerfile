FROM ubuntu:24.04

LABEL maintainer="Duan Uys <duysqubix>(duys@qubixds.com)"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && \
  apt install git wget curl nmap tree zsh sudo -y


RUN useradd -m -G sudo,adm \
  -s /bin/zsh devmate && \
  echo devmate:devmate | chpasswd


WORKDIR /home/devmate

RUN ls
RUN curl https://gist.githubusercontent.com/duysqubix/27084d18b99181c60eea9c3d2a321fce/raw/duysqubix-zshrc \
  >> /tmp/.zshrc

RUN HOME=/home/devmate /bin/zsh /tmp/.zshrc
RUN chown -R $(id -u devmate):$(id -g devmate) /home/devmate
RUN chown -R $(id -u devmate):$(id -g devmate) /tmp

USER devmate
RUN mv /tmp/.zshrc /home/devmate/.zshrc

ENTRYPOINT ["/bin/zsh", "-c", "ZSH_FORCE_UPDATE=1 /bin/zsh"]



