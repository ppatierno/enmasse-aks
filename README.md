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

### Delete the cluster

When the cluster isn't needed anymore, it's possible to delete the entire resource group.

    az group delete --name k8sgroup --yes --no-wait

## EnMasse

At the time of writing the latest EnMasse version is the 0.17.0 that you can dowload from the [releases page](https://github.com/EnMasseProject/enmasse/releases) or just running the following command for unpacking it as well.

    wget https://github.com/EnMasseProject/enmasse/releases/download/0.17.0/enmasse-0.17.0.tgz
    tar -xvzf enmasse-0.17.0.tgz

Then move to the unpacked folder and run the deployment script for Kubernetes :

    cd enmasse-0.17.0
    deploy-kubernetes.sh

After a while a set of Pods should be running :

    kubectl get pods -n enmasse

    NAME                                 READY     STATUS    RESTARTS   AGE
    address-controller-342601593-mqf5c   1/1       Running   0          59s
    admin-828300946-r6w0s                2/2       Running   0          53s
    mqtt-gateway-1247149937-8gqcb        2/2       Running   0          53s
    mqtt-lwt-3794926199-365rh            1/1       Running   0          52s
    none-authservice-2472962060-h8ltm    1/1       Running   0          1m
    qdrouterd-3390838898-33jx5           2/2       Running   1          52s
    subserv-3643744501-n2925             1/1       Running   0          52s

Other than the deployed services, it's useful to exposing the REST API as well.

    kubectl apply -f kubernetes/addons/external-lb.yaml -n enmasse    

Taking a look at services, some of them are exposed externally through load balancer and external IP addresses.

    kubectl get services -n enmasse

    NAME                 CLUSTER-IP     EXTERNAL-IP      PORT(S)                                           AGE
    address-controller   10.0.90.122    <none>           443/TCP                                           6m
    console              10.0.206.150   <none>           8081/TCP                                          6m
    console-external     10.0.201.217   40.68.154.198    8081:31810/TCP                                    6m
    messaging            10.0.219.206   <none>           5672/TCP,5671/TCP,55671/TCP,56671/TCP,55672/TCP   6m
    messaging-external   10.0.92.180    52.166.123.203   5671:31207/TCP                                    6m
    mqtt                 10.0.239.201   <none>           1883/TCP,8883/TCP                                 6m
    mqtt-external        10.0.24.149    52.174.51.191    8883:32718/TCP                                    6m
    none-authservice     10.0.247.190   <none>           5671/TCP                                          6m
    queue-scheduler      10.0.85.63     <none>           5672/TCP                                          6m
    ragent               10.0.21.137    <none>           5671/TCP                                          6m
    restapi-external     10.0.46.5      13.93.81.228     443:30772/TCP                                     2m
    subscription         10.0.177.25    <none>           5672/TCP                                          6m


The web console for handling address is accessible through the `console-external` service, opening a browser at `https://40.68.154.198:8081/#/dashboard`.
The related REST API are accessible at `https://13.93.81.228:443/apis/enmasse.io/v1`.

### Deploying addresses

In order to create some addresses as examples, use the following `addresses.json`.

```json
{
  "apiVersion": "enmasse.io/v1",
  "kind": "AddressList",
  "items": [
    {
      "spec": {
        "address": "myqueue",
        "type": "queue",
        "plan": "sharded-queue"
      }
    },
    {
      "spec": {
        "address": "mytopic",
        "type": "topic",
        "plan": "sharded-topic"
      }
    },
    {
      "spec": {
        "address": "myanycast",
        "type": "anycast",
        "plan": "standard-anycast"
      }
    },
    {
      "spec": {
        "address": "mymulticast",
        "type": "multicast",
        "plan": "standard-multicast"
      }
    }
  ]
}
```

It's needed to POST this JSON file to the REST API.

    curl -X POST -H "content-type: application/json" --data-binary @addresses.json -k https://13.93.81.228:443/apis/enmasse.io/v1/addresses/default

The addresses will be created in the `default` address space.

### Connecting with AMQP

Using Qpid Proton Python examples, [sender](http://qpid.apache.org/releases/qpid-proton-0.18.0/proton/python/examples/simple_send.py.html) and [receiver](http://qpid.apache.org/releases/qpid-proton-0.18.0/proton/python/examples/simple_recv.py.html).

Running the receiver for getting 10 messages.

    ./simple_recv.py -a "amqps://52.166.123.203:5671/myanycast" -m 10

Running the sender for sending 10 messages.

    ./simple_send.py -a "amqps://52.166.123.203:5671/myanycast" -m 10

### Connecting with MQTT

First getting TLS certificates.

    mkdir -p certs
    kubectl get secret external-certs-mqtt -o jsonpath='{.data.tls\.crt}' -n enmasse | base64 -d > certs/tls.crt

Using MQTT [sender](https://raw.githubusercontent.com/EnMasseProject/enmasse/master/documentation/design_docs/examples/tls_mqtt_send.py) and [receiver](https://raw.githubusercontent.com/EnMasseProject/enmasse/master/documentation/design_docs/examples/tls_mqtt_recv.py).

Running the receiver.

    ./tls_mqtt_recv.py -c 52.174.51.191 -p 8883 -t mytopic -q 1 -s ./certs/tls.crt

Running the server.

    ./tls_mqtt_send.py -c 52.174.51.191 -p 8883 -t mytopic -q 0 -s ./certs/tls.crt -m "Hello EnMasse"