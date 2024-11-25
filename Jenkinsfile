pipeline {
    agent none
    parameters {
        string(name: 'Repository', description: 'Repository with registry for container image')
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
              // Extract region and registry from ECR URL
              def region = sh(script: "echo \${params.Repository} | cut -d'.' -f4", returnStdout: true).trim()
              def registry = sh(script: "echo \${params.Repository} | cut -d'/' -f1", returnStdout: true).trim()

              // Get ECR login password and create docker config
              sh """
                mkdir -p /root/.docker
                aws ecr get-login-password --region ${region} | \
                python3 -c 'import sys, json; auth=sys.stdin.read().strip(); print(json.dumps({"auths": {"${registry}": {"auth": auth}}}))' \
                > /root/.docker/config.json
              """
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
