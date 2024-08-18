#!/bin/sh

until curl -u elastic:$ELASTIC_PASSWORD -k --silent --head --fail http://elasticsearch:9200; do
  echo "Waiting for Elasticsearch..."
  sleep 5
done

response=$(curl -X POST -u elastic:$ELASTIC_PASSWORD -H "Content-Type: application/json" -d "
{
  \"password\": \"$KIBANA_SYSTEM_PASSWORD\"
}" -s -w "\n%{http_code}" http://elasticsearch:9200/_security/user/kibana_system/_password)

body=$(echo "$response" | sed '$ d')
status_code=$(echo "$response" | tail -n1)

if [ "$status_code" -eq 200 ]; then
  echo "Password for kibana_system user changed successfully."
else
  echo "Failed to change password for kibana_system user. HTTP status code: $status_code"
  echo "Response body:"
  echo "$body"
fi
