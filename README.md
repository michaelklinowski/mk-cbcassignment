# mk-cbcassignment


# mk-cbcassignment

Michael Klinowski interview assignment for CBC AV Product team</br>

Since my expertise is more in process design and implementation (and not really in web development), I'm going to keep the scope of code creation to the functional aspect of social media platform post API calls.</br>
I will document the schemas, design choices and processes of the VCMS to implement this function.</br>
I am the sole author of everything in this assignment, no human assistance or generative AI was used. No ozone layers or oceans were harmed in the performance of this assignment.</br>


Assumptions:</br>
- The post is designed using the preexisting content-media association methodology in the CMS.
  - I will not be creating the mechanism to assemble the post.</br>
  - I will describe a schema for social media post content types, and description of CMS code to support CRUD.</br>
- Media asset association will have generated any necessary child assets to all required service-specific specifications using existing media schemas and processing automations servicing the CMS.</br>
  - I will provide a populated configuration schema for these conversions</br>
- There is already an X API access level account in place for the media organization.</br>


In scope:</br>
- Social media post content object schema and fulfilled data</br>
- Service definition schema and fulfilled data</br>
- Processing schema for media fulfilment per social media service</br>
- Mock CMS screens</br>
- Functional features to perform publication</br>
  - One-to-many service posting</br>
  - API call mechanism per service</br>
  - API call rendering from data object</br>
  - Defanged API call to service execution</br>
- Successful post action creates unique media asset for external post</br>
- Documentation</br>


Nice to haves:</br>
- Logging</br>
- Input media asset requirement checking (e.g. Instagram needs an image or video)</br>


Out of scope:</br>
- Allow for post management after initial publication</br>
- Allow for reposting - assume content duplication mechanism within CMS for reposts</br>
- Implementation of rolling post limitations</br>
	Instagram 50 posts per 24 hour period, rolling</br>
	X 200 requests per 15 minutes, 300 requests per 3 hours</br>


Social media platform API documentation links:</br>
https://docs.bsky.app/blog/create-post</br>
https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/content-publishing</br>
https://www.postman.com/xapidevelopers/twitter-s-public-workspace/request/cva25a0/create-a-tweet</br>
https://docs.x.com/x-api/posts/creation-of-a-post</br>


Additional documentation:</br>
- Deployment plan</br>
- CICD plan</br>



