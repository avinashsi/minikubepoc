pipeline {
  agent any
  stages {
    stage('Build') {
      steps {
        git(url: 'git@github.com:avinashsi/dockerfile.git', branch: 'master', poll: true)
      }
    }
  }
}