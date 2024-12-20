---
title: Audit Reference
description: Reference for Audit module
---

# Audit

The purpose of the audit module is to store logs and events provided by other
modules.

* [:fontawesome-brands-github: Audit Module](https://github.com/FocusFish/UVMS-AuditModule)
* [:simple-sonarqube: Audit](https://sonarcloud.io/project/overview?id=fish.focus.uvms.audit%3Aaudit)

## Artifacts

### Audit Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.audit</groupId>
        <artifactId>audit-module</artifactId>
        <version>4.3.12</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.audit:audit-module:4.3.12'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSAudit | java:/jms/queue/UVMSAudit | Response queue to Audit module |
| UVMSAuditEvent | java:/jms/queue/UVMSAuditEvent | Request queue to Audit module |
| UVMSConfigEvent | jms/queue/UVMSConfigEvent | Request queue to send a Config message |

## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_audit`| `java:/jdbc/uvms_audit` |

