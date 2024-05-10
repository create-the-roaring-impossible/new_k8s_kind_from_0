#!/usr/bin/env make

.PHONY:
	create_docker_registry \
	connect_registry_to_kind_network \
	disconnect_registry_to_kind_network \
	connect_registry_to_kind \
	create_kind_cluster \
	create_kind_cluster_with_registry \
	delete_docker_registry \
	delete_kind_cluster \
	install_gitlab \

# ------------------------------------------------------------------------------------------------------------------------------------------------------
# 	install_ingress_controller \
# 	install_dashboard \
# 	start_dashboard \
# 	install_prometheus \
# 	install_jaeger \
# 	install_hashicorp_vault \
# 	install_metric_server \
# 	install_awx \
# 	install_awx_cli \
# 	install_vagrant \
# 	install_k8s_via_kubeadm \
# 	install_rancher \
# 	install_awx_new \
# 	install_consul \

create_docker_registry:
	if ! docker ps | grep -q 'local-registry'; \
	then docker run -d -p 5000:5000 --name local-registry --restart=always registry; \
	else echo "---> local-registry is already running. There's nothing to do here."; \
	fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true;

disconnect_registry_to_kind_network:
	docker network disconnect kind local-registry || true;

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yml;

create_kind_cluster: create_docker_registry
	kind create cluster --name personal-kind.com --config ./kind_config.yml || true && \
	kubectl get nodes

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_docker_registry:
	docker stop local-registry && docker rm local-registry

delete_kind_cluster: delete_docker_registry
	kind delete cluster --name personal-kind.com

install_gitlab:
	helm repo add gitlab https://charts.gitlab.io/ && \
	helm repo update && \
	helm upgrade --install gitlab gitlab/gitlab \
  --timeout 600s \
  --set certmanager-issuer.email=slb6113@gmail.com \
  --set global.hosts.domain=personal-gitlab.com \
	--set global.edition=ce && \
	kubectl edit ingress -n default gitlab-webservice-default
# kubectl get all -n ingress-nginx && kubectl describe configmap -n ingress-nginx ingress-nginx-controller
# kubectl edit configmap -n ingress-nginx ingress-nginx-controller
# 	=> modify: 'allow-snippet-annotations: "false"' => 'allow-snippet-annotations: "true"'
# 	=> add: 'use-forwarded-headers: "true"'
# kubectl edit ingress -n cattle-system rancher
# 	=> add: 'ingressClassName: nginx' (into spec)
# 	=> add: 'nginx.ingress.kubernetes.io/configuration-snippet: |
#       more_set_headers "X-Forwarded-Proto: https";
# add: proxy_set_header X-Forwarded-Proto $scheme;
# add: proxy_set_header X-Forwarded-Ssl on;

# ------------------------------------------------------------------------------------------------------------------------------------------------------

# install_ingress_controller:
# 	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml && \
# 	sleep 5 && \
# 	kubectl wait --namespace ingress-nginx \
#   --for=condition=ready pod \
#   --selector=app.kubernetes.io/component=controller \
#   --timeout=90s

# install_dashboard:
# 	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml && \
# 	kubectl proxy && \
# 	kubectl apply -f dashboard-adminuser.yaml && \
#   kubectl -n kubernetes-dashboard create token admin-user

# start_dashboard:
# 	kubectl proxy && \
# 	kubectl -n kubernetes-dashboard create token admin-user

# install_prometheus:
# 	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts && \
# 	helm repo update && \
# 	helm install -f values.yaml prometheus prometheus-community/prometheus

# ##### TO FIX #####
# install_jaeger:
# 	echo "TO FIX"
# # 	helm repo add jaegertracing https://jaegertracing.github.io/helm-charts && \
# # 	helm repo update && \
# # 	helm upgrade -i jaeger jaegertracing/jaeger

# install_hashicorp_vault:
# 	helm repo add hashicorp https://helm.releases.hashicorp.com && \
# 	helm repo update && \
# 	helm upgrade -i vault hashicorp/vault

# install_metric_server:
# 	git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git && \
# 	cd kubernetes-metrics-server/ && \
# 	kubectl create -f . && \
# 	cd ..

# install_awx:
# 	helm repo add awx-operator https://ansible.github.io/awx-operator/ && \
# 	helm repo update && \
# 	helm search repo awx-operator && \
# 	helm install -n awx --create-namespace awx-operator awx-operator/awx-operator && \
# 	kubectl config set-context --current --namespace=awx && \
# 	kubectl apply -f awx-static-data-pvc.yaml && \
# 	kubectl apply -f awx-deployment.yaml

