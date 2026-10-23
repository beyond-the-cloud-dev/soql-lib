/**
 * SOQL -> SOQL Lib translator.
 *
 * Pipeline: tokenize -> recursive-descent parse -> AST -> SOQL Lib apex code.
 *
 * The generator mirrors the semantics of `SOQL.cls` (force-app/main/default/
 * classes/standard-soql/SOQL.cls). Every builder call emitted here renders back
 * to the SOQL clause it came from.
 */

/* ------------------------------------------------------------------------- *
 * Schema hints
 *
 * SOQL Lib needs SObjectField tokens (`User.Name`), so a relationship name has
 * to be resolved to its SObject. Custom relationships follow the `__r` -> `__c`
 * rule; standard ones need a lookup table. Anything unresolved falls back to
 * the String overloads, which compile and behave identically.
 * ------------------------------------------------------------------------- */

const PARENT_RELATIONSHIPS = {
  account: 'Account',
  approver: 'User',
  asset: 'Asset',
  assignee: 'User',
  campaign: 'Campaign',
  case: 'Case',
  contact: 'Contact',
  contract: 'Contract',
  contentdocument: 'ContentDocument',
  convertedaccount: 'Account',
  convertedcontact: 'Contact',
  convertedopportunity: 'Opportunity',
  createdby: 'User',
  delegatedapprover: 'User',
  entitlement: 'Entitlement',
  entity: 'Account',
  event: 'Event',
  individual: 'Individual',
  lastmodifiedby: 'User',
  lead: 'Lead',
  manager: 'User',
  opportunity: 'Opportunity',
  order: 'Order',
  owner: 'User',
  parentcase: 'Case',
  pricebook2: 'Pricebook2',
  pricebookentry: 'PricebookEntry',
  primarycontact: 'Contact',
  product2: 'Product2',
  profile: 'Profile',
  quote: 'Quote',
  recordtype: 'RecordType',
  reportsto: 'Contact',
  serviceappointment: 'ServiceAppointment',
  solution: 'Solution',
  user: 'User',
  userrole: 'UserRole',
  workorder: 'WorkOrder',
};

/** Relationships that point back at the object being queried. */
const SELF_PARENT_RELATIONSHIPS = new Set(['parent', 'masterrecord', 'original', 'clonedfrom']);

const CHILD_RELATIONSHIPS = {
  accountcontactroles: 'AccountContactRole',
  accountcontactrelations: 'AccountContactRelation',
  accountpartnersfrom: 'Partner',
  accountpartnersto: 'Partner',
  accountteammembers: 'AccountTeamMember',
  activityhistories: 'ActivityHistory',
  assets: 'Asset',
  attachments: 'Attachment',
  campaignmembers: 'CampaignMember',
  cases: 'Case',
  casecomments: 'CaseComment',
  childaccounts: 'Account',
  contacts: 'Contact',
  contentdocumentlinks: 'ContentDocumentLink',
  contracts: 'Contract',
  emailmessages: 'EmailMessage',
  entitlements: 'Entitlement',
  events: 'Event',
  leads: 'Lead',
  notes: 'Note',
  opportunities: 'Opportunity',
  opportunitycontactroles: 'OpportunityContactRole',
  opportunitylineitems: 'OpportunityLineItem',
  opportunityteammembers: 'OpportunityTeamMember',
  openactivities: 'OpenActivity',
  orders: 'Order',
  orderitems: 'OrderItem',
  partners: 'Partner',
  pricebookentries: 'PricebookEntry',
  processinstances: 'ProcessInstance',
  quotes: 'Quote',
  quotelineitems: 'QuoteLineItem',
  serviceappointments: 'ServiceAppointment',
  solutions: 'Solution',
  tasks: 'Task',
  users: 'User',
  workorders: 'WorkOrder',
  workorderlineitems: 'WorkOrderLineItem',
};

const AGGREGATE_FUNCTIONS = new Set(['COUNT', 'COUNT_DISTINCT', 'AVG', 'MIN', 'MAX', 'SUM']);

const DATE_FUNCTIONS = new Set([
  'CALENDAR_MONTH', 'CALENDAR_QUARTER', 'CALENDAR_YEAR', 'DAY_IN_MONTH', 'DAY_IN_WEEK',
  'DAY_IN_YEAR', 'DAY_ONLY', 'FISCAL_MONTH', 'FISCAL_QUARTER', 'FISCAL_YEAR', 'HOUR_IN_DAY',
  'WEEK_IN_MONTH', 'WEEK_IN_YEAR',
]);

const SCOPE_METHODS = {
  DELEGATED: 'delegatedScope',
  MINE: 'mineScope',
  MINE_AND_MY_GROUPS: 'mineAndMyGroupsScope',
  MY_TERRITORY: 'myTerritoryScope',
  MY_TEAM_TERRITORY: 'myTeamTerritoryScope',
  TEAM: 'teamScope',
};

const DATE_LITERALS = new Set([
  'YESTERDAY', 'TODAY', 'TOMORROW', 'LAST_WEEK', 'THIS_WEEK', 'NEXT_WEEK', 'LAST_MONTH',
  'THIS_MONTH', 'NEXT_MONTH', 'LAST_90_DAYS', 'NEXT_90_DAYS', 'THIS_QUARTER', 'LAST_QUARTER',
  'NEXT_QUARTER', 'THIS_YEAR', 'LAST_YEAR', 'NEXT_YEAR', 'THIS_FISCAL_QUARTER',
  'LAST_FISCAL_QUARTER', 'NEXT_FISCAL_QUARTER', 'THIS_FISCAL_YEAR', 'LAST_FISCAL_YEAR',
  'NEXT_FISCAL_YEAR',
]);

const DATE_LITERAL_PREFIXES = [
  'LAST_N_DAYS', 'NEXT_N_DAYS', 'LAST_N_WEEKS', 'NEXT_N_WEEKS', 'LAST_N_MONTHS',
  'NEXT_N_MONTHS', 'LAST_N_QUARTERS', 'NEXT_N_QUARTERS', 'LAST_N_YEARS', 'NEXT_N_YEARS',
  'LAST_N_FISCAL_QUARTERS', 'NEXT_N_FISCAL_QUARTERS', 'LAST_N_FISCAL_YEARS',
  'NEXT_N_FISCAL_YEARS', 'N_DAYS_AGO', 'N_WEEKS_AGO', 'N_MONTHS_AGO', 'N_QUARTERS_AGO',
  'N_YEARS_AGO', 'N_FISCAL_QUARTERS_AGO', 'N_FISCAL_YEARS_AGO',
];

/* ------------------------------------------------------------------------- *
 * Tokenizer
 * ------------------------------------------------------------------------- */

const DATE_TIME_RE = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?/;
const DATE_RE = /^\d{4}-\d{2}-\d{2}/;

