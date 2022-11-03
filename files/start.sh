#!/bin/bash
set -euo pipefail


# Setup the system user accounts
function setup_users() {
	# Print status
    echo "*> Configuring system users..."

    # Test for $USERS 
    if test -z "${USERS:-}"; then
        echo "!> Missing required environment variable \$USERS"
        exit 1
    fi

    # Configure users
    echo "$USERS" | jq -c ".[]" | while read USER; do
        # Parse JSON
        USER_NAME=`echo "$USER" | jq -r ".username"`
        USER_PASS=`echo "$USER" | jq -r ".password"`
        USER_UID=`echo "$USER" | jq -r ".uid"`

		# Check if the user exists already
		if getent passwd "$USER_NAME" >/dev/null; then
			return 0
		fi

		# Create user and set password
		echo "Creating user $USER_NAME"
		useradd --no-create-home --system --uid="$USER_UID" --shell=/sbin/nologin "$USER_NAME"
		echo "$USER_NAME:$USER_PASS" | chpasswd
    done
}


# Setup the shares
function setup_shares() {
	# Print status
    echo "*> Configuring shares..."

    # Test for $SHARES 
    if test -z "${SHARES:-}"; then
        echo "!> Missing required environment variable \$SHARES"
        exit 1
    fi

    # Configure users
    echo "$SHARES" | jq -c ".[]" | while read SHARE; do
        # Parse JSON
        SHARE_USER=`echo "$SHARE" | jq -r ".username"`
        SHARE_PATH=`echo "$SHARE" | jq -r ".path"`

		# Create share
		export SHARE_USER
		export SHARE_PATH
		cat /etc/netatalk/afp.conf.user-template | envsubst >> /etc/netatalk/afp.conf
    done
}


# Create users and start supervisor
setup_users
setup_shares
exec supervisord -c "/etc/netatalk/supervisord.conf"
