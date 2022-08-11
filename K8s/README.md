# Deploying an application using Kubernetes (on-premise)

## Install required tools:
- golang-migrate  
- docker
- kubectl
- minikube

---

Clone this repository and switch to the *K8s* directory, from which you will continue to work:

```
git clone https://github.com/eugenia-ponomarenko/ToDo-REST-Go.git
cd ToDo-REST-Go/K8s/
```

Now, you can create namespace for app in which all the resources created in the future will be located

```
kubectl create namespace todo-app-ns
```

And create a secret with a password, persistent volume and persistent volume claim, deployment and service for our DB, using the following commands:

```
kubectl apply -f secret.yaml    
kubectl apply -f pv.yaml    
kubectl apply -f pv-claim.yaml    
kubectl apply -f db.yaml    
```

Then get URL for the DB service which needed for migration, copy it without **http://** and enter instead of **MINIKUBE_URL_FOR_DB_SERVICE** on the next line: 

```
minikube service db --url -n todo-app-ns
migrate -path ../schema -database "postgres://postgres:qwerty@MINIKUBE_URL_FOR_DB_SERVICE/postgres?sslmode=disable" up 
```

---

### Docker build and push

First, you need change IP in swagger docs to **MINIKUBE_URL_FOR_DB_SERVICE** without **http://** as following:

```
sed -i -E "s/localhost:8000/MINIKUBE_URL_FOR_DB_SERVICE/g" ./cmd/main.go
sed -i -E "s/localhost:8000/MINIKUBE_URL_FOR_DB_SERVICE/g" ./docs/*
```

Login to your DockerHub account and build, push new docker image.

```
docker login -u YOUR_USERNAME -p YOUR_PASSWORD
docker build -t YOUR_USERNAME/todo_go_rest:kubernetes .
docker push YOUR_USERNAME/todo_go_rest:kubernetes 
```

---

Then in **app.yaml** file, change name of the image to **YOUR_USERNAME/todo_go_rest:kubernetes** on the *20th line* and create resources for the app:

```
kubectl apply -f app.yaml  
```

Finally, to get access to the app you need to get URL of Kubernetes service "app":

```
minikube service app --url -n todo-app-ns
```

Then you can open web-app in browser with MINIKUBE_URL_FOR_APP_SERVICE/swagger/index.html
