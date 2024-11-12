# Docker

## Change image tag

```bash
docker pull <img-url>:<version>
docker image tag <img-url>:<version> <new-repo>/<private-registry>:<version>
docker push <new-repo>/<private-registry>:<version>
```

## Create a entrypoint.sh that can run something after receiving a "stop" signal

```Dockerfile
# Dockerfile
FROM nginx

COPY entrypoint.sh .

ENTRYPOINT ["./entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
```

```shell
# entrypoint.sh

#!/bin/bash

log() {
  echo "[entrypoint.sh] $1"
}

# Define the curl command to run before stopping the container
on_exit() {
  log "Running on exit..."

  log "Gracefully shutting down CMD..."
  kill -QUIT "$CMD_PID"

  log "Running pre-stop curl"
}

trap 'on_exit' QUIT TERM INT

log "Running CMD on background"
"$@" &
CMD_PID=$!

# Wait for cmd to finish or a termination signal
wait "$CMD_PID"
EXIT_STATUS=$?

log "CMD process has stopped with status $EXIT_STATUS"

exit $EXIT_STATUS
```
