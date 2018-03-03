# enmasse-aks

About deploying EnMasse on a Kubernetes cluster provided by Azure Container Service (AKS).

## Azure CLI

In order to interact with Azure and handling all the related services and resources, the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) can be used instead of the [web portal](https://portal.azure.com).

### Installation

There are different ways for installing the Azure CLI 2.0 in order to manage Azure resources from the console.
More information on doing that [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

If you have Docker already installed on the PC, a really simple way could be using it to run a standalone Linux container with the Azure CLI 2.0 pre-installed. The big advantage of this solution is to start really quickly without installing any tools on the local PC.
More information on doing that [here](https://docs.microsoft.com/en-us/cli/azure/run-azure-cli-docker?view=azure-cli-latest).

In order to pull and run the above container, execute the following command :

    docker run -it microsoft/azure-cli

The Azure CLI 2.0 is now available as `az` command in the `/usr/local/bin` path.
Just to check that all is working fine and `az` is available in the running container, execute :

    bash-4.3# az --help

### Login

The next step is executing the login as described [here](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest) and the simplest way is the "Interactive login".

    az login

And follow the procedure using the provided code in the related page in the web browswer.
On success, JSON string is printed on the console containing all the information about the logged user and the related Azure subscription.

## Azure Container Service (AKS)

AKS is an Azure service which simplify the deployment, management and operations of Kubernetes. In order to deploy a Kubernetes cluster on Azure, you can avoid to create different VMs for the nodes and then installing Kubernetes on the bare metal making the cluster.
AKS is a fully managed Kubernetes container orchestration service which deploy a Kubernetes cluster for you in a really simple way.

> Other than Kubernetes, AKS supports other orchestrators like Docker Swarm or CD/OS

### Enabling AKS

At the time of writing, AKS is still in preview so it's needed to "enable" it for the current subscription.

    az provider register -n Microsoft.ContainerService

The Kubernetes cluster that we are going to deploy is made by different Azure resources which need to be grouped. For this reason creating a resource group is the next step in the cluster creation process.

    az group create --name k8sgroup --location westeurope

### Provisioning the Kubernetes cluster

In order to deploy a Kubernetes cluster named `k8scluster` with only `1` node and using the previously created resource group `k8sgroup` for grouping all the related Azure resources, run the following command.

    az aks create --resource-group k8sgroup --name k8scluster --node-count 1 --generate-ssh-keys

The command needs several minutes to complete and after that it return a JSON string with all the cluster information.

### Connect to the cluster

In order to interact with the Kubernetes cluster, the `kubectl` tool is needed. For installation and set up information see [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

Another simple way to install `kubectl` is through the Azure CLI.

    az aks install-cli

Finally, `kubectl` needs to be configured in order to connect the Kubernetes cluster.

    az aks get-credentials --resource-group k8sgroup --name k8scluster

To check the connection to the cluster, let's show the nodes.

    kubectl get nodes