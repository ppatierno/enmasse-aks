After downloding the latest EnMasse 0.17.1 release from [here](https://github.com/EnMasseProject/enmasse/releases) and unpacked it locally, the Azure CLI can be used through the `microsoft/azure-cli:latest` Docker image running it in the following way :

    docker run -it -v /home/ppatiern/Downloads/enmasse-0.17.1:/enmasse microsoft/azure-cli:latest

The only needed "sharded-topic" is :

`IAE`

The test environment has a Zigbee-MQTT gateway which publishes data to following topics on behalf of connected Zigbee devices : 

`IAE/powerMeterFast/DE-2/0013a200416486d4`

`IAE/powerMeterFast/DE-2/0013a200410815b7`

The monitoring application has an MQTT subscriber on : 

`IAE/powerMeterFast/DE-2/#`

or just :

`IAE/#`


