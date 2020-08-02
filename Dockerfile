FROM node:lts

ENV UID=${UID:-"483228"} \
    USER=${USER:-"blogappid"} \
    GID=${GID:-"16789"} \
    GROUP_NAME=${GROUP_NAME:-"bloggp"} 

RUN groupadd -g  ${GID} ${GROUP_NAME} \
    && useradd -m -u ${UID}  -g ${GID} -d /home/${USER} -s /bin/sh ${USER}

WORKDIR /home/${USER}/app/blog

COPY ./blog /home/${USER}/app/blog

RUN yarn install

RUN chown -R ${USER}:${GROUP_NAME} /home/${USER} 
USER ${UID}
ENTRYPOINT ["yarn", "run", "serve", "--build"]