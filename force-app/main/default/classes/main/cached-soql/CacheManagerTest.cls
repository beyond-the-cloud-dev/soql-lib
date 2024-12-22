/**
 * Copyright (c) 2025 BEYOND THE CLOUD Sp. z o.o. (BeyondTheCloud.Dev)
 * Licensed under the MIT License (https://github.com/beyond-the-cloud-dev/cache-manager/blob/main/LICENSE)
 *
 * PMD False Positives:
 * TBD
**/
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
        Assert.areEqual('Test Value', (String) CacheManager.ApexTransaction.get('TestKey'), 'Cached value should be the same');
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
        CacheManager.DefaultOrgCache.put('TestKey', 'Test Value');

        // Test
        Boolean hasKey = CacheManager.DefaultOrgCache.contains('TestKey');

        // Verify
        Assert.isTrue(hasKey, 'Key should exist');
    }

    @IsTest
    static void orgCacheGet() {
        // Setup
        CacheManager.DefaultOrgCache.put('TestKey', 'Test Value');

        // Test
        String cachedValue = (String) CacheManager.DefaultOrgCache.get('TestKey');

        // Verify
        Assert.areEqual('Test Value', cachedValue, 'Cached value should be the same');
    }

    @IsTest
    static void orgCachePut() {
        // Test
        CacheManager.DefaultOrgCache.put('TestKey', 'Test Value');

        // Verify
        Assert.areEqual('Test Value', (String) CacheManager.DefaultOrgCache.get('TestKey'), 'Cached value should be the same');
    }

    @IsTest
    static void orgCacheRemove() {
        // Setup
        CacheManager.DefaultOrgCache.put('TestKey', 'Test Value');

        // Test
        CacheManager.DefaultOrgCache.remove('TestKey');

        // Verify
        Assert.areEqual(null, CacheManager.DefaultOrgCache.get('TestKey'), 'Cached value should not exist.');
    }

    @IsTest
    static void orgCacheGetKeys() {
       // Setup
       CacheManager.DefaultOrgCache.put('TestKey', 'Test Value');
       CacheManager.DefaultOrgCache.put('TestKey2', 'Test Value 2');

       // Test
       Set<String> keys = CacheManager.DefaultOrgCache.getKeys();

       // Verify
       Assert.isTrue(keys.contains('TestKey'), 'Key should exist.');
       Assert.isTrue(keys.contains('TestKey2'), 'Key should exist.');
    }

    @IsTest
    static void orgCacheInvalidKey() {
        IllegalArgumentException keyException = null;

        // Test
        try {
            CacheManager.DefaultOrgCache.put('Test Key', 'Test Value');
        } catch (IllegalArgumentException e) {
            keyException = e;
        }

        // Verify
        Assert.isNotNull(keyException, 'Exception should be thrown for not alphanumeric key.');
    }

    @IsTest
    static void sessionCacheContains() {
        // Setup
        CacheManager.DefaultSessionCache.put('TestKey', 'Test Value');

        // Test
        Boolean hasKey = CacheManager.DefaultSessionCache.contains('TestKey');

        // Verify
        Assert.isTrue(hasKey, 'Key should exist');
    }

    @IsTest
    static void sessionCacheGet() {
        // Setup
        CacheManager.DefaultSessionCache.put('TestKey', 'Test Value');

        // Test
        String cachedValue = (String) CacheManager.DefaultSessionCache.get('TestKey');

        // Verify
        Assert.areEqual('Test Value', cachedValue, 'Cached value should be the same');
    }

    @IsTest
    static void sessionCachePut() {
        // Test
        CacheManager.DefaultSessionCache.put('TestKey', 'Test Value');

        // Verify
        Assert.areEqual('Test Value', (String) CacheManager.DefaultSessionCache.get('TestKey'), 'Cached value should be the same');
    }

    @IsTest
    static void sessionCacheRemove() {
        // Setup
        CacheManager.DefaultSessionCache.put('TestKey', 'Test Value');

        // Test
        CacheManager.DefaultSessionCache.remove('TestKey');

        // Verify
        Assert.areEqual(null, CacheManager.DefaultSessionCache.get('TestKey'), 'Cached value should not exist.');
    }

    @IsTest
    static void sessionCacheGetKeys() {
       // Setup
       CacheManager.DefaultSessionCache.put('TestKey', 'Test Value');
       CacheManager.DefaultSessionCache.put('TestKey2', 'Test Value 2');

       // Test
       Set<String> keys = CacheManager.DefaultSessionCache.getKeys();

       // Verify
       Assert.isTrue(keys.contains('TestKey'), 'Key should exist.');
       Assert.isTrue(keys.contains('TestKey2'), 'Key should exist.');
    }

    @IsTest
    static void sessionCacheInvalidKey() {
        IllegalArgumentException keyException = null;

        // Test
        try {
            CacheManager.DefaultSessionCache.put('Test Key', 'Test Value');
        } catch (IllegalArgumentException e) {
            keyException = e;
        }

        // Verify
        Assert.isNotNull(keyException, 'Exception should be thrown for not alphanumeric key.');
    }
}
