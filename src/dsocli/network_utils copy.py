import sys
import os
import ipaddress
import json
import yaml
import re
from logger import Logger
from settings import *
from exceptions import DSOException

UNNAMED_SUBNET = 'N/A'

def ipv4_to_binary(ip, sep="."):
    return  sep.join(map(str,["{0:08b}".format(int(x)) for x in ip.split(".")]))


class IPv4AddressX(ipaddress.IPv4Address):
    def to_binary(self, sep="."):
        """Represent IPv4 as 4 blocks of 8 bits."""
        return sep.join(f"{i:08b}" for i in self.packed)

    @classmethod
    def from_binary_repr(cls, binary_repr: str):
        """Construct IPv4 from binary representation."""
        # Remove anything that's not a 0 or 1
        i = int(re.sub(r"[^01]", "", binary_repr), 2)
        return cls(i)


def execute_subnet_plan(subnet_plan, summary=True):

    def add_partition_subnets(partitions, partition_ix, supernet, result: dict):

        def is_subnet_selected(supernet, subnet, selects):

            if not subnet.subnet_of(supernet):
                return False

            if not isinstance(selects, list): selects = [str(selects)]

            subnetIP = IPv4AddressX(subnet.network_address).to_binary(sep='')

            result = True
            for select in selects:
                ### inverse select is used?
                if select.startswith('!'):
                    select = select[1:]
                    inverse = True
                else:
                    inverse = False

                ### binary format
                if select.startswith('0b'):
                    select = select[2:]
                    m = re.match(r'^([x]*)([01]*)$', select)
                    if not m:
                        raise DSOException(f"Invalid value for 'select': {select}")
                    offset = len(m.group(1))
                    select = m.group(2)
                else:
                    raise NotImplementedError

                # print(f"1={supernetIP[:supernet.prefixlen]},{supernetIP[supernet.prefixlen:]}")
                # print(f"2={subnetIP[:supernet.prefixlen]},{subnetIP[supernet.prefixlen:]}")
                # print(f"3={subnetIP[supernet.prefixlen + offset:]}")
                # print(f"offset={offset}, select={select}, S={subnetIP[supernet.prefixlen + offset:]}")
                starting = subnetIP[supernet.prefixlen + offset:].startswith(select)
                selecetd = starting if not inverse else not(starting)

                result = result and selecetd

            return result

        ### if last partition, add host count
        if partition_ix == len(partitions):
            hosts = list(supernet.hosts())
            result['Hosts'] = {
                'Count': len(hosts),
                'IP': f"{hosts[0]}/32-{hosts[-1]}/32"
            }
            return

        partition = partitions[partition_ix]
        if partition['bits'] > 0:
            subnets = list(supernet.subnets(partition['bits']))
            result[partition['name']] = {
                'Count': 0, ### to be incremented while adding subnets
                'Ranges': []
            }
            range_first_subnet = None
            range_last_subnet = None
            for i, subnet in enumerate(subnets):
                Logger.debug(f"{partition['name']} {i}: {subnet}")
                if 'select' in partition:
                    if not is_subnet_selected(supernet, subnet, partition['select']): 
                        ### add the last subnet in the range if in summary mode
                        if summary and not range_last_subnet is None:
                            result[partition['name']]['Ranges'][-1]['Subnets'].append({
                                'CIDR' : range_last_subnet.with_prefixlen,
                                'Name' : partition['labels'].get(str(i), UNNAMED_SUBNET),
                            })
                            add_partition_subnets(partitions, partition_ix+1, range_last_subnet, result[partition['name']]['Ranges'][-1]['Subnets'][-1])

                        range_first_subnet = None
                        range_last_subnet = None
                        Logger.debug(f"{partition['name']} {i} excluded: {subnet}")
                        continue

                ### if start of a range, append a new Range
                if range_first_subnet is None:
                    range_first_subnet = subnet
                    result[partition['name']]['Ranges'].append({
                        'CIDR': range_first_subnet.with_prefixlen,
                        'Count': 0, ### to be incremented while adding subnets
                        'Subnets': []
                    })
                    if summary:
                        result[partition['name']]['Ranges'][-1]['Subnets'].append({
                            'CIDR': range_first_subnet.with_prefixlen,
                            'Name': partition['labels'].get(str(i), UNNAMED_SUBNET),
                        })
                        add_partition_subnets(partitions, partition_ix+1, range_first_subnet, result[partition['name']]['Ranges'][-1]['Subnets'][-1])
                else:
                    range_last_subnet = subnet
                    cidr = f"{range_first_subnet.with_prefixlen}-{range_last_subnet.with_prefixlen}"
                    ### updare Range CIDR
                    result[partition['name']]['Ranges'][-1]['CIDR'] = cidr
                    ### if in summary mode, always add the last subnet in the list
                    if summary and range_last_subnet == subnets[-1]:
                        result[partition['name']]['Ranges'][-1]['Subnets'].append({
                            'CIDR' : range_last_subnet.with_prefixlen,
                            'Name': partition['labels'].get(str(i), UNNAMED_SUBNET),
                        })
                        add_partition_subnets(partitions, partition_ix+1, range_last_subnet, result[partition['name']]['Ranges'][-1]['Subnets'][-1])

                ### always add the subnet if not in summary mode
                if not summary:
                    result[partition['name']]['Ranges'][-1]['Subnets'].append({
                        'CIDR' : subnet.with_prefixlen,
                        'Name': partition['labels'].get(str(i), UNNAMED_SUBNET),
                    })
                    add_partition_subnets(partitions, partition_ix+1, subnet, result[partition['name']]['Ranges'][-1]['Subnets'][-1])

                result[partition['name']]['Count'] = result[partition['name']]['Count'] + 1
                result[partition['name']]['Ranges'][-1]['Count'] = result[partition['name']]['Ranges'][-1]['Count'] + 1

            ### compact Range list if has only one element
            if len(result[partition['name']]['Ranges']) == 1:
                result[partition['name']].update(result[partition['name']]['Ranges'][0])
                result[partition['name']].pop('Ranges')

        ### skip partitions with 0 bits long, and move to the next partition
        else:
            add_partition_subnets(partitions, partition_ix+1, supernet, result)

    result = {
        'SubnetPlan': {
            'Name': subnet_plan['name'],
            'Description': subnet_plan['description'],
            'CIDR': subnet_plan['cidr']
        }
    }

    add_partition_subnets(subnet_plan['partitions'], 0, ipaddress.ip_network(subnet_plan['cidr']), result['SubnetPlan'])
    return result


subnet_plan_group = yaml.load(open('subnet-plan-group.yaml', 'r', encoding='utf-8'), yaml.SafeLoader)
for plan in subnet_plan_group['plans']:
    Logger.info(f"Executing subnet plan '{plan['name']}'...")
    planned = execute_subnet_plan(plan, summary=True)
    with open(f"{plan['name']}.yaml", 'w') as f:
        yaml.dump(planned, f, sort_keys=False, indent=2)
