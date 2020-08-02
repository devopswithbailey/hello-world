#!/usr/bin/env groovy

@Library("com.jenkins.pipeline.library@v0.3.0") _

import com.jenkins.pipeline.library.kubernetes.Kubernetes
import com.jenkins.pipeline.library.utils.dispatch.jenkins.JenkinsBeans


pipeline {
    agent {
        label 'docker-maven-slave'
    }

    options {
        disableConcurrentBuilds()
    }

    stages {

        stage("Load vars") {
            agent any
            steps {
                load "./jenkins_env.groovy"
            }
        }

        stage('push prod docker image to DTR') {
            when {
                branch 'master'
            }

            steps {
                glGitGetInfo()
                echo "Step docker build push"
                echo "LAST_RELEASE_VERSION : ${env.LAST_RELEASE_VERSION}"

                glDockerImageBuildPush dockerCredentialsId: "${env.GIT_CREDENTIALS_ID}",
                        dockerHost: "${env.DOCKER_REPOHOST}",
                        namespace: "${env.DOCKER_NONPROD_NS}",
                        extraBuildOptions: "--build-arg ARTIFACT_NAME=${env.ARTIFACT_NAME}-" + "${env.NEXT_VERSION}",
                        repository: "${env.DOCKER_REPO}",
                        tag: "${env.DOCKER_REPOHOST}" + "/" + "${env.DOCKER_NONPROD_NS}" + "/" + "${env.DOCKER_REPO}" + ":" + "${env.NEXT_VERSION}"

                // promote the recent version as the latest
                glArtifactoryDockerPromote credentialsId: "${env.GIT_CREDENTIALS_ID}",
                        destArtifactoryRepo: "${env.DEFAULT_DOCKER_ARTIFACTORY_REPOSITORY}",
                        sourceDockerRepo: "${env.DOCKER_NONPROD_NS}" + "/" + "${env.DOCKER_REPO}",
                        sourceTag: "${env.NEXT_VERSION}",
                        destTag: 'latest'

                echo "Step docker build push end for prod"
            }
        }

        stage('Deploy blog to k8s') {
            when {
                branch 'master'
            }
            agent { label 'docker-terraform-slave' }
            steps {
                script {
                    Object yamlMap = readYaml file: "namespace.yml"
                    def config = [
                        cluster    : yamlMap.clusterName,
                        namespace  : yamlMap.namespace,
                        credentials: yamlMap.clientSecret
                    ]
                    def kube = JenkinsBeans.create(Kubernetes, this)
                    withCredentials([string(credentialsId: config.credentials, variable: 'TOKEN')]) {
                        kube.configureKubectl(config)
                        def kubectlcmd = """
                                workingDir=`pwd`
                                export KUBECONFIG=\$workingDir/.kube/config
                                kubectl apply -f deployment.yml --validate=false """
                        command(kubectlcmd, false, '#!bin/bash +x')
                    }
                }
                
                echo "Step deploy blog to k8s end for prod"
            }

        }

    }
    post {
        always {
            echo 'This will always run'
            emailext body: "Build URL: ${BUILD_URL}",
                    subject: "$currentBuild.currentResult-$JOB_NAME",
                    to: 'learning.with.bailey@gmail.com'
        }
        success {
            echo 'This will run only if successful'
        }
        failure {
            echo 'This will run only if failed'
        }
        unstable {
            echo 'This will run only if the run was marked as unstable'
        }
        changed {
            echo 'This will run only if the state of the Pipeline has changed'
            echo 'For example, if the Pipeline was previously failing but is now successful'
        }
    }
}

