# Upload and sign application versions

**Latest Current version: 1.0.4**

Version | Comment | Date
---|---|---
1.0.0 | Initial release | 2020-04-24
1.0.1 | Updated integration API to release version 1.1.0 | 2020-04-28
1.0.2 | Redirect from root to open/login | 2020-04-29
1.0.3 | Capability to customize login button   | 2020-04-29
1.0.4 | UI update to eduSign style. Improved error page and login page | 2020-04-29

## Important Release Notes

### 1.0.0
Initial relese. All relevant information is present in the README.md file.


### 1.0.3
Added optional property `sigsp.config.login-button-html` to specify custom html for the login button

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
