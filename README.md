# Flask App Deployment on Kubernetes with Terraform & Private Tailscale Access

[![Terraform](https://img.shields.io/badge/Terraform-v1.5%2B-blue.svg)](https://www.terraform.io/)
[![IBM Cloud Provider](https://img.shields.io/badge/IBM__Cloud_Provider-v1.56%2B-orange.svg)](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository deploys a lightweight Kubernetes cluster using Terraform and provisions a secure Flask web application with private Tailscale integration. 
The setup enables private access to the Flask app's service and pod network over Tailscale, without exposing public ports. Ideal for development, self-hosted services, or secure API endpoints.

# Resources Created
- Kubernetes cluster (configurable for minikube, kind, or cloud providers)
- VPC/Networking infrastructure (subnets, gateways if applicable)
 -    Terraform state management with remote backend support
   -  Tailscale DaemonSet for node-level private connectivity
  -   Flask app Deployment, Service, and optional Ingress with Tailscale subnet routing
  -   Optional: Tailscale exit node for full network egress
# Production Value
 -    Automated Kubernetes & App Deployment
 -    Zero-trust private access via Tailscale
  -   Scalable Flask app hosting
# Prerequisites

| Requirement              | Details                                                                 |
|--------------------------|-------------------------------------------------------------------------|
| IBM Cloud Account        | Free Lite account sufficient → https://cloud.ibm.com/registration       |
| Terraform                | Installation Below -- v1.5 or higher                                    |
| IBM Cloud CLI            | Installation Below -- Latest version                                    |
| Tailscale Account        | Free tier sufficient → https://tailscale.com                            |
| Docker Account           | Free tier sufficient → https://docker.com                               |


# Installation (Ubuntu/Debian)

```bash
# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
```
# Cloning the Repo
```bash
git clone https://github.com/BrandynLo/flask-tailscale-k8s
cd IBM-Kubernetes_Terraform_Tailscale
```
# Install Terraform
```bash
sudo apt update && sudo apt install -y gnupg software-properties-common
```

# Installation (Ubuntu/Debian)

```bash
# Install IBM Cloud CLI
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
```
# Cloning the Repo
```bash
git clone https://github.com/BrandynLo/IBM-Kubernetes_Terraform_Tailscale.git
cd IBM-Kubernetes_Terraform_Tailscale
```
# Install Terraform
```bash
sudo apt update && sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

# Install the IBM Cloud Terraform provider plugin
```bash
ibmcloud plugin install cloud-internet-services
ibmcloud plugin install kubernetes-service
ibmcloud target -r us-south
terraform init -upgrade
```
# IBM Account Sync:
```bash
ibmcloud login --sso
```
<img width="1851" height="669" alt="image" src="https://github.com/user-attachments/assets/39f3923b-9b77-4341-9ea0-535e8df19e3d" />
Insert the one-time code and select the region of your choice.
<img width="1174" height="669" alt="image" src="https://github.com/user-attachments/assets/c3bcac06-f13f-4815-960c-e3ed9d9aa083" />


# IBM - Syncing API Keys
[Access your API keys through https://cloud.ibm.com/
Navigate to Manage Identities > API KEYS > Create:

#Edit the Variables.tf file:
- You only need to change the variable in variable.tf 
- -> Change it to your current public vlan by typing in your current zone (dal10 is mine):

        ibmcloud ks vlans --zone dal10 
This is what you need to change: 
<img width="1308" height="732" alt="image" src="https://github.com/user-attachments/assets/8b04d180-49b9-4bdd-ac2b-21ac713a5f98" />

Example:
ibmcloud ks vlans --zone dal10
ID        Name              **Number**   Type      Router  
1234567   vlan-pub-dal10    **2245**     public    xyzxyz.dal10  
2345678   vlan-priv-dal10   **2245**     private   xyzxyz.dal10

USE THE NUMBER TYPE: Example here is 2245 and replace it in your variables.tf
IF YOU ARE IN A DIFFERENT ZONE, Change your variables.tf default zone as well.

# Final Step: Cluster Creation with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
# Verify Cluster Creation:
<img width="1642" height="309" alt="Screenshot 2025-11-30 195613" src="https://github.com/user-attachments/assets/c5f1d2fd-7304-4037-a47a-82bd6baeba88" />
<img width="1919" height="1025" alt="image" src="https://github.com/user-attachments/assets/3e2ff5e3-4d43-4847-8a0f-2d1e52881f38" />

#Install pre-req files:

    ibmcloud plugin install container-registry -r "IBM Cloud"
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    docker --version
    kubectl get nodes
   


#Cluster creation-- Choose your personal cluster name
        
        ibmcloud ks cluster config --cluster <your-cluster-id-or-name> --admin

        #Example ibmcloud ks cluster config --cluster MY-FREE-CLUSTER --admin

  # Build and Push your Docker Image
  -Make you rememebr your "NAME SPACE" name you put on docker. Do not copy paste blindly. 
   
    cd flask-web-config
    docker build -t us.icr.io/your-namespace/flask-site:latest ./flask-app/
    docker push us.icr.io/your-namespace/flask-site:latest

#Example Of Mine, since Docker was not working correctly:
      
    sudo docker build -t us.icr.io/brandynlabs/flask-site:latest .
    sudo mkdir -p /root/.docker
    sudo cp ~/.docker/config.json /root/.docker/
    sudo docker push us.icr.io/brandynlabs/flask-site:latest
    ibmcloud cr login
    ibmcloud cr namespace-add brandynlabs     
 <img width="891" height="861" alt="Screenshot 2025-11-30 203605" src="https://github.com/user-attachments/assets/3c5c8405-7c47-4375-8e6c-2580f45147fa" />
<img width="822" height="215" alt="Screenshot 2025-11-30 203907" src="https://github.com/user-attachments/assets/1553e2b9-d642-4a17-9ce2-dc163d111de4" />

 # Deploy the app

    cd Kubernetes
    kubectl apply -f deploy.yaml
Ignore error:
<img width="1746" height="98" alt="Screenshot 2025-11-30 204324" src="https://github.com/user-attachments/assets/87baf225-2d62-42b6-91c8-b04cf061efdf" />

# 5. Get the public URL

    kubectl get nodes -o wide
    kubectl get svc flash-site-svc
<img width="1363" height="669" alt="image" src="https://github.com/user-attachments/assets/3cdedeb3-3341-45e7-ac73-a59ad93e7ac2" />
<img width="1919" height="1035" alt="image" src="https://github.com/user-attachments/assets/ea05e98f-1aa2-4d63-9ae9-efe598e096a4" />

# Short-hand commands: 
Run Diag:
      
      watch kubectl get pods

Run this command to watch realtime when the Website goes live.
  
    watch kubectl get svc flask-site-svc

If you edit the deploy.yaml:
    
    kubectl apply -f your-manifest.yaml


Edit the app.y in flask-web-config directory to edit the website. 
    
    sudo docker build -t us.icr.io/brandynlabs/flask-site:latest .
    sudo docker push us.icr.io/brandynlabs/flask-site:latest
  


    kubectl apply -f deploy.yaml
    kubectl get svc flask-site-svc  # Shows 80:30080/TCP
    kubectl get nodes -o wide       # Confirm worker EXTERNAL-IP

# CLOUDFLARE INSTALLATION:
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
<img width="938" height="349" alt="Screenshot 2025-11-30 210150" src="https://github.com/user-attachments/assets/40e9ec48-5615-4c15-a4ba-2dba0b67730b" />

You may run this on a paid domain through CLOUDFLARE or edit the yaml file if you have paid loadbalancing features through IBM K8s. 

If you need to run CLOUDFLARE temporarily, you can: 

On a different terminal, run:
    
    kubectl port-forward svc/flask-site-svc 8080:80
  <img width="736" height="67" alt="Screenshot 2025-11-30 210655" src="https://github.com/user-attachments/assets/c8cdce9d-5209-4f26-916d-ce1f743f85ff" />

On a seperate terminal, run:
      
      cloudflared tunnel --url http://localhost:8080
<img width="950" height="397" alt="Screenshot 2025-11-30 210709" src="https://github.com/user-attachments/assets/4bcca38f-0f06-4241-ae97-deb67f34b850" />
This will generate a temp cloudflare domain name. 
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/8b60e78e-bf4b-4c1e-b0d4-1ab12fac7287" />

6. Cleanup
   
        cd terraform
        terraform destroy

## Optional Tailscale Integration:
```bash
curl -fsSL https://tailscale.com/install.sh | sh
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
ibmcloud ks clusters
ibmcloud ks cluster config --cluster my-free-lite-cluster --admin
kubectl create namespace tailscale
```
<img width="1414" height="535" alt="Screenshot 2025-11-28 174951" src="https://github.com/user-attachments/assets/900317a5-5b23-49f5-8afd-4e1790f175af" />

Log into https://login.tailscale.com/admin/machines
<img width="1414" height="535" alt="Screenshot 2025-11-28 174951" src="https://github.com/user-attachments/assets/c323235f-589a-4fe7-9bc2-131cb2ba56eb" />

Generate an Auth key and replace it with:
<img width="1308" height="912" alt="image" src="https://github.com/user-attachments/assets/6d91a622-2bef-4c00-a957-f5f73805cc89" />
```bash
sudo tailscale up --auth-key=YOUR_Key_Goes_Here
```
example would be tskey-auth-k999999
```bash
kubectl create secret generic tailscale-auth --namespace tailscale \ --from-literal=TS_AUTHKEY=Key_Goes_Here
```
Copy this to setup tailscale:
```bash
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: tailscale
  namespace: tailscale
spec:
  selector:
    matchLabels:
      app: tailscale
  template:
    metadata:
      labels:
        app: tailscale
    spec:
      tolerations:
      - operator: Exists
        effect: NoSchedule
      - operator: Exists
        effect: NoExecute
      containers:
      - name: tailscale
        image: tailscale/tailscale:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
          tailscale up \
            --authkey=\$TS_AUTHKEY \
            --hostname=ibm-free-cluster \
            --advertise-routes=10.42.0.0/16,172.30.0.0/16 \
            --advertise-exit-node \
            --accept-dns=false \
            --reset
          tailscale status --web
        env:
        - name: TS_AUTHKEY
          valueFrom:
            secretKeyRef:
              name: tailscale-auth
              key: TS_AUTHKEY
        securityContext:
          privileged: true
        volumeMounts:
        - name: dev-net-tun
          mountPath: /dev/net/tun
      volumes:
      - name: dev-net-tun
        hostPath:
          path: /dev/net/tun
EOF

```
<img width="945" height="950" alt="Screenshot 2025-11-28 175527" src="https://github.com/user-attachments/assets/2b4d9ef5-a9cc-4bfb-9ca6-2f1471ded9ea" />

Run this to verify pod is connected:
```bash
kubectl -n tailscale get pods
```
<img width="621" height="73" alt="Screenshot 2025-11-28 181224" src="https://github.com/user-attachments/assets/11e44b6b-ad0c-4086-b4f9-6c1a8ce8f588" />

Verify connection of Cluster to TailScale
```bash
kubectl -n tailscale logs -f NAME_OF_YOUR_TAILSCALE
```
<img width="1308" height="912" alt="image" src="https://github.com/user-attachments/assets/95138d38-4361-462e-a707-c8b7b9422edf" />

Verify connection on TailScale:
<img width="1308" height="912" alt="image" src="https://github.com/user-attachments/assets/8d68e81a-68ed-486d-a005-c9904ab15aa9" />

You now have access to SSH into the personal cloud console of the Kubernetes Cluster you've provisioned.


# Extra Note:
- Not the most organized Readme i've made. Will provide an update by recreating this in a different VM to host kubernetes on. 


