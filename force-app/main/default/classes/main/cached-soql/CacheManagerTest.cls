/**
 * Copyright (c) 2025 Beyond The Cloud Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/cache-manager/blob/main/LICENSE)
 *
 * PMD False Positives:
 * - ApexDoc: Variable names are self-documented.
**/
@SuppressWarnings('PMD.ApexDoc')
@IsTest
private class CacheManagerTest {
    @IsTest
    static void apexTransactionContains() {
        // Setup
        CacheManager.ApexTransaction.put('TestKey', 'Test Value');

        // Test
        Boolean hasKey = CacheManager.ApexTransaction.contains('TestKey');

        // Verify
        Assert.isTrue(hasKey, 'Key should exist');
    }

    @IsTest
    static void apexTransactionGet() {
        // Setup
        CacheManager.ApexTransaction.put('TestKey', 'Test Value');

        // Test
        String cachedValue = (String) CacheManager.ApexTransaction.get('TestKey');

        // Verify
        Assert.areEqual('Test Value', cachedValue, 'Cached value should be the same');
    }

    @IsTest
    static void apexTransactionPut() {
        // Test
        CacheManager.ApexTransaction.put('TestKey', 'Test Value');

        // Verify
        Assert.areEqual('Test Value', CacheManager.ApexTransaction.get('TestKey'), 'Cached value should be the same');
    }

    @IsTest
    static void apexTransactionRemove() {
        // Setup
        CacheManager.ApexTransaction.put('TestKey', 'Test Value');

        // Test
        CacheManager.ApexTransaction.remove('TestKey');

        // Verify
        Assert.areEqual(null, CacheManager.ApexTransaction.get('TestKey'), 'Cached value should not exist.');
    }

    @IsTest
    static void apexTransactionGetKeys() {
        // Setup
        CacheManager.ApexTransaction.put('TestKey', 'Test Value');
        CacheManager.ApexTransaction.put('TestKey2', 'Test Value 2');

        // Test
        Set<String> keys = CacheManager.ApexTransaction.getKeys();

        // Verify
        Assert.isTrue(keys.contains('TestKey'), 'Key should exist.');
        Assert.isTrue(keys.contains('TestKey2'), 'Key should exist.');
    }

    @IsTest
    static void apexTransactionInvalidKey() {
        IllegalArgumentException keyException = null;

        // Test
        try {
            CacheManager.ApexTransaction.put('Test Key', 'Test Value');
        } catch (IllegalArgumentException e) {
            keyException = e;
        }

        // Verify
        Assert.isNotNull(keyException, 'Exception should be thrown for not alphanumeric key.');
    }

    @IsTest
    static void orgCacheContains() {
        // Setup
        CacheManager.SOQLOrgCache.put('TestKey', 'Test Value');

        // Test
        Boolean hasKey = CacheManager.SOQLOrgCache.contains('TestKey');

        // Verify
        Assert.isTrue(hasKey, 'Key should exist');
    }

    @IsTest
    static void orgCacheGet() {
        // Setup
        CacheManager.SOQLOrgCache.put('TestKey', 'Test Value');

        // Test
        String cachedValue = (String) CacheManager.SOQLOrgCache.get('TestKey');

        // Verify
        Assert.areEqual('Test Value', cachedValue, 'Cached value should be the same');
    }

    @IsTest
    static void orgCachePut() {
        // Test
        CacheManager.SOQLOrgCache.put('TestKey', 'Test Value');

        // Verify
        Assert.areEqual('Test Value', CacheManager.SOQLOrgCache.get('TestKey'), 'Cached value should be the same');
    }

    @IsTest
    static void orgCacheRemove() {
        // Setup
        CacheManager.SOQLOrgCache.put('TestKey', 'Test Value');

        // Test
        CacheManager.SOQLOrgCache.remove('TestKey');

        // Verify
        Assert.areEqual(null, CacheManager.SOQLOrgCache.get('TestKey'), 'Cached value should not exist.');
    }

    @IsTest
    static void orgCacheGetKeys() {
       // Setup
       CacheManager.SOQLOrgCache.put('TestKey', 'Test Value');
       CacheManager.SOQLOrgCache.put('TestKey2', 'Test Value 2');

       // Test
       Set<String> keys = CacheManager.SOQLOrgCache.getKeys();

       // Verify
       Assert.isTrue(keys.contains('TestKey'), 'Key should exist.');
       Assert.isTrue(keys.contains('TestKey2'), 'Key should exist.');
    }

    @IsTest
    static void orgCacheInvalidKey() {
        IllegalArgumentException keyException = null;

        // Test
        try {
            CacheManager.SOQLOrgCache.put('Test Key', 'Test Value');
        } catch (IllegalArgumentException e) {
            keyException = e;
        }

        // Verify
        Assert.isNotNull(keyException, 'Exception should be thrown for not alphanumeric key.');
    }

    @IsTest
    static void sessionCacheContains() {
        // Setup
        CacheManager.SOQLSessionCache.put('TestKey', 'Test Value');

        // Test
        Boolean hasKey = CacheManager.SOQLSessionCache.contains('TestKey');

        // Verify
        Assert.isTrue(hasKey, 'Key should exist');
    }

    @IsTest
    static void sessionCacheGet() {
        // Setup
        CacheManager.SOQLSessionCache.put('TestKey', 'Test Value');

        // Test
        String cachedValue = (String) CacheManager.SOQLSessionCache.get('TestKey');

        // Verify
        Assert.areEqual('Test Value', cachedValue, 'Cached value should be the same');
    }

    @IsTest
    static void sessionCachePut() {
        // Test
        CacheManager.SOQLSessionCache.put('TestKey', 'Test Value');

        // Verify
        Assert.areEqual('Test Value', CacheManager.SOQLSessionCache.get('TestKey'), 'Cached value should be the same');
    }

    @IsTest
    static void sessionCacheRemove() {
        // Setup
        CacheManager.SOQLSessionCache.put('TestKey', 'Test Value');

        // Test
        CacheManager.SOQLSessionCache.remove('TestKey');

        // Verify
        Assert.areEqual(null, CacheManager.SOQLSessionCache.get('TestKey'), 'Cached value should not exist.');
    }

    @IsTest
    static void sessionCacheGetKeys() {
       // Setup
       CacheManager.SOQLSessionCache.put('TestKey', 'Test Value');
       CacheManager.SOQLSessionCache.put('TestKey2', 'Test Value 2');

       // Test
       Set<String> keys = CacheManager.SOQLSessionCache.getKeys();

       // Verify
       Assert.isTrue(keys.contains('TestKey'), 'Key should exist.');
       Assert.isTrue(keys.contains('TestKey2'), 'Key should exist.');
    }

    @IsTest
    static void sessionCacheInvalidKey() {
        IllegalArgumentException keyException = null;

        // Test
        try {
            CacheManager.SOQLSessionCache.put('Test Key', 'Test Value');
        } catch (IllegalArgumentException e) {
            keyException = e;
        }

        // Verify
        Assert.isNotNull(keyException, 'Exception should be thrown for not alphanumeric key.');
    }
}
