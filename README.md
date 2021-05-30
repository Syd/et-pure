# et-pure

## what is it?

et-pure is a multi-stage Dockerfile that simply downloads the official Wolfenstein: Enemy Territory installer, extracts it, adds a single static linked binary (just to return 0 and allow the build to complete).

There is no Linux distribution to keep it as small as possible.

## example usage

build a new image from the latest weekly etlegacy build and copy pak0.pk3 from et-pure

```Dockerfile
FROM etlegacy/server:weekly as game
COPY --from=sydz/et-pure /et/etmain/pak0.pk3 /legacy/server/etmain/
```

```bash
$ docker build --compress --tag legacy:weekly .
$ docker run -it  -p 27960:27960/udp -d legacy:weekly
```
