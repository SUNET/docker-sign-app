# Upload and sign application versions

**Latest Current version: 1.1.0**

Version | Comment | Date
---|---|---
1.0.0 | Initial release | 2020-04-24
1.0.1 | Updated integration API to release version 1.1.0 | 2020-04-28
1.0.2 | Redirect from root to open/login | 2020-04-29
1.0.3 | Capability to customize login button   | 2020-04-29
1.0.4 | UI update to eduSign style. Improved error page and login page | 2020-04-29
1.0.5 | UI update | 2020-04-30
1.0.6 | Configurable html title | 2020-05-02
1.0.7 | Relaxed check for valid values in SAML attributes to handle complex attriubtes | 2020-05-02
1.0.8 | Updated attribute parsing | 2020-05-18
1.0.9 | Removes any presence of "," sign in file names in downloaded files. | 2020-06-10
1.0.10 | Added check that previously signed PDF files are signed using eduSign. | 2020-06-17
1.0.11 | Added config capability to list compatible pre-sign services. | 2020-06-17
1.0.12 | Fixed hardwired requested LoA. | 2020-10-21
1.0.13 | Added extra logging. | 2020-10-22
1.1.0  | Upload attempt when loginsession expirted now causes configurable alert and redirect to login page  | 2021-03-09

## Important Release Notes

## 1.1.0

This version make use of the updated properties structure as demonstrated in the `application.properties` file in the upload-sign-sp sample configuration folder.

To migrate from earlier releases of this application, the `application.properties` file mut be updated according to the following steps:

### Step 1 - Add new properties

#### Session expired alert
This version includes new configuration option for alert message to be shown if an upload is attempted when the loginsession has expired.

Default configuration is:

```
`sigsp.config.session-expired-alert`=Du har blivit utloggad p\u00e5 grund av inaktivitet
```

Setting this parameter to an emtpy string, then user is redirected without showing any alert.

#### Optional REST sign support configruation
There are new properties settings to connect to a REST sign support service. By default this support is set to false. See section 2.1 in README.md for more information

Example settings:

```
# REST client configuration
signservice.rest.enabled=false
signservice.rest.server-url=https://sig.sunet.se/signint
signservice.rest.client-username=upload-app
signservice.rest.client-password=change-me

```
**Note**: For this update, make sure that `signservice.rest.enabled`, if included, is set to **false**.


#### Declare sign message support settings
A new property should be included but with a false (disabled) setting regarding sign message support:

```
# Whether we support the SignMessage extension
signservice.sign-message.enabled=false

```

### Step 2 - Modify general properties

#### Declare configuration policy profile and SP entity ID
Remove old settings according to the following example:

>~~signservice.config.policy=default<br>
>signservice.config.default-sign-requester-id=https://sig.sunet.se/sig-sp<br>~~


Replace this with the new corresponding property settings:

```
# SAML SP name
sigsp.sp.entityid=https://sig.sunet.se/sig-sp
# default config policy name
signservice.default-policy-name=edusign
signservice.config.policy=${signservice.default-policy-name}
signservice.config.default-sign-requester-id=${sigsp.sp.entityid}

```
**Note:** The change of the policy name from `default` to `edusign` in the example is intentional.

### Step 3 - Sign page and sign image configuration changes

#### Move configuration property "include-identifier-in-name"
Find the property named `sigsp.config.signpage.image.include-identifier-in-name` in the section named
**Sign page configuration**. Preserve this property and add a comment as follows:

```
# Additional Sign page configuration
sigsp.config.signpage.image.include-identifier-in-name=false

```

#### Delete rest of "Sign page configuration" properties

Now delete the rest of the properteies in the "Sign page configuration" section as illustrated in this example:

>~~# Sign page configuration<br>
sigsp.config.signpage.location=file://${sigsp.config.dataDir}signimage/eduSign-page.pdf<br>
sigsp.config.signpage.x=37<br>
sigsp.config.signpage.y=165<br>
sigsp.config.signpage.cols=2<br>
sigsp.config.signpage.rows=6<br>
sigsp.config.signpage.xIncr=268<br>
sigsp.config.signpage.yincr=105<br>
sigsp.config.signpage.image.template=eduSign-image<br>
sigsp.config.signpage.image.scale=-74<br>
sigsp.config.signpage.image.include-identifier-in-name=false<br>~~

#### Replace this with new "Sign page configuration" properties

Add the following properties (with values matching the deleted properties above).
```
signservice.config.pdf-signature-pages[0].pdf-document.resource=file://${sigsp.config.dataDir}signimage/eduSign-page.pdf
signservice.config.pdf-signature-pages[0].image-placement-configuration.x-position=37
signservice.config.pdf-signature-pages[0].image-placement-configuration.y-position=165
signservice.config.pdf-signature-pages[0].columns=2
signservice.config.pdf-signature-pages[0].rows=6
signservice.config.pdf-signature-pages[0].image-placement-configuration.x-increment=268
signservice.config.pdf-signature-pages[0].image-placement-configuration.y-increment=105
signservice.config.pdf-signature-pages[0].signature-image-reference=eduSign-image
signservice.config.pdf-signature-pages[0].image-placement-configuration.scale=-74

```

