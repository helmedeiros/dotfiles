#!/bin/sh
#
#!/bin/sh
if test ! $(pgrep -f "Docker.app" | head -1)
then
 open /Applications/Docker.app
 docker --version
 docker compose version
fi