# install_awx_cli:
# 	python3 -m pip install --upgrade pip && \
# 	pip3 install awxkit && \
# 	awx --help && \
# 	pip3 install sphinx sphinxcontrib-autoprogram && \
# 	mkdir -p "awxkit/awxkit/cli/docs"

# install_vagrant:
# 	sudo apt install vagrant && \
# 	sudo mkdir -p "/etc/vbox/" && \
# 	echo "* 0.0.0.0/0 ::/0" | sudo tee -a /etc/vbox/networks.conf && \
# 	git clone https://github.com/scriptcamp/vagrant-kubeadm-kubernetes.git && \
# 	cd vagrant-kubeadm-kubernetes && \
# 	vagrant plugin install virtualbox_WSL2 && \
# 	export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1" && \
# 	export VAGRANT_WSL_WINDOWS_ACCESS_USER_HOME_PATH="/mnt/c/Users/m.cristiano/" && \
# 	export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox" && \
# 	export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0" && \
# 	export PATH="$PATH:/mnt/c/WINDOWS/system32" && \
# 	VAGRANT_LOG="debug" && \
# 	vagrant up

# install_k8s_via_kubeadm:
# 	sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && \
# 	sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab && \
# 	sudo yum install -y telnet && \
# 	sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config && \
# 	sudo dnf install -y iproute-tc && \
# 	sudo systemctl disable --now firewalld && \
# 	# sudo firewall-cmd --permanent --add-port=6443/tcp && sudo firewall-cmd --permanent --add-port=2379-2380/tcp && sudo firewall-cmd --permanent --add-port=10250/tcp && sudo firewall-cmd --permanent --add-port=10251/tcp && sudo firewall-cmd --permanent --add-port=10252/tcp && sudo firewall-cmd --reload && \ # TO RUN ONLY ON MASTER NODE
# 	# sudo firewall-cmd --permanent --add-port=10250/tcp && sudo firewall-cmd --permanent --add-port=30000-32767/tcp && sudo firewall-cmd --reload && \ # TO RUN ONLY ON WORKER NODES
# 	sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && \
# 	########################################################################################################################################################################################################
# 	sudo vi /etc/modules-load.d/k8s.conf # TO USE "CAT"
# overlay
# br_netfilter
# 	sudo modprobe overlay && sudo modprobe br_netfilter && sudo sh -c "echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables" sudo sh -c "echo '1' > /proc/sys/net/ipv4/ip_forward" && \
# 	sudo vi /etc/sysctl.d/k8s.conf # TO USE "CAT"
# net.bridge.bridge-nf-call-iptables  = 1
# net.ipv4.ip_forward                 = 1
# net.bridge.bridge-nf-call-ip6tables = 1
# 	sudo sysctl --system && \
# 	export VERSION=1.26 && export OS=CentOS_8 && \
# 	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo && \
# 	sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo && \
# 	sudo yum install -y cri-o && sudo systemctl enable crio && sudo systemctl start crio && \
# cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
# [kubernetes]
# name=Kubernetes
# baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
# enabled=1
# gpgcheck=1
# gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
# exclude=kubelet kubeadm kubectl
# EOF && \
# 	sudo setenforce 0 && \
# 	sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes && sudo systemctl enable --now kubelet && \
# 	sudo yum update -y && sudo yum upgrade -y && sudo yum update -y && sudo yum upgrade -y && \

# 	SINGLE-NODE:
# 		sudo kubeadm init --apiserver-advertise-address=ASDASDASD --pod-network-cidr=10.48.0.0/16 && \ # TO RUN ONLY ON MASTER NODE # sudo kubeadm init --apiserver-advertise-address=ASDASDASD --pod-network-cidr=10.244.0.0/16 && \ # TO RUN ONLY ON MASTER NODE
# 	MULTI-NODE:
# 		LOAD_BALANCER_IP="ASDASDASD" && sudo kubeadm init --apiserver-advertise-address "$LOAD_BALANCER_IP" --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint "$LOAD_BALANCER_IP:6443" --upload-certs && \ # sudo kubeadm init --apiserver-advertise-address "$LOAD_BALANCER_IP" --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint "$LOAD_BALANCER_IP:6443" --upload-certs && \ # TO RUN ONLY ON MASTER NODE

