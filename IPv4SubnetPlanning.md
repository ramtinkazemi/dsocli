This document describes the target subnet plan model for ’s infrastructure on AWS. It divides the IP range 10.0.0.0/8 into non-overlapping subnets based on workload sizes, which are:

Large Networks

256 hosts per subnet, public/private split, 2 subnet per availability zone

Up to 256 workloads per stage are supported

Medium Networks

128 hosts per subnet, public/private split, 2 subnet per availability zone

Up to 256 workloads per stage are supported

Small Networks

64 hosts per subnet, public/private split, 2 subnet per availability zone

Up to 256 workloads per stage are supported

Tiny Networks

32 per subnet, public/private split, 2 subnet per availability zone

Up to 512 workloads per stage are supported

CIDR Allocations

The following table shows the current allocation of CIDRs to applications/workloads. Please keep these tables updated based on new allocations.

Large Networks (H256A2S2):

Workload/Application

VPC

AWS Account

1

2

3

4

Medium Networks (H128A2S2):

Workload/Application

VPC

AWS Account

1

2

3

4

Small Networks (H64A2S2)

Workload/Application

VPC

AWS Account

1

2

3

4

Tiny Networks (H32A2S2):

Workload/Application

VPC

AWS Account

1

core/egress

10.28.0.0/23

network

2

core/vpn

10.28.2.0/23

network

3

stg/data

10.124.0.0/23

network

4

Allocation Guide

Subnet Plan Group:

The plan group is divided into for plans to map to the aforementioned plans, which are H256A2S2, H128A2S2, H64A2S2, and H32A2S2, where H, A and S stand for the number of Hosts, Accessibility, and SubnetGroup respectively. Within each plan, subnets are split into non-overlapping CIDRs based on stages (core, prd, stg, uat, …), workloads, private/public accessibility, and availability zones. Two private and two public subnets are available in each availability zone under SubnetGroups CIDRs, whose CIDRS will be used for the subnets within a VPC. The Workload CIDR itself is used for the VPC CIDR.

Each subnet plan supports 8 stages including core, prd, uat and stg. The following table shows a summary of the entire CIDR blocks used for each stage. 

Stage

CIDR

H256A2S2

H128A2S2

H64A2S2

H32A2S2

1

core

10.0.0.0/11-10.31.0.0/11

10.0.0.0/20-10.15.240.0/20

10.16.0.0/21-10.23.248.0/21

10.24.0.0/22-10.27.252.0/22

10.28.0.0/23-10.31.254.0/23

2

prd

10.32.0.0/11-10.63.0.0/11

10.32.0.0/20-10.47.240.0/20

10.48.0.0/21-10.55.248.0/21

10.56.0.0/22-10.59.252.0/22

10.60.0.0/23-10.63.254.0/23

3

uat

10.64.0.0/11-10.95.0.0/11

10.64.0.0/20-10.79.240.0/20

10.80.0.0/21-10.87.248.0/21

10.88.0.0/22-10.91.252.0/22

10.92.0.0/23-10.95.254.0/23

4

stg

10.96.0.0/11-10.127.0.0/11

10.96.0.0/20-10.111.240.0/20

10.112.0.0/21-10.119.248.0/21

10.120.0.0/22-10.123.252.0/22

10.124.0.0/23-10.127.254.0/23

5

10.128.0.0/11-10.159.0.0/11

10.128.0.0/20-10.143.240.0/20

10.144.0.0/21-10.151.248.0/21

10.152.0.0/22-10.155.252.0/22

10.156.0.0/23-10.159.254.0/23

6

10.160.0.0/11-10.191.0.0/11

10.160.0.0/20-10.175.240.0/20

10.176.0.0/21-10.183.248.0/21

10.184.0.0/22-10.187.252.0/22

10.188.0.0/23-10.191.254.0/23

7

10.192.0.0/11-10.223.0.0/11

10.192.0.0/20-10.207.240.0/20

10.208.0.0/21-10.215.248.0/21

10.216.0.0/22-10.219.252.0/22

10.220.0.0/23-10.223.254.0/23

8

10.224.0.0/11-10.255.0.0/11

10.224.0.0/20-10.239.240.0/20

10.240.0.0/21-10.247.248.0/21

10.248.0.0/22-10.251.252.0/22

10.252.0.0/23-10.255.254.0/23

The subnet plan group that has been executed by the DSO tool to generate the above table is as follows.

name: Default
plans:

