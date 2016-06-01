#!/usr/bin/env python
from pprint import pprint

import eventlet, json
eventlet.monkey_patch()

from ryu.services.protocols.bgp.bgpspeaker import BGPSpeaker
from ryu.services.protocols.bgp.bgpspeaker import RF_VPN_V4

def main():
  self = dict(
      as_number=65000,
      router_id='192.0.2.1',
      bgp_server_port=179,
      refresh_stalepath_time=0,
      refresh_max_eor_time=0,
      best_path_change_handler=lambda m: pprint(vars(m)),
      peer_down_handler=lambda ip, asn: pprint('Peer down: %(ip)s from %(asn)s' % locals()),
      peer_up_handler=None,
      ssh_console=False,
      label_range=(100, 100000))

  neighbor = dict(
      address='192.0.2.2',
      remote_as=65000,
      enable_ipv4=True,
      enable_vpnv4=True,
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

  vrf_red = dict(
      route_dist='65000:100',
      import_rts=['65000:100'],
      export_rts=['65000:100'],
      site_of_origins=None,
      route_family=RF_VPN_V4,
      multi_exit_disc=None)

  vrf_blue = dict(
      route_dist='65000:200',
      import_rts=['65000:200'],
      export_rts=['65000:200'],
      site_of_origins=None,
      route_family=RF_VPN_V4,
      multi_exit_disc=None)

  prefix_red = dict(
      prefix='99.99.99.99/32',
      next_hop='192.0.2.1',
      route_dist='65000:100')

  prefix_blue = dict(
      prefix='199.199.199.199/32',
      next_hop='192.0.2.1',
      route_dist='65000:200')

  speaker = BGPSpeaker(**self)
  speaker.neighbor_add(**neighbor)

  speaker.vrf_add(**vrf_red)
  speaker.vrf_add(**vrf_blue)

  speaker.prefix_add(**prefix_red)
  speaker.prefix_add(**prefix_blue)

  while True:
  #  pprint(speaker.neighbor_state_get())
    pprint(speaker.rib_get(family='vpnv4'))
    eventlet.sleep(10)

if __name__ == '__main__':
  main()

