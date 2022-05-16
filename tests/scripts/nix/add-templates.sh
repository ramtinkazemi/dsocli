#!/bin/bash

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' -g > /dev/null
Overridden Global Template
Params:
gp = {{gp}}
op = {{op}}
Secrets:
gs = {{gs}}
os = {{os}}
EOF

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' -g -s dev > /dev/null
Overridden Global Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
EOF

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' -n > /dev/null
Overriden Namespace Template
Params:
op = {{op}}
gp = {{gp}}
np = {{np}}
Secrets:
os = {{os}}
gs = {{gs}}
ns = {{ns}}
EOF

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' -n -s dev > /dev/null
Overriden Namespace Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
np = {{np}}
nsp = {{nsp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
ns = {{ns}}
nss = {{nss}}
EOF

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' > /dev/null
Overriden Application Template
Params:
op = {{op}}
gp = {{gp}}
np = {{np}}
ap = {{ap}}
Secrets:
os = {{os}}
gs = {{gs}}
ns = {{ns}}
as = {{as}}
EOF

cat <<-EOF | dso template add - ot -r '.dso/output/**/*' -s dev > /dev/null
Overriden Application Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
np = {{np}}
nsp = {{nsp}}
ap = {{ap}}
asp = {{asp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
ns = {{ns}}
nss = {{nss}}
as = {{as}}
ass = {{ass}}
EOF


cat <<-EOF | dso template add - gt -r '.dso/output/**/*' -g > /dev/null
Global Template
Params:
gp = {{gp}}
op = {{op}}
Secrets:
gs = {{gs}}
os = {{os}}
EOF


cat <<-EOF | dso template add - gst -r '.dso/output/**/*' -g -s dev > /dev/null
Global Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
EOF


cat <<-EOF | dso template add - nt -r '.dso/output/**/*' -n > /dev/null
Namespace Template
Params:
op = {{op}}
gp = {{gp}}
np = {{np}}
Secrets:
os = {{os}}
gs = {{gs}}
ns = {{ns}}
EOF

cat <<-EOF | dso template add - nst -r '.dso/output/**/*' -n -s dev > /dev/null
Namespace Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
np = {{np}}
nsp = {{nsp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
ns = {{ns}}
nss = {{nss}}
EOF

cat <<-EOF | dso template add - at -r '.dso/output/**/*' > /dev/null
Application Template
Params:
op = {{op}}
gp = {{gp}}
np = {{np}}
ap = {{ap}}
Secrets:
os = {{os}}
gs = {{gs}}
ns = {{ns}}
as = {{as}}
EOF

cat <<-EOF | dso template add - ast -r '.dso/output/**/*' -s dev > /dev/null
Application Stage Template
Params:
op = {{op}}
gp = {{gp}}
gsp = {{gsp}}
np = {{np}}
nsp = {{nsp}}
ap = {{ap}}
asp = {{asp}}
Secrets:
os = {{os}}
gs = {{gs}}
gss = {{gss}}
ns = {{ns}}
nss = {{nss}}
as = {{as}}
ass = {{ass}}
EOF


