# Deploying an application using Kubernetes (on premise)

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

Wait a little for **running** status of all resources and then forward port for **db** service to have access from the Internet and migrate DB (but for migration open a new terminal so as not to close the connection)

```
kubectl --namespace todo-app-ns port-forward svc/db 5432
migrate -path ../schema -database "postgres://postgres:qwerty@localhost:5432/postgres?sslmode=disable" up 
```

Then create resources for the app:

```
kubectl apply -f app.yaml  
```

Also, wait a little for **running** status of **svc/app** resource and forward port for it to get access to the app:

```
kubectl --namespace todo-app-ns port-forward svc/app 8000
```

Then you can open web-app in browser with [localhost:8000/swagger/index.html](http://localhost:8000/swagger/index.html)