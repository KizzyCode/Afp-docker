#!/bin/bash
set -euo pipefail


# Creates a single user
function create_user() {
	# Get args
	USERNAME="$1"
	USERPASS="$2"
	USERUID="$3"

	# Check if the user exists already
	if getent passwd "$USERNAME" >/dev/null; then
		return 0
	fi

	# Create user and set password
	echo "Creating user $USERNAME"
	useradd --no-create-home --system --uid="$USERUID" --shell=/sbin/nologin "$USERNAME"
	echo "$USERNAME:$USERPASS" | chpasswd

	# Create config
	export USERNAME
	export USERPASS
	cat /etc/netatalk/afp.conf.user-template | envsubst >> /etc/netatalk/afp.conf
}


# Creates all users
function create_users() {
	# Create users
	for INDEX in `seq 0 127`; do
		# Create the variable names
		USERNAME_VAR="AFP_USER${INDEX}_NAME"
		USERPASS_VAR="AFP_USER${INDEX}_PASS"
		USERUID_VAR="AFP_USER${INDEX}_UID"

		# Resolve variables
		USERNAME="${!USERNAME_VAR:-}"
		USERPASS="${!USERPASS_VAR:-}"
		USERUID="${!USERUID_VAR:-}"

		# Check if the username is set
		if test -n "$USERNAME"; then
			create_user "$USERNAME" "$USERPASS" "$USERUID"
		fi
	done
}


# Create users and start supervisor
create_users
exec supervisord -c "/etc/netatalk/supervisord.conf"
