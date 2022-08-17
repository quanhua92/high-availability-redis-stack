# High availability Redis Stack with Redis Sentinel

This tutorial shows how to run a Redis Stack Server (bundled Redis modules) with High Availbility using Redis Sentinel.

## Documentation

- [Redis Configuration](https://redis.io/docs/manual/config/)
- [Redis Replication](https://redis.io/docs/manual/replication/)
- [Redis Sentinel](https://redis.io/docs/manual/sentinel/)
- [Redis Stack](https://redis.io/docs/stack/)

## Quick Start

1. Prepare 03 Servers with Docker & Docker Compose installed
2. Edit the `prepare-config-files.sh` and replace the following variables: `SERVER_0_IP`, `SERVER_1_IP`, `SERVER_2_IP`, and `REDIS_PASSWORD`
3. Run the `prepare-config-files.sh` with the following command. This will create a `.conf` file from `.template` file in corresponding folder:

        ```bash
        sh prepare-config-files.sh
        ```
4. In server 0, go to `server-0` folder and run `docker compose up -d`
5. In server 1, go to `server-1` folder and run `docker compose up -d`
6. In server 2, go to `server-2` folder and run `docker compose up -d`