# 	kubectl taint nodes --all node-role.kubernetes.io/control-plane- && \ # TO RUN ONLY ON MASTER NODE
# 		sudo vi <filename> # TO USE "CAT", AND IF "Your Kubernetes control-plane has initialized successfully!" is in the output, AND TO RUN ONLY ON MASTER NODE
# 			mkdir -p $HOME/.kube
# 			sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# 			sudo chown $(id -u):$(id -g) $HOME/.kube/config
# 			OR
# 			export KUBECONFIG=/etc/kubernetes/admin.conf # IF YOU CAN'T RUN "sudo"
# 	kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml # TO RUN ONLY ON MASTER NODE

# 	# kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=interface=ens.*
# 	# kubectl set env daemonset/calico-node -n kube-system IP_AUTODETECTION_METHOD=kubernetes-internal-ip

# 	sudo swapoff -a && \
# 	sudo kubeadm join ASDASDASD:6443 --token ASDASDASD --discovery-token-ca-cert-hash sha256:ASDASDASD && \ # ON ALL WORKER NODES # sudo kubeadm join ASDASDASD:6443 --token p490k3.f97chirwoj2eu583 --discovery-token-ca-cert-hash sha256:b8bf0404641258411fbdc0660274f3ad05281a514d28f47de649437713e0caf6 && \ # ON ALL WORKER NODES
# 	sudo vi /etc/sysconfig/kubelet # TO USE "CAT", AND ON ALL NODES
# 		KUBELET_EXTRA_ARGS=--node-ip=ASDASDASD-11
# 	sudo swapoff -a && sudo systemctl daemon-reload && sudo systemctl restart kubelet && sudo systemctl status kubelet
# 	########################################################################################################################################################################################################
# 																																													# kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/sample-app.yaml && \
# 	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml && \
# 		sudo vi dashboard-adminuser.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# ---
# # dashboard-adminuser.yaml
# ---
# apiVersion: v1
# kind: ServiceAccount
# metadata:
#   name: admin-user
#   namespace: kubernetes-dashboard
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
#   name: admin-user
# roleRef:
#   apiGroup: rbac.authorization.k8s.io
#   kind: ClusterRole
#   name: cluster-admin
# subjects:
# - kind: ServiceAccount
#   name: admin-user
#   namespace: kubernetes-dashboard
# 		EOF && \
# 	kubectl apply -f dashboard-adminuser.yaml && \
#   # kubectl -n kubernetes-dashboard create token admin-user && \
# 	# kubectl proxy && \
# 	wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml && \ # TO RUN ONLY ON THE MASTER NODE
# 	sed -i 's/^        - --metric-resolution=15s$/        - --metric-resolution=15s\n        - --kubelet-insecure-tls/' components.yaml && \ # TO RUN ONLY ON THE MASTER NODE
# 	kubectl apply -f components.yaml && \ # TO RUN ONLY ON THE MASTER NODE
# 	# helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm repo update && \ # TO RUN ONLY ON THE MASTER NODE
# 	# helm search repo ingress-nginx -l && \ # TO RUN ONLY ON THE MASTER NODE
# 	# helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx --namespace ingress-nginx --set controller.service.type=NodePort --version 4.7.0 --create-namespace && \ # TO RUN ONLY ON THE MASTER NODE

