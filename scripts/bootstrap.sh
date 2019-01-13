echo Now, bind the clustered interface to all IP addresses availble on this machine:
curl -X PUT http://couchdb0.docker.com:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'
curl -X PUT http://couchdb1.docker.com:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'
curl -X PUT http://couchdb2.docker.com:5984/_node/_local/_config/chttpd/bind_address -d '"0.0.0.0"'

echo Set the UUID of the node to the first UUID you previously obtained:
curl -X PUT http://couchdb0.docker.com:5984/_node/_local/_config/couchdb/uuid -d '"d8702bee1e72f1517b27ee0da3000608"'
curl -X PUT http://couchdb1.docker.com:5984/_node/_local/_config/couchdb/uuid -d '"d8702bee1e72f1517b27ee0da3000608"'
curl -X PUT http://couchdb2.docker.com:5984/_node/_local/_config/couchdb/uuid -d '"d8702bee1e72f1517b27ee0da3000608"'

echo Finally, set the shared http secret for cookie creation to the second UUID:
curl -X PUT http://couchdb0.docker.com:5984/_node/_local/_config/couch_httpd_auth/secret -d '"d8702bee1e72f1517b27ee0da30011c3"'
curl -X PUT http://couchdb1.docker.com:5984/_node/_local/_config/couch_httpd_auth/secret -d '"d8702bee1e72f1517b27ee0da30011c3"'
curl -X PUT http://couchdb2.docker.com:5984/_node/_local/_config/couch_httpd_auth/secret -d '"d8702bee1e72f1517b27ee0da30011c3"'

echo Create the admin user and password:
curl -X PUT http://couchdb0.docker.com:5984/_node/_local/_config/admins/admin -d '"password"'
curl -X PUT http://couchdb1.docker.com:5984/_node/_local/_config/admins/admin -d '"password"'
curl -X PUT http://couchdb2.docker.com:5984/_node/_local/_config/admins/admin -d '"password"'

# Commented out because these commands returned {"error":"bad_request","reason":"Cluster is already enabled"}
#echo Set up each node for cluster:
#curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup \
#        -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "node_count":"3"}'
#curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb1.docker.com:5984/_cluster_setup \
#        -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "node_count":"3"}'
#curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb2.docker.com:5984/_cluster_setup \
#        -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "node_count":"3"}'

echo Use setup coordination node to join the nodes:
curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup \
        -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "port": 5984, "node_count": "3", "remote_node": "couchdb1.docker.com", "remote_current_user": "admin", "remote_current_password": "password" }'
curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup \
        -d '{"action": "add_node", "host":"couchdb1.docker.com", "port": 5984, "username": "admin", "password":"password"}'
curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup \
        -d '{"action": "enable_cluster", "bind_address":"0.0.0.0", "username": "admin", "password":"password", "port": 5984, "node_count": "3", "remote_node": "couchdb2.docker.com", "remote_current_user": "admin", "remote_current_password": "password" }'
curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup \
        -d '{"action": "add_node", "host":"couchdb2.docker.com", "port": 5984, "username": "admin", "password":"password"}'

echo Finish cluster setup and add system databases:
curl -X POST -H "Content-Type: application/json" http://admin:password@couchdb0.docker.com:5984/_cluster_setup -d '{"action": "finish_cluster"}'

echo Verify install:
curl http://admin:password@couchdb0.docker.com:5984/_cluster_setup

echo Verify all cluster nodes are connected:
curl http://admin:password@couchdb0.docker.com:5984/_membership
