---
title: Exchange Reference
description: Reference for Exchange module
---

# Exchange

The Exchange module facilitates data movement in and out of UVMS by defining
one interface that plugins interact with. Plugin examples range from receiving
AIS data to sending email.

* [:fontawesome-brands-github: Exchange Module](https://github.com/FocusFish/UVMS-ExchangeModule)
* [:simple-sonarqube: Exchange](https://sonarcloud.io/project/overview?id=fish.focus.uvms.exchange%3Aexchange)

## Artifacts

### Exchange Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.exchange</groupId>
        <artifactId>exchange-module</artifactId>
        <version>5.3.32</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.exchange:exchange-module:5.3.32'
    ```

### Exchange Client

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.exchange</groupId>
        <artifactId>exchange-client</artifactId>
        <version>5.3.32</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.exchange:exchange-client:5.3.32'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSMovementEvent | java:/jms/queue/UVMSMovementEvent | Request queue to Movement module |
| UVMSExchange | java:/jms/queue/UVMSExchange | Response queue to Exchange module |
| UVMSExchangeEvent | java:/jms/queue/UVMSExchangeEvent | Request queue to Exchange module |


## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_exchange`| `java:/jdbc/uvms_exchange` |

