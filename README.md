##  Flask App on Kubernetes Cluster with Docker, Terraform, Tailscale, and Cloudflare 
[![Terraform](https://img.shields.io/badge/Terraform-v1.5%2B-blue.svg)](https://www.terraform.io/)
[![IBM Cloud Provider](https://img.shields.io/badge/IBM__Cloud_Provider-v1.56%2B-orange.svg)](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Deploys a Flask web application to a Kubernetes cluster provisioned using Terraform (via IBM Cloud). The app was containerized with docker, and runs in pods scheduled on the cluster's worker nodes. I've provided support for optional Tailscale integration and Cloudflare integration further down in the documentation as well.
- Project was inspired after working with Oracle VMs using Terraform-- I felt compelled to learn more about Kubernetes Clusters, worker nodes, pods, and how dockerization works after the previous project. This is running off of the free version of IBM's free Kubernetes Cluster as a note.

## Infrastructure (Provisioned via Terraform)

- IBM Cloud Kubernetes Service (IKS) Lite Cluster
- Single-zone cluster
- One worker node
- Runs in a dedicated VPC with public and private subnets
- Worker node connected via public VLAN


## Application Deployment
- Pushes the image to IBM Container Registry (ICR).
- Deploys it to the Kubernetes cluster using a single deploy.yaml manifest:
- A Deployment managing scalable pods running the Flask container.
- A ClusterIP Service for internal cluster access on port 80.
- A NodePort (30080) exposing the service on the worker node's external IP (primarily for initial testing).

## Optional Tailscale Integration for remote management
Provides instructions and a ready-to-apply DaemonSet YAML to run Tailscale on every cluster node:
- Joins the nodes to your personal Tailscale tailnet using a one-time auth key.
- Advertises the Kubernetes pod CIDR (10.42.0.0/16) and service CIDR (172.30.0.0/16).
- Optionally configures the node as an exit node.
- Result: The Flask app becomes accessible privately from any device connected to your Tailscale network (e.g., http://<worker-tailscale-ip>:30080 or via routed CIDRs), without exposing public ports or incurring load balancer costs.

## Optional Clouflare Integration
Includes steps to use kubectl port-forward combined with Cloudflare Tunnel (

## Prerequisites
| Requirement              | Details                                                                 |
|--------------------------|-------------------------------------------------------------------------|
| IBM Cloud Account        | Free account sufficient → https://cloud.ibm.com/registration       |
| Terraform                | Installation on linux Below -- v1.5 or higher                                    |
| IBM Cloud CLI            | Installation on linux Below -- Latest version                                    |
| Tailscale Account        | Free account sufficient → https://tailscale.com                            |
| Docker Account           | Free account sufficient → https://docker.com                               |

## Security Note
This setup uses plain HTTP (no TLS encryption) and has no authentication, rate-limiting, or WAF. Port 30080 is exposed on worker nodes via NodePort. For production, add TLS (e.g., via Cloudflare or IBM Load Balancer) and auth as needed.

## Install IBM Cloud CLI

```bash
curl -fsSL https://clis.cloud.ibm.com/install/linux | sh
```
## Cloning the Repo
```bash
git clone https://github.com/BrandynLo/flask-tailscale-k8s
cd flask-tailscale-k8s
```
## Install Terraform
```bash
sudo apt update && sudo apt install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform -y
```

## Install the IBM Cloud Terraform provider plugin
```bash
ibmcloud plugin install cloud-internet-services
ibmcloud plugin install kubernetes-service
ibmcloud target -r us-south
terraform init -upgrade
```
## IBM Account Sync:
```bash
ibmcloud login --sso
```
<img width="1851" height="669" alt="image" src="https://github.com/user-attachments/assets/39f3923b-9b77-4341-9ea0-535e8df19e3d" />
- Insert the one-time code and select the region of your choice.
<img width="1174" height="669" alt="image" src="https://github.com/user-attachments/assets/c3bcac06-f13f-4815-960c-e3ed9d9aa083" />

## IBM - Syncing API Keys
[Access your API keys through https://cloud.ibm.com/
Navigate to Manage Identities > API KEYS > Create:

## Edit the Variables.tf file:
- You only need to change the variable in variable.tf 
- Change it to your current public vlan by typing in your current zone (dal10 is mine):

        ibmcloud ks vlans --zone dal10 
- This is what you need to change: 
<img width="1308" height="732" alt="image" src="https://github.com/user-attachments/assets/8b04d180-49b9-4bdd-ac2b-21ac713a5f98" />

Example:
ibmcloud ks vlans --zone dal10
ID        Name              **Number**   Type      Router  
1234567   vlan-pub-dal10    **2245**     public    xyzxyz.dal10  
2345678   vlan-priv-dal10   **2245**     private   xyzxyz.dal10

- USE THE NUMBER TYPE: Example here is 2245 and replace it in your variables.tf
- IF YOU ARE IN A DIFFERENT ZONE.
- Change your variables.tf default zone as well.
## Final Step: Cluster Creation with Terraform
```bash
cd terraform
terraform init
terraform plan
terraform apply
```
## Verify Cluster Creation:
<img width="1642" height="309" alt="Screenshot 2025-11-30 195613" src="https://github.com/user-attachments/assets/c5f1d2fd-7304-4037-a47a-82bd6baeba88" />
<img width="1919" height="1025" alt="image" src="https://github.com/user-attachments/assets/3e2ff5e3-4d43-4847-8a0f-2d1e52881f38" />

## Install pre-req files:
```bash
    ibmcloud plugin install container-registry -r "IBM Cloud"
    sudo apt install docker.io -y
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    docker --version
    kubectl get nodes
```
## Cluster creation-- Choose your personal cluster name
 ```bash       
        ibmcloud ks cluster config --cluster <your-cluster-id-or-name> --admin
```
Example: ibmcloud ks cluster config --cluster NameYourClusterHere --admin

## Build and Push your Docker Image
- Change  <Your-Namespace> to your namespace.
```bash
        cd flask-web-config
        docker build -t us.icr.io/your-namespace/flask-site:latest ./flask-app/
        docker push us.icr.io/your-namespace/flask-site:latest
```
- docker build cmd  → pushes the Image to be built/containzeried on our machine
- docker push cmd → pushes the Image to be uploaded to IBM Container Registry
## Example Of Mine, since Docker was not working correctly:
```bash 
    sudo docker build -t us.icr.io/brandynlabs/flask-site:latest .
    sudo mkdir -p /root/.docker
    sudo cp ~/.docker/config.json /root/.docker/
    sudo docker push us.icr.io/brandynlabs/flask-site:latest
    ibmcloud cr login
    ibmcloud cr namespace-add brandynlabs     
```
<img width="891" height="861" alt="Screenshot 2025-11-30 203605" src="https://github.com/user-attachments/assets/3c5c8405-7c47-4375-8e6c-2580f45147fa" />
<img width="822" height="215" alt="Screenshot 2025-11-30 203907" src="https://github.com/user-attachments/assets/1553e2b9-d642-4a17-9ce2-dc163d111de4" />

 ## Deploy the app
```bash
    cd Kubernetes
    kubectl apply -f deploy.yaml
```
- Command calls Kubernetes to create pods in the worker nodes and pulls the image to start the container in the pod(s)

Ignore error:
<img width="1746" height="98" alt="Screenshot 2025-11-30 204324" src="https://github.com/user-attachments/assets/87baf225-2d62-42b6-91c8-b04cf061efdf" />

## 5. Get the public URL
```bash
    kubectl get nodes -o wide
    kubectl get svc flash-site-svc
```
<img width="907" height="99" alt="image" src="https://github.com/user-attachments/assets/097ba4c4-7893-476c-90cc-63de31027dc5" />
<img width="1919" height="1035" alt="image" src="https://github.com/user-attachments/assets/ea05e98f-1aa2-4d63-9ae9-efe598e096a4" />

- Short-hand commands: 
```bash
      watch kubectl get pods
```
- Run this command to watch realtime when the Website goes live.
  ```bash
      watch kubectl get svc flask-site-svc
  ```
If you edit the deploy.yaml:
    ```bash
    kubectl apply -f your-manifest.yaml
    ```
Edit the app.y in flask-web-config directory to edit the website. 
```bash
    sudo docker build -t us.icr.io/brandynlabs/flask-site:latest .
    sudo docker push us.icr.io/brandynlabs/flask-site:latest
    kubectl apply -f deploy.yaml
    kubectl get svc flask-site-svc  # Shows 80:30080/TCP
    kubectl get nodes -o wide       # Confirm worker EXTERNAL-IP
```
## Cloudflare Setup:

```bash
    wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
    sudo dpkg -i cloudflared-linux-amd64.deb
```
<img width="938" height="349" alt="Screenshot 2025-11-30 210150" src="https://github.com/user-attachments/assets/40e9ec48-5615-4c15-a4ba-2dba0b67730b" />
- You may run this on a paid domain through Cloudflare or edit the yaml file to loadbalance through IBM. 

If you need to run CLOUDFLARE temporarily, you can: 
- On a different terminal, run:
  ```bash
      kubectl port-forward svc/flask-site-svc 8080:80
  ```
  <img width="736" height="67" alt="Screenshot 2025-11-30 210655" src="https://github.com/user-attachments/assets/c8cdce9d-5209-4f26-916d-ce1f743f85ff" />
- On a seperate terminal, run:
  ```bash
      cloudflared tunnel --url http://localhost:8080
  ```
<img width="950" height="397" alt="Screenshot 2025-11-30 210709" src="https://github.com/user-attachments/assets/4bcca38f-0f06-4241-ae97-deb67f34b850" />
- This will generate a temp cloudflare domain name. 
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
- Log into https://login.tailscale.com/admin/machines
<img width="1414" height="535" alt="Screenshot 2025-11-28 174951" src="https://github.com/user-attachments/assets/c323235f-589a-4fe7-9bc2-131cb2ba56eb" />
Generate an Auth key and replace it with:
<img width="1308" height="912" alt="image" src="https://github.com/user-attachments/assets/6d91a622-2bef-4c00-a957-f5f73805cc89" />

```bash
sudo tailscale up --auth-key=YOUR_Key_Goes_Here
```

- An example would be tskey-auth-k999999

```bash
kubectl create secret generic tailscale-auth --namespace tailscale \ --from-literal=TS_AUTHKEY=Key_Goes_Here
```
- Copy this to setup tailscale:

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
- Run this to verify pod is connected:

```bash
kubectl -n tailscale get pods
```

<img width="621" height="73" alt="Screenshot 2025-11-28 181224" src="https://github.com/user-attachments/assets/11e44b6b-ad0c-4086-b4f9-6c1a8ce8f588" />

- Verify connection of Cluster to TailScale

```bash
kubectl -n tailscale logs -f NAME_OF_YOUR_TAILSCALE
```
## Verify connection on TailScale:
<img width="471" height="223" alt="image" src="https://github.com/user-attachments/assets/286f0a6d-9473-4198-a5a8-05af9f15a79c" />
<img width="832" height="305" alt="image" src="https://github.com/user-attachments/assets/492c0a9b-0d47-4f9d-a9eb-f8b6878837a1" />

## Destroy Site:
```bash
kubectl get all --namespace=default
kubectl delete service flask-site-svc --namespace=default --force --grace-period=0
kubectl delete deployment flask-site service flask-site-svc ingress flask-site-ingress --ignore-not-found=true
terraform destroy
```

