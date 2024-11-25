pipeline {
  agent none
    parameters {
        string(name: 'Repository', defaultValue: '123456789012.ecr.us-west-2.amazonaws.com/jpetstore', description: 'Repository with registry for container image')
        string(name: 'Tag', defaultValue: 'v1.0.0', description: 'Tag for container image')
    }
  stages {
    stage('Build'){
      parallel {
        stage("Build for arm64 platform") {
            agent {
                kubernetes {
                  yamlFile 'Jenkins-agent-buildah-arm64.yaml'
                }
            }
            steps {
              script {
                docker.withRegistry("https://${params.Repository}", "ecr:us-west-2:IAMRole") {
                  container('buildah') {
                      sh 'buildah build --pull --platform linux/arm64 -t ${params.Repository}:${params.Tag}-arm64'
                      sh 'buildah push ${params.Repository}:${params.Tag}-arm64 docker://${params.Repository}:${params.Tag}-arm64'
                  }
                }
              }
            }
          }
        stage("Build for amd64 platform") {
            agent {
                kubernetes {
                  yamlFile 'Jenkins-agent-buildah-amd64.yaml'
                }
            }
            steps {
              script {
                docker.withRegistry("https://${params.Repository}", "ecr:us-west-2:IAMRole") {
                  container('buildah') {
                      sh 'buildah build --pull --platform linux/amd64 -t ${params.Repository}:${params.Tag}-amd64'
                      sh 'buildah push ${params.Repository}:${params.Tag}-amd64 docker://${params.Repository}:${params.Tag}-amd64'
                  }
                }
              }
            }
        }
      }
    }

    stage('Manifest'){
      agent {
            kubernetes {
              yamlFile 'Jenkins-agent-buildah-arm64.yaml'
            }
      }
      steps {
        script {
          docker.withRegistry("https://${params.Repository}", "ecr:us-west-2:IAMRole") {
            container('buildah') {
                sh 'buildah manifest create ${params.Repository}:${params.Tag} \
                    ${params.Repository}:${params.Tag}-arm64 \
                    ${params.Repository}:${params.Tag}-amd64'
                sh 'buildah manifest push ${params.Repository}:${params.Tag} docker://${params.Repository}:${params.Tag}'
            }
          }
        }
      }
    }
  }
}
