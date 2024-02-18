# Welcome

This repo uses pi-hole for docker. To learn more about it, look at the [official docs](https://docs.pi-hole.net/) and the [official github repo](https://github.com/pi-hole/docker-pi-hole/?tab=readme-ov-file#docker-pi-hole).

Although it was made for using Docker, I adapted it to use [Podman](https://podman.io/) instead. It should be compatible, but if not, you'll have to do some research to re-adapt back to Docker.

As a tip, I'd start by removing `docker.io` from `compose.yaml`.

# Setup

This repo contains a script to automatically:

1. fetch for podman and podman-compose and install them if not yet installed,
2. pull `pihole` image from docker hub,
3. start the container,
4. setup an admin password for you and also
5. change your DNS configuration to use pi-hole automatically.

The script is `start_pihole.sh`. It was made considering my own local machine (which runs a Manjaro Linux X64 distro), but should work for any linux distro with only a few tweak. If you're not an Arch linux user like me but you're on a linux environment, you'll mainly have to replace `pacman` commands with your distro's package manager commands (e.g. `apt`, `rpm` and so on) and that's it.

If you're on Windows, You'll probably have to manually download `podman` and do everything yourself. Sorry for that :/

To run the script, do the following:

```batch
# make the script executable
chmod ./start_pihole.sh

# execute the script
./start_pihole.sh
```

Have fun with a cleaner, lighter internet! :)