# install_rancher:
# 	helm repo add rancher-stable https://releases.rancher.com/server-charts/stable && \ # TO RUN ONLY ON THE MASTER NODE
# 	helm repo update && \ # TO RUN ONLY ON THE MASTER NODE
# 	kubectl create namespace cattle-system && \ # TO RUN ONLY ON THE MASTER NODE
# 	kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.crds.yaml && \ # TO RUN ONLY ON THE MASTER NODE
# 	helm repo add jetstack https://charts.jetstack.io && \ # TO RUN ONLY ON THE MASTER NODE
# 	helm repo update && \ # TO RUN ONLY ON THE MASTER NODE
# 	helm upgrade -i cert-manager jetstack/cert-manager --namespace cert-manager --create-namespace --version v1.11.0 && \ # TO RUN ONLY ON THE MASTER NODE
# 		??
# 	helm pull rancher-stable/rancher && \ # TO RUN ONLY ON THE MASTER NODE
# 	mkdir -p "rancher-chart" && \ # TO RUN ONLY ON THE MASTER NODE
# 	tar zxvf rancher-2.7.4.tgz -C rancher-chart && \ # TO RUN ONLY ON THE MASTER NODE
# 	sed -i 's/^kubeVersion: < 1.26.0-0$/kubeVersion: < 1.28.0-0/' rancher-chart/rancher/Chart.yaml && \ # TO RUN ONLY ON THE MASTER NODE
# 	vi rancher-chart/rancher/templates/deployment.yaml # TO USE CAT, AND TO RUN ONLY ON THE MASTER NODE, AND SET (60 -> 600), AND  (5 -> 600)
# 	          livenessProbe:
# 							httpGet:
# 								path: /healthz
# 								port: 80
# 							initialDelaySeconds: {{.Values.livenessProbe.initialDelaySeconds | default 600 }}
# 							periodSeconds: {{ .Values.livenessProbe.periodSeconds | default 30 }}
# 						readinessProbe:
# 							httpGet:
# 								path: /healthz
# 								port: 80
# 							initialDelaySeconds: {{.Values.readinessProbe.initialDelaySeconds | default  600}}
# 		EOF && \
# 	sudo vi /etc/crio/crio.conf # TO USE "CAT", AND TO RUN ONLY ON THE MASTER NODE
# 		default_capabilities = [
# 						"MKNOD",
# 						"CHOWN",
# 						"DAC_OVERRIDE",
# 						"FSETID",
# 						"FOWNER",
# 						"NET_RAW",
# 						"SETGID",
# 						"SETUID",
# 						"SETPCAP",
# 						"NET_BIND_SERVICE",
# 						"SYS_CHROOT",
# 						"KILL",
# 		]
# 	EOF && \
# 	sudo systemctl restart crio
# 	helm upgrade -i rancher ./rancher-chart/rancher --namespace cattle-system --set hostname=192-168-50-11.sslip.io --set bootstrapPassword=admin --set auditLog.level=3 --set debug=true --set ingress.enable=false --set replicas=-1 --set global.cattle.psp.enabled=false && \ # TO RUN ONLY ON THE MASTER NODE (x2)
# 	kubectl edit issuer rancher -n cattle-system # TO RUN ONLY ON THE MASTER NODE (x2)
# 		spec:
# 			selfSigned: {}
# 	kubectl delete certificate tls-rancher-ingress -n cattle-system && \ # TO RUN ONLY ON THE MASTER NODE (x2)
# 	helm rollback fleet -n cattle-fleet-system && \ # TO RUN ONLY ON THE MASTER NODE (WHEN helm-operation-xxxxx fails)

