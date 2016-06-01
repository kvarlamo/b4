#!/usr/bin/env python
import subprocess
import re

switches={}
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

def main():
    sw=discover_switches()
    print sw
    print get_mpls('le1',100,102)

if __name__ == "__main__":
   try:
      main()
   except KeyboardInterrupt:
      sys.exit()

