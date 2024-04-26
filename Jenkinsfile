pipeline {
    agent any

    properties(
        [
            githubProjectProperty(
                displayName: 'docker-syncovery',
                projectUrlStr: 'https://github.com/MyUncleSam/docker-syncovery/'
            ),
            parameters(
                [
                    string(
                        name: 'IMAGE_FULLNAME',
                        defaultValue: 'stefanruepp/syncoverycl'
                    )
                ]
            )
        ]
    )
    triggers {
        URLTrigger(
            cronTabSpec: '* * * * *',
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
                )
            ]
        )
    }
    stages {
        stage('Checkout') {
            steps {
                git "https://github.com/MyUncleSam/docker-syncovery.git"
            }
        }
        stage('Build') {
            steps {
                sh 'pwd'
                sh 'ls -lah'
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
    }
}
