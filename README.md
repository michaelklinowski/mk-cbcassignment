# mk-cbcassignment

Michael Klinowski interview assignment for CBC AV Product team</br>

Since my expertise is more in process design and implementation (and not really in web development), I'm going to keep the scope of code creation to the functional aspect of social media platform post API calls.</br>
I will document the schemas, design choices and processes of the VCMS to implement this function.</br>
I am the sole author of everything in this assignment, no human assistance or generative AI was used. No ozone layers or oceans were harmed in the performance of this assignment.</br>


Assumptions:</br>
- The post is designed using the preexisting content-media association methodology in the CMS.</br>
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



User story:

A user creates a media post content object defining the display data and media associations of the post to be created.</br>
This object may be created from a prexisting content object to be promoted, in which case it will be prepopulated with media associations.</br>
The user may electively add or remove media object associations using the preexisting CMS functionality.</br>
In addition, body text and publication scheduling data can be input on a per-service basis.</br>





First, we must define a social media service:</br>

social media service definition schema:
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
  
  <tr>
    <td>mp_social_media_service</td>
    <td>string</td>
    <td>media processing profile to submit for creation of service specific media resources</td>
  </tr>
</table>






social media post content type schema:
<table>
<caption>content_social_media_post</caption>
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
    <td>string</td>
    <td>global unique identifier for this object</td>
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
</table>

A null value for schedule_post_<i>foo</i> indicates immediate publication.</br></br>






Upon creation of the post content type, media object type definitions will be collected for the selected services, and media object associations created within the CMS.</br>
The objects will not have a guid associated with them as the assets do not yet actually exist - associated media objects will require conversion to service-specific formats.</br>
A preexisting media processing platform function will identify unfulfilled media objects (no guid associations) and queue conversion tasks.
Completed conversions tasks will create new CMS media objects of the required type, and associate the media object guids back to the previously created media object associations.</br>


Media asset object "cmsmoj" schema:
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
    <td>media_type</td>
    <td>enum(video,image)</td>
    <td>type family of media object</td>
  </tr>

  <tr>
    <td>mobj_type</td>
    <td>mp_obj_format_name(string)</td>
    <td>name of media object type</td>
  </tr>
</table>





Example schema for an image media format type:</br>
media object processing schema:
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
    <td>jsdfj6-iasdfu7-jshdf7</td>
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
    <td>display name of object type media format definiition</td>
  </tr>

  <tr>
    <td>mp_obj_format_description</td>
    <td>new image format for X as of March</td>
    <td>display description of object type media format definiition</td>
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

