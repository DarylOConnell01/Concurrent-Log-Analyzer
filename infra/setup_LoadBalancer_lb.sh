## --- Task 1: Create multiple web server instances (VMs & Firewall) ---

# 1. Create web1 Instance
gcloud compute instances create web1 \
    --zone=us-west4-a \
    --machine-type=e2-small \
    --tags=network-lb-tag \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "<h3>Web Server: web1</h3>" | tee /var/www/html/index.html'

# 2. Create web2 Instance
gcloud compute instances create web2 \
    --zone=us-west4-a \
    --machine-type=e2-small \
    --tags=network-lb-tag \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "<h3>Web Server: web2</h3>" | tee /var/www/html/index.html'

# 3. Create web3 Instance
gcloud compute instances create web3 \
    --zone=us-west4-a \
    --machine-type=e2-small \
    --tags=network-lb-tag \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "<h3>Web Server: web3</h3>" | tee /var/www/html/index.html'

# 4. Create Firewall Rule (Client Traffic to NLB VMs)
gcloud compute firewall-rules create www-firewall-network-lb \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --target-tags network-lb-tag


# --- Task 2: Configure the load balancing service (Network LB) ---

# 5. Create the Static External IP Address
gcloud compute addresses create network-lb-ip-1 --region=us-west4

# 6. Create the Target Pool
gcloud compute target-pools create www-pool --region=us-west4

# 7. Add Instances to the Target Pool
gcloud compute target-pools add-instances www-pool \
    --instances=web1,web2,web3 \
    --zone=us-west4-a

# 8. Create the Health Check Firewall Rule (NLB Probes)
gcloud compute firewall-rules create allow-health-check-nlb \
    --network default \
    --action allow \
    --target-tags network-lb-tag \
    --source-ranges 130.211.0.0/22,35.191.0.0/16 \
    --rules tcp:80

# 9. Create the Forwarding Rule (Links IP, Pool, and Port 80) 
gcloud compute forwarding-rules create www-rule \
    --region=us-west4 \
    --ports=80 \
    --address=network-lb-ip-1 \
    --target-pool=www-pool


# --- Task 3: Create an HTTP load balancer (Application LB) ---

# 10. Create the Backend Template (for MIG)
gcloud compute instance-templates create lb-backend-template \
    --machine-type=e2-medium \
    --tags=allow-health-check \
    --image-family=debian-12 \
    --image-project=debian-cloud \
    --metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "<h1>Welcome to a global load balancer!</h1>" | tee /var/www/html/index.html'

# 11. Create the Managed Instance Group (MIG)
gcloud compute instance-groups managed create lb-backend-group \
    --base-instance-name=lb-backend-group \
    --size=3 \
    --template=lb-backend-template \
    --zone=us-west4-a

# 12. Create the HTTP Health Check
gcloud compute health-checks create http http-basic-check --request-path=/ --port=80

# 13. Create the Health Check Firewall Rule (HTTP LB Probes - uses 'allow-health-check' tag)
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80

# 14. Create the Backend Service
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

# 15. Add the MIG to the Backend Service
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=us-west4-a \
    --global

# 16. Create the URL Map
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

# 17. Create the Target HTTP Proxy
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map-http

# 18. Create the Global IP Address
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global

# 19. Create the Global Forwarding Rule (Entry point) 
gcloud compute forwarding-rules create http-fw-rule \
    --address=lb-ipv4-1 \
    --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80 Define the Instance Template 
gcloud compute instance create web1 \
--machine-type=e2-small \
--region=us-central1 \
--image-family=debian-12 \
--image-project=debian-cloud\ 
--tags=netwrok_lb-tags


# Define the Instance Template
gcloud compute instance create web2 \
--machine-type=e2-small \
--region=us-central1 \
--image-family=debian-12 \
--image-project=debian-cloud\ 
--tags=network-lb-tags



# Define the Instance Template
gcloud compute instance create web3 \
--machine-type=e2-small \
--region=us-central1 \
--tags=netwrok_lb-tags \
--image-family=debian-12 \
--image-project=debian-cloud

#!/bin/bash
apt-get update
apt-get install apache2 -y
service apache2 restart
echo "<h3>Web Server: web-number</h3>" | tee /var/www/html/index.html

curl http://[IP_ADDRESS]

#Reserve a Static External IP Address
gcloud compute addresses create network-lb-ip-1 \
--region=us-west4

#create a target pool
gloud compute target-pools create www-pool \
--region=us-west4

gcloud compute target-pools add-instance www-pool \
--intances=web1, web2, web3 \
--zone=us-west4-a

#create a Health Check Firewall Rule
gloud compute firewall-rules create allow-health-check-nlb \
--network default \
--action allow \
--target-tags network-lb-tag \
--source-ranges 130.211.0.0/22,35.191.0.0/16 \
--rules tcp:80

#Create the forwarding Rule
gcloud compute forwarding rules create www-rule \
--region=us-west4 \
--address=network-lb-ip-1 \
--target-pool=www-pool 

#Setup Instance Template and MIG
gcloud compute instance-templates create lb-backend-template \
--machine-type=e2-small \
--tags=allow-health-check \
--image-family=debian-12 \
--image-project=debian-cloud \
--metadata=startup-scrip=--metadata=startup-script='#!/bin/bash
      apt-get update
      apt-get install apache2 -y
      service apache2 restart
      echo "<h1>Welcome to a global load balancer!</h1>" | tee /var/www/html/index.html'

# Create the Managed Instance Group (MIG)
gcloud compute instance-groups managed create lb-backend-group \
    --base-instance-name=lb-backend-group \
    --size=3 \
    --template=lb-backend-template \
    --zone=us-west4-a

# Create the HTTP Health Check
gcloud compute health-checks create http http-basic-check --request-path=/ --port=80

#Creat the Health Check Firewall Rule (Required for HTTP LB Probes)
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --target-tags=allow-health-check \
    --rules=tcp:80


#Create the Backend Service
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global

# Add the MIG to the Backend Service
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=us-west4-a \
    --global

#Create the URL Map (Routes requests to the backend service)
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service

#Create the Target HTTP Proxy
gcloud compute target-http-proxies create http-lb-proxy \
   --url-map web-map-http

 
#Create the Global IP Address
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global


#Create the Global Forwarding Rule (The entry point, links IP to Proxy)
gcloud compute forwarding-rules create http-fw-rule \
    --address=lb-ipv4-1 \
 















  UW PICO 5.09                                       File: setup_LoadBalancer_lb.sh                                       Modified  

#Create the Backend Service
gcloud compute backend-services create web-backend-service \
    --protocol=HTTP \
    --port-name=http \
    --health-checks=http-basic-check \
    --global
      
# Add the MIG to the Backend Service
gcloud compute backend-services add-backend web-backend-service \
    --instance-group=lb-backend-group \
    --instance-group-zone=us-west4-a \
    --global

#Create the URL Map (Routes requests to the backend service)
gcloud compute url-maps create web-map-http \
    --default-service web-backend-service
    
#Create the Target HTTP Proxy
gcloud compute target-http-proxies create http-lb-proxy \
   --url-map web-map-http


#Create the Global IP Address
gcloud compute addresses create lb-ipv4-1 \
    --ip-version=IPV4 \
    --global
    
    
#Create the Global Forwarding Rule (The entry point, links IP to Proxy)
gcloud compute forwarding-rules create http-fw-rule \
    --address=lb-ipv4-1 \
    -  --global \
    --target-http-proxy=http-lb-proxy \
    --ports=80
