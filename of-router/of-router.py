#!/usr/bin/env python
import subprocess
import re

def discover_switches():
   switches=[]
   for ins in subprocess.check_output("ovs-vsctl -f json -d json show", shell=True).decode("utf-8").splitlines():
       m = re.search(r'\s+Bridge\s\"*(\w+)\"*', ins)
       if m:
           switches.append(m.group(1))
   return switches

def main():
    a=discover_switches()
    print a

if __name__ == "__main__":
   try:
      main()
   except KeyboardInterrupt:
      sys.exit()

