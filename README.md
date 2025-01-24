# mk-cbcassignment

<h2>Michael Klinowski interview assignment - Development Team Lead, AV Platform</h2>
</br>


<h1>Preamble:</h1>
Since my expertise is more in process design and implementation (and not really in web development), I'm going to keep the scope of code creation to the functional aspect of social media platform post API calls.</br>
I will document the schemas, design choices and processes of the VCMS to implement this function.</br>
This isn't the assignment as written, but it does represent my approach to media systems.</br>
</br>


<h1>Assumptions:</h1>

- The post is designed using the preexisting content-media association methodology in the CMS.</br>
  - I will not be creating the mechanism to assemble the post.</br>
  - I will describe a schema for social media post content types, and description of CMS procedures to support CRUD.</br>
- Media asset association will have generated any necessary child assets to all required service-specific specifications using existing media schemas and processing automations servicing the CMS.</br>
  - I will provide a populated configuration schema for these conversions</br>
- There is already an X API access level account in place for the media organization.</br>
- There is an existing task scheduling function facilitating timed processing actions (in this case, performing API publication calls).</br>
</br>


<h1>In scope:</h1>

- Social media post content object schema and fulfilled data</br>
- Service definition schema and fulfilled data</br>
- Processing schema for media fulfilment per social media service</br>
- Functional features to perform publication</br>
  - One-to-many service posting</br>
  - API call mechanism per service</br>
  - API call rendering from data object</br>
  - API call to service execution</br>
- Documentation</br>
</br>


<h1>Out of scope:</h1>

- Allow for post management after initial publication</br>
- Allow for reposting - assume content duplication mechanism within CMS for reposts</br>
- Implementation of rolling post limitations</br>
	Instagram 50 posts per 24 hour period, rolling</br>
	X 200 requests per 15 minutes, 300 requests per 3 hours</br>

</br>
</br>


<h1>Intro</h1>
Throughout this I differentiate between content and media objects.</br>
A content object is a collection of data (title, description and such information), metadata (original broadcast date, runtime and the like), and media references (links to playable video, multilangauge audio tracks, closed captioning and subtitles, poster images and other consumable elements) that make up a presentation.</br>

A media object is a reference to a consumable piece of media, and helpful metadata about that media.</br>
(In this case, I use a URI as the reference, but in circumstances where media is stored as a database element, that element would be referenced directly.)</br>

A user creates a media post content object defining the display data and media associations of the post to be created.</br>
This object may be created from a prexisting content object to be promoted, in which case it will be prepopulated with media associations.</br>
The user may electively add or remove media object associations using the preexisting CMS functionality.</br>
In addition, body text and publication scheduling data can be input on a per-service basis.</br>

The schema definition tables below are minimal, only defining the functional data. There will be other data points required to support CMS functions not listed here.</br>  
</br>

<h1>Feature setup</h1>

At the deployment and setup stage, we must define the social media services to be targetted...</br>

<h3>social media service definition schema:</h3>
<table>
  <caption>ext_service_social_media</caption>
  <colgroup>
    <col />
    <col span="5" class="name" />
    <col span="5" class="type" />
    <col span="5" class="notes" />
  </colgroup>
  <tr>
    <th scope="col">name</th>
    <th scope="col">type</th>
    <th scope="col">notes</th>
  </tr>
  <tr>
    <td>guid</td>
    <td>string</td>
    <td>global unique identifier for this object</td>
  </tr>
  <tr>
    <td>servicename</td>
    <td>string</td>
    <td>display name of social media service</td>
  </tr>
  <tr>
    <td>description</td>
    <td>string</td>
    <td>description of social media service</td>
  </tr>
  <tr>
    <td>mp_obj_format_association</td>
    <td>mp_obj_format_name(string)</td>
    <td>name of required media format object type - multiple associations are possible/expected</td>
  </tr>
  <tr>
    <td>endpoint</td>
    <td>string</td>
    <td>URL of social media service API endpoint</td>
  </tr>
  <tr>
    <td>username</td>
    <td>string</td>
    <td>account username</td>
  </tr>
  <tr>
    <td>password</td>
    <td>string</td>
    <td>account password</td>
  </tr>  
</table>

... and define required media types for each of the social media services...</br>

