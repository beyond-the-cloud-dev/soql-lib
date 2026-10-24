/**
 * Expected translations that the round-trip check in verify-translator.mjs cannot see:
 * SObjectField tokens that would not compile, warnings, and errors for invalid SOQL.
 *
 * includes / excludes - substrings of the generated apex
 * warning / noWarning - substring of one of the warnings, or of none of them
 * error               - substring of the error; the query must not translate
 */

export default [
  /* ----- relationship paths resolve hop by hop ----- */
  {
    soql: 'SELECT Id, Account.Parent.Name, Account.Parent.Industry FROM Contact',
    includes: [".with('Account.Parent', Account.Name, Account.Industry)"],
  },
  { soql: 'SELECT Id, Parent.Parent.Name FROM Account', includes: [".with('Parent.Parent', Account.Name)"] },
  { soql: 'SELECT Id, Account.Owner.Name FROM Contact', includes: [".with('Account.Owner', User.Name)"] },
  { soql: 'SELECT Id, Owner.Name, Owner.Email FROM Account', includes: [".with('Owner', User.Name, User.Email)"] },
  { soql: 'SELECT Id, Parent.CaseNumber FROM CaseComment', includes: [".with('Parent', Case.CaseNumber)"] },
  { soql: 'SELECT Id, Parent.Name FROM Attachment', includes: [".with('Parent.Name')"] },
  {
    soql: 'SELECT Id FROM Contact ORDER BY Account.Parent.Name',
    includes: [".orderBy('Account.Parent', Account.Name)"],
  },
  {
    soql: 'SELECT Id, TYPEOF What WHEN Opportunity THEN Account.Owner.Name END FROM Task',
    includes: [".then('Account.Owner', User.Name)"],
  },

  /* ----- Owner is polymorphic (User or Queue) on these objects ----- */
  { soql: 'SELECT Id, Owner.Type, Owner.Name FROM Case', includes: [".with('Owner.Type, Owner.Name')"], excludes: ['User.Type'] },
  { soql: "SELECT Id FROM Lead WHERE Owner.Type = 'Queue'", includes: ["SOQL.Filter.with('Owner.Type').equal('Queue')"] },
  { soql: 'SELECT Owner.Type, COUNT(Id) FROM Case GROUP BY Owner.Type', includes: [".groupBy('Owner.Type')"] },

  /* ----- SObject alias is dropped from every field path ----- */
  {
    soql: "SELECT a.Id, a.Name FROM Account a WHERE a.Industry = 'IT' ORDER BY a.Name",
    includes: ['.with(Account.Id, Account.Name)', 'SOQL.Filter.with(Account.Industry)', '.orderBy(Account.Name)'],
    excludes: ["'a."],
  },

  /* ----- HavingFilter has no relationship overloads ----- */
  {
    soql: 'SELECT Opportunity.StageName, SUM(Quantity) FROM OpportunityLineItem GROUP BY Opportunity.StageName HAVING SUM(Opportunity.Amount) > 0',
    includes: ["SOQL.HavingFilter.with('SUM(Opportunity.Amount)').greaterThan(0)"],
  },

  /* ----- NOT that cannot be pushed into a comparator ----- */
  {
    soql: 'SELECT Id FROM Opportunity WHERE NOT (Amount > 100000)',
    includes: ['SOQL.Filter.with(Opportunity.Amount).greaterThan(100000)', ".conditionLogic('NOT 1')"],
    noWarning: 'raw',
  },
  {
    soql: 'SELECT Id FROM Opportunity WHERE StageName != null AND (NOT (Amount > 100000 OR Probability < 10))',
    includes: [".conditionLogic('NOT (1 OR 2)')"],
    noWarning: 'raw',
  },
  {
    soql: 'SELECT Industry, COUNT(Id) FROM Account GROUP BY Industry HAVING COUNT(Id) > 0 AND (NOT COUNT(Id) > 1)',
    includes: ['SOQL.HavingFilter.count(Account.Id).greaterThan(1)', ".conditionLogic('NOT 1')"],
    noWarning: 'raw',
  },

  /* ----- string escapes ----- */
  { soql: String.raw`SELECT Id FROM Account WHERE Site = 'Line1\nLine2'`, includes: [String.raw`.equal('Line1\nLine2')`] },
  { soql: String.raw`SELECT Id FROM Account WHERE Site = 'Tab\tTab'`, includes: [String.raw`.equal('Tab\tTab')`] },
  { soql: String.raw`SELECT Id FROM Account WHERE Site = 'C:\\temp'`, includes: [String.raw`.equal('C:\\temp')`] },
  { soql: String.raw`SELECT Id FROM Account WHERE Name = 'O\'Reilly'`, includes: [String.raw`.equal('O\'Reilly')`] },

  /* ----- literals ----- */
  {
    soql: 'SELECT Id FROM Opportunity WHERE Amount > USD5000',
    includes: [".whereAre('Amount > USD5000')"],
    warning: 'Currency literal',
  },
  { soql: 'SELECT Id FROM Account WHERE Name = Industry', error: 'Industry' },
  {
    soql: "SELECT Id FROM Account WHERE Name IN :new List<String>{ 'Acme', 'Energy Plus' }",
    includes: [".isIn(new List<String>{ 'Acme', 'Energy Plus' })"],
  },

  /* ----- invalid SOQL is reported, not translated into broken apex ----- */
  { soql: 'SELECT FROM Account', error: 'field' },
  { soql: 'SELECT Id, FROM Account', error: 'field' },
  { soql: 'SELECT Id FROM Account WHERE Name =', error: 'value' },
  { soql: 'SELECT Id FROM Account WHERE Name LIKE', error: 'value' },
  { soql: 'SELECT Id FROM Account WHERE Name = :', error: 'bind' },
  { soql: 'SELECT Id FROM Account WHERE Name IN ()', error: 'IN' },
  { soql: 'SELECT Id FROM Account LIMIT', error: 'LIMIT' },
  { soql: 'SELECT Id FROM Account LIMIT abc', error: 'LIMIT' },
  { soql: 'SELECT Id FROM Account OFFSET', error: 'OFFSET' },
  { soql: 'SELECT Id FROM Account ORDER BY Name NULLS', error: 'NULLS' },
  { soql: 'SELECT Id FROM Account USING SCOPE', error: 'SCOPE' },
  { soql: 'SELECT Id FROM Account FOR', error: 'FOR' },
  { soql: 'SELECT Id FROM Account FOR EVERYTHING', error: 'FOR' },
  { soql: 'SELECT Id FROM Account WITH', error: 'WITH' },
  { soql: 'SELECT Title FROM FAQ__kav WITH DATA CATEGORY', error: 'DATA CATEGORY' },
  { soql: 'SELECT Title FROM FAQ__kav WITH DATA CATEGORY Geography__c NEAR Europe__c', error: 'NEAR' },
  { soql: 'SELECT Id FROM Account WHERE DISTANCE(BillingAddress) < 5', error: 'DISTANCE' },

  /* ----- SOQL that Salesforce rejects is translated with a warning ----- */
  {
    soql: "SELECT Id FROM Account WHERE Industry = 'IT' AND Rating = 'Hot' OR Name = 'Acme'",
    warning: 'parentheses',
  },
  {
    soql: "SELECT Id FROM Account WHERE Industry = 'IT' OR Rating = 'Hot' AND Name = 'Acme'",
    warning: 'parentheses',
  },
  {
    soql: "SELECT Id FROM Account WHERE (Industry = 'IT' AND Rating = 'Hot') OR Name = 'Acme'",
    noWarning: 'parentheses',
  },
  { soql: "SELECT Id FROM Account WHERE Name != null AND NOT Name LIKE 'A%'", warning: 'NOT' },
  { soql: "SELECT Id FROM Account WHERE Name != null AND (NOT Name LIKE 'A%')", noWarning: 'NOT' },
  { soql: "SELECT Id FROM Account WHERE NOT Name LIKE 'A%'", noWarning: 'NOT' },
];
