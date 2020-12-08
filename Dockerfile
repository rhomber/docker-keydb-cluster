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
EXPOSE 7000 7001 7002 7003 7004 7005
# run multiple redis instances using supervisord 
# use sleep to wait for supervisord (running as daemon) spawn all process
# make all spawned process as redis cluster
# use tail to keep container open
CMD supervisord -c /etc/supervisor/supervisord.conf && \
    sleep 3 && \
    if [ -z "$IP" ]; then IP=$(hostname -i | awk '{print $1}'); fi && \
    yes yes | keydb-cli --cluster create ${IP}:7000 ${IP}:7001 ${IP}:7002 ${IP}:7003 ${IP}:7004 ${IP}:7005 --cluster-replicas 1 && \
    tail -f /var/log/supervisor/redis*.log
