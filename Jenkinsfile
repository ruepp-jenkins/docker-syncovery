properties(
    [
        githubProjectProperty(
            displayName: 'docker-syncovery',
            projectUrlStr: 'https://github.com/MyUncleSam/docker-syncovery/'
        ),
        disableConcurrentBuilds()
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'stefanruepp/syncoverycl'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
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
