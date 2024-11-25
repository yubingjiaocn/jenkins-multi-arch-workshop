#!/bin/bash
#
#    Copyright 2010-2024 the original author or authors.
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


helm repo add jenkins https://charts.jenkins.io
helm repo update

helm install jenkins jenkins/jenkins \
--namespace jenkins \
--create-namespace \
--set persistence.enabled=true \
--set persistence.storageClass=ebs-sc \
--set persistence.size=10Gi \
--set controller.serviceType=ClusterIP \
--set controller.admin.password=admin123 \
--set controller.ingress.enabled=true \
--set controller.ingress.annotations."kubernetes\.io/ingress\.class"=alb \
--set controller.ingress.annotations."alb\.ingress\.kubernetes\.io/scheme"=internal \
--set controller.ingress.annotations."alb\.ingress\.kubernetes\.io/target-type"=ip \
--version 5.7.14
