Standalone vcv-rack built from source to run in a docker container with VNC-enabled access or with local X server.

With local X server:

1. docker-compose build vcv
2. docker-compose build rack
3. ln -sf /path/to/repo/run_rack $HOME/bin # or whatever directory on the PATH
4. run_rack # without arguments

With VNC

1. docker-compose build vcv
2. docker-compose build vcv-server
3. docker-compose up vcv-server
4. vncviewer localhost:1 # from another terminal, or run the server quietly
