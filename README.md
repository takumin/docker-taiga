# docker-taiga

[Taiga.io](https://taiga.io/)

# First step

Please install docker ;-)

```
$ make up migrate initialize
```

# Backup

Stop the currently running container and back it up.

Also, backups older than 30 days will be deleted.

```
$ make backup
```

# Recovery

Recover from the last backup.

```
$ make recovery
```
