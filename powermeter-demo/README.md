The only needed "sharded-topic" is :

`IAE`

The test environment has a Zigbee-MQTT gateway which publishes data to following topics on behalf of connected Zigbee devices : 

`IAE/powerMeterFast/DE-2/0013a200416486d4`

`IAE/powerMeterFast/DE-2/0013a200410815b7`

The monitoring application has an MQTT subscriber on : 

`IAE/powerMeterFast/DE-2/#`

or just :

`IAE/#`


