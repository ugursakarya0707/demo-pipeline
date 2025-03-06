# Final Schema for CI/CD Pipeline

![image.png](attachment:be68535f-ce96-4de4-8b8f-7a0aa9c25c07:image.png)

## Setting Up Your Local Workspace (If you already have the project, skip this section)

### Java Project with Maven

1. Open **VS Code**.
2. Click **Create Java Project** (If you don't see this option, ensure Java extensions are installed).
3. Select **Maven** and choose the **quickstart archetype**.
4. Choose a folder for the project.
5. Press **Enter** to skip the snapshot version prompt.
6. Confirm the build configuration:

```
groupId: com.ugur007
artifactId: demo-docker-pipeline
version: 1.0-SNAPSHOT
package: com.ugur007

```

1. Click **Open** on the pop-up menu.

Here’s the project structure:

![image.png](attachment:c0696321-fe65-491e-bf3c-414a96cb2a65:image.png)

### Connecting to a Remote Git Repository

1. Create a **public repository** on GitHub and copy the repository URL.
2. Open a terminal and run:

```
git init
git remote add origin https://github.com/ugursakarya0707/demo-pipeline.git
git pull origin main
git add .
git commit -m "Initial commit"
git push -u origin main

```

> Note: If you encounter issues, force push with:
> 
> 
> ```
> git push --force origin main
> 
> ```
> 

### Creating a Dockerfile

Now, let’s create a `Dockerfile` and add the following content:

```
# 1. Build Stage: Use Maven to build the project
FROM maven:3.9.4-eclipse-temurin-17 AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# 2. Runtime Stage: Use a lightweight Java runtime
FROM eclipse-temurin:17-jdk
WORKDIR /app
COPY --from=builder /app/target/demo-docker-pipeline-1.0-SNAPSHOT.jar app.jar
CMD ["java", "-jar", "app.jar"]

```

### Building and Running the Docker Container

1. Log in to Docker:
    
    ```
    docker login
    
    ```
    
2. Build the Docker image:
    
    ```
    docker build -t my-quickstart-app .
    
    ```
    
3. If an error occurs, try:
    
    ```
    mvn clean package
    docker build -t my-quickstart-app .
    
    ```
    
4. Run the container:
    
    ```
    docker run --rm -p 8080:8080 my-quickstart-app
    
    ```
    

## Setting Up AWS CodePipeline

To prevent build-stage issues, we will create Docker images locally before integrating with AWS.

1. Go to **AWS Management Console**.
2. Navigate to **ECR (Elastic Container Registry)** > **Create Repository** > Name it `ecr-demo-app`.
3. Update the `buildspec.yml` file:

```yaml
version: 0.2
env:
  variables:
    ECR_REPO_NAME: ecr-demo-app
phases:
  pre_build:
    commands:
      - aws ecr-public get-login-password --region us-east-1 | docker login -u AWS --password-stdin public.ecr.aws
      - ECR_MAIN_URI="715841364973.dkr.ecr.us-east-1.amazonaws.com"
      - aws ecr get-login-password --region us-east-1 | docker login -u AWS --password-stdin ${ECR_MAIN_URI}
      - ECR_IMAGE_URI="${ECR_MAIN_URI}/${ECR_REPO_NAME}:${CODEBUILD_RESOLVED_SOURCE_VERSION:0:8}"
  build:
    commands:
      - docker build -t my-quickstart-app:latest .
  post_build:
    commands:
      - docker tag my-quickstart-app:latest ${ECR_IMAGE_URI}
      - docker push ${ECR_IMAGE_URI}
      - printf '[{"name":"angular1","imageUri":"%s"}]' ${ECR_IMAGE_URI} > imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json

```

### Deploying to AWS ECS

## Alternative: Setting Up Jenkins for CI/CD

Since AWS CodePipeline is costly, we can use **Jenkins** instead.

![image.png](attachment:0e54759b-ca9d-4ee4-a012-3aeb59734e54:image.png)

### Installing Jenkins

1. Install Jenkins:
    
    ```
    sudo apt update && sudo apt install jenkins -y
    
    ```
    
2. Check installation:
    
    ```
    jenkins --version
    
    ```
    
3. Start Jenkins:
    
    ```
    sudo service jenkins start
    
    ```
    
4. Verify its status:
    
    ```
    sudo service jenkins status
    
    ```
    
5. Open Jenkins in a browser: [http://localhost:8080](http://localhost:8080/).
6. Unlock Jenkins:
    
    ```
    sudo cat /var/lib/jenkins/secrets/initialAdminPassword
    
    ```
    

![image.png](attachment:953ff59b-855c-4243-819b-d632f92f3e74:image.png)

### Configuring Jenkins

1. Select **Plugins to Install**.
2. Create an **Admin User**.
3. Upgrade Jenkins packages:

![image.png](attachment:daf73fb8-b876-4f5b-b326-c5fcdf9f8f57:image.png)

```
sudo apt update && sudo apt upgrade jenkins -y

```

1. Verify Docker installation:
    
    ```
    docker --version
    
    ```
    
2. Grant Jenkins permissions to use Docker:
    
    ```
    sudo usermod -aG docker jenkins
    
    ```
    
3. Test Docker access for Jenkins:
