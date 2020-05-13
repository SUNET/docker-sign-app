FROM openjdk:11-jre
VOLUME /tmp
ADD target/upload-sign-sp.jar app.jar

# Start with debuggning enabled
# ENTRYPOINT ["java","-agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n","-Djava.security.egd=file:/dev/./urandom","-Dorg.apache.xml.security.ignoreLineBreaks=true","-jar","/app.jar"]

# Normal start
ENTRYPOINT ["java","-Dorg.apache.xml.security.ignoreLineBreaks=true","-Dorg.apache.xml.security.ignoreLineBreaks=true","-jar","/app.jar"]

EXPOSE 8080
EXPOSE 8443
EXPOSE 8009
