# Deploy the different GKE cluster


## Prerequisite

* gcloud installed
* terraform installed
* kubectl installed

# Deploy your cluster
Terraform script help you to deploy and configure your GKE clusters in different region.

First, create a copy of terraform.tfvarstest in terraform.tfvars and replace the values

```bash
cp terraform.tfvarstest terraform.tfvars
```
Then replace set the project id and project number value.

You should have a terraform.tfvars file like : 
```properties
regions = ["europe-west2","us-central1"]
project_id = "your-project-id"
project_number="your-project-number"
```


You can change the region ( add, remove or update) values in the regions variable. As an example I propose to go with 2 regions.

Now you can create the clusters by executing these 2 commands.
```bash
terraform init
terraform apply
kubectl patch configmap/asm-options -n istio-system --type merge -p '{"data":{"multicluster_mode":"connected"}}'
```

Now you have different GKE cluster deploy in the regions you choose. ASM is enabled and configured for each cluster.

## Configure ASM

```bash
export PROJECT_ID="your project ID"
export LOCATION_1=europe-west2
export LOCATION_2=us-central1
export CTX1=gke_${PROJECT_ID}_${LOCATION_1}_${LOCATION_1}-gke
export CTX2=gke_${PROJECT_ID}_${LOCATION_2}_${LOCATION_2}-gke
gcloud container clusters get-credentials ${LOCATION_1}-gke --region ${LOCATION_1}
gcloud container clusters get-credentials ${LOCATION_2}-gke --region ${LOCATION_2}

kubectl create ns demo --context ${CTX1}
kubectl  label namespace demo --context ${CTX1} istio-injection- istio.io/rev=asm-managed --overwrite
kubectl patch configmap/asm-options --context ${CTX1} -n istio-system --type merge -p '{"data":{"multicluster_mode":"connected"}}'

kubectl create ns demo --context ${CTX2}
kubectl  label namespace demo --context ${CTX2} istio-injection- istio.io/rev=asm-managed --overwrite
kubectl patch configmap/asm-options --context ${CTX2} -n istio-system --type merge -p '{"data":{"multicluster_mode":"connected"}}'
```


## Deploy the application

```bash
export PROJECT_ID="your project ID"
export LOCATION_1=europe-west2
export LOCATION_2=us-central1
export CTX1=gke_${PROJECT_ID}_${LOCATION_1}_${LOCATION_1}-gke
export CTX2=gke_${PROJECT_ID}_${LOCATION_2}_${LOCATION_2}-gke

kubectl apply -f  application/common --context ${CTX1}
kubectl apply -f  application/common --context ${CTX2}

kubectl apply -f  application/eu --context ${CTX2}
kubectl apply -f  application/us --context ${CTX2}
```

 


