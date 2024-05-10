tar -C ~/.local -xzf /tmp/nerdctl.tar.gz libexec
echo 'export CNI_PATH=~/.local/libexec/cni' >> ~/.bashrc
source ~/.bashr
cd /tmp/
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
