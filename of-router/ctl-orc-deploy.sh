docker pull mongo
docker pull brain4net/ctlsp-v1
docker pull brain4net/orc-v1
docker rm -f -v dbs ctl orc
docker run -d --net=host --restart=always --log-opt max-size=100m --name=dbs mongo mongod --replSet b4nrs
grep -m 1 "waiting for connections on port" <(docker logs -f dbs) >> /dev/null
docker exec dbs mongo --eval 'rs.initiate({_id:"b4nrs", members: [{"_id":1, "host":"127.0.0.1:27017"}]})'
grep -m 1 "transition to primary complete; database writes are now permitted" <(docker logs -f dbs) >> /dev/null
docker run -d --net=host --restart=always --log-opt max-size=100m --volumes-from dbs -e JAVA_OPTS='-Dmongo.host=127.0.0.1 -Dmongo.port=27017' --name ctl -h ctl brain4net/ctlsp-v1
docker run -d --net=host --restart=always --log-opt max-size=100m --volumes-from dbs -e JAVA_OPTS='-Dspring.data.mongodb.host=127.0.0.1' --name orc -h orc brain4net/orc-v1
ip link add dev le1sp type veth peer name sple1
ip link add dev le2sp type veth peer name sple2
ip link add dev le3sp type veth peer name sple3
ip link add dev le4sp type veth peer name sple4
ip link add dev le5sp type veth peer name sple5
ip link add dev h1le1 type veth peer name le1h1
ip link add dev h2le2 type veth peer name le2h2
ip link add dev h3le3 type veth peer name le3h3
ip link add dev h4le4 type veth peer name le4h4
ip link add dev h5le5 type veth peer name le5h5
ip link set dev le1sp up
ip link set dev le2sp up
ip link set dev le3sp up
ip link set dev le4sp up
ip link set dev le5sp up
ip link set dev sple1 up
ip link set dev sple2 up
ip link set dev sple3 up
ip link set dev sple4 up
ip link set dev sple5 up
ip link set dev h1le1 up
ip link set dev h2le2 up
ip link set dev h3le3 up
ip link set dev h4le4 up
ip link set dev h5le5 up
ip link set dev le1h1 up
ip link set dev le2h2 up
ip link set dev le3h3 up
ip link set dev le4h4 up
ip link set dev le5h5 up
ovs-vsctl --may-exist add-br sp
ovs-vsctl --may-exist add-br le1
ovs-vsctl --may-exist add-br le2
ovs-vsctl --may-exist add-br le3
ovs-vsctl --may-exist add-br le4
ovs-vsctl --may-exist add-br le5
ovs-vsctl set-fail-mode sp secure
ovs-vsctl set-fail-mode le1 secure
ovs-vsctl set-fail-mode le2 secure
ovs-vsctl set-fail-mode le3 secure
ovs-vsctl set-fail-mode le4 secure
ovs-vsctl set-fail-mode le5 secure
ovs-vsctl set bridge sp datapath_type=netdev
ovs-vsctl set bridge le1 datapath_type=netdev
ovs-vsctl set bridge le2 datapath_type=netdev
ovs-vsctl set bridge le3 datapath_type=netdev
ovs-vsctl set bridge le4 datapath_type=netdev
ovs-vsctl set bridge le5 datapath_type=netdev
systemctl restart openvswitch
ovs-vsctl --may-exist add-port sp sple1 -- set interface sple1 ofport_request=1
ovs-vsctl --may-exist add-port sp sple2 -- set interface sple2 ofport_request=2
ovs-vsctl --may-exist add-port sp sple3 -- set interface sple3 ofport_request=3
ovs-vsctl --may-exist add-port sp sple4 -- set interface sple4 ofport_request=4
ovs-vsctl --may-exist add-port sp sple5 -- set interface sple5 ofport_request=5
ovs-vsctl --may-exist add-port le1 le1sp -- set interface le1sp ofport_request=1
ovs-vsctl --may-exist add-port le2 le2sp -- set interface le2sp ofport_request=1
ovs-vsctl --may-exist add-port le3 le3sp -- set interface le3sp ofport_request=1
ovs-vsctl --may-exist add-port le4 le4sp -- set interface le4sp ofport_request=1
ovs-vsctl --may-exist add-port le5 le5sp -- set interface le5sp ofport_request=1
ovs-vsctl --may-exist add-port le1 le1h1 -- set interface le1h1 ofport_request=2
ovs-vsctl --may-exist add-port le2 le2h2 -- set interface le2h2 ofport_request=2
ovs-vsctl --may-exist add-port le3 le3h3 -- set interface le3h3 ofport_request=2
ovs-vsctl --may-exist add-port le4 le4h4 -- set interface le4h4 ofport_request=2
ovs-vsctl --may-exist add-port le5 le5h5 -- set interface le5h5 ofport_request=2
ip netns add h1
ip link set netns h1 dev h1le1
ip netns exec h1 ip link set dev lo up
ip netns exec h1 ip link set dev h1le1 up
ip netns add h2
ip link set netns h2 dev h2le2
ip netns exec h2 ip link set dev lo up
ip netns exec h2 ip link set dev h2le2 up
ip netns add h3
ip link set netns h3 dev h3le3
ip netns exec h3 ip link set dev lo up
ip netns exec h3 ip link set dev h3le3 up
ip netns add h4
ip link set netns h4 dev h4le4
ip netns exec h4 ip link set dev lo up
ip netns exec h4 ip link set dev h4le4 up
ip netns add h5
ip link set netns h5 dev h5le5
ip netns exec h5 ip link set dev lo up
ip netns exec h5 ip link set dev h5le5 up
ovs-vsctl set-controller sp tcp:127.0.0.1:6653
ovs-vsctl set-controller le1 tcp:127.0.0.1:6653
ovs-vsctl set-controller le2 tcp:127.0.0.1:6653
ovs-vsctl set-controller le3 tcp:127.0.0.1:6653
ovs-vsctl set-controller le4 tcp:127.0.0.1:6653
ovs-vsctl set-controller le5 tcp:127.0.0.1:6653

screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
screen -X -S OF-ROUTER kill
sleep 2

screen -S OF-ROUTER -t RVNF-qemu -d -m qemu-system-x86_64 \
-nographic -m 4096 \
-hda /opt/xrv-kvarlamo/ios_xr.vmdk \
-serial telnet::9011,server,nowait \
-serial telnet::9111,server,nowait \
-net nic,model=virtio,macaddr=00:01:00:ff:11:01,vlan=0 -net tap,ifname=tap-rvnf1-m,vlan=0,script=no,downscript=no \
-net nic,model=virtio,macaddr=00:01:00:ff:11:02,vlan=101 -net tap,ifname=tap-rvnf1-g0,vlan=101,script=no,downscript=no \
-net nic,model=virtio,macaddr=00:01:00:ff:11:03,vlan=102 -net tap,ifname=tap-rvnf1-g1,vlan=102,script=no,downscript=no
screen -X -S OF-ROUTER title RVNF-qemu
sleep 1
ovs-vsctl --may-exist add-port le1 tap-rvnf1-g0 -- set interface tap-rvnf1-g0 ofport_request=100
ip link set tap-rvnf1-g0 up
brctl addbr rvnf-infra
brctl addif rvnf-infra tap-rvnf1-g1
ip link set tap-rvnf1-g1 up
ip link set rvnf-infra up
ip addr add 10.0.202.1/24 dev rvnf-infra

screen -S OF-ROUTER -t CE2-qemu -X screen qemu-system-x86_64 \
-nographic -m 4096 \
-hda /opt/xrv-kvarlamo/ios_xr2.vmdk \
-serial telnet::9021,server,nowait \
-serial telnet::9121,server,nowait \
-net nic,model=virtio,macaddr=00:01:00:ff:21:01,vlan=0 -net tap,ifname=tap-ce2-m,vlan=0,script=no,downscript=no \
-net nic,model=virtio,macaddr=00:01:00:ff:21:02,vlan=101 -net tap,ifname=tap-ce2-g0,vlan=101,script=no,downscript=no
screen -X -S OF-ROUTER title CE2-qemu
sleep 1
ovs-vsctl --may-exist add-port le2 tap-ce2-g0 -- set interface tap-ce2-g0 ofport_request=100
ip link set tap-ce2-g0 up


screen -S OF-ROUTER -t CE3-qemu -X screen qemu-system-x86_64 \
-nographic -m 4096 \
-hda /opt/xrv-kvarlamo/ios_xr3.vmdk \
-serial telnet::9031,server,nowait \
-serial telnet::9131,server,nowait \
-net nic,model=virtio,macaddr=00:01:00:ff:31:01,vlan=0 -net tap,ifname=tap-ce3-m,vlan=0,script=no,downscript=no \
-net nic,model=virtio,macaddr=00:01:00:ff:31:02,vlan=101 -net tap,ifname=tap-ce3-g0,vlan=101,script=no,downscript=no
screen -X -S OF-ROUTER title CE3-qemu
sleep 1
ovs-vsctl --may-exist add-port le3 tap-ce3-g0 -- set interface tap-ce3-g0 ofport_request=100
ip link set tap-ce3-g0 up

screen -S OF-ROUTER -t CE4-qemu -X screen qemu-system-x86_64 \
-nographic -m 4096 \
-hda /opt/xrv-kvarlamo/ios_xr4.vmdk \
-serial telnet::9041,server,nowait \
-serial telnet::9141,server,nowait \
-net nic,model=virtio,macaddr=00:01:00:ff:41:01,vlan=0 -net tap,ifname=tap-ce4-m,vlan=0,script=no,downscript=no \
-net nic,model=virtio,macaddr=00:01:00:ff:41:02,vlan=101 -net tap,ifname=tap-ce4-g0,vlan=101,script=no,downscript=no
screen -X -S OF-ROUTER title CE4-qemu
sleep 1
ovs-vsctl --may-exist add-port le4 tap-ce4-g0 -- set interface tap-ce4-g0 ofport_request=100
ip link set tap-ce4-g0 up


screen -S OF-ROUTER -t RVNF1-telnet -X screen telnet 127.0.0.1 9011
screen -X -S OF-ROUTER title RVNF1-telnet
screen -S OF-ROUTER -t CE2-telnet -X screen telnet 127.0.0.1 9021
screen -X -S OF-ROUTER title CE2-telnet
screen -S OF-ROUTER -t CE3-telnet -X screen telnet 127.0.0.1 9031
screen -X -S OF-ROUTER title CE3-telnet
screen -S OF-ROUTER -t CE4-telnet -X screen telnet 127.0.0.1 9041
screen -X -S OF-ROUTER title CE4-telnet
echo "************"
echo "You can attach all-in-one screen anytime with command below:"
echo "screen -x OF-ROUTER"
echo "Press any key to attach now or Ctrl-C to return to shell"
read
screen -x OF-ROUTER
