pipeline {
    agent any
    environment {
    //   DOCKER_TAG = getVersion()
      AWS_ACCOUNT_ID="053132126130"
      AWS_DEFAULT_REGION="ap-south-1" 
      IMAGE_REPO_NAME="pv-dev-stockscan-validation"
      IMAGE_TAG="IMAGE_TAG"
      REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
      }
    stages {
        stage('Build') {
            steps {
                // Get some code from a GitHub repository
            echo 'git repo'
            git branch: 'sandbox',credentialsId: 'JenkinsUserEvCharging', url: 'https://github.com/tmlconnected/Validation-Dealer-Vehicle-Stockscan-PV'

            
            
          
            }

        }
         // Building Docker images
    stage('Building image') {
      environment {
        DOCKER_TAG = getVersion()
        }   

      steps{
        script {
        sh "docker build . -t  ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$DOCKER_TAG"
        sh 'docker tag ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$DOCKER_TAG "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:latest"'
        }
      }
      
    }
    
   stage('Logging into AWS ECR') {
            steps {
                script {
                sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
               
                }
                 
            }
        }
        
    stage('Pushing to ECR') {

     environment {
        DOCKER_TAG = getVersion()
        }    
     steps{  
         script {
                
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:$DOCKER_TAG"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:latest"
                
         }
        }
      }    
     
    stage('K8S Deploy') {
        environment {
        DOCKER_TAG = getVersion()
        } 
        steps{   
            script {
             withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'eks-pv-dev-cluster', contextName: '', credentialsId: 'jenkins-dev-eks-pv', namespace: 'kube-system', serverUrl: 'https://0A0FC90DB8006F0176052A1DD2725373.gr7.ap-south-1.eks.amazonaws.com']]) {

                 sh '/var/lib/jenkins/kubectl set image -n pv --record deploy/validation-stockscan validation-stockscan=${REPOSITORY_URI}:$DOCKER_TAG'   
                //  sh '/var/lib/jenkins/kubectl rollout restart deployment edukaan-validation -n cv-prod'
                 sh ('/var/lib/jenkins/kubectl get pods -n pv')
              //  }
             }
            }
        }
       }   
       
       // ==============Test Cdoe ===========
       
        stage('TEST') {
        steps{   
            script {
             withKubeCredentials(kubectlCredentials: [[caCertificate: '', clusterName: 'eks-pv-dev-cluster', contextName: '', credentialsId: 'jenkins-dev-eks-pv', namespace: 'kube-system', serverUrl: 'https://0A0FC90DB8006F0176052A1DD2725373.gr7.ap-south-1.eks.amazonaws.com']]) {
               
                
                // sleep 30
                
                 sh '/var/lib/jenkins/kubectl rollout status deploy/validation-stockscan -n pv -w --timeout=120s'
            
                }
            }
        }
       }    
       
        // ==============Test Cdoe END ===========
       
       
   }
    }
def getVersion(){
def commitHash = sh label: '', returnStdout: true, script: 'git rev-parse --short HEAD'
return commitHash
}
