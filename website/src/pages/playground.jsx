import React, { useMemo, useState } from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';
import CodeBlock from '@theme/CodeBlock';
import { translate } from '../lib/soqlTranslator';

const DEFAULT_QUERY = `SELECT Id, Name, Industry, Owner.Name
FROM Account
WHERE Industry = 'Technology'
  AND (BillingCity = 'San Francisco' OR BillingCity = 'New York')
  AND NumberOfEmployees > 100
ORDER BY Name
LIMIT 10`;

const EXAMPLE_GROUPS = [
  {
    name: 'Basics',
    examples: [
      {
        name: 'Simple query',
        query: "SELECT Id, Name\nFROM Account\nWHERE Name LIKE '%Test%'",
      },
      {
        name: 'Many fields',
        query: 'SELECT Id, Name, Industry, Rating, Type, Phone, Website, AnnualRevenue\nFROM Account',
      },
      {
        name: 'Field set of one record',
        query: "SELECT Id, Name\nFROM Account\nWHERE Id = :accountId\nLIMIT 1",
      },
    ],
  },
  {
    name: 'Relationships',
    examples: [
      {
        name: 'Parent fields',
        query: 'SELECT Id, Name, CreatedBy.Name, CreatedBy.Email, Owner.Name\nFROM Account',
      },
      {
        name: 'Multi-level parent',
        query: 'SELECT Id, Account.Owner.Profile.Name\nFROM Contact',
      },
      {
        name: 'Custom relationship',
        query: 'SELECT Id, Invoice__r.Name, Invoice__r.Total__c\nFROM Invoice_Line__c',
      },
    ],
  },
  {
    name: 'Sub-queries',
    examples: [
      {
        name: 'Child records',
        query: 'SELECT Id, Name, (SELECT Id, LastName FROM Contacts)\nFROM Account',
      },
      {
        name: 'Filtered sub-query',
        query:
          "SELECT Id, Name, (SELECT Id, StageName FROM Opportunities WHERE StageName != 'Closed Lost' ORDER BY Amount DESC LIMIT 5)\nFROM Account\nWHERE Industry = 'IT'",
      },
      {
        name: 'Two sub-queries',
        query: 'SELECT Id, (SELECT Id FROM Contacts), (SELECT Id FROM Cases)\nFROM Account',
      },
    ],
  },
  {
    name: 'Filters',
    examples: [
      {
        name: 'Comparison operators',
        query:
          'SELECT Id, Name\nFROM Opportunity\nWHERE Amount > 10000\n  AND Probability <= 80\n  AND CloseDate >= 2024-01-01',
      },
      {
        name: 'LIKE patterns',
        query:
          "SELECT Id, Name\nFROM Account\nWHERE Name LIKE 'Test%'\n  AND BillingCity LIKE '%Francisco%'\n  AND NOT Website LIKE '%.test'",
      },
      {
        name: 'IN and NOT IN',
        query:
          "SELECT Id, Name\nFROM Account\nWHERE Industry IN ('Technology', 'Healthcare')\n  AND Rating NOT IN ('Cold')",
      },
      {
        name: 'NULL and boolean',
        query: 'SELECT Id, Name\nFROM Account\nWHERE ParentId != null\n  AND IsDeleted = false',
      },
      {
        name: 'Date literals',
        query: 'SELECT Id\nFROM Opportunity\nWHERE CloseDate = THIS_MONTH\n  AND CreatedDate >= LAST_N_DAYS:30',
      },
      {
        name: 'Multi-select picklist',
        query:
          "SELECT Id\nFROM AccountContactRelation\nWHERE Roles INCLUDES ('Business User;Decision Maker')\n  AND Roles EXCLUDES ('Influencer', 'Economic Buyer')",
      },
      {
        name: 'Semi-join',
        query:
          "SELECT Id, Name\nFROM Contact\nWHERE AccountId IN (SELECT Id FROM Account WHERE Industry = 'Technology')",
      },
    ],
  },
  {
    name: 'Condition logic',
    examples: [
      {
        name: 'AND / OR',
        query:
          "SELECT Id, Name\nFROM Account\nWHERE (Industry = 'Technology' OR Industry = 'Healthcare')\n  AND NumberOfEmployees > 100",
      },
      {
        name: 'Nested groups',
        query:
          "SELECT Id\nFROM Account\nWHERE Industry = 'IT'\n  AND ((Name = 'My Account' AND NumberOfEmployees >= 10)\n    OR (Name = 'My Account 2' AND NumberOfEmployees <= 20))",
      },
      {
        name: 'NOT',
        query: "SELECT Id\nFROM Account\nWHERE NOT (Type = 'Prospect' OR Type = 'Other')",
      },
    ],
  },
  {
    name: 'Aggregates',
    examples: [
      { name: 'COUNT()', query: "SELECT COUNT()\nFROM Account\nWHERE Industry = 'IT'" },
      {
        name: 'GROUP BY',
        query: 'SELECT LeadSource, COUNT(Id) total, AVG(NumberOfEmployees) avgSize\nFROM Lead\nGROUP BY LeadSource',
      },
      {
        name: 'HAVING',
        query:
          'SELECT LeadSource, COUNT(Id) total\nFROM Lead\nGROUP BY LeadSource\nHAVING COUNT(Id) > 100\nORDER BY COUNT(Id) DESC',
      },
      {
        name: 'ROLLUP',
        query: 'SELECT Type, Status, COUNT(Id) total\nFROM Campaign\nGROUP BY ROLLUP(Type, Status)',
      },
    ],
  },
  {
    name: 'Sorting and paging',
    examples: [
      {
        name: 'ORDER BY',
        query: 'SELECT Id, Name, Industry\nFROM Account\nORDER BY Industry ASC NULLS LAST, Name DESC',
      },
      { name: 'LIMIT and OFFSET', query: 'SELECT Id, Name\nFROM Account\nORDER BY Name\nLIMIT 20\nOFFSET 40' },
      { name: 'FOR UPDATE', query: 'SELECT Id\nFROM Account\nWHERE Id = :accountId\nFOR UPDATE' },
    ],
  },
  {
    name: 'Advanced',
    examples: [
      { name: 'USING SCOPE', query: 'SELECT Id, Name\nFROM Account\nUSING SCOPE MINE\nORDER BY Name' },
      {
        name: 'WITH DATA CATEGORY',
        query:
          "SELECT Id, Title\nFROM Knowledge__kav\nWHERE PublishStatus = 'Online'\nWITH DATA CATEGORY Geography__c ABOVE (Europe__c, Asia__c)",
      },
      { name: 'System mode', query: 'SELECT Id, Name\nFROM Account\nWITH SYSTEM_MODE' },
      {
        name: 'DISTANCE',
        query:
          "SELECT Id, Name\nFROM Account\nWHERE DISTANCE(BillingAddress, GEOLOCATION(37.775, -122.418), 'mi') < 20\nORDER BY DISTANCE(BillingAddress, GEOLOCATION(37.775, -122.418), 'mi')",
      },
      { name: 'toLabel and FORMAT', query: 'SELECT Id, toLabel(Status), FORMAT(Amount)\nFROM Opportunity' },
    ],
  },
];

