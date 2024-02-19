#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a pihole container is already running
is_pihole_running() {
    sudo podman container list | grep -q "pihole"
}

print_line() {
    echo "----------------------------------------------"
}

configure_dns() {
    device_name=$1
    echo ">> Fetching configurations for device: '$device_name'"

    # Step 2: Fetch IP addresses for the connection
    device_settings=$(nmcli -p device show "$device_name")

    connection_name=$(echo "$device_settings" | grep -E "GENERAL.CONNECTION")
    connection_name=$(echo "$connection_name" | grep -oE "\S+\s*$")

    echo ">> Connection: '$connection_name'"

    ipv4_addr=$(ip route get 1.2.3.4 | awk '{print $7}')

    echo ">> IPV4: '$ipv4_addr'"

    ipv6_addr=$(echo "$device_settings" | grep -E "IP6.ADDRESS\[2\]")
    ipv6_addr=$(echo "$ipv6_addr" | grep -oE "\S+\s*$" | xargs | grep -Eo "([0-9a-zA-Z]{0,4}):([0-9a-zA-Z]{0,4}:{1}){1,6}([0-9a-zA-Z]{0,4})")

    echo ">> IPV6: '$ipv6_addr'"

    echo ">> Setting Up DNS"

    # Step 3: Disconnect the connection
    echo ">> Bringing '$connection_name' down"
    nmcli conn down "$connection_name"

    # Step 4: Disable auto DNS resolution (IPv4 + IPv6)
    echo ">> Disabling auto DNS from default gateway"
    nmcli conn modify "$connection_name" ipv4.ignore-auto-dns yes
    nmcli conn modify "$connection_name" ipv6.ignore-auto-dns yes

    # Step 5: Update DNS servers to local IPs
    echo ">> Changing IPV4 DNS to '$ipv4_addr'"
    nmcli conn modify "$connection_name" ipv4.dns "$ipv4_addr"
    echo ">> Changing IPV6 DNS to '$ipv6_addr'"
    nmcli conn modify "$connection_name" ipv6.dns "$ipv6_addr"

    # Step 6: Reconnect the connection
    echo ">> Bringing '$connection_name' back up"
    nmcli conn up "$connection_name"

    print_line
}

print_success() {
    echo "You're good to go now!"
    echo "Now you can access Pi-hole's admin dashboard in 'localhost/admin' with the password defined in '$SCRIPTPATH/compose.yaml' or start browsing!"
}

first_run=false
SCRIPT=$(realpath "$0")
SCRIPTPATH=$(dirname "$SCRIPT")

# Check for Podman
if ! command_exists podman; then
    first_run=true
    echo "Podman not found. Installing..."
    # Replace this section with your distro's Podman installation commands
    sudo pacman -Syu podman # for Arch distros
    # sudo apt install podman  # for Debian/Ubuntu
fi

# Check for Podman Compose
if ! command_exists podman-compose; then
    first_run=true
    echo "Podman Compose not found. Installing..."
    # Replace this section with your distro's Podman Compose installation commands
    sudo pacman -Syu podman-compose # for Arch distros
    # sudo apt install podman-compose  # for Debian/Ubuntu
    # ... add instructions for other distros if needed
fi

if ! is_pihole_running; then
    echo "Starting Pi-hole..."
    if ! [ $first_run ]; then
        container_id=$(sudo podman container list -a | grep "pihole" | awk '{print $1}')
        sudo podman container start "$container_id" | grep -o ""
    else
        sudo podman compose -f "$SCRIPTPATH/compose.yaml" up -d # untested. if this throws an error, replace it with the path to your local `compose.yaml` file
    fi
else
    echo "Pi-hole is already running..."
fi

echo "Configuring Pi-hole as your DNS provider"
print_line

# Command to fetch connected device information
device_names=$(nmcli d | grep -E " connected\s+" | grep -Ev "\(.*\)" | cut -d ' ' -f 1)
length=${#device_names[@]}

if ((length == 1)); then
    configure_dns "$device_names"
    print_success
elif ((length > 1)); then
    # Use a simple for loop (read splits automatically with \n)
    for device in $device_names; do
        configure_dns "$device"
    done
    print_success
else
    echo "No network devices detected. No configuration done."
fi
