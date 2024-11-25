#
#    Copyright 2010-2023 the original author or authors.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       https://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#

FROM public.ecr.aws/docker/library/maven:3.9.9-amazoncorretto-21-al2023 AS builder
COPY . /usr/src/myapp
WORKDIR /usr/src/myapp
RUN ["/bin/sh", "-c", "mvn --no-transfer-progress clean package"]

FROM public.ecr.aws/docker/library/tomcat:9-jre21 AS runner
COPY --from=builder /usr/src/myapp/target/jpetstore.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
