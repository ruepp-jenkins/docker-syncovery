properties(
    [
        githubProjectProperty(
            displayName: 'docker-syncovery',
            projectUrlStr: 'https://github.com/MyUncleSam/docker-syncovery/'
        ),
        disableConcurrentBuilds(abortPrevious: true)
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'stefanruepp/syncoverycl'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
        TRIVY_TOKEN = credentials('TRIVY_TOKEN')
    }

    triggers {
        URLTrigger(
            cronTabSpec: 'H/30 * * * *',
            entries: [
                URLTriggerEntry(
                    url: 'https://www.syncovery.com/linver_x86_64-Web.tar.gz.txt',
                    contentTypes: [
                        MD5Sum()
                    ]
                ),
                URLTriggerEntry(
                    url: 'https://www.syncovery.com/linver_aarch64.tar.gz.txt',
                    contentTypes: [
                        MD5Sum()
                    ]
                ),
                URLTriggerEntry(
                    url: 'https://hub.docker.com/v2/namespaces/library/repositories/ubuntu/tags/24.04',
                    contentTypes: [
                        JsonContent(
                            [
                                JsonContentEntry(jsonPath: '$.last_updated')
                            ]
                        )
                    ]
                )
            ]
        )
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: env.BRANCH_NAME, url: env.GIT_URL
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
        stage('SBOM generation') {
            steps {
                sh "docker run --rm --network Internal -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace aquasec/trivy image --server http://172.20.89.4:4954 --token ${TRIVY_TOKEN} --format cyclonedx --output ${WORKSPACE}/bom.xml --scanners vuln,misconfig,secret,license ${IMAGE_FULLNAME}:latest"
            }
        }
        stage('DependencyTracker') {
            steps {
                dependencyTrackPublisher artifact: 'bom.xml', projectName: env.JOB_NAME, projectVersion: 'latest', synchronous: true, projectProperties: [tags: ['image']]
            }
        }
    }

    post {
        always {
            discordSend result: currentBuild.currentResult,
                description: env.GIT_URL,
                link: env.BUILD_URL,
                title: JOB_NAME,
                webhookURL: DISCORD_WEBHOOK
            cleanWs()
        }
    }
}
