pipeline {
    agent none
    parameters {
        string(name: 'Repository', defaultValue: '600413481647.dkr.ecr.us-west-2.amazonaws.com/jpetstore', description: 'Repository with registry for container image')
        string(name: 'Tag', defaultValue: 'v1.0.0', description: 'Tag for container image')
    }
    stages {
      stage('Build') {
        parallel {
          stage('Build for arm64 platform') {
            agent {
              kubernetes {
                yamlFile 'Jenkins-agent-kaniko-arm64.yaml'
              }
            }
            steps {
              script {
                container('kaniko') {
                  sh """
                    /kaniko/executor --context . \
                                   --dockerfile Dockerfile \
                                   --customPlatform linux/arm64 \
                                   --destination ${params.Repository}:${params.Tag}-arm64
                  """
                }
              }
            }
          }

          stage('Build for amd64 platform') {
            agent {
              kubernetes {
                yamlFile 'Jenkins-agent-kaniko-amd64.yaml'
              }
            }
            steps {
              script {
                container('kaniko') {
                  sh """
                    /kaniko/executor --context . \
                                   --dockerfile Dockerfile \
                                   --customPlatform linux/amd64 \
                                   --destination ${params.Repository}:${params.Tag}-amd64
                  """
                }
              }
            }
          }
        }
      }

      stage('Create Manifest') {
        agent {
          kubernetes {
            yamlFile 'Jenkins-agent-manifest-tool.yaml'
          }
        }
        steps {
          script {
            container('awscli') {
/*            // Extract region and registry from ECR URL
              def region = sh(script: "echo \"${params.Repository}\" | cut -d'.' -f4", returnStdout: true).trim()
              def registry = sh(script: "echo \"${params.Repository}\" | cut -d'/' -f1", returnStdout: true).trim()

              // Get ECR login password and create docker config
              sh """
                  mkdir -p /root/.docker && \
                  export ECR_CRED=\$(aws ecr get-login-password --region ${region}) && \
                  export ECR_AUTH=\$(echo -n \"AWS:$ECR_CRED\" | base64 -w 0) && \
                  echo "{\"auths\":{\"${registry}\": {\"auth\": \"\$ECR_AUTH\"}}}" > /root/.docker/config.json
              """ */

              // Temporary hardcode something...
              sh 'mkdir -p /tmp/.docker'

              // Get ECR login password and encode it for Docker config
              def ecrCred = sh(script: 'aws ecr get-login-password --region us-west-2', returnStdout: true).trim()
              def ecrAuth = sh(script: "echo -n \"AWS:${ecrCred}\" | base64 -w 0", returnStdout: true).trim()

              // Create Docker config.json with the ECR authentication
              def configJson = """{
                  "auths": {
                      "600413481647.dkr.ecr.us-west-2.amazonaws.com": {
                          "auth": "${ecrAuth}"
                      }
                  }
              }"""

              // Write the config.json to the .docker directory
              writeFile(file: '/tmp/.docker/config.json', text: configJson)

              // Output the contents of config.json for verification
              sh 'cat /tmp/.docker/config.json'
            }

            container('manifest-tool') {
              // Create and push manifest using manifest-tool
              sh """
                manifest-tool push from-args \
                  --platforms linux/amd64,linux/arm64 \
                  --template ${params.Repository}:${params.Tag}-ARCH \
                  --target ${params.Repository}:${params.Tag}
              """
            }
          }
        }
      }
    }
}
