---
title: Spatial Reference
description: Reference for Spatial module
---

# Spatial

Performs area calculations for incoming vessel positions.

* [:fontawesome-brands-github: Spatial Module](https://github.com/FocusFish/UVMS-SpatialModule)
* [:simple-sonarqube: Spatial](https://sonarcloud.io/project/overview?id=fish.focus.uvms.spatial%3Aspatial)

## Artifacts

### Spatial Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.spatial</groupId>
        <artifactId>spatial-module</artifactId>
        <version>2.2.12</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.spatial:spatial-module:2.2.12'
    ```

### Spatial Client

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.spatial</groupId>
        <artifactId>spatial-client</artifactId>
        <version>2.2.12</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.spatial:spatial-client:2.2.12'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSSpatial | java:/jms/queue/UVMSSpatial | Response queue to Spatial module |
| UVMSSpatialEvent | java:/jms/queue/UVMSSpatialEvent | Request queue to Spatial service module |
| UVMSConfigEvent | java:/jms/queue/UVMSConfigEvent | Request queue to Config service module |

## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_spatial`| `java:/jdbc/uvms_spatial` |