export function tokenize(input) {
  const tokens = [];
  const source = String(input);
  let i = 0;

  const isIdentStart = (c) => /[A-Za-z_]/.test(c);
  const isIdentChar = (c) => /[A-Za-z0-9_]/.test(c);

  const readString = () => {
    const start = i;
    i++; // opening quote
    let value = '';
    while (i < source.length) {
      const c = source[i];
      if (c === '\\' && i + 1 < source.length) {
        const escaped = source[i + 1];
        // Decode the escapes that stand for a character; keep LIKE escapes (\_ \%) intact.
        value += "'\"\\\\".includes(escaped) ? escaped : c + escaped;
        i += 2;
        continue;
      }
      if (c === "'") {
        // SOQL escapes with \', but SQL-style '' is a common paste; accept it when
        // the doubled quote is followed by more of the same literal.
        if (source[i + 1] === "'" && !/^['\s,)]|^$/.test(source[i + 2] || '')) {
          value += "'";
          i += 2;
          continue;
        }
        i++;
        return { type: 'string', value, raw: source.slice(start, i), start };
      }
      value += c;
      i++;
    }
    throw new SoqlSyntaxError('Unterminated string literal', start);
  };

  while (i < source.length) {
    const c = source[i];

    if (/\s/.test(c)) {
      i++;
      continue;
    }

    if (c === "'") {
      tokens.push(readString());
      continue;
    }

    // Dates and date-times must win over plain numbers.
    const rest = source.slice(i);
    const dateTimeMatch = rest.match(DATE_TIME_RE);
    if (dateTimeMatch) {
      tokens.push({ type: 'datetime', value: dateTimeMatch[0], start: i });
      i += dateTimeMatch[0].length;
      continue;
    }
    const dateMatch = rest.match(DATE_RE);
    if (dateMatch) {
      tokens.push({ type: 'date', value: dateMatch[0], start: i });
      i += dateMatch[0].length;
      continue;
    }

    if (/[0-9]/.test(c) || (c === '-' && /[0-9]/.test(source[i + 1] || ''))) {
      const numberMatch = rest.match(/^-?\d+(?:\.\d+)?/);
      tokens.push({ type: 'number', value: numberMatch[0], start: i });
      i += numberMatch[0].length;
      continue;
    }

    if (isIdentStart(c)) {
      const start = i;
      while (i < source.length && (isIdentChar(source[i]) || (source[i] === '.' && isIdentStart(source[i + 1] || '')))) {
        i++;
      }
      let value = source.slice(start, i);

      // Date literals carry their own colon: LAST_N_DAYS:30
      const upper = value.toUpperCase();
      if (source[i] === ':' && DATE_LITERAL_PREFIXES.includes(upper)) {
        const tail = source.slice(i).match(/^:\s*(\d+)/);
        if (tail) {
          value += ':' + tail[1];
          i += tail[0].length;
        }
      }
      tokens.push({ type: 'ident', value, start });
      continue;
    }

    if (c === ':') {
      const start = i;
      i++;
      const expression = readBindExpression();
      tokens.push({ type: 'bind', value: expression, start });
      continue;
    }

    if (c === '(' || c === ')' || c === ',') {
      tokens.push({ type: 'punct', value: c, start: i });
      i++;
      continue;
    }

    const twoChar = source.slice(i, i + 2);
    if (twoChar === '!=' || twoChar === '<=' || twoChar === '>=' || twoChar === '<>') {
      tokens.push({ type: 'op', value: twoChar === '<>' ? '!=' : twoChar, start: i });
      i += 2;
      continue;
    }
    if (c === '=' || c === '<' || c === '>') {
      tokens.push({ type: 'op', value: c, start: i });
      i++;
      continue;
    }

    throw new SoqlSyntaxError(`Unexpected character "${c}"`, i);
  }

  tokens.push({ type: 'eof', value: '', start: source.length });
  return tokens;

  /** Apex bind expressions may be a path, a method call, or a concatenation. */
  function readBindExpression() {
    let expression = '';
    let depth = 0;
    let previousMeaningful = '';

    while (i < source.length) {
      const c = source[i];

      if (c === "'") {
        const token = readString();
        expression += token.raw;
        previousMeaningful = "'";
        continue;
      }
      if (c === '(' || c === '<' || c === '{' || c === '[') depth++;
      if (c === ')' || c === '>' || c === '}' || c === ']') {
        if (depth === 0) break;
        depth--;
      }
      if (c === ',' && depth === 0) break;

      if (/\s/.test(c) && depth === 0) {
        const ahead = source.slice(i).match(/^\s+([+\-*/])/);
        const continues = ahead || /[+\-*/]$/.test(previousMeaningful);
        if (!continues) break;
        expression += ' ';
        i++;
        continue;
      }

      expression += c;
      previousMeaningful = c;
      i++;
    }

    return expression.trim();
  }
}

export class SoqlSyntaxError extends Error {
  constructor(message, position) {
    super(message);
    this.name = 'SoqlSyntaxError';
    this.position = position;
  }
}

/* ------------------------------------------------------------------------- *
 * Parser
 * ------------------------------------------------------------------------- */

const CLAUSE_KEYWORDS = new Set([
  'FROM', 'USING', 'WHERE', 'WITH', 'GROUP', 'HAVING', 'ORDER', 'LIMIT', 'OFFSET',
  'FOR', 'UPDATE', 'ALL', 'AND', 'OR', 'NOT', 'ASC', 'DESC', 'NULLS', 'END', 'WHEN',
  'THEN', 'ELSE', 'LIKE', 'IN', 'INCLUDES', 'EXCLUDES', 'OFFSET',
]);

class Parser {
  constructor(tokens) {
    this.tokens = tokens;
    this.pos = 0;
    this.warnings = [];
  }

  peek(offset = 0) {
    return this.tokens[Math.min(this.pos + offset, this.tokens.length - 1)];
  }

  next() {
    return this.tokens[this.pos++];
  }

  atKeyword(word, offset = 0) {
    const token = this.peek(offset);
    return token.type === 'ident' && token.value.toUpperCase() === word;
  }

  atKeywords(...words) {
    return words.every((word, index) => this.atKeyword(word, index));
  }

  eatKeyword(word) {
    if (!this.atKeyword(word)) return false;
    this.next();
    return true;
  }

  eatKeywords(...words) {
    if (!this.atKeywords(...words)) return false;
    words.forEach(() => this.next());
    return true;
  }

  expectKeyword(word) {
    if (!this.eatKeyword(word)) {
      throw new SoqlSyntaxError(`Expected ${word} but found "${this.peek().value || 'end of query'}"`, this.peek().start);
    }
  }

  atPunct(char, offset = 0) {
    const token = this.peek(offset);
    return token.type === 'punct' && token.value === char;
  }

  eatPunct(char) {
    if (!this.atPunct(char)) return false;
    this.next();
    return true;
  }

  expectPunct(char) {
    if (!this.eatPunct(char)) {
      throw new SoqlSyntaxError(`Expected "${char}" but found "${this.peek().value || 'end of query'}"`, this.peek().start);
    }
  }

  warn(message) {
    if (!this.warnings.includes(message)) this.warnings.push(message);
  }

  /* ----- query ----- */

  parseQuery() {
    this.expectKeyword('SELECT');
    const fields = this.parseSelectList();
    this.expectKeyword('FROM');

    const fromToken = this.next();
    if (fromToken.type !== 'ident') {
      throw new SoqlSyntaxError('Expected an SObject name after FROM', fromToken.start);
    }

    const query = {
      object: fromToken.value,
      alias: null,
      fields,
      scope: null,
      where: null,
      accessMode: null,
      dataCategories: [],
      groupBy: null,
      having: null,
      orderBy: [],
      limit: null,
      offset: null,
      forClauses: [],
      allRows: false,
      updateTracking: false,
      updateViewstat: false,
    };

    if (this.peek().type === 'ident' && !CLAUSE_KEYWORDS.has(this.peek().value.toUpperCase())) {
      query.alias = this.next().value;
    }

    this.parseTrailingClauses(query);
    return query;
  }

  parseTrailingClauses(query) {
    for (;;) {
      if (this.peek().type === 'eof' || this.atPunct(')')) return;

      if (this.eatKeywords('USING', 'SCOPE')) {
        query.scope = this.next().value.toUpperCase();
        continue;
      }
      if (this.eatKeyword('WHERE')) {
        query.where = this.parseCondition();
        continue;
      }
      if (this.atKeyword('WITH')) {
        this.parseWithClause(query);
        continue;
      }
      if (this.eatKeywords('GROUP', 'BY')) {
        query.groupBy = this.parseGroupBy();
        continue;
      }
      if (this.eatKeyword('HAVING')) {
        query.having = this.parseCondition();
        continue;
      }
      if (this.eatKeywords('ORDER', 'BY')) {
        query.orderBy = this.parseOrderBy();
        continue;
      }
      if (this.eatKeyword('LIMIT')) {
        query.limit = this.next().value;
        continue;
      }
      if (this.eatKeyword('OFFSET')) {
        query.offset = this.next().value;
        continue;
      }
      if (this.eatKeywords('ALL', 'ROWS')) {
        query.allRows = true;
        continue;
      }
      if (this.eatKeywords('UPDATE', 'TRACKING')) {
        query.updateTracking = true;
        this.warn('UPDATE TRACKING has no SOQL Lib equivalent and was dropped.');
        continue;
      }
      if (this.eatKeywords('UPDATE', 'VIEWSTAT')) {
        query.updateViewstat = true;
        this.warn('UPDATE VIEWSTAT has no SOQL Lib equivalent and was dropped.');
        continue;
      }
      if (this.eatKeyword('FOR')) {
        do {
          const forToken = this.next();
          query.forClauses.push(String(forToken.value).toUpperCase());
        } while (this.eatPunct(','));
        continue;
      }

      throw new SoqlSyntaxError(`Unexpected "${this.peek().value}"`, this.peek().start);
    }
  }

  parseWithClause(query) {
    this.expectKeyword('WITH');

    if (this.eatKeywords('DATA', 'CATEGORY')) {
      query.dataCategories = this.parseDataCategories();
      return;
    }
    const modeToken = this.next();
    const mode = String(modeToken.value).toUpperCase();
    if (mode === 'USER_MODE' || mode === 'SYSTEM_MODE' || mode === 'SECURITY_ENFORCED') {
      query.accessMode = mode;
      return;
    }
    throw new SoqlSyntaxError(`Unsupported WITH clause "${modeToken.value}"`, modeToken.start);
  }

  parseDataCategories() {
    const filters = [];
    do {
      const field = this.next().value;
      const operatorToken = this.next();
      const operator = String(operatorToken.value).toUpperCase();
      const categories = [];
      if (this.eatPunct('(')) {
        do {
          categories.push(this.next().value);
        } while (this.eatPunct(','));
        this.expectPunct(')');
      } else {
        categories.push(this.next().value);
      }
      filters.push({ field, operator, categories });
    } while (this.eatKeyword('AND'));
    return filters;
  }

  parseGroupBy() {
    let type = 'simple';
    if (this.atKeyword('ROLLUP') && this.atPunct('(', 1)) {
      type = 'rollup';
      this.next();
      this.next();
    } else if (this.atKeyword('CUBE') && this.atPunct('(', 1)) {
      type = 'cube';
      this.next();
      this.next();
    }

    const fields = [];
    do {
      fields.push(this.parseOperand());
    } while (this.eatPunct(','));

    if (type !== 'simple') this.expectPunct(')');
    return { type, fields };
  }

  parseOrderBy() {
    const items = [];
    do {
      const expression = this.parseOperand();
      let direction = null;
      let nulls = null;
      if (this.eatKeyword('ASC')) direction = 'ASC';
      else if (this.eatKeyword('DESC')) direction = 'DESC';
      if (this.eatKeyword('NULLS')) nulls = String(this.next().value).toUpperCase();
      items.push({ expression, direction, nulls });
    } while (this.eatPunct(','));
    return items;
  }

  /* ----- SELECT list ----- */

  parseSelectList() {
    const items = [];
    do {
      items.push(this.parseSelectItem());
    } while (this.eatPunct(','));
    return items;
  }

  parseSelectItem() {
    if (this.atPunct('(')) {
      this.next();
      const subQuery = this.parseQuery();
      this.expectPunct(')');
      return { kind: 'subquery', query: subQuery };
    }

    if (this.atKeyword('TYPEOF')) {
      return this.parseTypeOf();
    }

    const expression = this.parseOperand();
    let alias = null;
    if (this.peek().type === 'ident' && !CLAUSE_KEYWORDS.has(this.peek().value.toUpperCase())) {
      alias = this.next().value;
    }
    return { kind: 'expression', expression, alias };
  }

  parseTypeOf() {
    this.expectKeyword('TYPEOF');
    const parts = ['TYPEOF', this.next().value];
    while (!this.atKeyword('END')) {
      if (this.peek().type === 'eof') {
        throw new SoqlSyntaxError('TYPEOF is missing its END', this.peek().start);
      }
      const token = this.next();
      if (token.type === 'punct' && token.value === ',') parts[parts.length - 1] += ',';
      else parts.push(token.value);
    }
    this.expectKeyword('END');
    parts.push('END');
    this.warn('TYPEOF has no SOQL Lib equivalent - it is left as a comment in the generated code.');
    return { kind: 'typeof', raw: parts.join(' ') };
  }

  /** A field path, a function call, or a literal used on the left of a comparison. */
  parseOperand() {
    const token = this.peek();

    if (token.type === 'ident' && this.atPunct('(', 1)) {
      const name = this.next().value;
      this.next(); // (
      const args = [];
      if (!this.atPunct(')')) {
        do {
          args.push(this.parseOperand());
        } while (this.eatPunct(','));
      }
      this.expectPunct(')');
      return { kind: 'function', name, args };
    }

    if (token.type === 'ident') {
      this.next();
      return { kind: 'field', path: token.value };
    }

    if (token.type === 'string' || token.type === 'number' || token.type === 'date' || token.type === 'datetime' || token.type === 'bind') {
      this.next();
      return { kind: 'literal', literal: token };
    }

    throw new SoqlSyntaxError(`Unexpected "${token.value || 'end of query'}"`, token.start);
  }

  /* ----- conditions ----- */

  parseCondition() {
    return this.parseOr();
  }

  parseOr() {
    let left = this.parseAnd();
    while (this.atKeyword('OR')) {
      this.next();
      const right = this.parseAnd();
      if (left.type === 'or') left.operands.push(right);
      else left = { type: 'or', operands: [left, right] };
    }
    return left;
  }

  parseAnd() {
    let left = this.parseNot();
    while (this.atKeyword('AND')) {
      this.next();
      const right = this.parseNot();
      if (left.type === 'and') left.operands.push(right);
      else left = { type: 'and', operands: [left, right] };
    }
    return left;
  }

  parseNot() {
    if (this.atKeyword('NOT') && !this.atKeyword('LIKE', 1) && !this.atKeyword('IN', 1)) {
      this.next();
      return { type: 'not', operand: this.parseNot() };
    }
    return this.parsePrimary();
  }

  parsePrimary() {
    if (this.atPunct('(')) {
      this.next();
      const condition = this.parseOr();
      this.expectPunct(')');
      return condition;
    }
    return this.parseComparison();
  }

  parseComparison() {
    const field = this.parseOperand();
    const operatorToken = this.peek();

    if (operatorToken.type === 'op') {
      this.next();
      return { type: 'comparison', field, operator: operatorToken.value, value: this.parseValue() };
    }

    if (operatorToken.type === 'ident') {
      const word = operatorToken.value.toUpperCase();
      if (word === 'NOT' && (this.atKeyword('LIKE', 1) || this.atKeyword('IN', 1))) {
        this.next();
        const nextWord = this.next().value.toUpperCase();
        return { type: 'comparison', field, operator: `NOT ${nextWord}`, value: this.parseValue() };
      }
      if (word === 'LIKE' || word === 'IN' || word === 'INCLUDES' || word === 'EXCLUDES') {
        this.next();
        return { type: 'comparison', field, operator: word, value: this.parseValue() };
      }
    }

    throw new SoqlSyntaxError(`Expected a comparison operator but found "${operatorToken.value || 'end of query'}"`, operatorToken.start);
  }

  parseValue() {
    if (this.atPunct('(')) {
      if (this.atKeyword('SELECT', 1)) {
        this.next();
        const subQuery = this.parseQuery();
        this.expectPunct(')');
        return { kind: 'semiJoin', query: subQuery };
      }
      this.next();
      const values = [];
      if (!this.atPunct(')')) {
        do {
          values.push(this.next());
        } while (this.eatPunct(','));
      }
      this.expectPunct(')');
      return { kind: 'list', values };
    }

    const token = this.next();
    if (token.type === 'ident' && this.atPunct('(')) {
      this.pos--;
      return { kind: 'expression', expression: this.parseOperand() };
    }
    return { kind: 'scalar', token };
  }
}

export function parseSoql(input) {
  const parser = new Parser(tokenize(input));
  const query = parser.parseQuery();
  if (parser.peek().type !== 'eof') {
    throw new SoqlSyntaxError(`Unexpected trailing input "${parser.peek().value}"`, parser.peek().start);
  }
  return { query, warnings: parser.warnings };
}

/* ------------------------------------------------------------------------- *
 * Schema resolution helpers
 * ------------------------------------------------------------------------- */

const ID_PATTERN = /^[a-zA-Z0-9]{15}(?:[a-zA-Z0-9]{3})?$/;

function isCustomRelationship(name) {
  return /__r$/i.test(name);
}

function customRelationshipToObject(name) {
  return name.replace(/__r$/i, '__c');
}

/** Resolve the SObject that a relationship path points at, or null. */
function resolveParentObject(relationshipPath, rootObject) {
  const lastSegment = relationshipPath.split('.').pop();
  if (isCustomRelationship(lastSegment)) return customRelationshipToObject(lastSegment);
  const key = lastSegment.toLowerCase();
  if (SELF_PARENT_RELATIONSHIPS.has(key)) return rootObject;
  return PARENT_RELATIONSHIPS[key] || null;
}

function resolveChildObject(relationshipName) {
  if (isCustomRelationship(relationshipName)) return customRelationshipToObject(relationshipName);
  return CHILD_RELATIONSHIPS[relationshipName.toLowerCase()] || null;
}

function splitFieldPath(path) {
  const segments = path.split('.');
  const field = segments.pop();
  return { relationship: segments.length ? segments.join('.') : null, field };
}

function apexString(value) {
  return `'${String(value).replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
}

function isDateLiteral(value) {
  const upper = String(value).toUpperCase();
  if (DATE_LITERALS.has(upper)) return true;
  return DATE_LITERAL_PREFIXES.some((prefix) => upper.startsWith(`${prefix}:`));
}

/** `SOQL.Filter.with(...)` accepts up to five tokens; beyond that use a List. */
function fieldTokenList(objectName, fields, level = 1) {
  const tokens = fields.map((field) => `${objectName}.${field}`);
  if (tokens.length <= 5) return tokens.join(', ');

  const single = `new List<SObjectField>{ ${tokens.join(', ')} }`;
  if (single.length + level * INDENT.length <= 100) return single;

  const rows = [];
  let row = [];
  for (const token of tokens) {
    row.push(token);
    if (row.join(', ').length > 70) { rows.push(row.join(', ')); row = []; }
  }
  if (row.length) rows.push(row.join(', '));
  const inner = indentOf(level + 1);
  return `new List<SObjectField>{\n${rows.map((line) => `${inner}${line}`).join(',\n')}\n${indentOf(level)}}`;
}

/* ------------------------------------------------------------------------- *
 * Generator
 * ------------------------------------------------------------------------- */

const INDENT = '    ';

function indentOf(level) {
  return INDENT.repeat(level);
}

/** `prefix(body)` - keeps the closing paren aligned when the body is multi-line. */
function call(prefix, body, level) {
  if (!body.includes('\n')) return `${prefix}(${body})`;
  return `${prefix}(${body}\n${indentOf(level)})`;
}

class Generator {
  constructor(warnings = []) {
    this.warnings = [...warnings];
  }

  warn(message) {
    if (!this.warnings.includes(message)) this.warnings.push(message);
  }

  generate(query) {
    const lines = [`SOQL.of(${query.object}.SObjectType)`];

    if (query.alias) {
      this.warn(`SObject alias "${query.alias}" is not supported by SOQL Lib and was dropped.`);
    }

    this.warnAboutDroppedFields(query);
    lines.push(...this.selectLines(query, 1));

    if (query.scope) {
      const method = SCOPE_METHODS[query.scope];
      if (method) lines.push(`${INDENT}.${method}()`);
      else if (query.scope === 'EVERYTHING') this.warn('USING SCOPE EVERYTHING is the default and was dropped.');
      else this.warn(`USING SCOPE ${query.scope} has no SOQL Lib equivalent and was dropped.`);
    }

    if (query.where) {
      const body = this.renderCondition(query.where, query, 2);
      lines.push(`${INDENT}${call('.whereAre', body, 1)}`);
    }

    for (const dataCategory of query.dataCategories) {
      lines.push(`${INDENT}.withDataCategory(${this.renderDataCategory(dataCategory)})`);
    }

    if (query.groupBy) lines.push(...this.groupByLines(query));
    if (query.having) {
      const body = this.renderHaving(query.having, query, 2);
      lines.push(`${INDENT}${call('.have', body, 1)}`);
    }

    lines.push(...this.orderByLines(query));

    if (query.limit !== null) lines.push(`${INDENT}.setLimit(${query.limit})`);
    if (query.offset !== null) lines.push(`${INDENT}.offset(${query.offset})`);

    for (const forClause of query.forClauses) {
      if (forClause === 'UPDATE') lines.push(`${INDENT}.forUpdate()`);
      else if (forClause === 'VIEW') lines.push(`${INDENT}.forView()`);
      else if (forClause === 'REFERENCE') lines.push(`${INDENT}.forReference()`);
      else this.warn(`FOR ${forClause} has no SOQL Lib equivalent and was dropped.`);
    }
    if (query.allRows) lines.push(`${INDENT}.allRows()`);

    if (query.accessMode === 'SYSTEM_MODE') {
      lines.push(`${INDENT}.systemMode()`);
    } else if (query.accessMode === 'SECURITY_ENFORCED') {
      lines.push(`${INDENT}.userMode()`);
      this.warn('WITH SECURITY_ENFORCED is replaced by .userMode(), which also enforces sharing rules.');
    }

    lines.push(`${INDENT}${this.resultMethod(query)};`);
    return lines.join('\n');
  }

  /**
   * SOQL.cls keeps only grouped or aggregated elements once a query aggregates
   * (`SoqlFields.toString` retains `groupedFields`). Say so rather than let the
   * field disappear silently.
   */
  warnAboutDroppedFields(query) {
    const expressions = query.fields.filter((item) => item.kind === 'expression');
    const hasAggregate = expressions.some(
      (item) => item.expression.kind === 'function' && AGGREGATE_FUNCTIONS.has(item.expression.name.toUpperCase())
    );
    if (!query.groupBy && !hasAggregate) return;

    const grouped = new Set((query.groupBy ? query.groupBy.fields : []).map((field) => expressionToSoql(field)));
    const dropped = [];

    for (const item of expressions) {
      const expression = item.expression;
      if (expression.kind === 'function') {
        const name = expression.name.toUpperCase();
        // Aggregates, GROUPING and the date functions all land in aggregateFields.
        if (AGGREGATE_FUNCTIONS.has(name) || DATE_FUNCTIONS.has(name) || name === 'GROUPING') continue;
      } else if (item.alias) {
        continue; // `.with(field, alias)` is stored as an aggregate element.
      }
      const stored = item.alias
        ? `${expressionToSoql(expression)} ${item.alias}`
        : expressionToSoql(expression);
      if (!grouped.has(stored)) dropped.push(stored);
    }

    if (dropped.length) {
      this.warn(`SOQL Lib removes non-grouped elements from an aggregate query, so ${dropped.join(', ')} will not be selected.`);
    }
  }

  resultMethod(query) {
    const expressions = query.fields.filter((item) => item.kind === 'expression').map((item) => item.expression);
    const isCountOnly = query.fields.length === 1
      && expressions.length === 1
      && expressions[0].kind === 'function'
      && expressions[0].name.toUpperCase() === 'COUNT'
      && expressions[0].args.length === 0;

    if (isCountOnly) return '.toInteger()';

    const hasAggregate = expressions.some(
      (expression) => expression.kind === 'function' && AGGREGATE_FUNCTIONS.has(expression.name.toUpperCase())
    );
    if (hasAggregate || query.groupBy) return '.toAggregated()';
    return '.toList()';
  }

  /* ----- SELECT ----- */

  selectLines(query, level) {
    const lines = [];
    const pad = indentOf(level);
    const plainFields = [];
    const relationshipGroups = new Map();
    const trailing = [];

    for (const item of query.fields) {
      if (item.kind === 'subquery') {
        trailing.push(this.subQueryLines(item.query, level));
        continue;
      }
      if (item.kind === 'typeof') {
        trailing.push([
          `${pad}// TYPEOF has no SOQL Lib equivalent - select this polymorphic field manually:`,
          `${pad}// ${item.raw}`,
        ]);
        continue;
      }

      const { expression, alias } = item;

      if (expression.kind === 'function') {
        trailing.push([`${pad}${this.functionSelect(expression, alias, query)}`]);
        continue;
      }

      if (expression.kind !== 'field') {
        this.warn('An unsupported SELECT element was emitted as a raw string.');
        trailing.push([`${pad}.with(${apexString(this.renderExpression(expression))})`]);
        continue;
      }

      const { relationship, field } = splitFieldPath(expression.path);

      if (alias) {
        // `.with(field, alias)` is the only aliasing overload and it takes a token.
        if (relationship || !query.object) {
          trailing.push([`${pad}.with(${apexString(`${expression.path} ${alias}`)})`]);
        } else {
          trailing.push([`${pad}.with(${query.object}.${field}, ${apexString(alias)})`]);
        }
        continue;
      }

      if (!relationship) {
        plainFields.push(field);
        continue;
      }
      if (!relationshipGroups.has(relationship)) relationshipGroups.set(relationship, []);
      relationshipGroups.get(relationship).push(field);
    }

    if (plainFields.length) {
      lines.push(query.object
        ? `${pad}.with(${fieldTokenList(query.object, plainFields, level)})`
        : `${pad}.with(${apexString(plainFields.join(', '))})`);
    }

    for (const [relationship, fields] of relationshipGroups) {
      const parentObject = resolveParentObject(relationship, query.object);
      if (parentObject) {
        lines.push(`${pad}.with(${apexString(relationship)}, ${fieldTokenList(parentObject, fields, level)})`);
      } else {
        const paths = fields.map((field) => `${relationship}.${field}`).join(', ');
        lines.push(`${pad}.with(${apexString(paths)})`);
      }
    }

    for (const block of trailing) lines.push(...block);
    return lines;
  }

  functionSelect(expression, alias, query) {
    const name = expression.name.toUpperCase();
    const rendered = this.renderExpression(expression);
    const aliasArgument = alias ? `, ${apexString(alias)}` : '';

    if (name === 'COUNT' && expression.args.length === 0) return '.count()';

    if (AGGREGATE_FUNCTIONS.has(name) && expression.args.length === 1 && expression.args[0].kind === 'field') {
      const method = name === 'COUNT_DISTINCT' ? 'countDistinct' : name.toLowerCase();
      const { relationship, field } = splitFieldPath(expression.args[0].path);
      if (!relationship && query.object) return `.${method}(${query.object}.${field}${aliasArgument})`;
      const parentObject = resolveParentObject(relationship, query.object);
      if (parentObject) return `.${method}(${apexString(relationship)}, ${parentObject}.${field}${aliasArgument})`;
    }

    if (name === 'GROUPING' && alias && query.object && expression.args.length === 1 && expression.args[0].kind === 'field') {
      const { relationship, field } = splitFieldPath(expression.args[0].path);
      if (!relationship) return `.grouping(${query.object}.${field}, ${apexString(alias)})`;
    }

    if (name === 'TOLABEL' && expression.args.length === 1 && expression.args[0].kind === 'field') {
      const { relationship, field } = splitFieldPath(expression.args[0].path);
      const target = relationship || !query.object ? apexString(expression.args[0].path) : `${query.object}.${field}`;
      return `.toLabel(${target}${aliasArgument})`;
    }

    if (name === 'FORMAT' && query.object && expression.args.length === 1 && expression.args[0].kind === 'field') {
      const { relationship, field } = splitFieldPath(expression.args[0].path);
      if (!relationship) return `.format(${query.object}.${field}${aliasArgument})`;
    }

    if (!AGGREGATE_FUNCTIONS.has(name) && !DATE_FUNCTIONS.has(name) && name !== 'FIELDS'
      && !['TOLABEL', 'FORMAT', 'GROUPING', 'CONVERTCURRENCY', 'CONVERTTIMEZONE', 'DISTANCE'].includes(name)) {
      this.warn(`${expression.name}() is not modelled by SOQL Lib - emitted as a raw field string.`);
    }

    return `.with(${apexString(alias ? `${rendered} ${alias}` : rendered)})`;
  }

  subQueryLines(subQuery, level) {
    const childObject = resolveChildObject(subQuery.object);
    const inner = level + 1;
    const pad = indentOf(inner);
    const lines = [`${indentOf(level)}.with(SOQL.SubQuery.of(${apexString(subQuery.object)})`];

    const scoped = { ...subQuery, object: childObject };
    lines.push(...this.selectLines(scoped, inner));

    if (subQuery.where) {
      const body = this.renderCondition(subQuery.where, scoped, inner + 1);
      lines.push(`${pad}${call('.whereAre', body, inner)}`);
    }
    lines.push(...this.orderByLines(scoped, inner));
    if (subQuery.limit !== null) lines.push(`${pad}.setLimit(${subQuery.limit})`);
    if (subQuery.offset !== null) lines.push(`${pad}.offset(${subQuery.offset})`);
    for (const forClause of subQuery.forClauses) {
      if (forClause === 'VIEW') lines.push(`${pad}.forView()`);
      else if (forClause === 'REFERENCE') lines.push(`${pad}.forReference()`);
      else this.warn(`FOR ${forClause} is not available on a SOQL Lib sub-query and was dropped.`);
    }
    if (subQuery.groupBy || subQuery.having || subQuery.scope) {
      this.warn('GROUP BY, HAVING and USING SCOPE are not available on a SOQL Lib sub-query and were dropped.');
    }
    if (!childObject) {
      this.warn(`"${subQuery.object}" is not a known child relationship, so its fields use the String overload.`);
    }

    lines.push(`${indentOf(level)})`);
    return lines;
  }

  /* ----- GROUP BY / ORDER BY ----- */

  groupByLines(query) {
    const lines = [];
    const method = { simple: 'groupBy', rollup: 'groupByRollup', cube: 'groupByCube' }[query.groupBy.type];

    for (const expression of query.groupBy.fields) {
      if (expression.kind === 'field') {
        const { relationship, field } = splitFieldPath(expression.path);
        if (!relationship) {
          lines.push(`${INDENT}.${method}(${query.object}.${field})`);
          continue;
        }
        const parentObject = resolveParentObject(relationship, query.object);
        if (parentObject) {
          lines.push(`${INDENT}.${method}(${apexString(relationship)}, ${parentObject}.${field})`);
        } else if (method === 'groupBy') {
          lines.push(`${INDENT}.groupBy(${apexString(expression.path)})`);
        } else {
          this.warn(`GROUP BY ${query.groupBy.type.toUpperCase()} on "${expression.path}" needs an SObjectField token - check the relationship type.`);
          lines.push(`${INDENT}.${method}(${apexString(relationship)}, ${relationship.split('.').pop()}.${field})`);
        }
        continue;
      }

      const rendered = this.renderExpression(expression);
      if (method === 'groupBy') {
        lines.push(`${INDENT}.groupBy(${apexString(rendered)})`);
      } else {
        this.warn(`GROUP BY ${query.groupBy.type.toUpperCase()} only accepts fields, so "${rendered}" was emitted as GROUP BY.`);
        lines.push(`${INDENT}.groupBy(${apexString(rendered)})`);
      }
    }
    return lines;
  }

  orderByLines(query, level = 1) {
    const lines = [];
    const pad = indentOf(level);

    for (const item of query.orderBy) {
      const expression = item.expression;

      if (expression.kind === 'function' && expression.name.toUpperCase() === 'DISTANCE') {
        lines.push(`${pad}.orderBy(${this.renderDistance(expression, query)})`);
      } else if (expression.kind === 'function' && expression.name.toUpperCase() === 'COUNT'
        && expression.args.length === 1 && expression.args[0].kind === 'field'
        && !expression.args[0].path.includes('.')) {
        lines.push(query.object
          ? `${pad}.orderByCount(${query.object}.${expression.args[0].path})`
          : `${pad}.orderBy(${apexString(this.renderExpression(expression))})`);
      } else if (expression.kind === 'field') {
        const { relationship, field } = splitFieldPath(expression.path);
        if (!relationship) {
          lines.push(query.object
            ? `${pad}.orderBy(${query.object}.${field})`
            : `${pad}.orderBy(${apexString(field)})`);
        } else {
          const parentObject = resolveParentObject(relationship, query.object);
          lines.push(parentObject
            ? `${pad}.orderBy(${apexString(relationship)}, ${parentObject}.${field})`
            : `${pad}.orderBy(${apexString(expression.path)})`);
        }
      } else {
        lines.push(`${pad}.orderBy(${apexString(this.renderExpression(expression))})`);
      }

      if (item.direction === 'DESC') lines.push(`${pad}.sortDesc()`);
      if (item.nulls === 'LAST') lines.push(`${pad}.nullsLast()`);
    }
    return lines;
  }

  renderDataCategory(dataCategory) {
    const method = {
      AT: 'at', ABOVE: 'above', BELOW: 'below', ABOVE_OR_BELOW: 'aboveOrBelow',
    }[dataCategory.operator];

    if (!method) {
      this.warn(`WITH DATA CATEGORY operator "${dataCategory.operator}" is not supported.`);
      return `SOQL.DataCategoryFilter.with(${apexString(dataCategory.field)}).at(${apexString(dataCategory.categories[0])})`;
    }
    const argument = dataCategory.categories.length === 1
      ? apexString(dataCategory.categories[0])
      : `new List<String>{ ${dataCategory.categories.map(apexString).join(', ')} }`;
    return `SOQL.DataCategoryFilter.with(${apexString(dataCategory.field)}).${method}(${argument})`;
  }
}

