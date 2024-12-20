---
title: Asset Reference
description: Reference for Asset module
---

# Asset

The asset module adds support for assets such as vessels and mobile terminals.
The module is responsible for adding and updating incoming vessel information.
There are three interfaces available; JMS, REST, and Java client (uses the REST
interface). All three interfaces has support for updating, inserting, and
querying.

* [:fontawesome-brands-github: Asset Module](https://github.com/FocusFish/UVMS-AssetModule)
* [:simple-sonarqube: Asset](https://sonarcloud.io/project/overview?id=fish.focus.uvms.asset%3Aasset)

## Artifacts

### Asset Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.asset</groupId>
        <artifactId>asset-module</artifactId>
        <version>6.8.35</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.asset:asset-module:6.8.35'
    ```

### Asset Client

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.asset</groupId>
        <artifactId>asset-client</artifactId>
        <version>6.8.35</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.asset:asset-client:6.8.35'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSAssetEvent | java:/jms/queue/UVMSAssetEvent | Request queue to Asset service module |
| UVMSAsset | java:/jms/queue/UVMSAsset | Response queue to Asset module |
| UVMSAuditEvent | java:/jms/queue/UVMSAuditEvent | Request queue to Audit service module |
| UVMSUserEvent | java:/jms/queue/UVMSUserEvent | Request queue to User service module |

## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_asset`| `java:/jdbc/uvms_asset` |

