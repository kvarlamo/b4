#!/usr/bin/env python
import subprocess
import re
from pprint import pprint
import eventlet, json
eventlet.monkey_patch()
from ryu.services.protocols.bgp.bgpspeaker import BGPSpeaker


switches={}
nhops={'10.0.102.2':{'switch':'le2','port':100, 'vlan':None, 'cemac':'0001.00ff.2102', 'pemac':'0001.00ff.1102'},'10.0.103.2':{'switch':'le3','port':100,'vlan':None, 'cemac':'0001.00ff.3102', 'pemac':'0001.00ff.1102'},'10.0.104.2':{'switch':'le4','port':100,'vlan':None, 'cemac':'0001.00ff.3102', 'pemac':'0001.00ff.1102'}}

def bpchange(e):
    if not e['is_withdraw']:
        print "add %s via %s" % (e['prefix'],e['nexthop'])
    else:
        print "rem %s via %s" % (e['prefix'],e['nexthop'])

self = dict(
      as_number=1,
      router_id='192.0.2.1',
      bgp_server_port=179,
      refresh_stalepath_time=0,
      refresh_max_eor_time=0,
      best_path_change_handler=lambda m: bpchange(vars(m)),
      #best_path_change_handler=lambda m: pprint(vars(m)),
      peer_down_handler=lambda ip, asn: pprint('Peer down: %(ip)s from %(asn)s' % locals()),
      peer_up_handler=None,
      ssh_console=False,
      label_range=(100, 100000))

neighbor = dict(
      address='10.0.202.2',
      remote_as=1,
      enable_ipv4=True,
      enable_enhanced_refresh=False,
      next_hop=None,
      password=None,
      multi_exit_disc=None,
      site_of_origins=None,
      is_route_server_client=False,
      is_next_hop_self=True,
      local_address=None,
      local_port=None,
      connect_mode='both')



def discover_switches():
   groups=[]
   for ins in subprocess.check_output("ovs-vsctl -f json -d json show", shell=True).decode("utf-8").splitlines():
       m = re.search(r'\s+Bridge\s\"*(\w+)\"*', ins)
       if m:
           switches[m.group(1)]={'ports':{},'sis':[]}
   for isw in switches:
       # discover ports
       for iline in subprocess.check_output("ovs-ofctl -O OpenFlow13 dump-ports-desc %s" % isw, shell=True).decode("utf-8").splitlines():
           m = re.search(r'\s(\d+)\(([\w\-]+)\)\: addr\:([0-9a-f\:]+)', iline)
           if m:
               switches[isw]['ports'][int(m.group(1))]={'name':m.group(2), 'mac':m.group(3)}
       # discover groups
       switches[isw]['groups']=[]
       for iline in subprocess.check_output("ovs-ofctl -O OpenFlow13 dump-groups %s" % isw, shell=True).decode("utf-8").splitlines():
           m = re.search(r'group_id\=(\d+)\,', iline)
           if m:
               switches[isw]['groups'].append(int(m.group(1)))
               groups.append(int(m.group(1)))
       for iline in subprocess.check_output("ovs-ofctl -O OpenFlow13 dump-flows %s" % isw, shell=True).decode("utf-8").splitlines():
           m = re.search(r'priority\=20\,mpls\,mpls_label\=(\d+)\,mpls_tc\=0 actions\=pop_mpls\:0x8847\,write_actions\(set_queue\:\d\,push_vlan\:0x8100\,set_field\:(\d+)\-\>vlan_vid\,output\:(\d+)\)\,goto_table\:1', iline)
           if m:
               print m.group(1),m.group(2),m.group(3)
               vlan=int(m.group(2))-4096
               switches[isw]['sis'].append({'slabel':int(m.group(1)),'vlan': vlan, 'port':int(m.group(3))})
           m = re.search(r'priority\=20\,mpls\,mpls_label\=(\d+) actions\=pop_mpls\:0x8847\,write_actions\(set_queue\:\d+,output\:(\d+)\)\,goto_table\:1', iline)
           if m:
               print m.group(1),m.group(2)
               switches[isw]['sis'].append({'slabel':int(m.group(1)),'port':int(m.group(2))})
   #find transport label
   for isw in switches:
       switches[isw]['trlabel']=list(set(groups)-set(switches[isw]['groups']))[0]
   return switches

def get_mpls(switch , port, vlan):
    trlabel=None
    slabel=None
    trlabel=switches[switch]['trlabel']
    for i in range(len(switches[switch]['sis'])):
        if vlan:
            if vlan == switches[switch]['sis'][i]['vlan']:
                slabel = switches[switch]['sis'][i]['slabel']
        else:
            slabel = switches[switch]['sis'][i]['slabel']
    if trlabel and slabel:
        return([trlabel,slabel])

def resolve_nhops():
    for i in nhops:
        nhops[i]['labels']=get_mpls(nhops[i]['switch'],nhops[i]['port'],nhops[i]['vlan'])
        

def main():
    sw=discover_switches()
    print sw
    resolve_nhops()
    print nhops
    speaker = BGPSpeaker(**self)
    speaker.neighbor_add(**neighbor)
    while True:
        eventlet.sleep(10)

if __name__ == "__main__":
   try:
      main()
   except KeyboardInterrupt:
      sys.exit()

