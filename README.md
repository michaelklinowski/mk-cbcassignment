# mk-cbcassignment



Michael Klinowski interview assignement for CBC AV Product team

Assignment



Assumptions:

The post is designed using the existing content-media association methodology in the CMS, and therefore I will not be creating the mechanism to assemble the post.

A schema for social media post content types will be created and CMS code to support CRUD will be implemented. I will describe such a content object but not define it. Only external platform publication interface and mechanisms will be in scope.

Media asset association will have generated any necessary child assets to all required service-specific specifications using existing media processing automations servicing the CMS. (I will provide a populated configuration schema for these conversions)

There is already an X API access level account in place for the media organization.


Will get made:

Service definition schema and fulfilled data
Mock CMS screens
Functional features to perform publication
API call mechanism per service
Defanged API call execution
Successful post action creates unique media asset for external post
Logging
Documentation


Shall not:
Allow for post management after initial publication
Allow for reposting - assume content duplication mechanism within CMS for reposts
Account for rolling post limitations
	Instagram 50 posts per 24 hour period, rolling
	X 200 requests per 15 minutes, 300 requests per 3 hours


Core functionality:
One-to-many service posting
{
API call rendering from data object
API call to post to service
}
Service definition schema

https://docs.bsky.app/blog/create-post
https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/content-publishing
https://www.postman.com/xapidevelopers/twitter-s-public-workspace/request/cva25a0/create-a-tweet
https://docs.x.com/x-api/posts/creation-of-a-post





Scaffolding to do:
Git project
Deployment plan
CICD plan
CMS mockup


Nice to have, document if it can’t get done:

Input media asset requirement checking (Instagram needs an image or video)