/* ------------------------------------------------------------------------- *
 * Condition rendering
 * ------------------------------------------------------------------------- */

const RELATIONAL_OPERATORS = new Set(['<', '<=', '>', '>=']);

const NEGATED_OPERATORS = {
  '=': '!=',
  '!=': '=',
  LIKE: 'NOT LIKE',
  'NOT LIKE': 'LIKE',
  IN: 'NOT IN',
  'NOT IN': 'IN',
};

/**
 * Push a NOT down to the leaves. Returns null when a leaf cannot be negated
 * without changing how SOQL treats null values, so the caller can fall back to
 * a raw `NOT (...)` string condition.
 */
function negateCondition(node) {
  if (node.type === 'not') return node.operand;
  if (node.type === 'and' || node.type === 'or') {
    const operands = node.operands.map(negateCondition);
    if (operands.some((operand) => operand === null)) return null;
    return { type: node.type === 'and' ? 'or' : 'and', operands };
  }
  if (node.type === 'comparison') {
    const operator = NEGATED_OPERATORS[node.operator];
    if (!operator) return null;
    return { ...node, operator };
  }
  return null;
}

function conditionToSoql(node) {
  if (node.type === 'and' || node.type === 'or') {
    const separator = node.type === 'and' ? ' AND ' : ' OR ';
    return node.operands.map((operand) => {
      const rendered = conditionToSoql(operand);
      return operand.type === 'and' || operand.type === 'or' ? `(${rendered})` : rendered;
    }).join(separator);
  }
  if (node.type === 'not') return `NOT (${conditionToSoql(node.operand)})`;
  return `${expressionToSoql(node.field)} ${node.operator} ${valueToSoql(node.value)}`;
}

