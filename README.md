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

### Step 2: Expected Warnings and Config Updates

When deploying through Portainer, you may see these warnings/errors:

1. **Detach Warning**: 
   ```
   Since --detach=false was not specified, tasks will be created in the background.
   ```
   - This is just an informational message and can be safely ignored
   - In future Docker versions, this will be the default behavior

2. **Config Update Error** (when re-deploying after changes):
   ```
   failed to update config: only updates to Labels are allowed
   ```
   - This happens because Docker Swarm configs are immutable
   - Solution: We use versioned configs (`*_v1`, `*_v2`, etc.) to avoid this error

### Step 3: Updating Configurations

If you need to modify the MariaDB configuration or backup script:

1. Edit the respective file (mariadb-config.cnf or backup.sh)
2. Increment the version numbers in docker-compose.yml in both places:

```yaml
# In the service definition:
configs:
  - source: mariadb_config_v2  # Change from v1 to v2
    target: /etc/mysql/conf.d/custom.cnf

# In the configs section at the bottom:
configs:
  mariadb_config_v2:  # Change from v1 to v2
    file: ./mariadb-config.cnf
    name: librenms_mariadb_config_v2  # Change from v1 to v2
```

This approach works because Docker Swarm will create a new config with the new name rather than trying to update the existing one.

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