- name: H256A2S2
  description: 256 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads per stage)
  cidr: 10.0.0.0/8
  segments:
  - name: Stage
    bits: 3
    labels:
      '0': core
      '1': prd
      '2': uat
      '3': stg
      '7': stage7
  - name: Worklaod
    bits: 9
    labels:
      '0': large-app1
      '255': large-app256
    select: 'msd(0b0)'
  - name: Accessibility
    plural: Accessibilities
    bits: 1
    labels:
      '0': private
      '1': public
  - name: AvailabilityZone
    bits: 2
    labels:
      '0': a
      '1': b
      '2': c
      '3': d
  - name: SubnetGroup
    bits: 1
    labels:
      '0': '1'
      '1': '2'

- name: H128A2S2
  description: 128 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads per stage)
  cidr: 10.0.0.0/8
  segments:
  - name: Stage
    bits: 3
    labels:
      '0': core
      '1': prd
      '2': uat
      '3': stg
      '7': stage7

  - name: Worklaod
    bits: 10
    labels:
      '0': medium-app1
      '255': large-app256
    select: 'msd(0b1) | msd(0bx0)'
  - name: Accessibility
    plural: Accessibilities
    bits: 1
    labels:
      '0': private
      '1': public
  - name: AvailabilityZone
    bits: 2
    labels:
      '0': a
      '1': b
      '2': c
      '3': d
  - name: SubnetGroup
    bits: 1
    labels:
      '0': '1'
      '1': '2'

- name: H64A2S2
  description: 64 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads per stage)
  cidr: 10.0.0.0/8
  segments:
  - name: Stage
    bits: 3
    labels:
      '0': core
      '1': prd
      '2': uat
      '3': stg
      '7': stage7
  - name: Worklaod
    bits: 11
    labels:
      '0': small-app1
      '255': small-app256
    select: 'msd(0b1) | msd(0bx1) | msd(0bxx0)'
  - name: Accessibility
    plural: Accessibilities
    bits: 1
    labels:
      '0': private
      '1': public
  - name: AvailabilityZone
    bits: 2
    labels:
      '0': a
      '1': b
      '2': c
      '3': d
  - name: SubnetGroup
    bits: 1
    labels:
      '0': '1'
      '1': '2'

- name: H32A2S2
  description: 32 hosts per subnet, 2 subnet per AZ, public/private split (512 workloads per stage)
  cidr: 10.0.0.0/8
  segments:
  - name: Stage
    bits: 3
    labels:
      '0': core
      '1': prd
      '2': uat
      '3': stg
      '7': stage7
  - name: Worklaod
    bits: 12
    labels:
      '0': tiny-app1
      '511': tiny-app256
    select: 'msd(0b1) | msd(0bx1) | msd(0bxx1)'
  - name: Accessibility
    plural: Accessibilities
    bits: 1
    labels:
      '0': private
      '1': public
  - name: AvailabilityZone
    bits: 2
    labels:
      '0': a
      '1': b
      '2': c
      '3': d
  - name: SubnetGroup
    bits: 1
    labels:
      '0': '1'
      '1': '2'

A summary of each plan execution can be found in the following. Please note only the first and the last subnets in each segment of the CIDRs are shown here.

Large Networks