# install_awx_new:
# 	helm repo add awx-operator https://ansible.github.io/awx-operator/ && helm repo update && \ # TO RUN ONLY ON THE MASTER NODE
# 	helm search repo awx-operator && \ # TO RUN ONLY ON THE MASTER NODE
# 	sudo vi local-storage-class.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: standard
# provisioner: kubernetes.io/no-provisioner
# volumeBindingMode: WaitForFirstConsumer
# 	kubectl apply -f local-storage-class.yaml && \ # TO RUN ONLY ON MASTER NODE
# 	sudo mkdir -p "/mnt/data/local-storage-pv-static" && sudo mkdir -p "/mnt/data/local-storage-pv-postgresql" && sudo mkdir -p "/mnt/data/local-storage-pv-claim" && \
# 	helm upgrade -i -n awx --create-namespace awx-operator awx-operator/awx-operator && \ # TO RUN ONLY ON THE MASTER NODE
# 	kubectl label nodes <your-node-name> kubernetes.io/awx-pvc=yep
# 	kubectl label node <your-node-name> kubernetes.io/aws-pvc=yep-
# 	sudo vi local-pv-postgresql.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: local-pv-postgresql
#   namespace: awx
# spec:
#   capacity:
#     storage: 100Gi
#   volumeMode: Filesystem
#   accessModes:
#   - ReadWriteOnce
#   persistentVolumeReclaimPolicy: Delete
#   storageClassName: standard
#   local:
#     path: /mnt/data/local-storage-pv-postgresql
#   nodeAffinity:
#     required:
#       nodeSelectorTerms:
#       - matchExpressions:
#         - key: kubernetes.io/awx-pvc
#           operator: In
#           values:
#           - yep
# 	sudo vi postgresql-pvc.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: postgres-13-awx-postgres-13-0
#   namespace: awx
# spec:
#   storageClassName: standard
#   volumeName: local-pv-postgresql
#   accessModes:
#     - ReadWriteOnce
#   resources:
#     requests:
#       storage: 100Gi
# 	sudo vi local-pv-awx-static-data.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: local-pv-static
#   namespace: awx
# spec:
#   capacity:
#     storage: 50Gi
#   volumeMode: Filesystem
#   accessModes:
#   - ReadWriteOnce
#   persistentVolumeReclaimPolicy: Delete
#   storageClassName: standard
#   local:
#     path: /mnt/data/local-storage-pv-static
#   nodeAffinity:
#     required:
#       nodeSelectorTerms:
#       - matchExpressions:
#         - key: kubernetes.io/awx-pvc
#           operator: In
#           values:
#           - yep
# 	sudo vi awx-static-data-pvc.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: awx-static-data-pvc
#   namespace: awx
# spec:
#   storageClassName: standard
#   volumeName: local-pv-static
#   accessModes:
#     - ReadWriteOnce
#   resources:
#     requests:
#       storage: 50Gi
# 	sudo vi local-pv-awx-projects-claim.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: local-pv-claim
#   namespace: awx
# spec:
#   capacity:
#     storage: 50Gi
#   volumeMode: Filesystem
#   accessModes:
#   - ReadWriteOnce
#   persistentVolumeReclaimPolicy: Delete
#   storageClassName: standard
#   local:
#     path: /mnt/data/local-storage-pv-claim
#   nodeAffinity:
#     required:
#       nodeSelectorTerms:
#       - matchExpressions:
#         - key: kubernetes.io/awx-pvc
#           operator: In
#           values:
#           - yep
# 	sudo vi awx-projects-claim-pvc.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# apiVersion: v1
# kind: PersistentVolumeClaim
# metadata:
#   name: awx-projects-claim
#   namespace: awx
# spec:
#   storageClassName: standard
#   volumeName: local-pv-claim
#   accessModes:
#     - ReadWriteOnce
#   resources:
#     requests:
#       storage: 50Gi
# 	sudo vi awx-deployment.yaml # TO USE "CAT", AND TO RUN ONLY ON MASTER NODE
# ---
# apiVersion: awx.ansible.com/v1beta1
# kind: AWX
# metadata:
#   name: awx
#   namespace: awx
# spec:
#   service_type: nodeport
#   hostname: awxprod.lottomatica.com
#   extra_settings:
#     - setting: CSRF_TRUSTED_ORIGINS
#       value:
#         - "https://awxprod.lottomatica.com"
#   postgres_configuration_secret: awx-postgres-configuration
# #  postgres_storage_class: standard
#   projects_persistence: true
#   projects_storage_access_mode: ReadWriteOnce
#   web_extra_volume_mounts: |
#     - name: static-data
#       mountPath: /var/lib/projects
#   extra_volumes: |
#     - name: static-data
#       persistentVolumeClaim:
#         claimName:  awx-static-data-pvc
# #	kubectl apply -f local-pv-postgresql.yaml
# 	kubectl apply -f local-pv-awx-static-data.yaml
# 	kubectl apply -f local-pv-awx-projects-claim.yaml
# #	kubectl apply -f postgresql-pvc.yaml
# 	kubectl apply -f awx-static-data-pvc.yaml
# 	kubectl apply -f awx-deployment.yaml
# 		kubectl delete -f awx-deployment.yaml
# 		kubectl delete -f awx-static-data-pvc.yaml
# #		kubectl delete -f postgresql-pvc.yaml
# 		kubectl delete -f local-pv-awx-projects-claim.yaml
# 		kubectl delete -f local-pv-awx-static-data.yaml
# #		kubectl delete -f local-pv-postgresql.yaml
# 		kubectl delete -f awx-ingress.yml
# 	kubectl edit pvc awx-projects-claim -n awx && \ # TO RUN ONLY ON MASTER NODE
# 		TO ADD "storageClassName: standard", "volumeName: local-pv-claim"
# 		# kubectl -n kube-system rollout restart deployment coredns
# 	clear && kubectl get secret awx-postgres-configuration -o go-template='{{range $k,$v := .data}}{{printf "%s: " $k}}{{if not $v}}{{$v}}{{else}}{{$v | base64decode}}{{end}}{{"\n"}}{{end}}' -n awx && kubectl get secrets -n awx | grep -i admin-password && kubectl get secret awx-admin-password -o jsonpath="{.data.password}" -n awx | base64 --decode ; echo
# 		# kubectl exec -it awx-postgres-13-0 -n awx -- psql -U awx
# 		# 	ALTER USER awx WITH PASSWORD 'ASDASDASD';
# 		# awx-manage migrate --noinput
# 	sudo vi external-postgresql-configuration.yaml
# ---
# apiVersion: v1
# kind: Secret
# metadata:
#   name: awx-postgres-configuration
#   namespace: awx
# stringData:
#   host: bep-awxdb03
#   port: "5432"
#   database: awxdb
#   username: awx
#   password: ASDASDASD # ASDASDASD
#   sslmode: prefer # disable
#   type: unmanaged
# type: Opaque
# 	kubectl apply -f external-postgresql-configuration.yaml
# 	kubectl apply -f awx-deployment.yaml

