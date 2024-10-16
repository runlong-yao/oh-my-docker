
FROM ubuntu:23.10

RUN apt update -y

ENV PNPM_HOME /root/.local/share/pnpm
ENV PATH="$PNPM_HOME:$PATH"
RUN apt install nodejs npm -y && \
    npm install -g pnpm && \
    pnpm config set registry https://registry.npmmirror.com

ENV TZ=Asia/Shanghai
RUN apt install tzdata -y && \
    cp /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
    apt remove tzdata -y


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
RUN apt install zsh git tree htop vim curl wget fzf exa fd-find rsync silversearcher-ag openssl -y
ENV SHELL /bin/zsh
# end

#oh-my-zsh
RUN rm -rf ~/.oh-my-zsh/ && \
    curl -L http://install.ohmyz.sh > install.sh && \
    sh install.sh && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions   && \
    sed -i 's/^plugins=(\(.*\)/plugins=(zsh-autosuggestions zsh-syntax-highlighting \1/' /root/.zshrc


#设置中文
RUN apt install locales -y && \
    sed -ie 's/^# zh_CN.UTF-8/zh_CN.UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo 'export LANG=zh_CN.UTF-8' >> /root/.zshrc && \
    echo 'export LC_ALL=zh_CN.UTF-8' >> /root/.zshrc && \
    echo 'export LANGUAGE=zh_CN.UTF-8' >> /root/.zshrc


# nvm
ENV NVM_DIR /root/.nvm
ADD nvm-0.39.1 /root/.nvm/
RUN sh ${NVM_DIR}/nvm.sh &&\
    echo '' >> /root/.zshrc &&\
    echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.zshrc &&\
    echo '[ -s "${NVM_DIR}/nvm.sh" ] && { source "${NVM_DIR}/nvm.sh" }' >> /root/.zshrc &&\
    echo '[ -s "${NVM_DIR}/bash_completion" ] && { source "${NVM_DIR}/bash_completion" } ' >> /root/.zshrc




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

RUN wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz -O go.tar.gz && \
    tar -xzvf go.tar.gz -C /usr/local
ENV GOROOT /usr/local/go
ENV PATH $GOROOT/bin:$PATH
RUN go env -w GO111MODULE=on &&\
    go env -w GOPROXY=https://goproxy.cn,direct &&\
    go install github.com/silenceper/gowatch@latest &&\
    go install golang.org/x/tools/gopls@latest
# end