function expressionToSoql(expression) {
  if (expression.kind === 'field') return expression.path;
  if (expression.kind === 'function') {
    return `${expression.name}(${expression.args.map(expressionToSoql).join(', ')})`;
  }
  return tokenToSoql(expression.literal);
}

function tokenToSoql(token) {
  if (token.type === 'string') return `'${token.value.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
  if (token.type === 'bind') return `:${token.value}`;
  return token.value;
}

function valueToSoql(value) {
  if (value.kind === 'scalar') return tokenToSoql(value.token);
  if (value.kind === 'list') return `(${value.values.map(tokenToSoql).join(', ')})`;
  if (value.kind === 'expression') return expressionToSoql(value.expression);
  return `(${queryToSoql(value.query)})`;
}

function queryToSoql(query) {
  const fields = query.fields.map((item) => {
    if (item.kind === 'subquery') return `(${queryToSoql(item.query)})`;
    if (item.kind === 'typeof') return item.raw;
    return item.alias ? `${expressionToSoql(item.expression)} ${item.alias}` : expressionToSoql(item.expression);
  });
  let soql = `SELECT ${fields.join(', ')} FROM ${query.object}`;
  if (query.where) soql += ` WHERE ${conditionToSoql(query.where)}`;
  if (query.limit !== null) soql += ` LIMIT ${query.limit}`;
  return soql;
}

/** Infer the Apex list type for an `IN (...)` literal list. */
function listTypeOf(tokens) {
  if (tokens.every((token) => token.type === 'number')) {
    return tokens.some((token) => token.value.includes('.')) ? 'Decimal' : 'Integer';
  }
  if (tokens.every((token) => token.type === 'date')) return 'Date';
  if (tokens.every((token) => token.type === 'datetime')) return 'Datetime';
  if (tokens.every((token) => token.type === 'string' && ID_PATTERN.test(token.value))) return 'Id';
  return 'String';
}

function literalToApex(token) {
  if (token.type === 'string') return apexString(token.value);
  if (token.type === 'number') return token.value;
  if (token.type === 'bind') return token.value;
  if (token.type === 'date') {
    const [year, month, day] = token.value.split('-');
    return `Date.newInstance(${Number(year)}, ${Number(month)}, ${Number(day)})`;
  }
  if (token.type === 'datetime') {
    // Normalise the offset away - newInstanceGmt takes UTC components.
    const withZone = /(?:Z|[+-]\d{2}:\d{2})$/.test(token.value) ? token.value : `${token.value}Z`;
    const instant = new Date(withZone);
    const parts = [
      instant.getUTCFullYear(), instant.getUTCMonth() + 1, instant.getUTCDate(),
      instant.getUTCHours(), instant.getUTCMinutes(), instant.getUTCSeconds(),
    ];
    return `Datetime.newInstanceGmt(${parts.join(', ')})`;
  }
  const upper = String(token.value).toUpperCase();
  if (upper === 'TRUE' || upper === 'FALSE') return upper.toLowerCase();
  if (upper === 'NULL') return 'null';
  if (isDateLiteral(token.value)) return apexString(upper);
  return apexString(token.value);
}

Object.assign(Generator.prototype, {
  renderCondition(node, query, level) {
    if (node.type === 'not') {
      const negated = negateCondition(node.operand);
      if (negated) return this.renderCondition(negated, query, level);
      this.warn('NOT could not be pushed into a filter and was emitted as a raw condition string.');
      return `SOQL.FilterGroup.add(${apexString(`NOT (${conditionToSoql(node.operand)})`)})`;
    }

    if (node.type === 'and' || node.type === 'or') {
      const inner = level;
      const pad = indentOf(inner);
      const lines = ['SOQL.FilterGroup'];
      for (const operand of node.operands) {
        const body = this.renderCondition(operand, query, inner + 1);
        lines.push(`${pad}${call('.add', body, inner)}`);
      }
      if (node.type === 'or') lines.push(`${pad}.anyConditionMatching()`);
      return lines.join('\n');
    }

    return this.renderFilter(node, query, level);
  },

  renderFilter(comparison, query, level) {
    const reference = this.filterFieldReference(comparison.field, query);
    if (!reference) {
      this.warn('A condition could not be mapped to SOQL.Filter and was emitted as a raw string.');
      return apexString(conditionToSoql(comparison));
    }

    const suffix = this.comparatorCall(comparison, query, level);
    if (suffix === null) {
      this.warn('A condition could not be mapped to SOQL.Filter and was emitted as a raw string.');
      return apexString(conditionToSoql(comparison));
    }
    return `${reference}${suffix}`;
  },

  filterFieldReference(expression, query) {
    if (expression.kind === 'function') {
      if (expression.name.toUpperCase() === 'DISTANCE') {
        return `SOQL.Filter.with(${this.renderDistance(expression, query)})`;
      }
      return null;
    }
    if (expression.kind !== 'field') return null;

    const path = expression.path;
    if (path.toLowerCase() === 'id') return 'SOQL.Filter.id()';
    if (path.toLowerCase() === 'name') return 'SOQL.Filter.name()';
    if (path.toLowerCase() === 'recordtype.developername') return 'SOQL.Filter.recordType()';

    const { relationship, field } = splitFieldPath(path);
    if (!relationship) {
      return query.object
        ? `SOQL.Filter.with(${query.object}.${field})`
        : `SOQL.Filter.with(${apexString(field)})`;
    }

    const parentObject = resolveParentObject(relationship, query.object);
    return parentObject
      ? `SOQL.Filter.with(${apexString(relationship)}, ${parentObject}.${field})`
      : `SOQL.Filter.with(${apexString(path)})`;
  },

  comparatorCall(comparison, query, level = 1) {
    const { operator, value } = comparison;

    if (operator === 'IN' || operator === 'NOT IN') {
      const method = operator === 'IN' ? 'isIn' : 'notIn';
      if (value.kind === 'semiJoin') {
        return call(`.${method}`, this.renderInnerJoin(value.query, level + 1), level);
      }
      if (value.kind === 'list') {
        const type = listTypeOf(value.values);
        return `.${method}(new List<${type}>{ ${value.values.map(literalToApex).join(', ')} })`;
      }
      if (value.kind === 'scalar' && value.token.type === 'bind') return `.${method}(${value.token.value})`;
      return null;
    }

    if (operator === 'INCLUDES' || operator === 'EXCLUDES') {
      if (value.kind !== 'list' || !value.values.every((token) => token.type === 'string')) return null;
      const rawValues = value.values.map((token) => token.value);
      const isSemicolonForm = rawValues.length === 1 && rawValues[0].includes(';');
      if (rawValues.length > 1 && rawValues.some((entry) => entry.includes(';'))) return null;
      const entries = isSemicolonForm ? rawValues[0].split(';').map((entry) => entry.trim()) : rawValues;
      const list = `new List<String>{ ${entries.map(apexString).join(', ')} }`;
      if (operator === 'INCLUDES') return isSemicolonForm ? `.includesAll(${list})` : `.includesSome(${list})`;
      return isSemicolonForm ? `.excludesSome(${list})` : `.excludesAll(${list})`;
    }

    if (operator === 'LIKE' || operator === 'NOT LIKE') {
      return this.likeCall(operator === 'NOT LIKE', value);
    }

    if (value.kind !== 'scalar') return null;
    const token = value.token;
    const dateLiteralSuffix = token.type === 'ident' && isDateLiteral(token.value) ? '.asDateLiteral()' : '';
    const isNullLiteral = token.type === 'ident' && token.value.toUpperCase() === 'NULL';
    const isTrueLiteral = token.type === 'ident' && token.value.toUpperCase() === 'TRUE';
    const isFalseLiteral = token.type === 'ident' && token.value.toUpperCase() === 'FALSE';

    if (operator === '=') {
      if (isNullLiteral) return '.isNull()';
      if (isTrueLiteral) return '.isTrue()';
      if (isFalseLiteral) return '.isFalse()';
      return `.equal(${literalToApex(token)})${dateLiteralSuffix}`;
    }
    if (operator === '!=') {
      if (isNullLiteral) return '.isNotNull()';
      return `.notEqual(${literalToApex(token)})${dateLiteralSuffix}`;
    }

    const method = { '<': 'lessThan', '<=': 'lessOrEqual', '>': 'greaterThan', '>=': 'greaterOrEqual' }[operator];
    if (!method) return null;
    return `.${method}(${literalToApex(token)})${dateLiteralSuffix}`;
  },

  likeCall(isNegated, value) {
    const prefix = isNegated ? 'not' : '';
    const name = (base) => (isNegated ? `not${base[0].toUpperCase()}${base.slice(1)}` : base);

    if (value.kind !== 'scalar') return null;
    const token = value.token;

    if (token.type === 'bind') {
      const expression = token.value.replace(/^\((.*)\)$/s, '$1').trim();
      const contains = expression.match(/^'%'\s*\+\s*(.+?)\s*\+\s*'%'$/);
      if (contains) return `.${name('contains')}(${contains[1]})`;
      const startsWith = expression.match(/^(.+?)\s*\+\s*'%'$/);
      if (startsWith) return `.${name('startsWith')}(${startsWith[1]})`;
      const endsWith = expression.match(/^'%'\s*\+\s*(.+)$/);
      if (endsWith) return `.${name('endsWith')}(${endsWith[1]})`;
      return `.${name('contains')}('', ${expression}, '')`;
    }

    if (token.type !== 'string') return null;
    const pattern = token.value;
    const core = pattern.slice(1, -1);

    if (pattern.length > 1 && pattern.startsWith('%') && pattern.endsWith('%') && !core.includes('%')) {
      return `.${name('contains')}(${apexString(core)})`;
    }
    if (!pattern.startsWith('%') && pattern.endsWith('%') && !pattern.slice(0, -1).includes('%')) {
      return `.${name('startsWith')}(${apexString(pattern.slice(0, -1))})`;
    }
    if (pattern.startsWith('%') && !pattern.endsWith('%') && !pattern.slice(1).includes('%')) {
      return `.${name('endsWith')}(${apexString(pattern.slice(1))})`;
    }
    return `.${prefix ? 'notContains' : 'contains'}('', ${apexString(pattern)}, '')`;
  },

  renderInnerJoin(query, level) {
    const field = query.fields.find((item) => item.kind === 'expression' && item.expression.kind === 'field');
    const fieldPath = field ? field.expression.path : 'Id';
    const pad = indentOf(level);
    const lines = [
      `SOQL.InnerJoin.of(${query.object}.SObjectType)`,
      `${pad}.with(${query.object}.${fieldPath})`,
    ];
    if (query.where) {
      const body = this.renderCondition(query.where, query, level + 1);
      lines.push(`${pad}${call('.whereAre', body, level)}`);
    }
    if (query.fields.length > 1 || query.limit !== null || query.orderBy.length) {
      this.warn('SOQL.InnerJoin supports one field and a WHERE clause only - the rest of the semi-join was dropped.');
    }
    return lines.join('\n');
  },

  renderDistance(expression, query) {
    const [fieldArgument, locationArgument, unitArgument] = expression.args;
    if (!fieldArgument || fieldArgument.kind !== 'field') return apexString(expressionToSoql(expression));

    const { relationship, field } = splitFieldPath(fieldArgument.path);
    let target;
    if (!relationship) {
      target = query.object ? `${query.object}.${field}` : null;
    } else {
      const parentObject = resolveParentObject(relationship, query.object);
      target = parentObject ? `${apexString(relationship)}, ${parentObject}.${field}` : null;
    }
    if (!target) return apexString(expressionToSoql(expression));

    let between = '';
    if (locationArgument && locationArgument.kind === 'function' && locationArgument.args.length === 2) {
      const coordinates = locationArgument.args.map((argument) => expressionToSoql(argument));
      between = `.between(${coordinates.join(', ')})`;
    }
    const unit = unitArgument && unitArgument.kind === 'literal' && /mi/i.test(unitArgument.literal.value) ? '.mi()' : '.km()';
    return `SOQL.Distance.of(${target})${between}${unit}`;
  },

  /* ----- HAVING ----- */

  renderHaving(node, query, level) {
    if (node.type === 'not') {
      const negated = negateCondition(node.operand);
      if (negated) return this.renderHaving(negated, query, level);
      this.warn('NOT could not be pushed into a HAVING filter and was emitted as a raw condition string.');
      return apexString(`NOT (${conditionToSoql(node.operand)})`);
    }

    if (node.type === 'and' || node.type === 'or') {
      const pad = indentOf(level);
      const lines = ['SOQL.HavingFilterGroup'];
      for (const operand of node.operands) {
        const body = this.renderHaving(operand, query, level + 1);
        lines.push(`${pad}${call('.add', body, level)}`);
      }
      if (node.type === 'or') lines.push(`${pad}.anyConditionMatching()`);
      return lines.join('\n');
    }

    const reference = this.havingFieldReference(node.field, query);
    const suffix = this.havingComparator(node);
    if (!reference || suffix === null) {
      this.warn('A HAVING condition could not be mapped and was emitted as a raw string.');
      return apexString(conditionToSoql(node));
    }
    return `${reference}${suffix}`;
  },

  havingFieldReference(expression, query) {
    if (expression.kind === 'function') {
      const name = expression.name.toUpperCase();
      if (!AGGREGATE_FUNCTIONS.has(name) || expression.args.length !== 1 || expression.args[0].kind !== 'field') return null;
      const method = name === 'COUNT_DISTINCT' ? 'countDistinct' : name.toLowerCase();
      const { relationship, field } = splitFieldPath(expression.args[0].path);
      if (relationship) {
        const parentObject = resolveParentObject(relationship, query.object);
        if (!parentObject) return null;
        return `SOQL.HavingFilter.${method}(${parentObject}.${field})`;
      }
      return `SOQL.HavingFilter.${method}(${query.object}.${field})`;
    }
    if (expression.kind !== 'field') return null;

    const { relationship, field } = splitFieldPath(expression.path);
    if (!relationship) return `SOQL.HavingFilter.with(${query.object}.${field})`;
    return `SOQL.HavingFilter.with(${apexString(expression.path)})`;
  },

  havingComparator(comparison) {
    const { operator, value } = comparison;

    if (operator === 'IN' || operator === 'NOT IN') {
      if (value.kind !== 'list' || !value.values.every((token) => token.type === 'string')) return null;
      const list = `new List<String>{ ${value.values.map((token) => apexString(token.value)).join(', ')} }`;
      return operator === 'IN' ? `.isIn(${list})` : `.notIn(${list})`;
    }
    if (operator === 'LIKE' || operator === 'NOT LIKE') return this.likeCall(operator === 'NOT LIKE', value);
    if (value.kind !== 'scalar') return null;

    const token = value.token;
    const isNullLiteral = token.type === 'ident' && token.value.toUpperCase() === 'NULL';
    if (operator === '=') {
      if (isNullLiteral) return '.isNull()';
      if (token.type === 'ident' && token.value.toUpperCase() === 'TRUE') return '.isTrue()';
      if (token.type === 'ident' && token.value.toUpperCase() === 'FALSE') return '.isFalse()';
      return `.equal(${literalToApex(token)})`;
    }
    if (operator === '!=') {
      if (isNullLiteral) return '.isNotNull()';
      return `.notEqual(${literalToApex(token)})`;
    }
    const method = { '<': 'lessThan', '<=': 'lessOrEqual', '>': 'greaterThan', '>=': 'greaterOrEqual' }[operator];
    if (!method) return null;
    return `.${method}(${literalToApex(token)})`;
  },

  renderExpression(expression) {
    return expressionToSoql(expression);
  },
});

/* ------------------------------------------------------------------------- *
 * Public API
 * ------------------------------------------------------------------------- */

export function translate(soqlText) {
  if (!String(soqlText || '').trim()) {
    return { code: '', warnings: [], error: null };
  }
  try {
    const { query, warnings } = parseSoql(soqlText);
    const generator = new Generator(warnings);
    const code = generator.generate(query);
    return { code, warnings: generator.warnings, error: null };
  } catch (error) {
    if (error instanceof SoqlSyntaxError) {
      return { code: '', warnings: [], error: error.message };
    }
    return { code: '', warnings: [], error: `Could not translate the query: ${error.message}` };
  }
}

export default translate;