# 	kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
# 	kubectl exec -it dnsutils -n default -- nslookup google.com
# 	kubectl exec -it dnsutils -n default -- cat /etc/resolv.conf
# 	kubectl logs --namespace=kube-system -l k8s-app=kube-dns
# 	nslookup kubernetes.default

# install_consul:
# 	sudo yum install -y yum-utils
# 	sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
# 	sudo yum -y install consul
# 	consul version
# 	sudo netstat -anp | grep "consul"
# 	export DATACENTER="k8s" && export DOMAIN="consul" && export CONSUL_DATA_DIR="/etc/consul/data" && export CONSUL_CONFIG_DIR="/etc/consul/config" && export CONSUL_BIND_ADDR="0.0.0.0" && export CONSUL_ADVERTISE_ADDR="ASDASDASD"
# 	vi generate_consul_server_config.sh
# 	chmod +x generate_consul_server_config.sh
# 	sudo ./generate_consul_server_config.sh
# 	clear && sudo consul agent -node=consul -config-dir=${CONSUL_CONFIG_DIR}
# 	clear && consul acl bootstrap --format json > ./acl-token-bootstrap.json
# 	cat ./acl-token-bootstrap.json
# 	export CONSUL_HTTP_TOKEN=ASDASDASD # or `cat ./acl-token-bootstrap.json | jq -r ".SecretID"`
# 		sudo vi /etc/consul/data/acl-bootstrap-reset
# 		consul acl bootstrap
# 	consul info
# 	consul members
# 	consul catalog nodes -detailed
# 	curl localhost:8500/v1/catalog/nodes
# 	dig @127.0.0.1 -p 8600 consul.service.consul
# 	sudo touch /etc/consul.d/k8s.json
# 	sudo vi touch /etc/consul.d/k8s.json => {"service": {"id": "k8s_node_1", "name": "k8s", "tags": ["k8s"], "port": 6443, "address": "ASDASDASD"}, "service": {"id": "k8s_node_2", "name": "k8s", "tags": ["k8s"], "port": 6443, "address": "192.168.50.11"}}
# 	consul services register /etc/consul.d/k8s.json
# 	dig @127.0.0.1 -p 8600 k8s.service.consul
# 	consul reload

# ##### awx-ingress #####
# controller_tag=$(curl -s https://api.github.com/repos/kubernetes/ingress-nginx/releases/latest | grep tag_name | cut -d '"' -f 4)
# echo $controller_tag
# wget https://github.com/kubernetes/ingress-nginx/archive/refs/tags/${controller_tag}.tar.gz
# tar xvf ${controller_tag}.tar.gz
# cd ingress-nginx-${controller_tag}
# cd charts/ingress-nginx/
# kubectl create namespace ingress-nginx
# helm install -n ingress-nginx ingress-nginx -f values.yaml .
# kubectl get all -n ingress-nginx
# cd ..
# cd ..
# vi charts/ingress-nginx/values.yaml => metti gli IP nella lista "externalIPs"
# cd charts/ingress-nginx/
# helm upgrade --install -n ingress-nginx ingress-nginx -f values.yaml .
# cd ..
# cd ..
# cd ..
# sudo vi awx-ingress.yml
# kubectl apply -f awx-ingress.yml

# ##### rook #####
# kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.1/cert-manager.yaml
# helm repo add rook-release https://charts.rook.io/release
# helm repo update
# helm install --create-namespace --namespace rook-ceph rook-ceph rook-release/rook-ceph -f values.yaml
# 	vi cluster.yaml
# <see "cluster.yaml" file>
# kubectl create -f cluster.yaml