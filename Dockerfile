# set base image
FROM eqalpha/keydb:latest
# install dependencies
RUN apt-get update
RUN apt-get install -y wget ruby-dev supervisor
# set workdir
WORKDIR /workdir
# copy supervisor config
COPY supervisord.conf /etc/supervisor/supervisord.conf
# expose ports
EXPOSE 6400 6401 6402 6403 6404 6405
# run multiple redis instances using supervisord 
# use sleep to wait for supervisord (running as daemon) spawn all process
# make all spawned process as redis cluster
# use tail to keep container open

CMD supervisord -c /etc/supervisor/supervisord.conf && \
    sleep 3 && \
    if [ -z "$IP" ]; then IP=$(hostname -i | awk '{print $1}'); fi && \
    yes yes | keydb-cli --cluster create ${IP}:6400 ${IP}:6401 ${IP}:6402 ${IP}:6403 ${IP}:6404 ${IP}:6405 --cluster-replicas 1 && \
    tail -f /var/log/supervisor/keydb*.log
