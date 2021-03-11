#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PREVIOUS_CONTAINERS=$(
	docker ps -a | \
	rev | \
	cut -f1 -d " " | \
	rev | \
	grep -E "node-watcher|auth-server|hasura|chain-db-watcher|front-end" | \
	xargs
)

# clean previously created containers
if [[ $PREVIOUS_CONTAINERS != "" ]]; then
	printf "\n-- killing docker containers [node-watcher,auth-server,hasura,chain-db-watcher,front-end]\n"
	docker kill $PREVIOUS_CONTAINERS &> /dev/null && echo "OK" || (echo "Containers not running" && exit 1)

	printf "\n-- deleting docker containers [node-watcher,auth-server,hasura,chain-db-watcher,front-end]\n"
	docker rm $PREVIOUS_CONTAINERS &> /dev/null && echo "OK" || (echo "Containers not created" && exit 1)

	printf "\n-- Cleaned, want to launch? "
	read;

	printf "Launching...\n"
fi

### NODE WATCHER ###
echo "Launch node-watcher..."
echo "-------------------------------------"
cd $DIR/node-watcher && docker-compose up -d

docker logs node-watcher_scraper_1 -f &
sleep 20 && kill $(jobs -p | grep '[1]' | cut -d ' ' -f4) &> /dev/null
echo


### AUTH SERVER ###
echo "Launch auth-server..."
echo "-------------------------------------"
cd $DIR/auth-server && docker-compose up -d

docker logs auth-server_auth-server_1 -f &
sleep 10 && kill $(jobs -p | grep '[1]' | cut -d ' ' -f4) &> /dev/null
echo


### HASURA ###
echo "Launch hasura..."
echo "-------------------------------------"
cd $DIR/hasura && docker-compose up -d

docker logs hasura_hasura-migrations_1 -f &
sleep 15 && kill $(jobs -p | grep '[1]' | cut -d ' ' -f4) &> /dev/null
echo


### FRONT END ###
echo "Launch front-end..."
echo "-------------------------------------"
cd $DIR/front-end && docker-compose up -d

docker logs front-end_react-app_1 -f &
sleep 50 && kill $(jobs -p | grep '[1]' | cut -d ' ' -f4) &> /dev/null
echo


echo 'Create user "bot" with password "proposal_bot_password" on front-end. Then, press ENTER to continue with this script...'
read;


### CHAIN DB WATCHER ###
echo "Launch chain-db-watcher..."
echo "-------------------------------------"
cd $DIR/chain-db-watcher && docker-compose up -d

docker logs chain-db-watcher_db-watcher_1 -f &
sleep 30 && kill $(jobs -p | grep '[1]' | cut -d ' ' -f4) &> /dev/null
echo

