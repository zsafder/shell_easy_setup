#!/bin/bash -e
apt update -y
#install zsh
apt install -y zsh
chsh -s $(which zsh)
yes | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
#install zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
sed -i "/plugins=(git)/c\plugins=(git extract git-extras vagrant kubectl helm zsh-syntax-highlighting zsh-autosuggestions)" ~/.zshrc
#install python-pip
apt install -y python-pip
#install aws-cli
/usr/bin/pip install awscli
ln -s /usr/local/bin/aws /usr/bin/aws
apt install -y ec2-api-tools
REGION=`/usr/bin/ec2metadata | grep "^availability-zone:" | awk '{print substr($2, 1, length($2)-1)}'`
aws configure set default.region $REGION
aws configure set default.output yaml
#update PATH 
echo 'export PATH=$PATH:~/bin' >> ~/.zshrc
#install eks
curl --location "https://github.com/weaveworks/eksctl/releases/download/0.17.0-rc.0/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
mv /tmp/eksctl /usr/local/bin
mkdir -p ~/.zsh/completion/
eksctl completion zsh > ~/.zsh/completion/_eksctl
echo 'fpath=($fpath ~/.zsh/completion)' >> ~/.zshrc
echo 'autoload -U compinit' >> ~/.zshrc
echo 'compinit' >> ~/.zshrc
#install aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mkdir -p ~/bin && cp ./aws-iam-authenticator ~/bin/aws-iam-authenticator
#install kubectl (aws varient)
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/kubectl
chmod +x ./kubectl
mkdir -p ~/bin && cp ./kubectl ~/bin/kubectl
echo '. <(kubectl completion zsh)' >>  ~/.zshrc
#install helm package manager
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod 700 get_helm.sh
./get_helm.sh
## Add official stable Helm repository
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
#install stern
wget https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64
chmod +x stern_linux_amd64
mv stern_linux_amd64 /usr/local/bin/stern