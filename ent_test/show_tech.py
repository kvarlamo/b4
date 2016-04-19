#!/usr/bin/env python

from datetime import datetime, date, time
import subprocess
import re
a=datetime.now().strftime("%Y%m%d%H%M")
sw='br0'
swhosts=['sw1','sw2','sw3','sw4']
filename="%s_diag.log" % a

def main():
    f = open(filename, 'w')
    f.write("######## date: %s ###########\r\n" % a)
    for sh in swhosts:
        cmd = []
        cmd.append("ovs-vsctl show")
        cmd.append("ovs-ofctl dump-ports-desc -O OpenFlow13 %s" % sw)
        cmd.append("ovs-ofctl dump-ports -O OpenFlow13 %s" % sw)
        cmd.append("ovs-ofctl dump-flows -O OpenFlow13 %s" % sw )
        cmd.append("ovs-ofctl dump-groups -O OpenFlow13 %s" % sw )
        for c in cmd:
            f.write("######### %s %s ######\r\n" % (sh,c))
            for p in subprocess.check_output("ssh %s %s" % (sh,c), shell=True).decode("utf-8").splitlines():
                f.write( p + "\r\n")
    f.close()
    print ("%s written" % filename)

if __name__ == "__main__":
   try:
      main()
   except KeyboardInterrupt:
      sys.exit()
