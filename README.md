# docker-chia

Docker for [chia-blockchain](https://github.com/Chia-Network/chia-blockchain/)

## docker-compose.yml example

```yaml
version: '3.7'

services:
  chia:
    container_name: chia
    image: ghtsto/chia:latest
    ports:
      - "8444:8444"
    volumes:
      - config:/root/.chia/
      - blockchain:/root/.chia/mainnet/db/
      - keychain:/root/.local/share/python_keyring/
      - wallet:/root/.chia/mainnet/wallet/db/
      # - ./ca:/remote-ca:ro
      # - ./plots:/plots/store1:ro
      # - ./seed.key:/seed.key:ro
    environment:
      - TZ=America/Vancouver
      - FULL_NODE=true
      - FARMER=true
      - HARVESTER=true
      - WALLET=true
      - LOG_LEVEL=INFO
      - REMOTE_HARVESTER=false
      - REMOTE_FARMER_IP=${REMOTE_FARMER_IP}
      - REMOTE_FARMER_PORT=8447

networks:
  default:
    external:
      name: chia

volumes:
  config:
  blockchain:
  keychain:
  wallet:
```
## Volumes, mounts and environment variables
Copy and rename .env.example to .env and update ```COMPOSE_PROJECT_NAME``` (default: chia). If you plan on using this as a remote harvester, update the ```REMOTE_FARMER_IP```.

### Volumes
The idea behind structuring the volumes in this way is that the config data can easily be preserved between container destruction and give some flexibility when wanting to delete/recreate volumes.
| Volumes  | Description |
|---|---|
| ```config```  | config file, logs, certs |
| ```blockchain```  | blockchain db data |
| ```keychain```  | chia keys saved to python keyring |
| ```wallet```  | wallet db data |

### Mounts
Mounts can be mounted as read-only (eg. `/plots/:/plots/store1:ro`). If you plan on creating plots with the container, the destination plot directory must be writable. All host mounts are optional.
| Mounts  | Description  |
|---|---|
| ```/remote-ca```  | mounted host directory containing farmer CA files |
| ```/plots/plot1```  | when farming, the container scans for /plot subdirectory host mounts and adds those to chia config |
| ```/seed.key```  | use an existing seed phrase, will be ignored if keys already generated in container |

### Environment variables
Using the default values, the container will start chia as if the `chia start farmer` command was used
| ENV  | Description  | Default  |
|---|---|---|
| ```TZ```  | timezone | America/Vancouver  |
| ```FULL_NODE```  | start full node  | true  |
| ```FARMER```  | start farmer (only)  | true  |
| ```HARVESTER```  | start harvester  | true  |
| ```WALLET```  | start wallet (only)  | true  |
| ```LOG_LEVEL```  | sets the chia log level  | INFO  |
| ```REMOTE_HARVESTER```  | start remote harvester  | false  |
| ```REMOTE_FARMER_IP```  | the remote farmer IP your harvester will use  | null  |
| ```REMOTE_FARMER_PORT```  | the remote farmer port your harvester will use  | 8447  |


## Commands
Run `chia` commands
```bash
docker-compose exec <container_name> chia <options>

Examples:

docker-compose exec chia chia show -s
docker-compose exec chia chia farm summary
docker-compose exec chia chia plots create -k 25 --override-k -d /plots/store1
```
Check chia logs. Using -f will follow the log file output
```bash
docker-compose exec <container_name> logs [-f]

Example:

docker-compose exec chia logs -f
```