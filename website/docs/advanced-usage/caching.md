---
sidebar_position: 5
---

# SOQL Caching

SOQL caching is more complex than it seems. To make it robust and bug-proof, we made the following assumptions:

## Records are stored in the cache as a List. The cache key is the SObjectType.

Key: `Profile`

Records:

| Id | Name | UserType |
| -- | ---- | -------- |
| 00e3V000000DhteQAC | Standard Guest | Guest |
| 00e3V000000DhteQAC | Standard Guest | Guest |
| 00e3V000000DhtfQAC | Community Profile | Guest |
| 00e3V000000NmefQAC | Standard User | Standard |
| 00e3V000000Nme3QAC | System Administrator | Standard |
| 00e3V000000NmeAQAS | Standard Platform User | Standard |
| 00e3V000000NmeHQAS | Customer Community Plus User | PowerCustomerSuccess |
| 00e3V000000NmeNQAS | Customer Community Plus Login User | PowerCustomerSuccess |

**Why not just cache by SOQL String?**

`SELECT Id, Name FROM Profile` => List of Profiles.

There are several reasons why caching by SOQL string is not the best approach:
1. **Identical Queries Treated Differently**
Even the same SOQL query can be treated as different due to variations in the string format.
For instance, `SELECT Id, Name FROM Profile` and `SELECT Name, Id FROM Profile` are identical in intent but differ in query string format. This issue becomes even more complex when dealing with `WHERE` conditions.
2. **Duplicate Entries and Inefficient Record Retrieval**
A simple query like `SELECT Id, Name FROM Profile` is a subset of a more complex query like `SELECT Id, Name, UserType FROM Profile`.
If the results of `SELECT Id, Name, UserType FROM Profile` are already cached, the simpler query should ideally retrieve the relevant data from the cache. However, if the cache uses the query string as the key, this won’t work, leading to duplication and inefficiency.
3. **Cache Storage Limitations**
Cache storage is limited. If different variations of queries continually add new entries to the cache, it can quickly fill up with redundant or overlapping records, reducing overall effectiveness.

## A query requires a single condition, and that condition must filter by a unique field.

To ensure that cached records are aligned with the database, a single condition is required.
A query without a condition cannot guarantee that the number of records in the cache matches the database.
Let assume that developer made the query: `SELECT Id, Name FROM Profile`. Cached records will be returned, which may differ from the records in the database.
