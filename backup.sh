#!/bin/sh
# LibreNMS Docker Backup Script
# Handles automated backups of both database and application data

# Set timestamp for backup files
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup"
DB_BACKUP_DIR="${BACKUP_DIR}/db"
APP_BACKUP_DIR="${BACKUP_DIR}/librenms"
RETENTION_DAYS=7

# Ensure backup directories exist
mkdir -p ${DB_BACKUP_DIR}
mkdir -p ${APP_BACKUP_DIR}

# Log function
log_message() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ${BACKUP_DIR}/backup.log
}

log_message "Starting backup process"

# Database backup via mysqldump
# Note: Uses docker exec to connect to the db container
if [ -d "${DB_BACKUP_DIR}" ]; then
  log_message "Backing up MariaDB database"
  
  # Create database dump
  BACKUP_FILE="${DB_BACKUP_DIR}/librenms_db_${TIMESTAMP}.sql.gz"
  
  # We need to use environment variables from the db service
  # This assumes we have access to the database credentials
  mysqldump --host=db --user=librenms --password=${MYSQL_PASSWORD} \
    --single-transaction --quick --lock-tables=false librenms | gzip > ${BACKUP_FILE}
  
  if [ $? -eq 0 ]; then
    log_message "Database backup completed successfully: ${BACKUP_FILE}"
  else
    log_message "ERROR: Database backup failed"
  fi
  
  # Clean up old database backups
  find ${DB_BACKUP_DIR} -name "librenms_db_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete
  log_message "Cleaned up database backups older than ${RETENTION_DAYS} days"
else
  log_message "ERROR: Database backup directory not available"
fi

# Application data backup
if [ -d "${APP_BACKUP_DIR}" ]; then
  log_message "Backing up LibreNMS application data"
  
  # Create a compressed archive of the app data
  BACKUP_FILE="${APP_BACKUP_DIR}/librenms_app_${TIMESTAMP}.tar.gz"
  
  # This assumes we have the LibreNMS data mounted at a known location
  tar -czf ${BACKUP_FILE} -C /data .
  
  if [ $? -eq 0 ]; then
    log_message "Application data backup completed successfully: ${BACKUP_FILE}"
  else
    log_message "ERROR: Application data backup failed"
  fi
  
  # Clean up old application backups
  find ${APP_BACKUP_DIR} -name "librenms_app_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete
  log_message "Cleaned up application backups older than ${RETENTION_DAYS} days"
else
  log_message "ERROR: Application backup directory not available"
fi

log_message "Backup process completed"

# If run via cron, exit cleanly
exit 0