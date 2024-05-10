
FROM node:20-buster-slim

RUN apt update

# RUN echo 'deb http://mirrors.aliyun.com/debian/ buster main non-free contrib\n\
#     deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib\n\
#     deb http://mirrors.aliyun.com/debian-security buster/updates main\n\
#     # deb-src http://mirrors.aliyun.com/debian-security buster/updates main\n\
#     deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib\n\
#     # deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib\n\
#     deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib\n\
#     deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib\n'\
#     >> /etc/apt/sources.list

ENV TZ=Asia/Shanghai
RUN apt install tzdata -y && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt remove tzdata -y

ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable && \
    corepack prepare pnpm@latest-8 --activate && \
    pnpm config set registry https://registry.npmmirror.com && \
    apt-get update -y && apt-get install -y openssl


WORKDIR /tmp
ENV SHELL /bin/bash
# ADD mirrorlist /etc/pacman.d/mirrorlist
# RUN yes | pacman -Syu
# RUN yes | pacman -S git zsh which vim curl tree htop
RUN mkdir -p /root/.config
VOLUME [ "/root/.config", "/root/repos", "/root/.vscode-server/extensions", "/root/go/bin", "/var/lib/docker", "/root/.local/share/pnpm", "/usr/local/rvm/gems", "/root/.ssh" ]
# end

# z
ADD z /root/.z_jump
# end

# other
RUN apt install zsh git tree htop vim curl wget fzf exa fd-find rsync silversearcher-ag -y
ENV SHELL /bin/zsh
# end

# nvm
ENV NVM_DIR /root/.nvm
ADD nvm-0.39.1 /root/.nvm/
RUN sh ${NVM_DIR}/nvm.sh &&\
	echo '' >> /root/.zshrc &&\
	echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.zshrc &&\
	echo '[ -s "${NVM_DIR}/nvm.sh" ] && { source "${NVM_DIR}/nvm.sh" }' >> /root/.zshrc &&\
	echo '[ -s "${NVM_DIR}/bash_completion" ] && { source "${NVM_DIR}/bash_completion" } ' >> /root/.zshrc
# end

# tools
# RUN yes | pacman -S fzf openssh exa the_silver_searcher fd rsync &&\
# 		ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key &&\
# 		ssh-keygen -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key
# end



# fq
# ADD proxychains.conf /root/.config/proxychains.conf
# RUN yes | pacman -S trojan proxychains-ng
# end

# others
# RUN yes | pacman -S postgresql-libs
# end

# dotfiles
ADD bashrc /root/.bashrc
RUN echo '[ -f /root/.bashrc ] && source /root/.bashrc' >> /root/.zshrc; \
    echo '[ -f /root/.zshrc.local ] && source /root/.zshrc.local' >> /root/.zshrc
RUN mkdir -p /root/.config; \
    touch /root/.config/.profile; ln -s /root/.config/.profile /root/.profile; \
    touch /root/.config/.gitconfig; ln -s /root/.config/.gitconfig /root/.gitconfig; \
    touch /root/.config/.zsh_history; ln -s /root/.config/.zsh_history /root/.zsh_history; \
    touch /root/.config/.z; ln -s /root/.config/.z /root/.z; \
    touch /root/.config/.rvmrc; ln -s /root/.config/.rvmrc /root/.rvmrc; \
    touch /root/.config/.bashrc; ln -s /root/.config/.bashrc /root/.bashrc.local; \
    touch /root/.config/.zshrc; ln -s /root/.config/.zshrc /root/.zshrc.local;
RUN echo "rvm_silence_path_mismatch_check_flag=1" >> /root/.rvmrc
RUN git config --global core.editor "code --wait"; \
    git config --global init.defaultBranch main