SubnetPlan:
  Name: H256A2S2
  Description: 256 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads
    per stage)
  CIDR: 10.0.0.0/8
  Stages:
    Count: 8
    CIDR: 10.0.0.0/11-10.224.0.0/11
    Subnets:
    - CIDR: 10.0.0.0/11
      Name: core
      Worklaods:
        Count: 256
        CIDR: 10.0.0.0/20-10.15.240.0/20
        Subnets:
        - CIDR: 10.0.0.0/20
          Name: large-app1
          Accessibilities:
            Count: 2
            CIDR: 10.0.0.0/21-10.0.8.0/21
            Subnets:
            - CIDR: 10.0.0.0/21
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.0.0.0/23-10.0.6.0/23
                Subnets:
                - CIDR: 10.0.0.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.0.0.0/24-10.0.1.0/24
                    Subnets:
                    - CIDR: 10.0.0.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.0.0.1/32-10.0.0.254/32
                    - CIDR: 10.0.1.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.0.1.1/32-10.0.1.254/32
                - CIDR: 10.0.6.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.0.6.0/24-10.0.7.0/24
                    Subnets:
                    - CIDR: 10.0.6.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.0.6.1/32-10.0.6.254/32
                    - CIDR: 10.0.7.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.0.7.1/32-10.0.7.254/32
            - CIDR: 10.0.8.0/21
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.0.8.0/23-10.0.14.0/23
                Subnets:
                - CIDR: 10.0.8.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.0.8.0/24-10.0.9.0/24
                    Subnets:
                    - CIDR: 10.0.8.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.0.8.1/32-10.0.8.254/32
                    - CIDR: 10.0.9.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.0.9.1/32-10.0.9.254/32
                - CIDR: 10.0.14.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.0.14.0/24-10.0.15.0/24
                    Subnets:
                    - CIDR: 10.0.14.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.0.14.1/32-10.0.14.254/32
                    - CIDR: 10.0.15.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.0.15.1/32-10.0.15.254/32
        - CIDR: 10.15.240.0/20
          Name: large-app256
          Accessibilities:
            Count: 2
            CIDR: 10.15.240.0/21-10.15.248.0/21
            Subnets:
            - CIDR: 10.15.240.0/21
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.15.240.0/23-10.15.246.0/23
                Subnets:
                - CIDR: 10.15.240.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.15.240.0/24-10.15.241.0/24
                    Subnets:
                    - CIDR: 10.15.240.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.15.240.1/32-10.15.240.254/32
                    - CIDR: 10.15.241.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.15.241.1/32-10.15.241.254/32
                - CIDR: 10.15.246.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.15.246.0/24-10.15.247.0/24
                    Subnets:
                    - CIDR: 10.15.246.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.15.246.1/32-10.15.246.254/32
                    - CIDR: 10.15.247.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.15.247.1/32-10.15.247.254/32
            - CIDR: 10.15.248.0/21
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.15.248.0/23-10.15.254.0/23
                Subnets:
                - CIDR: 10.15.248.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.15.248.0/24-10.15.249.0/24
                    Subnets:
                    - CIDR: 10.15.248.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.15.248.1/32-10.15.248.254/32
                    - CIDR: 10.15.249.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.15.249.1/32-10.15.249.254/32
                - CIDR: 10.15.254.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.15.254.0/24-10.15.255.0/24
                    Subnets:
                    - CIDR: 10.15.254.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.15.254.1/32-10.15.254.254/32
                    - CIDR: 10.15.255.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.15.255.1/32-10.15.255.254/32
    - CIDR: 10.224.0.0/11
      Name: stage7
      Worklaods:
        Count: 256
        CIDR: 10.224.0.0/20-10.239.240.0/20
        Subnets:
        - CIDR: 10.224.0.0/20
          Name: large-app1
          Accessibilities:
            Count: 2
            CIDR: 10.224.0.0/21-10.224.8.0/21
            Subnets:
            - CIDR: 10.224.0.0/21
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.224.0.0/23-10.224.6.0/23
                Subnets:
                - CIDR: 10.224.0.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.224.0.0/24-10.224.1.0/24
                    Subnets:
                    - CIDR: 10.224.0.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.224.0.1/32-10.224.0.254/32
                    - CIDR: 10.224.1.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.224.1.1/32-10.224.1.254/32
                - CIDR: 10.224.6.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.224.6.0/24-10.224.7.0/24
                    Subnets:
                    - CIDR: 10.224.6.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.224.6.1/32-10.224.6.254/32
                    - CIDR: 10.224.7.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.224.7.1/32-10.224.7.254/32
            - CIDR: 10.224.8.0/21
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.224.8.0/23-10.224.14.0/23
                Subnets:
                - CIDR: 10.224.8.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.224.8.0/24-10.224.9.0/24
                    Subnets:
                    - CIDR: 10.224.8.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.224.8.1/32-10.224.8.254/32
                    - CIDR: 10.224.9.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.224.9.1/32-10.224.9.254/32
                - CIDR: 10.224.14.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.224.14.0/24-10.224.15.0/24
                    Subnets:
                    - CIDR: 10.224.14.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.224.14.1/32-10.224.14.254/32
                    - CIDR: 10.224.15.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.224.15.1/32-10.224.15.254/32
        - CIDR: 10.239.240.0/20
          Name: large-app256
          Accessibilities:
            Count: 2
            CIDR: 10.239.240.0/21-10.239.248.0/21
            Subnets:
            - CIDR: 10.239.240.0/21
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.239.240.0/23-10.239.246.0/23
                Subnets:
                - CIDR: 10.239.240.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.239.240.0/24-10.239.241.0/24
                    Subnets:
                    - CIDR: 10.239.240.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.239.240.1/32-10.239.240.254/32
                    - CIDR: 10.239.241.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.239.241.1/32-10.239.241.254/32
                - CIDR: 10.239.246.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.239.246.0/24-10.239.247.0/24
                    Subnets:
                    - CIDR: 10.239.246.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.239.246.1/32-10.239.246.254/32
                    - CIDR: 10.239.247.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.239.247.1/32-10.239.247.254/32
            - CIDR: 10.239.248.0/21
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.239.248.0/23-10.239.254.0/23
                Subnets:
                - CIDR: 10.239.248.0/23
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.239.248.0/24-10.239.249.0/24
                    Subnets:
                    - CIDR: 10.239.248.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.239.248.1/32-10.239.248.254/32
                    - CIDR: 10.239.249.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.239.249.1/32-10.239.249.254/32
                - CIDR: 10.239.254.0/23
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.239.254.0/24-10.239.255.0/24
                    Subnets:
                    - CIDR: 10.239.254.0/24
                      Name: '1'
                      Hosts:
                        Count: 254
                        IP: 10.239.254.1/32-10.239.254.254/32
                    - CIDR: 10.239.255.0/24
                      Name: '2'
                      Hosts:
                        Count: 254
                        IP: 10.239.255.1/32-10.239.255.254/32


