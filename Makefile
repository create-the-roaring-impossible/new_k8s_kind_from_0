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
	install_gitlab \
	get_root_password_gitlab \
	port_forward_gitlab \
	uninstall_gitlab \
	install_sonarqube \
	get_admin_password_sonarqube \
	port_forward_sonarqube \
	uninstall_sonarqube \


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

which_is_my_external_ip:
	@ifconfig | grep "inet " | grep -v  "127.0.0.1" | grep -v  "172.17" | awk -F " " '{print $$2}' | head -n1

install_metrics_server:
	wget https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/high-availability-1.21+.yaml; \
	grep -q "        - --kubelet-insecure-tls" high-availability-1.21+.yaml || sed -i '/        - --metric-resolution=15s/a\        - --kubelet-insecure-tls' high-availability-1.21+.yaml; \
	kubectl apply -f high-availability-1.21+.yaml;

uninstall_metrics_server:
	kubectl delete -f high-availability-1.21+.yaml

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

install_gitlab:
	helm repo add gitlab https://charts.gitlab.io/ && \
	helm repo update && \
	helm upgrade --install gitlab gitlab/gitlab \
	--create-namespace --namespace gitlab \
	--timeout 600s \
	--set global.edition=ce \
	--set certmanager-issuer.email=slb6113@gmail.com \
	--set global.hosts.domain=personal-gitlab.com \
	--set global.hosts.https=false \
	--set global.hosts.gitlab.name=gitlab.personal-gitlab.com \
	--set global.hosts.gitlab.https=false \
	--set global.hosts.registry.name=registry.personal-gitlab.com \
	--set global.hosts.registry.https=false \
	--set global.hosts.minio.name=minio.personal-gitlab.com \
	--set global.hosts.minio.https=false \
	--set global.hosts.smartcard.name=smartcard.personal-gitlab.com \
	--set global.hosts.kas.name=kas.personal-gitlab.com \
	--set global.hosts.pages.name=pages.personal-gitlab.com \
	--set global.hosts.pages.https=false \
	--set global.hosts.ssh=pages.personal-gitlab.com \
	--set global.ingress.configureCertmanager=false \
	--set global.ingress.tls.enabled=false \
	--set gitlab-runner.install=false \
	--set global.resources.requests.cpu=2 \
	--set global.resources.requests.memory=4Gi \
	--set global.resources.limits.cpu=4 \
	--set global.resources.limits.memory=8Gi

get_root_password_gitlab:
	kubectl get secret -n gitlab gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo

port_forward_gitlab: get_root_password_gitlab
	kubectl port-forward -n gitlab svc/gitlab-webservice-default 8182:8181

uninstall_gitlab:
	helm uninstall gitlab -n gitlab

install_sonarqube:
	helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube && \
	helm repo update && \
	helm upgrade --install sonarqube sonarqube/sonarqube \
	--create-namespace --namespace sonarqube \
	--set image.tag="lts-community" \
	--set community.enabled=true \
	--set resources.requests.memory=2048M \
	--set resources.requests.cpu=400m \
	--set resources.requests.ephemeral-storage=1536M \
	--set resources.limits.memory=5944M \
	--set resources.limits.cpu=800m \
	--set resources.limits.ephemeral-storage=500Gi \
	--timeout 600s

port_forward_sonarqube:
	kubectl --namespace sonarqube port-forward svc/sonarqube-sonarqube 9001:9000

uninstall_sonarqube:
	helm uninstall sonarqube -n sonarqube

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