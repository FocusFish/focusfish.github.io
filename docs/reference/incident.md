---
title: Incident Reference
description: Reference for Incident module
---

# Incident

Responsible for events related to work flows for users, for example vessels
that are not sending positions.

* [:fontawesome-brands-github: Incident Module](https://github.com/FocusFish/UVMS-IncidentModule)
* [:simple-sonarqube: Incident](https://sonarcloud.io/project/overview?id=fish.focus.uvms.incident%3Aincident)

## Artifacts

### Incident Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.incident</groupId>
        <artifactId>incident-application</artifactId>
        <version>1.0.15</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.incident:incident-application:1.0.15'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| EventStream | java:/jms/topic/EventStream | Publishes an event on the topic |
| IncidentEvent | jms/queue/IncidentEvent | Request queue to incident module |

## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_incident`| `java:/jdbc/uvms_incident` |

