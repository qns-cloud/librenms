# LibreNMS Docker Swarm Deployment

This repository contains configuration files for deploying LibreNMS on Docker Swarm using Portainer.

## Prerequisites

- Docker Swarm cluster
- Portainer installed
- Git repository access

## Files

- `docker-compose.yml`: Stack configuration
- `mariadb-config.cnf`: MariaDB optimized settings
- `backup.sh`: Automated backup script

## Deployment Instructions for Portainer

### Step 1: Set Environment Variables

When deploying through Portainer, set the following environment variables:

```
DB_PASSWORD=your_secure_password
DB_ROOT_PASSWORD=your_secure_root_password
```

If you don't set these, default values will be used (`librenms_password` and `librenms_root_password`).

### Step 2: Deploy with Detach Flag

> **IMPORTANT**: When deploying through Portainer, use these settings:
>
> - In Portainer's "Advanced Mode" or "Additional Settings" section, look for "Detach" or "--detach" option
> - Set it to "false" or ensure "--detach=false" is used
>
> This addresses the warning: "Since --detach=false was not specified, tasks will be created in the background."
>
> If Portainer doesn't offer this option, you may see this warning, but deployment should still succeed.

### Step 3: Verify Deployment

After deployment:

1. Check that all services are running properly
2. Verify LibreNMS is accessible at http://[your-server]:8080
3. Confirm the backup service is running correctly

## Troubleshooting

### Common Issues

- **Missing backup.sh**: Ensure the `backup.sh` script is included in your repository
- **Database connection issues**: Verify environment variables are set correctly
- **Permission problems**: Ensure volumes have proper permissions

### Access Information

- Web UI: http://[your-server]:8080
- Default login: admin/admin (change immediately)

## Security Notes

- This configuration uses capability restrictions (`cap_drop`, `cap_add`) and read-only containers for security
- Default passwords should be changed immediately after first login
- Consider implementing additional network security measures

## Maintenance

- Backups are configured to run daily at 2 AM
- Backup retention period is 7 days
- Logs are rotated automatically