---
title: Movement Rules Reference
description: Reference for Movement Rules module
---

# Movement Rules

Users can create customized rules that are then executed in the Movement Rules
module. The rules can for example based on a position take a decision to
forward it to an external party.

* [:fontawesome-brands-github: Movement Rules Module](https://github.com/FocusFish/UVMS-MovementRulesModule)
* [:simple-sonarqube: Movement Rules](https://sonarcloud.io/project/overview?id=fish.focus.uvms.movement-rules%3Amovement-rules)

## Artifacts

### Movement Rules Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.movement-rules</groupId>
        <artifactId>movement-rules-module</artifactId>
        <version>2.4.22</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.movement-rules:movement-rules-module:2.4.22'
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
| `uvms_movementrules`| `java:/jdbc/uvms_movementrules` |