#### Add new "Sign page configuration" properties
In addition to the properties above. Add the following:
```
signservice.config.pdf-signature-pages[0].id=edusign-sign-page
signservice.config.pdf-signature-pages[0].pdf-document.eagerly-load-contents=true

```

#### Remove old "signature image" properties
Remove the properties according to the following example:

>~~# Test signature image templates<br>
signservice.pdf-signature-image.template[0].resource=file://${sigsp.config.dataDir}signimage/eduSign-image.svg<br>
signservice.pdf-signature-image.template[0].reference=eduSign-image<br>
signservice.pdf-signature-image.template[0].width=967<br>
signservice.pdf-signature-image.template[0].height=351<br>
signservice.pdf-signature-image.template[0].includeSignerName=true<br>
signservice.pdf-signature-image.template[0].includeSigningTime=true<br>
signservice.pdf-signature-image.template[0].fields.idp=IdP EntityID<br>~~


#### Replace with new "signature image" properties
Add the following properties (with values matching the deleted properties above).

```
signservice.config.pdf-signature-image-templates[0].svg-image-file.resource=file://${sigsp.config.dataDir}signimage/eduSign-image.svg
signservice.config.pdf-signature-image-templates[0].reference=eduSign-image
signservice.config.pdf-signature-image-templates[0].width=967
signservice.config.pdf-signature-image-templates[0].height=351
signservice.config.pdf-signature-image-templates[0].includeSignerName=true
signservice.config.pdf-signature-image-templates[0].includeSigningTime=true
signservice.config.pdf-signature-image-templates[0].fields.idp=IdP EntityID

```
#### Add new "Signature imagage" properties
In addition to the properties above. Add the following:
```
signservice.config.pdf-signature-image-templates[0].svg-image-file.eagerly-load-contents=true
```

## 1.0.11

This version adds a configuration property in `application.properties` for listing other compatible services that share the same PDF sign page setup.

When this service is asked to sign a PDF document, the document to be signed can only be signed if the uploaded document has a compatible sign page where the signature image is added.

To add another SP entityID representing a compatible service add the property `signservice.config.compatible-pre-sign-service-id[n]`, where `n` is the index of the identifier. Example:

    `signservice.config.compatible-pre-sign-service-id[0]=eduSign`
    `signservice.config.compatible-pre-sign-service-id[1]=https://example.com/compatible-service`

**NOTE:** Old instances of sign service included a configured "ServiceID" string as the SP identifier in sign certificates. For backwards compatibility, these identifiers also need to be added to the list. This is demonstrated by the id "eduSign" in the example above. New installations of the sign service code includes the SP EntityID instead, illustrated by the second ID in the example. All new SP:s should be added in the form of EntityID URI:s.

## 1.0.8
This version has updated attribute parsing to support more accurate display of user attributes. Multivalued attributes such as level of assurance is correctly supported.

NameID valued attribute dispaly is now configurable. NameID values are random of nature and only applies to the unique combination of SP/IdP and normally lacks value as displayed attribute in a GUI. Display of such attributes is controlled by the following property in application.properties:

> `sigsp.config.display-name-id-attributes=false`

If not set, the default value is fasle.

## 1.0.6
This version adds the application.property setting `sigsp.config.html.title` which sets the title element of the html page (in the head element).

> Ex: sigsp.config.html.title=eduSign - s\u00E4ker digital underskrift

Note that spceial characters must be represented by their unicode code as shown in this example for the letter "ä".

### 1.0.4
This version introduce a new property `sigsp.config.signpage.image.include-identifier-in-name` with default value set to `true`.
A value of true means that the user ID will be included in the user name in PDF sign images. Ex "John Doe (id-of-john-doe)". A value of false excludes the ID
from the presented name and only leaves "John Doe".

The sign page configuration and files as been updated in the resources folder. Changes are made to application.properties settings and the basic files in the signimage folder.

New settings are:
```
# Sign page configuration
sigsp.config.signpage.location=file://${sigsp.config.dataDir}signimage/eduSign-page.pdf
sigsp.config.signpage.x=37
sigsp.config.signpage.y=165
sigsp.config.signpage.cols=2
sigsp.config.signpage.rows=6
sigsp.config.signpage.xIncr=268
sigsp.config.signpage.yincr=105
sigsp.config.signpage.image.template=eduSign-image
sigsp.config.signpage.image.scale=-74
sigsp.config.signpage.image.include-identifier-in-name=false

# Test signature image templates
signservice.pdf-signature-image.template[0].resource=file://${sigsp.config.dataDir}signimage/eduSign-image.svg
signservice.pdf-signature-image.template[0].reference=eduSign-image
signservice.pdf-signature-image.template[0].width=967
signservice.pdf-signature-image.template[0].height=351
signservice.pdf-signature-image.template[0].includeSignerName=true
signservice.pdf-signature-image.template[0].includeSigningTime=true
signservice.pdf-signature-image.template[0].fields.idp=IdP EntityID

```

Note that the color scheme for this verison has changed. This has caused the signText.md sample to be changed as well to align with the new color scheme based on the man color #FF500D.

> `<h3 style="color: #FF500D">Underskrift</h3>`

Finally, this version has moved the login button to the upper right corner of the login page and error pages has been updated to display information about what went wrong.


### 1.0.3
Added optional property `sigsp.config.login-button-html` to specify custom html for the login button

### 1.0.0
Initial relese. All relevant information is present in the README.md file.
