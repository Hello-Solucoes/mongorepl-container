#!/bin/bash

mkdir /data/db/repl1
mkdir /data/db/repl2

/usr/bin/mongod --bind_ip_all --port 27017 --replSet ${RS} --dbpath=/data/db/repl1 &
/usr/bin/mongod --bind_ip_all --port 27018 --replSet ${RS} --dbpath=/data/db/repl2 &

echo "Waiting for startup.."

until mongo --host 127.0.0.1:27017 --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
      printf '.'
        sleep 1
    done

    echo "Started.."

    echo setup.sh time now: `date +"%T" `
    mongo --host 127.0.0.1:27017 <<EOF
    var cfg = {
        "_id": "${RS}",
        "protocolVersion": 1,
        "members": [
            {
                "_id": 0,
                "host": "${HOSTNAME}:27017",
            },
            {
                "_id": 1,
                "host": "${HOSTNAME}:27018",
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
EOF

echo "ReplicaSet configured, tailing log"

tail -f /dev/null
