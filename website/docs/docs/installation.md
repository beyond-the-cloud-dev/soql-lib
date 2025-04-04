---
slug: '/installation'
sidebar_position: 15
---

# Installation

**System Requirements**

- API: 63.0

## Deploy

### Deploy via Button

Click the button below to deploy SOQL Lib to your environment.

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main">
    DEPLOY TO SALESFORCE
</a>

### Copy and Deploy

#### Standard SOQL

Copy:

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL_Test.cls)

and deploy them to your environment.

#### Cached SOQL

Copy:

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL_Test.cls)
- [`CacheManager.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/CacheManager.cls)
- [`CacheManagerTest.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/CacheManagerTest.cls)
- [`SQOLCache.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/SOQLCache.cls)
- [`SOQLCache_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/SOQLCache_Test.cls)
- [`SOQL.cachePartition-meta.xml`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/cachePartitions/SOQL.cachePartition-meta.xml)

and deploy them to your environment.

## Build Your Selector

You are ready to build your selector classes.

Go to the [Build Your Selector](./build-your-selector.md) section to see more details.
