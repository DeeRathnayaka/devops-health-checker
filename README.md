# DevOps Health Checker

Through WSL2 terminal run
./health_check.sh -o daily_report.log

crontab configured for automated checkups every minute.

Automated system health check script for Linux hosts.

## Features

- CPU and memory monitoring
- Root disk usage monitoring
- Top 5 memory-consuming processes
- Network port and service checks
- Disk usage warning when usage exceeds 80%
- Daily health report logging


#0 0 * * * /mnt/d/Learning/DIPROIT/health checker/devops-health-checker/health_check.sh -o /mnt/d/Learning/DIPROIT/health\ checker/devops-health-checker/daily_report.log
