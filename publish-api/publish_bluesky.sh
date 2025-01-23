#!/bin/bash

# accept the publication task parameters
# in a production system this would likely receive this data via API or directly from a query
# for simpliciy in this proof of concept the necessary data is simply read from a file

eval "$(cat "$1")"


# create session
session_response=$(curl -s -X POST \
-H 'Content-Type: application/json' \
-d "{ \"identifier\": \"${bluesky_user}\", \"password\": \"${bluesky_password}\" }" \
"${bluesky_session_endpoint}" | jq .)

# a session access token nominally lasts a few minutes which is more than enough to complete these API calls
# Bluesky session rate limits are currently 10 session per 24 hours
# in production, the this function should retrieve the current session definition, check that it is still in effect and renew the session with the refreshJwt token
# sessions should probably be maintained by a separate service which ensures there is always a valid session and makes the current session data available to publication tasks


# sample session response

# session_response='{ \
#   "did": "did:plc:p7ya5vaqejb3h4zhyipp5gpd",\
#   "didDoc": {\
#     "@context": [\
#       "https://www.w3.org/ns/did/v1",\
#       "https://w3id.org/security/multikey/v1",\
#       "https://w3id.org/security/suites/secp256k1-2019/v1"\
#     ],\
#     "id": "did:plc:p7ya5vaqejb3h4zhyipp5gpd",\
#     "alsoKnownAs": [\
#       "at://letsrockyeeaaahhhh.bsky.social"\
#     ],\
#     "verificationMethod": [\
#       {\
#         "id": "did:plc:p7ya5vaqejb3h4zhyipp5gpd#atproto",\
#         "type": "Multikey",\
#         "controller": "did:plc:p7ya5vaqejb3h4zhyipp5gpd",\
#         "publicKeyMultibase": "zQ3shmdXckaGGqaLfSx8bxTZdvRGLyn51EjeM3dExVxNQiEuf"\
#       }\
#     ],\
#     "service": [\
#       {\
#         "id": "#atproto_pds",\
#         "type": "AtprotoPersonalDataServer",\
#         "serviceEndpoint": "https://truffle.us-east.host.bsky.network"\
#       }\
#     ]\
#   },\
#   "handle": "letsrockyeeaaahhhh.bsky.social",\
#   "email": "warbler-speck.0g@icloud.com",\
#   "emailConfirmed": true,\
#   "emailAuthFactor": false,\
#   "accessJwt": "eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJFUzI1NksifQ.eyJzY29wZSI6ImNvbS5hdHByb3RvLmFjY2VzcyIsInN1YiI6ImRpZDpwbGM6cDd5YTV2YXFlamIzaDR6aHlpcHA1Z3BkIiwiaWF0IjoxNzM3NjAyNDMyLCJleHAiOjE3Mzc2MDk2MzIsImF1ZCI6ImRpZDp3ZWI6dHJ1ZmZsZS51cy1lYXN0Lmhvc3QuYnNreS5uZXR3b3JrIn0.yHQYmwazLJ-Bmumzdjk0We57ZOgLLngoWcj9sekGAzlBWAK_fHpvNWbbdaa0wKXcDuGS4Ye8Q92OMHeSPEvSCw",\
#   "refreshJwt": "eyJ0eXAiOiJyZWZyZXNoK2p3dCIsImFsZyI6IkVTMjU2SyJ9.eyJzY29wZSI6ImNvbS5hdHByb3RvLnJlZnJlc2giLCJzdWIiOiJkaWQ6cGxjOnA3eWE1dmFxZWpiM2g0emh5aXBwNWdwZCIsImF1ZCI6ImRpZDp3ZWI6YnNreS5zb2NpYWwiLCJqdGkiOiJVZm1yV1dXREo2UlRGZDFzUmlhelVyOGk1M3BQN0NVem1md0RiNnhZQjdJIiwiaWF0IjoxNzM3NjAyNDMyLCJleHAiOjE3NDUzNzg0MzJ9._pt9QD37XmnTfL_gaQtgYHU8IMK0NlS9j68ejdLeCxNVJrxci-Au5J9dN3368f3aYPepaFbbnwqB54mdnAEm8A",\
#   "active": true\
# }'


