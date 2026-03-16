#!/bin/bash
echo "21 CFR Part 11 Audit Trail - $(date)" > audit_$(date +%Y%m%d).csv
echo "timestamp,action,user,ip,status" >> audit_$(date +%Y%m%d).csv
tail -f /var/log/nginx/access.log | awk '{print $1","$4","$7","$9}' >> audit_$(date +%Y%m%d).csv
