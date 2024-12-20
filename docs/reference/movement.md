---
title: Movement Reference
description: Reference for Movement module
---

# Movement

The Movement modules area of responsibility is positions and movements of ships.

* [:fontawesome-brands-github: Movement Module](https://github.com/FocusFish/UVMS-MovementModule)
* [:simple-sonarqube: Movement](https://sonarcloud.io/project/overview?id=fish.focus.uvms.movement%3Amovement)

## Artifacts

### Movement Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.movement</groupId>
        <artifactId>movement-module</artifactId>
        <version>5.6.21</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.movement:movement-module:5.6.21'
    ```

### Movement Client

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.movement</groupId>
        <artifactId>movement-client</artifactId>
        <version>5.6.21</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.movement:movement-client:5.6.21'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSMovement | java:/jms/queue/UVMSMovement | Response queue to Movement module |
| UVMSMovementEvent | java:/jms/queue/UVMSMovementEvent | Request queue to Movement module |
| UVMSExchangeEvent | java:/jms/queue/UVMSExchangeEvent | Request queue to Exchange module |


## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_movement`| `java:/jdbc/uvms_movement` |

