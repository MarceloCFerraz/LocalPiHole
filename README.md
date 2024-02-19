# Welcome

This repo uses pi-hole for docker. To learn more about it, look at the [official docs](https://docs.pi-hole.net/) and the [official github repo](https://github.com/pi-hole/docker-pi-hole/?tab=readme-ov-file#docker-pi-hole).

Although it was made for using Docker, I adapted it to use [Podman](https://podman.io/) instead. It should be compatible, but if not, you'll have to do some research to re-adapt back to Docker.

As a tip, I'd start by removing `docker.io` from `compose.yaml`.

# Setup

This repo contains a script to automatically:

1. fetch for podman and podman-compose and install them if not yet installed;
2. pull `pihole` image from docker hub;
3. start the container;
4. setup an admin password for you; and
5. change your local DNS configuration to use pi-hole as DNS provider.

The script is `start_pihole.sh`. It was made considering my own local machine (which runs a Manjaro Linux X64 distro), but should work for any linux distro with only a few tweak. If you're not an Arch linux user like me but you're on a linux environment, you'll mainly have to replace `pacman` commands with your distro's package manager commands (e.g. `apt`, `rpm` and so on) and that's it.

If you're on Windows, You'll probably have to manually download `podman` and do everything yourself. Sorry for that :/

To run the setup script on linux or mac, first open your terminal, clone this repo and `cd` into the destination directory, then make the script executable and run it.

To make everything work smoothly, I made podman use `host` network, what means `podman compose` must be executed with admin privileges (i.e. `sudo podman compose`) to properly allocate ports `53`, `57` and `80` to the container.

In other words, you'll need to provide your password after executing the script. If that's not ok for you, feel free to execute `sudo podman compose -f compose.yaml up -d` by yourself. After that, search for your local IPV4 and IPV6 addresses and set them as your DNS.

You can check steps in the script if you don't know how to do any of that.

## Execute The Script:

```bash
# Step 1: clone the repo
git clone https://github.com/MarceloCFerraz/LocalPiHole

# Step 2: cd into dir
cd LocalPiHole

# Step 3: make the script executable
chmod +x ./start_pihole.sh

# Step 4: execute the script
./start_pihole.sh

# Step 5: type your sudo password
```

By default, pi-hole will use Google's DNS, but you can change that in [`localhost/admin/settings.php?tab=dns`](http://localhost/admin/settings.php?tab=dns). Also, check this [article](https://docs.pi-hole.net/guides/dns/cloudflared/) on how to use DNS over HTTPs (DoH).

# Domain Filtering

There are multiple people who maintain huge lists of ads providers. I recommend checking out for yourself, but if you want a quick start (and don't want to use the default list that comes with pi-hole), here's a list of AD hosts providers that I'm currently using:

-   https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
-   https://raw.githubusercontent.com/KnightmareVIIVIIXC/AIO-Firebog-Blocklists/main/phlists/aiofirebog.txt
-   https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/master/hosts/hosts0
-   https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/master/hosts/hosts1
-   https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/master/hosts/hosts2
-   https://raw.githubusercontent.com/Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist/master/hosts/hosts3
-   https://raw.githubusercontent.com/jerryn70/GoodbyeAds/master/Hosts/GoodbyeAds.txt

Summing all of the before mentioned host files will give you a list with **1.5 million** addresses that will be blocked before they get the chance to download any data in your network.

As a side effect, some websites might not work properly. You can correct that by adding specific domains to the white list: [`localhost/admin/groups-domains.php`](http://localhost/admin/groups-domains.php)

Have fun with a cleaner, lighter internet! :)