currentjwt=$(echo ${session_response} | jq .accessJwt)
currentjwt=$(echo ${currentjwt//\"/})
# echo ${currentjwt}

# optionally maintain the current access token to avoid exceeding the session rate limit

#currentjwt="eyJ0eXAiOiJhdCtqd3QiLCJhbGciOiJFUzI1NksifQ.eyJzY29wZSI6ImNvbS5hdHByb3RvLmFjY2VzcyIsInN1YiI6ImRpZDpwbGM6cDd5YTV2YXFlamIzaDR6aHlpcHA1Z3BkIiwiaWF0IjoxNzM3NjAyNDMyLCJleHAiOjE3Mzc2MDk2MzIsImF1ZCI6ImRpZDp3ZWI6dHJ1ZmZsZS51cy1lYXN0Lmhvc3QuYnNreS5uZXR3b3JrIn0.yHQYmwazLJ-Bmumzdjk0We57ZOgLLngoWcj9sekGAzlBWAK_fHpvNWbbdaa0wKXcDuGS4Ye8Q92OMHeSPEvSCw"

# set the current datetime inteh correct format
currentdate=$(echo $(date --iso-8601=seconds ))





# post text only
text_post_response=$(curl -s -X POST \
-H 'Content-Type: application/json' \
-H "Authorization: Bearer ${currentjwt}" \
-d "{ \"collection\": \"app.bsky.feed.post\", \"repo\": \"${bluesky_user}\", \"record\": { \"text\": \"${bluesky_post_text}\", \"createdAt\": \"${currentdate}\", \"\$type\": \"app.bsky.feed.post\" } }" \
https://bsky.social/xrpc/com.atproto.repo.createRecord )





# post with image
# upload image as blob
image_blob_response=$(curl -s -X POST -H 'Content-Type: image/jpeg' -H "Authorization: Bearer ${currentjwt}" -T "${bluesky_image}" https://bsky.social/xrpc/com.atproto.repo.uploadBlob)

#imageblobresponse='{"blob":{"$type":"blob","ref":{"$link":"bafkreieqsru5k6czxnc5jblkontvuea4ztjzuyu5vvhfjalg77blf63yau"},"mimeType":"image/jpeg","size":1524613}}'

image_blob=$(echo ${image_blob_response} | jq '.blob.ref."$link"')
image_blob=$(echo ${image_blob//\"/})
#echo ${image_blob}

image_mimeType=$(echo ${image_blob_response} | jq .blob.mimeType)
image_mimeType=$(echo ${image_mimeType//\"/})
#echo ${image_mimeType}

image_size=$(echo ${image_blob_response} | jq .blob.size)
image_size=$(echo ${image_size//\"/})
#echo ${image_size}


# create post with image referencing blob
# Bluesky seems to overwrite posts if submitted with identical datetimes, so reset the datetime for subsequent API posts
currentdate=$(echo $(date --iso-8601=seconds ))

image_post_response=$(curl -s -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${currentjwt}" -d "{ \"collection\": \"app.bsky.feed.post\", \"repo\": \"${bluesky_user}\", \"record\": { \"text\": \"${bluesky_image_text}\", \"createdAt\": \"${currentdate}\", \"\$type\": \"app.bsky.feed.post\", \"embed\": { \"\$type\": \"app.bsky.embed.images\", \"images\": [ { \"alt\": \"${bluesky_image_alt_text}\", \"image\": { \"\$type\": \"blob\", \"ref\": { \"\$link\": \"${image_blob}\" }, \"mimeType\": \"${image_mimeType}\", \"size\": ${image_size} } } ] } } }" https://bsky.social/xrpc/com.atproto.repo.createRecord)





# post with video
# post video blob
videoblobresponse=$(curl -s -X POST -H 'Content-Type: video/mp4' -H "Authorization: Bearer ${currentjwt}" -T "${bluesky_video}" https://bsky.social/xrpc/com.atproto.repo.uploadBlob)

#videoblobresponse='{"blob":{"$type":"blob","ref":{"$link":"bafkreia2w6gsibnbsvuolqgnvpacnopmy5rojhzgunjzorhh2bpcbghyba"},"mimeType":"video/mp4","size":10925322}}'

video_blob=$(echo ${videoblobresponse} | jq '.blob.ref."$link"')
video_blob=$(echo ${video_blob//\"/})
#echo ${video_blob}

video_mimeType=$(echo ${videoblobresponse} | jq .blob.mimeType)
video_mimeType=$(echo ${video_mimeType//\"/})
#echo ${video_mimeType}

video_size=$(echo ${videoblobresponse} | jq .blob.size)
video_size=$(echo ${video_size//\"/})
#echo ${video_size}


# create post with video referencing blob
currentdate=$(echo $(date --iso-8601=seconds ))

video_post_response=$(curl -s -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer ${currentjwt}" -d "{ \"collection\": \"app.bsky.feed.post\", \"repo\": \"${bluesky_user}\", \"record\": { \"text\": \"${bluesky_video_text}\", \"createdAt\": \"${currentdate}\", \"\$type\": \"app.bsky.feed.post\", \"embed\": { \"\$type\": \"app.bsky.embed.video\", \"alt\": \"${bluesky_video_alt_text}\", \"video\": { \"\$type\": \"blob\", \"ref\": { \"\$link\": \"${video_blob}\" }, \"mimeType\": \"${video_mimeType}\", \"size\": ${video_size} } } } }" https://bsky.social/xrpc/com.atproto.repo.createRecord)

exit 0