const MAPPING_REFERENCE = [
  ['SELECT Id, Name', '.with(Account.Id, Account.Name)', '/soql/api/soql#with-field1---field5'],
  ['SELECT Owner.Name', ".with('Owner', User.Name)", '/soql/api/soql#with-related-field1---field5'],
  ['(SELECT Id FROM Contacts)', ".with(SOQL.SubQuery.of('Contacts')…)", '/soql/api/soql-sub'],
  ['WHERE Name = :value', '.whereAre(SOQL.Filter.name().equal(value))', '/soql/api/soql-filter'],
  ['AND / OR', 'SOQL.FilterGroup + .anyConditionMatching()', '/soql/api/soql-filters-group'],
  ["LIKE '%v%'", ".contains('v')", '/soql/api/soql-filter#contains'],
  ['IN (SELECT …)', '.isIn(SOQL.InnerJoin.of(…))', '/soql/api/soql-join'],
  ['GROUP BY / HAVING', '.groupBy(…) + .have(SOQL.HavingFilter…)', '/soql/examples/group-by'],
  ['ORDER BY x DESC NULLS LAST', '.orderBy(…).sortDesc().nullsLast()', '/soql/examples/order-by'],
  ['LIMIT / OFFSET', '.setLimit(n) / .offset(n)', '/soql/examples/limit'],
  ['WITH SYSTEM_MODE', '.systemMode()', '/soql/examples/fls'],
  ['USING SCOPE MINE', '.mineScope()', '/soql/examples/scope'],
];

