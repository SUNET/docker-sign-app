
---
# CURRENT BUILD VERSION = 1.0.9
---
# docker-sig-app

This repo contains build and deploy scripts for the SUNET electronic signing application for uploading and signing documents. The following build and deployment steps should be followed:

1. Building a docker image
2. Setting up key files and configuration data.
3. Configuring metadata sources  and storage location for cached data.
4. Deploying the docker image as docker container.
5. Setting up Shibboleth SP authentication

The signing application is provided as a Spring Boot application which is deployed to the maven repo at: [https://maven.eidastest.se](https://maven.eidastest.se/artifactory/webapp/#/home)

## 0. Using the pre-built docker image

```bash
# docker pull docker.sunet.se/upload-sign-app:<version>
# docker pull docker.sunet.se/shibsp-ajp
```

The second image provides a useful ajp-enabled proxy service with shibboleth enabled.

## 1. Building docker file

The docker build script "build.sh" builds a docker image for the signing application by performing the following actions:

- Downloading the executable .jar file from maven repository
- Downloading the signature (asc) on the metadata validator executable
- Verifying the signature on the downloaded .jar file.
- Building the docker image.

```
Usage: build.sh [options...]

   -u, --user             Username for Maven repository (default is eidasuser)
   -p, --passwd           Password for Maven repository (will be prompted for if not given)
   -v, --version          Version for artifact to download
   -i, --image            Name of image to create (default is upload-sign-sp)
   -t, --tag              Optional docker tag for image
   -c, --clear            Clears the target directory after a successful build (default is to keep it)
   -h, --help             Prints this help
```

There is a Makefile in the directory that simplifies the build. Just run 'make'. Note that this requires read access to
the maven repository servers. If you don't have access, feel free to use the ready-made docker images instead.

## 2. Configuration
The resources folder contains sample configuration data. The content of the `upload-sign-sp` folder illustrates a working example file structure to be placed in a directory specified in a suitable location reflected in the settings of the `application.properties` file in combination with the environment variable `SPRING_CONFIG_ADDITIONAL_LOCATION`.

The following folders and files are present in `upload-sign-sp`:

Folder | Description
--- | ---
`keystore` | Keystores and certificates for the application
`metadata` | files and cached data reltaed to SAML metadata downloaded and used by the application
`signimage` | PDF files with sign page and SVG sign image templates

The following files are present in the base directory:

File | Description
--- | ---
application.properties | Main configuration file
presentationText.md  | Text in Markdown format displayed on the home login page of the application
signText.md  | Text in Markdown format displayed as warning when a document is being signed

### 2.1 Configuration settings
The `application.properties` file in the resources folder illustrates sensible defaults. However, the following property values should be checked and assigned correct values:

Property | Value
--- | ---
`sigsp.config.mode`  |  mode options are "dev", "test" or "prod". Affecting visual appearance
`sigsp.config.title`  |  Title on the front of the login page. Note that åäöÅÄÖ must be escaped as unicode characters. E.g "Bastj\u00E4nst f\u00F6r Elektronisk Underskrift"
`sigsp.config.html.title`  |  The html head title of the html pages. Note that special characters must be unicode escaped as with the login page title above
`sigsp.config.login-button-html`  |  Optional property used to provide custom html for the login button. Example: `sigsp.config.login-button-html=<a href='../secure/main' class='btn btn-primary'>Login</a>``server.port`  |  Set the server port for the service. If TLS is used (port 8443) then the TLS settings must also be settings
`tomcat.ajp.enabled`  |  true or false dependeing on whether AJP should be exposed
`spring.servlet.multipart.max-file-size`  |  Sets the max file upload size. This value can be set to a maximum of 10 MB. Sizes larger than 10MB requires other measures to increase internal Spring Boot limitations.
`sigsp.config.signpage`  |  Sets properties related to the sign page
`signservice.pdf-signature-image.template`  |  Sets properties relatedto PDF sign image
`sigsp.federation.metadata` | Properties for downloading, validating and caching SAML metadta
`signservice.credential`  |  Properties for setting up the signing key for signing SignRequest to the signature service
`signservice.config.default-sign-requester-id`  |  The EntityID of this application expressed as the sign requesting service in requests to the signing service.
`signservice.config.sign-service-id`  |  The EntityID of the sign service  |
`signservice.config.default-destination-url` |  The URL where the Sign Request to the sign service is sent.
`sigsp.config.signpage.image.include-identifier-in-name`  |  A value of true includes the user ID in the user name. E.g. "John Doe (id-of-john-doe)" when included in a PDF sign image. A value of false excludes the uer ID from the displayed name.


## 3. Running the docker container

The samples folder contains a sample docker deploy script `deploy.sh`:

This example assumes that metadata is maintained at /etc/metadata/swamid-idp-transitive.xml on the docker-host. This is best left to
a cron-script instead of using shibboleths built-in mechanism for metadata refresh which is pretty slow.

This is an illustration of the docker commands used - your environment may differ slightly - adjust accordingly!

It is of course possible to use your own shibboleth/SAML frontend. The upload-sign-app assumes the normal AJP convention of passing
all shibboleth attributes as request headers with the "AJP_" prefix. This is documented in the shibboleth wiki and implemented in
the shibsp-ajp container.

```
#!/bin/bash

docker run --net docker -d --name sign-app-sp --restart=always \
  -p 443:443 \
  -e "SP_CONTACT=helpdesk@example.com" \
  -e "METADATA_FILE=/etc/metadata/swamid-idp-transitive.xml" \
  -e "BACKEND_URL=ajp://upload-sign-app:8009" \
  -e "SP_HOSTNAME=signapp.exmple.com" \
  -e "SP_ABOUT=/open/login" \
  -e "PROTECTED_URL=/secure" \
  -v "/etc/ssl:/etc/ssl" \
  -v "/etc/metadata:/etc/metadata:ro" \
  -v "/var/log:/var/log" \
  docker.sunet.se/shibsp-ajp:latest

docker run --net docker -d --name upload-sign-app --restart=always \
  -e "SPRING_CONFIG_ADDITIONAL_LOCATION=/opt/upload-sign-app/" \
  -v /etc/localtime:/etc/localtime:ro \
  -v /opt/docker/upload-sign-sp:/opt/upload-sign-app \
  docker.sunet.se/upload-sign-app:1.0.3

echo Done!
```

Use of http, https and ajp access to the service is specified in `application.properties`. The `Dockerfile` is reflecting this by currently exposing port 8080, 8443 and 8009.

The environment variable `SPRING_CONFIG_ADDITIONAL_LOCATION`, specifies the location where the configuration folder is located. Note that the specified location must end with a "/" character.

All property values in application.properties can be overridden by docker run environment variable settings. The convention is to specify the property name in uppercase letters and replace "." and "-" characters with underscore ("\_")

## 4. Shibboleth SP authentication

The current application requires a logged in user and depends on Shibboleth SP to provide user authetnication.
A sample shibboleth2.xml as well as a sample attribute-map.xml file is provided in the `shib-sp` folder in the `resources` folder.
