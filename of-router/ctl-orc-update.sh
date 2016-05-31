docker pull brain4net/ctlsp-v1
docker pull brain4net/orc-v1
docker rm -f -v ctl orc
docker run -d --net=host --restart=always --log-opt max-size=100m --volumes-from dbs -e JAVA_OPTS='-Dmongo.host=127.0.0.1 -Dmongo.port=27017' --name ctl -h ctl brain4net/ctlsp-v1
docker run -d --net=host --restart=always --log-opt max-size=100m --volumes-from dbs -e JAVA_OPTS='-Dspring.data.mongodb.host=127.0.0.1' --name orc -h orc brain4net/orc-v1
