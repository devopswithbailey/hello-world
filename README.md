# hello-world
Hello World for DevOps and CICD pipeline

## Install Docusaurus V2
1. Check the intallation requirements by following the link: https://v2.docusaurus.io/docs/installation
2. Install docusaurus v2
    ```
    npx @docusaurus/init@next init blog classic
    ```
3. Self hosting docusaurus website by following the link: https://v2.docusaurus.io/docs/deployment#self-hosting
    ```
    npm run serve --build
    ```
## Deploy blog
### Docker
1. [Dockerfile](Dockerfile)
2. Build docker image
    ```
    docker build -t your_docker_registry/blog:0.1.0 .
    ```
### Kubernetes
1. [deployment.yml](deployment.yml)
2. Deploy blog to kubernetes
    ```
    kubectl apply -f deployment.yml
    ```
### CICD
To automate building docker image and deploying blog to kubernetes using [jenkins](Jenkinsfile)
