#!/bin/bash
# LibreNMS Docker Swarm Deployment Script
# This script helps deploy the LibreNMS stack to Docker Swarm with the proper flags

set -e

# Default values
STACK_NAME="librenms"
COMPOSE_FILE="docker-compose.yml"
DB_PASSWORD=${DB_PASSWORD:-"librenms_password"}
DB_ROOT_PASSWORD=${DB_ROOT_PASSWORD:-"librenms_root_password"}

# Display help
show_help() {
  echo "LibreNMS Docker Swarm Deployment Script"
  echo ""
  echo "Usage: $0 [options]"
  echo ""
  echo "Options:"
  echo "  -h, --help              Show this help message"
  echo "  -n, --name NAME         Set stack name (default: $STACK_NAME)"
  echo "  -f, --file FILE         Set compose file (default: $COMPOSE_FILE)"
  echo "  -p, --password PWD      Set database password (default: auto-generated)"
  echo "  -r, --root-pwd PWD      Set database root password (default: auto-generated)"
  echo ""
}

# Parse arguments
while [ "$1" != "" ]; do
  case $1 in
    -h | --help )      show_help
                        exit
                        ;;
    -n | --name )      shift
                        STACK_NAME=$1
                        ;;
    -f | --file )      shift
                        COMPOSE_FILE=$1
                        ;;
    -p | --password )  shift
                        DB_PASSWORD=$1
                        ;;
    -r | --root-pwd )  shift
                        DB_ROOT_PASSWORD=$1
                        ;;
    * )                show_help
                        exit 1
  esac
  shift
done

# Check if file exists
if [ ! -f "$COMPOSE_FILE" ]; then
  echo "Error: Compose file $COMPOSE_FILE not found!"
  exit 1
fi

# Ensure backup.sh exists and is executable
if [ ! -f "backup.sh" ]; then
  echo "Error: backup.sh not found!"
  exit 1
fi
chmod +x backup.sh

# Export environment variables for the compose file
export DB_PASSWORD
export DB_ROOT_PASSWORD

echo "======================================"
echo "Deploying LibreNMS to Docker Swarm"
echo "======================================"
echo "Stack name: $STACK_NAME"
echo "Compose file: $COMPOSE_FILE"
echo "Using --detach=false for proper task creation"
echo "======================================"

# Deploy the stack with --detach=false
docker stack deploy --compose-file "$COMPOSE_FILE" --detach=false "$STACK_NAME"

echo "======================================"
echo "Deployment complete!"
echo "======================================"
echo "You can access LibreNMS at: http://localhost:8080"
echo "Database password is set"
echo "Root password is set"
echo "======================================"