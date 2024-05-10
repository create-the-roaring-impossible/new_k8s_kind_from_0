FROM eclipse-temurin:17-jdk-alpine
VOLUME /tmp
COPY target/*.jar app.jar
ENTRYPOINT ["java","-jar","/app.jar"]

# docker build -t myorg/myapp .
# docker run -p 8080:8080 myorg/myapp