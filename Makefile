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
	which_is_my_external_ip \
	install_metrics_server \
	uninstall_metrics_server \
	install_hashicorp_vault \
	port_forward_hashicorp_vault \
	uninstall_hashicorp_vault \
	install_jenkins \
	get_admin_password_jenkins \
	port_forward_jenkins \
	uninstall_jenkins \

# install_argo \
# get_admin_password_argo \
# port_forward_argo \
# uninstall_argo \
# install_vagrant \
# install_flux \
# get_admin_password_flux \
# port_forward_flux \
# uninstall_flux \

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- #

create_docker_registry:
	if ! docker ps | grep -q 'local-registry'; \
	then docker run -d -p 5000:5000 --name local-registry --restart=always registry; \
	else echo "=====> 'local-registry' is already running, so there's nothing to do here!!"; \
	fi

connect_registry_to_kind_network:
	docker network connect kind local-registry || true;

disconnect_registry_to_kind_network:
	docker network disconnect kind local-registry || true;

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yml;

create_kind_cluster: create_docker_registry
	kind create cluster --name personal-kind --config ./kind_config.yml || true && \
	kubectl get nodes

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_docker_registry:
	docker stop local-registry && docker rm local-registry

delete_kind_cluster: delete_docker_registry
	kind delete cluster --name personal-kind

which_is_my_external_ip:
	@ifconfig | grep "inet " | grep -v  "127.0.0.1" | grep -v  "172.17" | awk -F " " '{print $$2}' | head -n1

install_metrics_server:
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ && \
	helm upgrade --install metrics-server -n default metrics-server/metrics-server && \
	kubectl patch deployment metrics-server -n default --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

uninstall_metrics_server:
	helm uninstall metrics-server -n default

install_hashicorp_vault:
	helm repo add hashicorp https://helm.releases.hashicorp.com && \
	helm repo update && \
	helm upgrade -i vault hashicorp/vault \
	--create-namespace --namespace vault

port_forward_hashicorp_vault:
	kubectl --namespace vault port-forward svc/vault 8300:8200

uninstall_hashicorp_vault:
	helm uninstall vault -n vault

install_jenkins:
	helm repo add jenkins https://charts.jenkins.io && \
	helm repo update && \
	helm upgrade --install jenkins jenkins/jenkins \
	--create-namespace --namespace jenkins \
	--timeout 600s

get_admin_password_jenkins:
	kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

port_forward_jenkins: get_admin_password_jenkins
	kubectl --namespace jenkins port-forward svc/jenkins 8081:8080

uninstall_jenkins:
	helm uninstall jenkins -n jenkins

# install_argo:
# 	helm repo add jenkins https://charts.jenkins.io && \
# 	helm repo update && \
# 	helm upgrade --install jenkins jenkins/jenkins \
# 	--create-namespace --namespace jenkins \
# 	--timeout 600s

# get_admin_password_argo:
# 	kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# port_forward_argo: get_admin_password_jenkins
# 	kubectl --namespace jenkins port-forward svc/jenkins 8081:8080

# uninstall_argo:
# 	helm uninstall argo -n argo

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

# install_flux:
# 	helm repo add jenkins https://charts.jenkins.io && \
# 	helm repo update && \
# 	helm upgrade --install jenkins jenkins/jenkins \
# 	--create-namespace --namespace jenkins \
# 	--timeout 600s

# get_admin_password_flux:
# 	kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# port_forward_flux: get_admin_password_jenkins
# 	kubectl --namespace jenkins port-forward svc/jenkins 8081:8080

# uninstall_flux:
# 	helm uninstall flux -n flux