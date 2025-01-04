---
slug: '/installation'
sidebar_position: 15
---

# Installation

**System Requirements**

- API: 62.0

## Deploy

### Deploy via Button

Click the button below to deploy SOQL Lib to your environment.

<button href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main">
    Deploy to Salesforce
</button>

### Copy and Deploy

#### Standard SOQL

Copy:

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL_Test.cls)

and deploy them to your environment.

#### Cached SOQL

Do you need cached selectors?

Copy:

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL_Test.cls)
- [`CacheManager.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL.cls)
- [`CacheManagerTest.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL_Test.cls)
- [`SQOLCache.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL.cls)
- [`SOQLCache_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/SOQL_Test.cls)

and deploy them to your environment.

## Build Your Selector

You are ready to build your selector classes.

Go to the [Build Your Selector](./build-your-selector.md) section to see more details.