Medium Networks

SubnetPlan:
  Name: H128A2S2
  Description: 128 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads
    per stage)
  CIDR: 10.0.0.0/8
  Stages:
    Count: 8
    CIDR: 10.0.0.0/11-10.224.0.0/11
    Subnets:
    - CIDR: 10.0.0.0/11
      Name: core
      Worklaods:
        Count: 256
        CIDR: 10.16.0.0/21-10.23.248.0/21
        Subnets:
        - CIDR: 10.16.0.0/21
          Name: medium-app1
          Accessibilities:
            Count: 2
            CIDR: 10.16.0.0/22-10.16.4.0/22
            Subnets:
            - CIDR: 10.16.0.0/22
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.16.0.0/24-10.16.3.0/24
                Subnets:
                - CIDR: 10.16.0.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.16.0.0/25-10.16.0.128/25
                    Subnets:
                    - CIDR: 10.16.0.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.16.0.1/32-10.16.0.126/32
                    - CIDR: 10.16.0.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.16.0.129/32-10.16.0.254/32
                - CIDR: 10.16.3.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.16.3.0/25-10.16.3.128/25
                    Subnets:
                    - CIDR: 10.16.3.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.16.3.1/32-10.16.3.126/32
                    - CIDR: 10.16.3.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.16.3.129/32-10.16.3.254/32
            - CIDR: 10.16.4.0/22
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.16.4.0/24-10.16.7.0/24
                Subnets:
                - CIDR: 10.16.4.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.16.4.0/25-10.16.4.128/25
                    Subnets:
                    - CIDR: 10.16.4.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.16.4.1/32-10.16.4.126/32
                    - CIDR: 10.16.4.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.16.4.129/32-10.16.4.254/32
                - CIDR: 10.16.7.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.16.7.0/25-10.16.7.128/25
                    Subnets:
                    - CIDR: 10.16.7.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.16.7.1/32-10.16.7.126/32
                    - CIDR: 10.16.7.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.16.7.129/32-10.16.7.254/32
        - CIDR: 10.23.248.0/21
          Name: large-app256
          Accessibilities:
            Count: 2
            CIDR: 10.23.248.0/22-10.23.252.0/22
            Subnets:
            - CIDR: 10.23.248.0/22
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.23.248.0/24-10.23.251.0/24
                Subnets:
                - CIDR: 10.23.248.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.23.248.0/25-10.23.248.128/25
                    Subnets:
                    - CIDR: 10.23.248.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.23.248.1/32-10.23.248.126/32
                    - CIDR: 10.23.248.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.23.248.129/32-10.23.248.254/32
                - CIDR: 10.23.251.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.23.251.0/25-10.23.251.128/25
                    Subnets:
                    - CIDR: 10.23.251.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.23.251.1/32-10.23.251.126/32
                    - CIDR: 10.23.251.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.23.251.129/32-10.23.251.254/32
            - CIDR: 10.23.252.0/22
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.23.252.0/24-10.23.255.0/24
                Subnets:
                - CIDR: 10.23.252.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.23.252.0/25-10.23.252.128/25
                    Subnets:
                    - CIDR: 10.23.252.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.23.252.1/32-10.23.252.126/32
                    - CIDR: 10.23.252.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.23.252.129/32-10.23.252.254/32
                - CIDR: 10.23.255.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.23.255.0/25-10.23.255.128/25
                    Subnets:
                    - CIDR: 10.23.255.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.23.255.1/32-10.23.255.126/32
                    - CIDR: 10.23.255.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.23.255.129/32-10.23.255.254/32
    - CIDR: 10.224.0.0/11
      Name: stage7
      Worklaods:
        Count: 256
        CIDR: 10.240.0.0/21-10.247.248.0/21
        Subnets:
        - CIDR: 10.240.0.0/21
          Name: medium-app1
          Accessibilities:
            Count: 2
            CIDR: 10.240.0.0/22-10.240.4.0/22
            Subnets:
            - CIDR: 10.240.0.0/22
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.240.0.0/24-10.240.3.0/24
                Subnets:
                - CIDR: 10.240.0.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.240.0.0/25-10.240.0.128/25
                    Subnets:
                    - CIDR: 10.240.0.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.240.0.1/32-10.240.0.126/32
                    - CIDR: 10.240.0.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.240.0.129/32-10.240.0.254/32
                - CIDR: 10.240.3.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.240.3.0/25-10.240.3.128/25
                    Subnets:
                    - CIDR: 10.240.3.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.240.3.1/32-10.240.3.126/32
                    - CIDR: 10.240.3.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.240.3.129/32-10.240.3.254/32
            - CIDR: 10.240.4.0/22
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.240.4.0/24-10.240.7.0/24
                Subnets:
                - CIDR: 10.240.4.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.240.4.0/25-10.240.4.128/25
                    Subnets:
                    - CIDR: 10.240.4.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.240.4.1/32-10.240.4.126/32
                    - CIDR: 10.240.4.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.240.4.129/32-10.240.4.254/32
                - CIDR: 10.240.7.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.240.7.0/25-10.240.7.128/25
                    Subnets:
                    - CIDR: 10.240.7.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.240.7.1/32-10.240.7.126/32
                    - CIDR: 10.240.7.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.240.7.129/32-10.240.7.254/32
        - CIDR: 10.247.248.0/21
          Name: large-app256
          Accessibilities:
            Count: 2
            CIDR: 10.247.248.0/22-10.247.252.0/22
            Subnets:
            - CIDR: 10.247.248.0/22
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.247.248.0/24-10.247.251.0/24
                Subnets:
                - CIDR: 10.247.248.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.247.248.0/25-10.247.248.128/25
                    Subnets:
                    - CIDR: 10.247.248.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.247.248.1/32-10.247.248.126/32
                    - CIDR: 10.247.248.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.247.248.129/32-10.247.248.254/32
                - CIDR: 10.247.251.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.247.251.0/25-10.247.251.128/25
                    Subnets:
                    - CIDR: 10.247.251.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.247.251.1/32-10.247.251.126/32
                    - CIDR: 10.247.251.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.247.251.129/32-10.247.251.254/32
            - CIDR: 10.247.252.0/22
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.247.252.0/24-10.247.255.0/24
                Subnets:
                - CIDR: 10.247.252.0/24
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.247.252.0/25-10.247.252.128/25
                    Subnets:
                    - CIDR: 10.247.252.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.247.252.1/32-10.247.252.126/32
                    - CIDR: 10.247.252.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.247.252.129/32-10.247.252.254/32
                - CIDR: 10.247.255.0/24
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.247.255.0/25-10.247.255.128/25
                    Subnets:
                    - CIDR: 10.247.255.0/25
                      Name: '1'
                      Hosts:
                        Count: 126
                        IP: 10.247.255.1/32-10.247.255.126/32
                    - CIDR: 10.247.255.128/25
                      Name: '2'
                      Hosts:
                        Count: 126
                        IP: 10.247.255.129/32-10.247.255.254/32