export default function Playground() {
  const [soqlInput, setSoqlInput] = useState(DEFAULT_QUERY);
  const { code, warnings, error } = useMemo(() => translate(soqlInput), [soqlInput]);
  const hasInput = Boolean(soqlInput.trim());

  return (
    <Layout title="SOQL Playground" description="Convert traditional SOQL queries to SOQL Lib syntax">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        <div className="text-center mb-8">
          <Heading as="h1" className="text-4xl font-bold mb-4">
            SOQL Lib Playground
          </Heading>
          <p className="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Paste a SOQL query and see it translated to SOQL Lib as you type. Every clause — sub-queries, nested
            conditions, aggregates, sorting and paging — is parsed and mapped to the matching builder method.
          </p>
        </div>

        <div className="mb-8">
          <div className="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Examples</div>
          <div className="flex flex-col gap-2">
            {EXAMPLE_GROUPS.map((group) => (
              <div key={group.name} className="flex flex-wrap items-baseline gap-2">
                <span className="text-xs uppercase tracking-wide text-gray-500 dark:text-gray-400 w-full sm:w-40 sm:shrink-0">
                  {group.name}
                </span>
                {group.examples.map((example) => (
                  <button
                    key={example.name}
                    type="button"
                    onClick={() => setSoqlInput(example.query)}
                    className="px-3 py-1 text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full hover:bg-blue-200 dark:hover:bg-blue-800 transition-colors border-none cursor-pointer"
                  >
                    {example.name}
                  </button>
                ))}
              </div>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
          <div className="min-w-0">
            <div className="flex items-center justify-between mb-2">
              <label htmlFor="soql-input" className="text-xl font-semibold">
                Traditional SOQL
              </label>
              <button
                type="button"
                onClick={() => setSoqlInput('')}
                className="px-3 py-1 text-sm bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 rounded transition-colors border-none cursor-pointer"
              >
                Clear
              </button>
            </div>
            <textarea
              id="soql-input"
              value={soqlInput}
              spellCheck={false}
              onChange={(event) => setSoqlInput(event.target.value)}
              className="w-full h-96 p-4 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 font-mono text-sm resize-y focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="SELECT Id, Name FROM Account WHERE Industry = 'IT'"
            />
          </div>

          <div className="min-w-0">
            <div className="flex items-center justify-between mb-2">
              <h2 className="text-xl font-semibold">SOQL Lib</h2>
              {hasInput && !error && (
                <span className="text-xs text-green-700 dark:text-green-400">✓ translated</span>
              )}
            </div>

            {error ? (
              <div className="h-96 p-4 border border-red-300 dark:border-red-800 rounded-lg bg-red-50 dark:bg-red-950/40">
                <div className="font-semibold text-red-800 dark:text-red-300 mb-1">Could not parse this query</div>
                <div className="font-mono text-sm text-red-700 dark:text-red-400">{error}</div>
              </div>
            ) : (
              <div className="[&_pre]:h-96 [&_pre]:overflow-auto">
                <CodeBlock language="apex">
                  {code || '// Enter a SOQL query to see the SOQL Lib equivalent.'}
                </CodeBlock>
              </div>
            )}
          </div>
        </div>

        {warnings.length > 0 && (
          <div className="mt-6 p-4 border border-amber-300 dark:border-amber-800 rounded-lg bg-amber-50 dark:bg-amber-950/30">
            <div className="font-semibold text-amber-900 dark:text-amber-200 mb-2">Worth knowing</div>
            <ul className="list-disc pl-5 space-y-1 text-sm text-amber-900 dark:text-amber-200">
              {warnings.map((warning) => (
                <li key={warning}>{warning}</li>
              ))}
            </ul>
          </div>
        )}

        <div className="mt-12">
          <h3 className="text-lg font-semibold mb-3">How clauses are mapped</h3>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr>
                  <th className="text-left">SOQL</th>
                  <th className="text-left">SOQL Lib</th>
                  <th className="text-left">Docs</th>
                </tr>
              </thead>
              <tbody>
                {MAPPING_REFERENCE.map(([soql, lib, href]) => (
                  <tr key={soql}>
                    <td>
                      <code>{soql}</code>
                    </td>
                    <td>
                      <code>{lib}</code>
                    </td>
                    <td>
                      <a href={href}>API</a>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          <p className="mt-4 text-sm text-gray-600 dark:text-gray-400">
            <strong>Note:</strong> <code>WITH USER_MODE</code> is the SOQL Lib default, so it produces no extra method
            call. Values become bind variables, which is why the generated query is safe against SOQL injection. See the{' '}
            <a href="/soql/examples/select">full documentation</a> for everything the builder supports.
          </p>
        </div>
      </div>
    </Layout>
  );
}
