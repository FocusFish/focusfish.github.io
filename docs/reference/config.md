---
title: Configuration Module Reference
description: Reference for Configuration Module
---

# Configuration

The Config module is the main repository for all application settings. It
stores both global and module-specific settings, and allows access to them by
the application, typically through a REST interface. Settings can be accessed
all at once (as a catalog), only the ones associated with a certain module
including global settings or individually.

* [:fontawesome-brands-github: Config Module](https://github.com/FocusFish/UVMS-ConfigModule)
* [:simple-sonarqube: Config](https://sonarcloud.io/project/overview?id=fish.focus.uvms.config%3Aconfig)

## Artifacts

### Config Module

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.config</groupId>
        <artifactId>config-module</artifactId>
        <version>4.3.12</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.config:config-module:4.3.12'
    ```

### Config library

=== "Maven"

    ``` maven
    <dependency>
        <groupId>fish.focus.uvms.lib</groupId>
        <artifactId>uvms-config</artifactId>
        <version>4.1.6</version>
    </dependency>
    ```

=== "Gradle"

    ``` gradle
    implementation 'fish.focus.uvms.lib:uvms-config:4.1.6'
    ```

## JMS queues

| Name | JNDI | Description |
| --- | --- | --- |
| UVMSAuditEvent | java:/jms/queue/UVMSAuditEvent | Request queue to Audit module |
| UVMSConfigEvent | jms/queue/UVMSConfigEvent | Request queue to Config module |

## Datasources

| Name | JDNI |
| ---- | ---- |
| `uvms_config`| `java:/jdbc/uvms_config` |

## Global Settings

Available in the GUI and encompasses settings that are not tied to a specific
module.

!!! warning
    Changes are applied directly without an explicit save step.

### Configuration Options

| Name | Default value | Description |
| --- | --- | --- |
| Available languages | English (GB) | Note that only English (GB) is supported for now even though the dropdown has more options listed |
| Coordinates format | `DD MM,SS'` | Changes between the two coordinate formats `DD MM,SS'` and `DD.MMM` |
| Default home page | Reporting | Which "tab" should be opened when the old "admin type of interface" is opened |
| Distance unit | nautical miles | Supports `nautical miles`, `kilometers`, and `miles` |
| Long polling | false | |
| Maximum speed (kts) | 15 | |
| Numeric system | metric | Changes between metric and imperial numeric systems |
| Speed unit | knots | Supports `knots`, `kilometers per hour`, and `miles per hour` |
| Time format | `YYYY-MM-DD HH:mm:ss` | Changes between the two time formats `YYYY-MM-DD HH:mm:ss` and `YY/MM/DD HH:mm:ss` |
| Timezone | `+00:00` | The timezone that the system is running in |