Small Network

SubnetPlan:
  Name: H64A2S2
  Description: 64 hosts per subnet, 2 subnet per AZ, public/private split (256 workloads
    per stage)
  CIDR: 10.0.0.0/8
  Stages:
    Count: 8
    CIDR: 10.0.0.0/11-10.224.0.0/11
    Subnets:
    - CIDR: 10.0.0.0/11
      Name: core
      Worklaods:
        Count: 256
        CIDR: 10.24.0.0/22-10.27.252.0/22
        Subnets:
        - CIDR: 10.24.0.0/22
          Name: small-app1
          Accessibilities:
            Count: 2
            CIDR: 10.24.0.0/23-10.24.2.0/23
            Subnets:
            - CIDR: 10.24.0.0/23
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.24.0.0/25-10.24.1.128/25
                Subnets:
                - CIDR: 10.24.0.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.24.0.0/26-10.24.0.64/26
                    Subnets:
                    - CIDR: 10.24.0.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.24.0.1/32-10.24.0.62/32
                    - CIDR: 10.24.0.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.24.0.65/32-10.24.0.126/32
                - CIDR: 10.24.1.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.24.1.128/26-10.24.1.192/26
                    Subnets:
                    - CIDR: 10.24.1.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.24.1.129/32-10.24.1.190/32
                    - CIDR: 10.24.1.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.24.1.193/32-10.24.1.254/32
            - CIDR: 10.24.2.0/23
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.24.2.0/25-10.24.3.128/25
                Subnets:
                - CIDR: 10.24.2.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.24.2.0/26-10.24.2.64/26
                    Subnets:
                    - CIDR: 10.24.2.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.24.2.1/32-10.24.2.62/32
                    - CIDR: 10.24.2.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.24.2.65/32-10.24.2.126/32
                - CIDR: 10.24.3.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.24.3.128/26-10.24.3.192/26
                    Subnets:
                    - CIDR: 10.24.3.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.24.3.129/32-10.24.3.190/32
                    - CIDR: 10.24.3.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.24.3.193/32-10.24.3.254/32
        - CIDR: 10.27.252.0/22
          Name: small-app256
          Accessibilities:
            Count: 2
            CIDR: 10.27.252.0/23-10.27.254.0/23
            Subnets:
            - CIDR: 10.27.252.0/23
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.27.252.0/25-10.27.253.128/25
                Subnets:
                - CIDR: 10.27.252.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.27.252.0/26-10.27.252.64/26
                    Subnets:
                    - CIDR: 10.27.252.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.27.252.1/32-10.27.252.62/32
                    - CIDR: 10.27.252.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.27.252.65/32-10.27.252.126/32
                - CIDR: 10.27.253.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.27.253.128/26-10.27.253.192/26
                    Subnets:
                    - CIDR: 10.27.253.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.27.253.129/32-10.27.253.190/32
                    - CIDR: 10.27.253.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.27.253.193/32-10.27.253.254/32
            - CIDR: 10.27.254.0/23
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.27.254.0/25-10.27.255.128/25
                Subnets:
                - CIDR: 10.27.254.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.27.254.0/26-10.27.254.64/26
                    Subnets:
                    - CIDR: 10.27.254.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.27.254.1/32-10.27.254.62/32
                    - CIDR: 10.27.254.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.27.254.65/32-10.27.254.126/32
                - CIDR: 10.27.255.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.27.255.128/26-10.27.255.192/26
                    Subnets:
                    - CIDR: 10.27.255.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.27.255.129/32-10.27.255.190/32
                    - CIDR: 10.27.255.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.27.255.193/32-10.27.255.254/32
    - CIDR: 10.224.0.0/11
      Name: stage7
      Worklaods:
        Count: 256
        CIDR: 10.248.0.0/22-10.251.252.0/22
        Subnets:
        - CIDR: 10.248.0.0/22
          Name: small-app1
          Accessibilities:
            Count: 2
            CIDR: 10.248.0.0/23-10.248.2.0/23
            Subnets:
            - CIDR: 10.248.0.0/23
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.248.0.0/25-10.248.1.128/25
                Subnets:
                - CIDR: 10.248.0.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.248.0.0/26-10.248.0.64/26
                    Subnets:
                    - CIDR: 10.248.0.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.248.0.1/32-10.248.0.62/32
                    - CIDR: 10.248.0.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.248.0.65/32-10.248.0.126/32
                - CIDR: 10.248.1.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.248.1.128/26-10.248.1.192/26
                    Subnets:
                    - CIDR: 10.248.1.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.248.1.129/32-10.248.1.190/32
                    - CIDR: 10.248.1.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.248.1.193/32-10.248.1.254/32
            - CIDR: 10.248.2.0/23
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.248.2.0/25-10.248.3.128/25
                Subnets:
                - CIDR: 10.248.2.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.248.2.0/26-10.248.2.64/26
                    Subnets:
                    - CIDR: 10.248.2.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.248.2.1/32-10.248.2.62/32
                    - CIDR: 10.248.2.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.248.2.65/32-10.248.2.126/32
                - CIDR: 10.248.3.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.248.3.128/26-10.248.3.192/26
                    Subnets:
                    - CIDR: 10.248.3.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.248.3.129/32-10.248.3.190/32
                    - CIDR: 10.248.3.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.248.3.193/32-10.248.3.254/32
        - CIDR: 10.251.252.0/22
          Name: small-app256
          Accessibilities:
            Count: 2
            CIDR: 10.251.252.0/23-10.251.254.0/23
            Subnets:
            - CIDR: 10.251.252.0/23
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.251.252.0/25-10.251.253.128/25
                Subnets:
                - CIDR: 10.251.252.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.251.252.0/26-10.251.252.64/26
                    Subnets:
                    - CIDR: 10.251.252.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.251.252.1/32-10.251.252.62/32
                    - CIDR: 10.251.252.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.251.252.65/32-10.251.252.126/32
                - CIDR: 10.251.253.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.251.253.128/26-10.251.253.192/26
                    Subnets:
                    - CIDR: 10.251.253.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.251.253.129/32-10.251.253.190/32
                    - CIDR: 10.251.253.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.251.253.193/32-10.251.253.254/32
            - CIDR: 10.251.254.0/23
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.251.254.0/25-10.251.255.128/25
                Subnets:
                - CIDR: 10.251.254.0/25
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.251.254.0/26-10.251.254.64/26
                    Subnets:
                    - CIDR: 10.251.254.0/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.251.254.1/32-10.251.254.62/32
                    - CIDR: 10.251.254.64/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.251.254.65/32-10.251.254.126/32
                - CIDR: 10.251.255.128/25
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.251.255.128/26-10.251.255.192/26
                    Subnets:
                    - CIDR: 10.251.255.128/26
                      Name: '1'
                      Hosts:
                        Count: 62
                        IP: 10.251.255.129/32-10.251.255.190/32
                    - CIDR: 10.251.255.192/26
                      Name: '2'
                      Hosts:
                        Count: 62
                        IP: 10.251.255.193/32-10.251.255.254/32


