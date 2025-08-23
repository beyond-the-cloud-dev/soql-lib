---
slug: '/installation'
sidebar_position: 20
---

# Installation

## Install via Package

Install the SOQL Lib unmanaged package to your Salesforce environment:

`/packaging/installPackage.apexp?p0=04tJ5000000op3j`

<a href="https://test.salesforce.com/packaging/installPackage.apexp?p0=04tJ5000000op3j" target="_blank" style={{display: 'inline-block', backgroundColor: '#1976d2', color: 'white', padding: '10px 20px', textDecoration: 'none', borderRadius: '4px', marginRight: '10px'}}>
    <p style={{margin: '0px'}}>Install on Sandbox</p>
</a>

<a href="https://login.salesforce.com/packaging/installPackage.apexp?p0=04tJ5000000op3j" target="_blank" style={{display: 'inline-block', backgroundColor: '#d32f2f', color: 'white', padding: '10px 20px', textDecoration: 'none', borderRadius: '4px'}}>
    <p style={{margin: '0px'}}>Install on Production</p>
</a>

## Deploy via Button

Click the button below to deploy SOQL Lib to your environment.

<a href="https://githubsfdeploy.herokuapp.com?owner=beyond-the-cloud-dev&repo=soql-lib&ref=main" target="_blank" style={{display: 'inline-block', backgroundColor: '#1976d2', color: 'white', padding: '10px 20px', textDecoration: 'none', borderRadius: '4px', marginRight: '10px'}}>
    <p style={{margin: '0px'}}>Deploy to Salesforce</p>
</a>


## Copy and Deploy

### SOQL

**Apex**

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL_Test.cls)

### Cache _(optional)_

**Apex**

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL_Test.cls)
- [`CacheManager.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/CacheManager.cls)
- [`CacheManagerTest.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/CacheManagerTest.cls)
- [`SOQLCache.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/SOQLCache.cls)
- [`SOQLCache_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/cached-soql/SOQLCache_Test.cls)

**Cache Partitions**

- [`SOQL.cachePartition-meta.xml`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/cachePartitions/SOQL.cachePartition-meta.xml)

### Evaluator _(optional)_

**Apex**

- [`SOQL.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL.cls)
- [`SOQL_Test.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/standard-soql/SOQL_Test.cls)
- [`SOQLEvaluator.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/soql-evaluator/SOQLEvaluator.cls)
- [`SOQLEvaluatorTest.cls`](https://github.com/beyond-the-cloud-dev/soql-lib/blob/main/force-app/main/default/classes/main/soql-evaluator/SOQLEvaluator_Test.cls)
