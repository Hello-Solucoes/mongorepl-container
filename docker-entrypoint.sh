#!/bin/bash

/usr/bin/mongod --bind_ip_all --port ${PORT} --replSet ${RS} &

echo "Waiting for startup.."
until mongo --host 127.0.0.1:${PORT} --eval 'quit(db.runCommand({ ping: 1 }).ok ? 0 : 2)' &>/dev/null; do
      printf '.'
        sleep 1
    done

    echo "Started.."

    echo setup.sh time now: `date +"%T" `
    mongo --host 127.0.0.1:${PORT} <<EOF
    var cfg = {
        "_id": "${RS}",
        "protocolVersion": 1,
        "members": [
            {
                "_id": 0,
                "host": "${REPL1}:${PORT}",
            }
        ]
    };
    rs.initiate(cfg, { force: true });
    rs.reconfig(cfg, { force: true });
EOF

echo "ReplicaSet configured, tailing log"

tail -f /dev/null
