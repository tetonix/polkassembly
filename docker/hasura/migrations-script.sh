#/bin/bash

# echo 'Environment'
# echo "HASURA_PROJECT:       $HASURA_PROJECT"
# echo "HASURA_ADMIN_SECRET:  $HASURA_ADMIN_SECRET"
# echo

echo 'Wait for GraphQL-Engine...' 
sleep 10


echo 'Executing migrations...' 
hasura migrate apply \
    --skip-update-check \
    --project $HASURA_PROJECT \
    --admin-secret $HASURA_ADMIN_SECRET

echo 'Applying metadata...' 
hasura metadata apply \
    --skip-update-check \
    --project $HASURA_PROJECT \
    --admin-secret $HASURA_ADMIN_SECRET

echo 'Inserting initial data...'
curl -sL \
    -H "Content-Type: application/json" \
    -H "X-Hasura-Role: admin" \
    -H "X-Hasura-Admin-Secret: $HASURA_ADMIN_SECRET" \
    -d "{
        \"type\": \"run_sql\",
        \"args\": { 
            \"sql\": \"
                insert into post_topics values  (1, 'Democracy');
                insert into post_topics values  (2, 'Council');
                insert into post_topics values  (3, 'Technical Committee');
                insert into post_topics values  (4, 'Treasury');
                insert into post_topics values  (5, 'General');

                insert into post_types values (1, 'Discussion');
                insert into post_types values (2, 'On chain');

                create index \\\"posts_topic_id_index\\\" on \\\"posts\\\" (\\\"topic_id\\\");
                create index \\\"posts_type_id_index\\\" on \\\"posts\\\" (\\\"type_id\\\");
                create index \\\"comments_post_id_index\\\" on \\\"comments\\\" (\\\"post_id\\\");
                create index \\\"onchain_links_post_id_index\\\" on \\\"onchain_links\\\" (\\\"post_id\\\");
            \" 
        }
    }" localhost:8080/v1/query

echo
echo 'Finished! :D'