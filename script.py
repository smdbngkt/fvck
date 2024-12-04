import json
import os
import sys
from eth_account import Account

def generate_wallet():
    account = Account.create()
    return {
        "address": account.address,
        "private_key": '0x' + account._private_key.hex()
    }

def generate_wallets(count):
    return [generate_wallet() for _ in range(count)]

def save_wallets_to_json(wallets):
    with open("wallets.json", "w") as json_file:
        json.dump(wallets, json_file, indent=4)
    print("Generated wallets saved to wallets.json")

def create_typesense_compose():
    typesense_api_key = 'inTheBestDkNodes'
    admin_password = 'DkNodes'
    docker_compose_template = f"""
services:
  typesense:
    image: typesense/typesense:26.0
    container_name: typesense
    ports:
      - "8108:8108"
    environment:
      TYPESENSE_API_KEY: '{typesense_api_key}'
      ADMIN_PASSWORD: '{admin_password}'
    networks:
      - ocean_network
    volumes:
      - typesense-data:/data
    command: '--data-dir /data --api-key={typesense_api_key} --enable-authentication=true --admin-password={admin_password}'
volumes:
  typesense-data:
    driver: local

networks:
  ocean_network:
    external: true
"""
    save_docker_compose_file(docker_compose_template, 1)
    print("Generated docker-compose1.yaml for typesense")

rpcs = {
    "10": {
        "rpc": "https://optimism-mainnet.infura.io/v3/475b4727c26b449d86cf2faa155737da",
        "fallbackRPCs": [
            "https://optimism-mainnet.infura.io/v3/0dbeb1e332314119ba197a6edde4f860",
            "https://opt-mainnet.g.alchemy.com/v2/rDwBqKe2Zy38AF5b-GB2Y5bfH7wspLM5",
            "https://optimism-mainnet-archive.rpc.l0vd.com/tuqlaKMJP3IvI3kTZ6caWMcK"
        ],
        "chainId": 10,
        "network": "optimism",
        "chunkSize": 100
    }
}

rpcs_json = json.dumps(rpcs)

def create_ocean_node_compose(wallet, i, ip_address):
    http_api_port = 2002 + i
    p2p_tcp_port = 3002 + i
    p2p_ws_port = 4002 + i
    docker_compose_template = f"""
services:
  ocean-node{i}:
    image: oceanprotocol/ocean-node:latest
    pull_policy: always
    container_name: ocean-node-{i}
    restart: on-failure
    ports:
      - "{2002 + i}:{2002 + i}"
      - "{3002 + i}:{3002 + i}"
      - "{4002 + i}:{4002 + i}"
      - "{5002 + i}:{5002 + i}"
      - "{6002 + i}:{6002 + i}"
    environment:
      PRIVATE_KEY: '{wallet['private_key']}'
      RPCS: '{rpcs_json}'
      DB_URL: 'http://typesense:8108/?apiKey=inTheBestDkNodes'
      IPFS_GATEWAY: 'https://ipfs.io/'
      ARWEAVE_GATEWAY: 'https://arweave.net/'
      INTERFACES: '["HTTP","P2P"]'
      ALLOWED_ADMINS: '["{wallet['address']}"]'
      HTTP_API_PORT: '{http_api_port}'
      P2P_ENABLE_IPV4: 'true'
      P2P_ipV4BindAddress: '0.0.0.0'
      P2P_ipV4BindTcpPort: '{p2p_tcp_port}'
      P2P_ipV4BindWsPort: '{p2p_ws_port}'
      P2P_ANNOUNCE_ADDRESSES: '["/ip4/{ip_address}/tcp/{p2p_tcp_port}", "/ip4/{ip_address}/ws/tcp/{p2p_ws_port}"]'
    networks:
      - ocean_network

networks:
  ocean_network:
    external: true
"""
    save_docker_compose_file(docker_compose_template, i + 1)
    print(f"Generated docker-compose{i + 1}.yaml for ocean-node-{i}")

def save_docker_compose_file(content, i):
    filename = f'docker-compose{i}.yaml'
    with open(filename, 'w') as file:
        file.write(content)

def main():
    if len(sys.argv) != 3:
        print("Usage: python3 script.py <IP_ADDRESS> <NUM_NODES>")
        sys.exit(1)

    ip_address = sys.argv[1]
    num_files = int(sys.argv[2])

    wallets = generate_wallets(num_files)
    save_wallets_to_json(wallets)
    create_typesense_compose()

    for i, wallet in enumerate(wallets, start=1):
        create_ocean_node_compose(wallet, i, ip_address)

if __name__ == "__main__":
    main()
