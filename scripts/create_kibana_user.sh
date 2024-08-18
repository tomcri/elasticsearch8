#!/bin/bash

until curl -u elastic:${ELASTIC_PASSWORD} -s "http://elasticsearch:9200/_cluster/health?wait_for_status=yellow&timeout=50s"; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

USER_EXISTS=$(curl -u elastic:${ELASTIC_PASSWORD} -s -o /dev/null -w "%{http_code}" "http://elasticsearch:9200/_security/user/${ELASTICSEARCH_USERNAME}")

if [ "$USER_EXISTS" -eq 200 ]; then
  echo "Kibana user already exists"
else
  curl -u elastic:${ELASTIC_PASSWORD} -X POST "http://elasticsearch:9200/_security/user/${ELASTICSEARCH_USERNAME}" -H "Content-Type: application/json" -d'
  {
    "password" : "'"${ELASTICSEARCH_PASSWORD}"'",
    "roles" : [ "kibana_user" ],
    "full_name" : "Kibana User"
  }'
  echo "Kibana user created"
fi