Tiny Networks

SubnetPlan:
  Name: H32A2S2
  Description: 32 hosts per subnet, 2 subnet per AZ, public/private split (512 workloads
    per stage)
  CIDR: 10.0.0.0/8
  Stages:
    Count: 8
    CIDR: 10.0.0.0/11-10.224.0.0/11
    Subnets:
    - CIDR: 10.0.0.0/11
      Name: core
      Worklaods:
        Count: 512
        CIDR: 10.28.0.0/23-10.31.254.0/23
        Subnets:
        - CIDR: 10.28.0.0/23
          Name: tiny-app1
          Accessibilities:
            Count: 2
            CIDR: 10.28.0.0/24-10.28.1.0/24
            Subnets:
            - CIDR: 10.28.0.0/24
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.28.0.0/26-10.28.0.192/26
                Subnets:
                - CIDR: 10.28.0.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.28.0.0/27-10.28.0.32/27
                    Subnets:
                    - CIDR: 10.28.0.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.28.0.1/32-10.28.0.30/32
                    - CIDR: 10.28.0.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.28.0.33/32-10.28.0.62/32
                - CIDR: 10.28.0.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.28.0.192/27-10.28.0.224/27
                    Subnets:
                    - CIDR: 10.28.0.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.28.0.193/32-10.28.0.222/32
                    - CIDR: 10.28.0.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.28.0.225/32-10.28.0.254/32
            - CIDR: 10.28.1.0/24
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.28.1.0/26-10.28.1.192/26
                Subnets:
                - CIDR: 10.28.1.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.28.1.0/27-10.28.1.32/27
                    Subnets:
                    - CIDR: 10.28.1.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.28.1.1/32-10.28.1.30/32
                    - CIDR: 10.28.1.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.28.1.33/32-10.28.1.62/32
                - CIDR: 10.28.1.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.28.1.192/27-10.28.1.224/27
                    Subnets:
                    - CIDR: 10.28.1.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.28.1.193/32-10.28.1.222/32
                    - CIDR: 10.28.1.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.28.1.225/32-10.28.1.254/32
        - CIDR: 10.31.254.0/23
          Name: tiny-app256
          Accessibilities:
            Count: 2
            CIDR: 10.31.254.0/24-10.31.255.0/24
            Subnets:
            - CIDR: 10.31.254.0/24
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.31.254.0/26-10.31.254.192/26
                Subnets:
                - CIDR: 10.31.254.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.31.254.0/27-10.31.254.32/27
                    Subnets:
                    - CIDR: 10.31.254.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.31.254.1/32-10.31.254.30/32
                    - CIDR: 10.31.254.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.31.254.33/32-10.31.254.62/32
                - CIDR: 10.31.254.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.31.254.192/27-10.31.254.224/27
                    Subnets:
                    - CIDR: 10.31.254.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.31.254.193/32-10.31.254.222/32
                    - CIDR: 10.31.254.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.31.254.225/32-10.31.254.254/32
            - CIDR: 10.31.255.0/24
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.31.255.0/26-10.31.255.192/26
                Subnets:
                - CIDR: 10.31.255.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.31.255.0/27-10.31.255.32/27
                    Subnets:
                    - CIDR: 10.31.255.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.31.255.1/32-10.31.255.30/32
                    - CIDR: 10.31.255.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.31.255.33/32-10.31.255.62/32
                - CIDR: 10.31.255.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.31.255.192/27-10.31.255.224/27
                    Subnets:
                    - CIDR: 10.31.255.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.31.255.193/32-10.31.255.222/32
                    - CIDR: 10.31.255.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.31.255.225/32-10.31.255.254/32
    - CIDR: 10.224.0.0/11
      Name: stage7
      Worklaods:
        Count: 512
        CIDR: 10.252.0.0/23-10.255.254.0/23
        Subnets:
        - CIDR: 10.252.0.0/23
          Name: tiny-app1
          Accessibilities:
            Count: 2
            CIDR: 10.252.0.0/24-10.252.1.0/24
            Subnets:
            - CIDR: 10.252.0.0/24
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.252.0.0/26-10.252.0.192/26
                Subnets:
                - CIDR: 10.252.0.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.252.0.0/27-10.252.0.32/27
                    Subnets:
                    - CIDR: 10.252.0.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.252.0.1/32-10.252.0.30/32
                    - CIDR: 10.252.0.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.252.0.33/32-10.252.0.62/32
                - CIDR: 10.252.0.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.252.0.192/27-10.252.0.224/27
                    Subnets:
                    - CIDR: 10.252.0.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.252.0.193/32-10.252.0.222/32
                    - CIDR: 10.252.0.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.252.0.225/32-10.252.0.254/32
            - CIDR: 10.252.1.0/24
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.252.1.0/26-10.252.1.192/26
                Subnets:
                - CIDR: 10.252.1.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.252.1.0/27-10.252.1.32/27
                    Subnets:
                    - CIDR: 10.252.1.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.252.1.1/32-10.252.1.30/32
                    - CIDR: 10.252.1.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.252.1.33/32-10.252.1.62/32
                - CIDR: 10.252.1.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.252.1.192/27-10.252.1.224/27
                    Subnets:
                    - CIDR: 10.252.1.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.252.1.193/32-10.252.1.222/32
                    - CIDR: 10.252.1.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.252.1.225/32-10.252.1.254/32
        - CIDR: 10.255.254.0/23
          Name: tiny-app256
          Accessibilities:
            Count: 2
            CIDR: 10.255.254.0/24-10.255.255.0/24
            Subnets:
            - CIDR: 10.255.254.0/24
              Name: private
              AvailabilityZones:
                Count: 4
                CIDR: 10.255.254.0/26-10.255.254.192/26
                Subnets:
                - CIDR: 10.255.254.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.255.254.0/27-10.255.254.32/27
                    Subnets:
                    - CIDR: 10.255.254.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.255.254.1/32-10.255.254.30/32
                    - CIDR: 10.255.254.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.255.254.33/32-10.255.254.62/32
                - CIDR: 10.255.254.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.255.254.192/27-10.255.254.224/27
                    Subnets:
                    - CIDR: 10.255.254.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.255.254.193/32-10.255.254.222/32
                    - CIDR: 10.255.254.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.255.254.225/32-10.255.254.254/32
            - CIDR: 10.255.255.0/24
              Name: public
              AvailabilityZones:
                Count: 4
                CIDR: 10.255.255.0/26-10.255.255.192/26
                Subnets:
                - CIDR: 10.255.255.0/26
                  Name: a
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.255.255.0/27-10.255.255.32/27
                    Subnets:
                    - CIDR: 10.255.255.0/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.255.255.1/32-10.255.255.30/32
                    - CIDR: 10.255.255.32/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.255.255.33/32-10.255.255.62/32
                - CIDR: 10.255.255.192/26
                  Name: d
                  SubnetGroups:
                    Count: 2
                    CIDR: 10.255.255.192/27-10.255.255.224/27
                    Subnets:
                    - CIDR: 10.255.255.192/27
                      Name: '1'
                      Hosts:
                        Count: 30
                        IP: 10.255.255.193/32-10.255.255.222/32
                    - CIDR: 10.255.255.224/27
                      Name: '2'
                      Hosts:
                        Count: 30
                        IP: 10.255.255.225/32-10.255.255.254/32


