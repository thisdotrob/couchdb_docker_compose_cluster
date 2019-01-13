```
docker run -it \
           -v bootstrap.sh:/bootstrap.sh \
           alpine:3.8 \
           apk add --no-cache curl && ./bootstrap.sh
```
