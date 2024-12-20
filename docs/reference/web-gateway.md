---
title: Web Gateway Reference
description: Reference for Web Gateway module
---

# Web Gateway

API that combines information from several sources, if needed. For example,
viewing an incident in the GUI requires more information than just the
incident, the web gateway will then fetch notes, positions, and poll logs that
are related to the incident.

* [:fontawesome-brands-github: Web Gateway Module](https://github.com/FocusFish/UVMS-WebGateway)
* [:simple-sonarqube: Web Gateway](https://sonarcloud.io/project/overview?id=fish.focus.uvms.web-gateway%3Aweb-gateway)

## Artifacts

### Web Gateway Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.web-gateway</groupId>
        <artifactId>web-gateway</artifactId>
        <version>1.0.9</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.web-gateway:web-gateway:1.0.9'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| EventStream | java:/jms/topic/EventStream | Listens for events on the topic and publishes them on an SSE stream |

