# enmasse-aks

About deploying EnMasse on Azure Container Service (AKS)

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
