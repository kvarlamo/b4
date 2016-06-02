OF-Router is a daemon which peers with traditional router over SSH, processes BGP updates and pushes corresponding flows to OpenFlow network managed by Brain4Net controller (Segment routing cluster).
This script requires Brain4Net OpenVswitch build which supports deeper MPLS stack.
This program is not tested and is not more than just a proof of concept for internal B4N researches.
**This is absolutely unuseful for anybody outside Brain4Net Inc.**
# of-router.py
main daemon script
# ctl-orc-deploy.sh
setup script - provisions and configures controller and orchestrator, builds Openvswitch topology (similar to mininet), runs virtual routers