<h3>Media asset object "cmsmobj" schema:</h3>
<table>
<caption>cmsmobj</caption>
  <colgroup>
    <col />
    <col span="2" class="name" />
    <col span="2" class="type" />
  </colgroup>
  <tr>
    <th scope="col">name</th>
    <th scope="col">type</th>
    <th scope="col">notes</th>
  </tr>
  <tr>
    <td>guid</td>
    <td>string</td>
    <td>global unique identifier for this object</td>
  </tr>
  <tr>
    <td>status</td>
    <td>enum</br>(CREATED,PROCESSING,COMPLETE)</td>
    <td>global unique identifier for this object</td>
  </tr>
  <tr>
    <td>media_type</td>
    <td>enum(video,image)</td>
    <td>type family of media object</td>
  </tr>
  <tr>
    <td>mobj_type</td>
    <td>mp_obj_format_name(string)</td>
    <td>name of media object type</td>
  </tr>
  <tr>
    <td>URI</td>
    <td>uri</td>
    <td>URI reference to the media file</td>
  </tr>
</table>

</br>
... as well as format definitions for creation of the media formats specified by the different social media services.</br>
Here is an example schema for an image media format type:</br>

<h3>media object processing schema:</h3>
<table>
  <caption>mp_image</caption>
  <colgroup>
    <col />
    <col span="5" class="name" />
    <col span="5" class="type" />
  </colgroup>
  <tr>
    <th scope="col">name</th>
    <th scope="col">type</th>
    <th scope="col">notes</th>
  </tr>
  <tr>
    <td>guid</td>
    <td>5d77992c-5991-40a1-80df-c96db7cf5e3e</td>
    <td>global unique identifier for this object</td>
  </tr>
  <tr>
    <td>mobj_type</td>
    <td>image</td>
    <td>name of media object type</td>
  </tr>
  <tr>
    <td>mp_obj_format_name</td>
    <td>jpg_q70_800_600</td>
    <td>name of object type media format definition</td>
  </tr>
  <tr>
    <td>mp_obj_format_display name</td>
    <td>X service image 800x600 jpg</td>
    <td>display name of object type media format definition</td>
  </tr>
  <tr>
    <td>mp_obj_format_description</td>
    <td>new image format for X as of March</td>
    <td>display description of object type media format definition</td>
  </tr>
  <tr>
    <td>mp_obj_image_width</td>
    <td>800</td>
    <td>image width</td>
  </tr>
  <tr>
    <td>mp_obj_image_height</td>
    <td>600</td>
    <td>image height</td>
  </tr>
  <tr>
    <td>mp_obj_image_format</td>
    <td>jpg</td>
    <td>image format</td>
  </tr>
</table>

</br>
<h1>Feature operation</h1>
To use the feature, the operator may:

- navigate to an existing content item in the CMS, and select the "new social media post" action 
- create a new social media post content item</br>

This creates a new empty social media post object and immediately opens the edit view for the new post object.</br>
</br>

<h3>social media post content type schema:</h3>
<table>
<caption>content_social_media_post</caption>
  <colgroup>
    <col />
    <col span="5" class="name" />
    <col span="5" class="type" />
    <col span="5" class="notes" />
  </colgroup>
  <tr>
    <th scope="col">name</th>
    <th scope="col">type</th>
    <th scope="col">notes</th>
  </tr>
  <tr>
    <td>guid</td>
    <td>string</td>
    <td>global unique identifier for this object</td>
  </tr>
  <tr>
    <td>status</td>
    <td>enum</br>(CREATED,PROCESSING,</br>READY_FOR_PUBLICATION,PUBLISHED)</td>
    <td>status flags to reflect operational stages and facilitate processing workflows</td>
  </tr>
  <tr>
    <td>type</td>
    <td>cms_cobj_post</td>
    <td>name of content object type</td>
  </tr>
  <tr>
    <td>title</td>
    <td>string</td>
    <td>title for this post - will not propagate to social media service</td>
  </tr>
  <tr>
    <td>description</td>
    <td>string</td>
    <td>description of this post - will not propagate to social media service</td>
  </tr>
  <tr>
    <td></td>
    <td>string</td>
    <td>description of this post - will not propagate to social media service</td>
  </tr>
  <tr>
    <td>media_asset_association</td>
    <td>guid(string)</td>
    <td>guid of associated media asset - any number of media asset objects can be associated</td>
  </tr>
  <tr>
    <td>service_include_x</td>
    <td>boolean</td>
    <td>flag indicated intended publication to X</td>
  </tr>
  <tr>
    <td>service_include_instagram</td>
    <td>boolean</td>
    <td>flag indicated intended publication to Instagram</td>
  </tr>
  <tr>
    <td>service_include_bluesky</td>
    <td>boolean</td>
    <td>flag indicated intended publication to Bluesky</td>
  </tr>
  <tr>
    <td>text_post_x</td>
    <td>string</td>
    <td>display text of post for publication to X</td>
  </tr>
  <tr>
    <td>text_post_instagram</td>
    <td>string</td>
    <td>display text of post for publication to Instagram</td>
  </tr>
  <tr>
    <td>text_post_bluesky</td>
    <td>string</td>
    <td>display text of post for publication to Bluesky</td>
  </tr>
  <tr>
    <td>schedule_post_x</td>
    <td>datetime</td>
    <td>display title of post for publication to X</td>
  </tr>
  <tr>
    <td>schedule_post_instagram</td>
    <td>datetime</td>
    <td>display title of post for publication to Instagram</td>
  </tr>
  <tr>
    <td>schedule_post_bluesky</td>
    <td>datetime</td>
    <td>display title of post for publication to Bluesky</td>
  </tr>
  <tr>
    <td>status_post_x</td>
    <td>enum(CREATED,COMPLETE)</td>
    <td>status of publication to X</td>
  </tr>
  <tr>
    <td>status_post_instagram</td>
    <td>enum(CREATED,COMPLETE)</td>
    <td>status of publication to Instagram</td>
  </tr>
  <tr>
    <td>status_post_bluesky</td>
    <td>enum(CREATED,COMPLETE)</td>
    <td>status of publication to Bluesky</td>
  </tr>
