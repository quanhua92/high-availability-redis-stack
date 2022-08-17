# High availability Redis Stack with Redis Sentinel

This tutorial shows how to run a Redis Stack Server (bundled Redis modules) with High Availbility using Redis Sentinel.

## Documentation

- [Redis Configuration](https://redis.io/docs/manual/config/)
- [Redis Replication](https://redis.io/docs/manual/replication/)
- [Redis Sentinel](https://redis.io/docs/manual/sentinel/)
- [Redis Stack](https://redis.io/docs/stack/)

## Quick Start

```bash
docker-compose -p stack up -d
```

## Config

### redis-0/redis.conf

```txt
protected-mode no
port 6379
replica-announce-ip 127.0.0.1
replica-announce-port 6380

# authentication
masterauth password-here
requirepass password-here
```

### redis-1/redis.conf

```txt
protected-mode no
port 6379
replicaof redis-0 6379
replica-announce-ip 127.0.0.1
replica-announce-port 6381

# authentication
masterauth password-here
requirepass password-here
```

### redis-2/redis.conf

```txt
protected-mode no
port 6379
replicaof redis-0 6379
replica-announce-ip 127.0.0.1
replica-announce-port 6382

# authentication
masterauth password-here
requirepass password-here
```

### sentinel.conf

```txt
port 5000
sentinel announce-ip 127.0.0.1
sentinel announce-port 26380
sentinel monitor mymaster redis-0 6379 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 60000
sentinel auth-pass mymaster password-here
```

## Test Replication

1. Exec to `redis-0`

    ```bash
    docker exec -it redis-0 /bin/bash
    ```

2. Run `redis-cli`

    ```bash
    redis-cli
    ```

3. Authenticate and set a test key-value. Replace `password-here` with your password in config file.

    ```bash
    AUTH password-here

    INFO replication

    SET hello "world from redis-0"
    ```

4. Exec to `redis-2`

    ```bash
    docker exec -it redis-2 /bin/bash
    ```

5. Run `redis-cli`

    ```bash
    redis-cli
    ```

6. Get keys

    ```bash
    AUTH password-here

    INFO replication

    KEYS *

    GET hello
    ```

## Setup High Availability with Redis Sentinel

1. Run sentinel-0 sentinel-1 sentinel-2. If you are using Window, replace **\`pwd\`** with **${PWD}**

      ```bash
      docker run -d --rm --name sentinel-0 --net redis -v `pwd`/sentinel-0:/etc/sentinel redis/redis-stack-server:latest redis-sentinel /etc/sentinel/sentinel.conf

      docker run -d --rm --name sentinel-1 --net redis -v `pwd`/sentinel-1:/etc/sentinel redis/redis-stack-server:latest redis-sentinel /etc/sentinel/sentinel.conf

      docker run -d --rm --name sentinel-2 --net redis -v `pwd`/sentinel-2:/etc/sentinel redis/redis-stack-server:latest redis-sentinel /etc/sentinel/sentinel.conf
      ```

2. Check sentinel-0 logs with `docker logs sentinel-0`. The result should look as follows:

      ```txt
      1:X 15 Aug 2022 18:26:50.625 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
      1:X 15 Aug 2022 18:26:50.625 # Redis version=6.2.7, bits=64, commit=00000000, modified=0, pid=1, just started
      1:X 15 Aug 2022 18:26:50.625 # Configuration loaded
      1:X 15 Aug 2022 18:26:50.626 * monotonic clock: POSIX clock_gettime
      1:X 15 Aug 2022 18:26:50.627 # A key '__redis__compare_helper' was added to Lua globals which is not on the globals allow list nor listed on the deny list.
      1:X 15 Aug 2022 18:26:50.627 * Running mode=sentinel, port=5000.
      1:X 15 Aug 2022 18:26:50.644 # Sentinel ID is b76baedb3ec6f8c3f70bfbac81c424bebd5333bd
      1:X 15 Aug 2022 18:26:50.644 # +monitor master mymaster 172.18.0.2 6379 quorum 2
      1:X 15 Aug 2022 18:26:50.645 * +slave slave 172.18.0.3:6379 172.18.0.3 6379 @ mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:26:50.656 * +slave slave 172.18.0.4:6379 172.18.0.4 6379 @ mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:28:03.788 * +sentinel sentinel 96e5e9c5536fde15a8c00265373f6503ee9d0550 172.18.0.6 5000 @ mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:28:05.830 * +sentinel sentinel 57213ff3f7fd33eaf381ee6286a7ef39c7dbccc1 172.18.0.7 5000 @ mymaster 172.18.0.2 6379
      ```

## Test Automatic Failover

1. Remove `redis-0`

      ```bash
      docker rm -f redis-0
      ```

2. Check sentinel-0 logs with `docker logs sentinel-0`. The result should look as follows:

      ```txt
      1:X 15 Aug 2022 18:34:41.467 # +sdown master mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:41.522 # +odown master mymaster 172.18.0.2 6379 #quorum 2/2
      1:X 15 Aug 2022 18:34:41.523 # +new-epoch 1
      1:X 15 Aug 2022 18:34:41.523 # +try-failover master mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:41.535 # +vote-for-leader b76baedb3ec6f8c3f70bfbac81c424bebd5333bd 1
      1:X 15 Aug 2022 18:34:41.555 # 57213ff3f7fd33eaf381ee6286a7ef39c7dbccc1 voted for b76baedb3ec6f8c3f70bfbac81c424bebd5333bd 1
      1:X 15 Aug 2022 18:34:41.588 # +elected-leader master mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:41.588 # +failover-state-select-slave master mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:41.672 # -failover-abort-no-good-slave master mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:41.725 # Next failover delay: I will not start a failover before Mon Aug 15 18:36:42 2022
      1:X 15 Aug 2022 18:34:42.770 # +sdown slave 172.18.0.4:6379 172.18.0.4 6379 @ mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:42.770 # +sdown slave 172.18.0.3:6379 172.18.0.3 6379 @ mymaster 172.18.0.2 6379
      1:X 15 Aug 2022 18:34:42.770 # +sdown sentinel 96e5e9c5536fde15a8c00265373f6503ee9d0550 172.18.0.6 5000 @ mymaster 172.18.0.2 6379
      ```