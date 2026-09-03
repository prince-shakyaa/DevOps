# Docker Networking

Exploring how containers communicate with each other and the host system.

## Network Types
- **Bridge**: The default network. Containers can communicate if explicitly linked or on the same custom bridge.
- **Host**: Removes network isolation. The container uses the host's networking namespace directly.
- **Overlay**: Used in Swarm mode to connect multiple Docker daemons.

## Volumes & Mounts
- **Bind Mounts**: Maps a specific directory on the host to the container. Great for live-reloading code.
- **Named Volumes**: Docker manages the storage location. Ideal for persistent database data.

### Commands
- `docker network create mynet`: Creates a new bridge network.
- `docker run --network mynet ...`: Attaches a container to a network.
- `docker run -v /host/path:/container/path ...`: Creates a bind mount.
