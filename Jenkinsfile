pipeline {
    agent none
    parameters {
        string(name: 'Repository', description: 'Repository with registry for container image')
        string(name: 'Tag', defaultValue: 'v1.0.0', description: 'Tag for container image')
    }
    stages {
        stage('Prep') {
      stage('Get ECR Token') {
        agent {
          kubernetes {
            yamlFile 'Jenkins-agent-awscli-arm64.yaml'
          }
        }
        steps {
          script {
            container('awscli') {
              def creds = sh "aws ecr get-login-password --region us-west-2"
            }
          }
        }
      }
        }

        stage('Build') {
      parallel {
        stage('Build for arm64 platform') {
          agent {
            kubernetes {
              yamlFile 'Jenkins-agent-buildah-arm64.yaml'
            }
          }
          steps {
            script {
              container('buildah') {
                sh "buildah build --pull --platform linux/arm64 -t ${params.Repository}:${params.Tag}-arm64"
                sh "buildah push ${params.Repository}:${params.Tag}-arm64 docker://${params.Repository}:${params.Tag}-arm64 --creds AWS:${creds}"
              }
            }
          }
        }
        stage('Build for amd64 platform') {
          agent {
            kubernetes {
              yamlFile 'Jenkins-agent-buildah-amd64.yaml'
            }
          }
          steps {
            script {
              container('buildah') {
                sh "buildah build --pull --platform linux/amd64 -t ${params.Repository}:${params.Tag}-amd64"
                sh "buildah push ${params.Repository}:${params.Tag}-amd64 docker://${params.Repository}:${params.Tag}-amd64 --creds AWS:${creds}"
              }
            }
          }
        }
      }
        }

        stage('Manifest') {
      agent {
        kubernetes {
          yamlFile 'Jenkins-agent-buildah-arm64.yaml'
        }
      }
      steps {
        script {
          container('buildah') {
            sh "buildah manifest create ${params.Repository}:${params.Tag} \
                    ${params.Repository}:${params.Tag}-arm64 \
                    ${params.Repository}:${params.Tag}-amd64"
            sh "buildah manifest push ${params.Repository}:${params.Tag} docker://${params.Repository}:${params.Tag} --creds AWS:${creds}"
          }
        }
      }
        }
    }
}
