FROM public.ecr.aws/docker/library/maven:3.9-amazoncorretto-8-al2023 AS builder
WORKDIR /app
COPY src/ /app/src
COPY pom.xml /app/pom.xml
RUN mvn -B clean package -Dmaven.test.skip=true

FROM public.ecr.aws/amazoncorretto/amazoncorretto:8-al2023-jre AS runner
WORKDIR /app
COPY --from=builder /app/target/demo-V1024.jar /app
CMD ["java -jar demo-V1024.jar"]