</table>

</br>
The operator may select a "Publish" action, which updates the post object record and changes the status to "READY", or select a "Save" action, which updates any changed values in the interface without updating the staus to "READY".</br>
A null value for schedule_post_<i>foo</i> indicates immediate publication. The current datetime will be subsituted just previous to the update to the post content object.</br>
</br>

</br>
<h1>Subsequent media processing and publication workflow</h1>

- A periodic media workflow process will identify post content objects with a "CREATED" status, collect media object type definitions for the selected services, create media objects of the required format types (with a status of "CREATED"), update the post content object with associations to the created media objects, and update the post content object's status to "PROCESSING".</br>

- A second media workflow process will identify media objects with a status of "CREATED", collect the service-specific media processing definitions, update the status to "PROCESSING", and queue a batch of media processing tasks.</br>

- When the batch of media processing tasks completes, the workflow will update the media objects' status to "COMPLETE", and update the status of the post content object to "READY_FOR_PUBLICATION".</br>

- A subsequent periodic workflow process will identify post content objects with "READY_FOR_PUBLICATION" status, compile all necessary references and submit a set of tasks to a processing queue, one for each targetted social media service.</br>
Each task will have its own timestamp to support the per-service publication datetimes.</br>

- This workflow will execute the publication API calls to the selected social media services' publication API endpoints. A success response from the endpoint will update the status_post_<i>foo</i> for the social media service published to.</br>

- A final workflow periodic workflow will identify post content objects with "READY_FOR_PUBLICATION" status and all service_include_<i>foo</i> designated services' status_post_<i>foo</i> "COMPLETE" values, and update the post content object's status to "COMPLETE".</br>  
</br>

<h1>publish-api</h1>

This directory contains the script and artifacts used to demonstrate publication to Bluesky.
I have found Unix bash to be the most efficient and straightforward platform for proofs of concept and prototypes due to portability and ease of translation into the language of choice for the platform.
The posts visible in my Bluesky profile page were created with a single run of the publish-api.sh script demonstrating three modes of publication, text-only, post with image, and post with video.</br>

<h3>Script execution</h3>
This script depends on jq for json filtering.
If required, install using your Unix install's package manager (typically apt or apt-get).

A valid Bluesky user profile and password will need to be included in the .config file.

<h3>Execution</h3>
./publish_bluesky.sh 20250121_publish_bluesky.config

</br>
The publication method would be invoked by a periodic scheduler at the specified datetime. 
As long as even one social media service does not support post scheduling, handling all services' should be handled by this single in-house mechanism. This also simplifies the association of the created posts back to the content object.
</br>
</br>


<h2>Social media platform API documentation links:</h2>
</br>
https://docs.bsky.app/blog/create-post</br>
https://developers.facebook.com/docs/instagram-platform/instagram-api-with-facebook-login/content-publishing</br>
https://www.postman.com/xapidevelopers/twitter-s-public-workspace/request/cva25a0/create-a-tweet</br>
https://docs.x.com/x-api/posts/creation-of-a-post</br>
</br>
</br>