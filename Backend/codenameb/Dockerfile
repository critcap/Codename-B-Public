FROM openjdk:17-jdk-slim
WORKDIR /app/backend
COPY /target/Codenameb.jar ./
ENTRYPOINT ["java", "-jar", "Codenameb.jar"]
EXPOSE 8080