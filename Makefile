#!/usr/bin/env make

.PHONY:
	install_kubectl \
	install_helm \
	install_kind \

# install_vagrant \

	create_docker_registry \
	connect_registry_to_kind_network \
	disconnect_registry_to_kind_network \
	connect_registry_to_kind \
	create_kind_cluster \
	create_kind_cluster_with_registry \
	delete_docker_registry \
	delete_kind_cluster \
	install_calico \
	uninstall_calico \
	install_metrics_server \
	uninstall_metrics_server \
	install_keda \
	uninstall_keda \

# install_ado_agents \
# uninstall_keda \
# install_gh_runners \
# uninstall_gh_runners \

	install_gl_runners \
	uninstall_gl_runners \

# which_is_my_external_ip \

# install_hashicorp_vault \
# port_forward_hashicorp_vault \
# uninstall_hashicorp_vault \

# install_argo \
# get_admin_password_argo \
# port_forward_argo \
# uninstall_argo \

# install_flux \
# get_admin_password_flux \
# port_forward_flux \
# uninstall_flux \

# ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- #

install_kubectl:
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
	chmod +x kubectl && \
	mv kubectl /usr/local/bin/kubectl

install_helm:
	curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
	chmod 700 get_helm.sh && \
	./get_helm.sh

install_kind:
	curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.30.0/kind-linux-amd64 # TODO: to parametrize "v0.30.0" version
	chmod +x ./kind
	sudo mv ./kind /usr/local/bin/kind

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
	kubectl get nodes -o wide

create_kind_cluster_with_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_docker_registry:
	$(MAKE) disconnect_registry_to_kind_network && docker stop local-registry && docker rm local-registry

delete_kind_cluster: delete_docker_registry
	kind delete cluster --name personal-kind

install_calico:
	helm repo add projectcalico https://docs.tigera.io/calico/charts && \
	helm repo update && \
	helm upgrade --install calico projectcalico/tigera-operator --version v3.30.3 --namespace tigera-operator --create-namespace

uninstall_calico:
	helm uninstall calico -n tigera-operator

install_metrics_server:
	helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/ && \
	helm repo update && \
	helm upgrade --install metrics-server -n default metrics-server/metrics-server && \ # TODO: to specify version
	kubectl patch deployment metrics-server -n default --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

uninstall_metrics_server:
	helm uninstall metrics-server -n default

install_keda:
	helm repo add kedacore https://kedacore.github.io/charts && \
	helm repo update && \
	helm upgrade --install keda kedacore/keda --namespace keda --create-namespace # TODO: to specify version

uninstall_keda:
	helm uninstall keda -n keda

# install_ado_agents:
# 	asd
# 	asd  # TODO: to specify version

# uninstall_ado_agents:
# 	helm uninstall asd -n devops

# install_gh_runners:
# 	asd
# 	asd  # TODO: to specify version

# uninstall_gh_runners:
# 	helm uninstall asd -n devops

install_gl_runners:
	@read -p "Enter GitLab registration token: " REGISTRATION_TOKEN && \
    echo "Using registration token: $$REGISTRATION_TOKEN" && \
	helm repo add gitlab https://charts.gitlab.io && \
	helm repo update && \
	helm upgrade --install gitlab-runner gitlab/gitlab-runner --namespace devops --create-namespace \
		--set gitlabUrl="https://gitlab.com/" \
		--set runnerRegistrationToken=$$REGISTRATION_TOKEN \
		--set unregisterRunners=true \
		--set rbac.create=true \
		--set serviceAccount.create=true # TODO: to specify version

uninstall_gl_runners:
	helm uninstall gitlab-runner -n devops



# which_is_my_external_ip:
# 	@ifconfig | grep "inet " | grep -v  "127.0.0.1" | grep -v  "172.17" | awk -F " " '{print $$2}' | head -n1



# install_hashicorp_vault:
# 	helm repo add hashicorp https://helm.releases.hashicorp.com && \
# 	helm repo update && \
# 	helm upgrade -i vault hashicorp/vault \
# 	--create-namespace --namespace vault

# port_forward_hashicorp_vault:
# 	kubectl --namespace vault port-forward svc/vault 8300:8200

# uninstall_hashicorp_vault:
# 	helm uninstall vault -n vault



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