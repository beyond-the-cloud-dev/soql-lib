/**
 * Emulates SOQL.cls: consumes generated SOQL Lib apex and renders the SOQL
 * string the Apex library would produce. Bind variables are inlined so the
 * result can be compared against the original query.
 */

/* ----- Apex expression tokenizer / parser ----- */

function tokenizeApex(rawSource) {
  const source = rawSource.replace(/\/\/[^\n]*/g, '');
  const tokens = [];
  let i = 0;
  while (i < source.length) {
    const c = source[i];
    if (/\s/.test(c)) { i++; continue; }
    if (c === "'") {
      let value = ''; i++;
      while (i < source.length) {
        if (source[i] === '\\') { value += source[i + 1]; i += 2; continue; }
        if (source[i] === "'") { i++; break; }
        value += source[i]; i++;
      }
      tokens.push({ type: 'string', value });
      continue;
    }
    if (/[0-9]/.test(c) || (c === '-' && /[0-9]/.test(source[i + 1] || ''))) {
      const m = source.slice(i).match(/^-?\d+(?:\.\d+)?/);
      tokens.push({ type: 'number', value: m[0] }); i += m[0].length; continue;
    }
    if (/[A-Za-z_]/.test(c)) {
      const m = source.slice(i).match(/^[A-Za-z_][A-Za-z0-9_]*/);
      tokens.push({ type: 'ident', value: m[0] }); i += m[0].length; continue;
    }
    if ('(){}<>,.;[]'.includes(c)) { tokens.push({ type: 'punct', value: c }); i++; continue; }
    if ('+-*/'.includes(c)) { tokens.push({ type: 'operator', value: c }); i++; continue; }
    throw new Error(`Unexpected apex character "${c}" at ${i}`);
  }
  tokens.push({ type: 'eof', value: '' });
  return tokens;
}

class ApexParser {
  constructor(tokens) { this.tokens = tokens; this.pos = 0; }
  peek(o = 0) { return this.tokens[Math.min(this.pos + o, this.tokens.length - 1)]; }
  next() { return this.tokens[this.pos++]; }
  isPunct(c, o = 0) { const t = this.peek(o); return t.type === 'punct' && t.value === c; }
  eatPunct(c) { if (!this.isPunct(c)) return false; this.next(); return true; }
  expectPunct(c) { if (!this.eatPunct(c)) throw new Error(`Expected "${c}" but found "${this.peek().value}"`); }

  parseExpression() {
    let node = this.parseChain();
    if (this.peek().type === 'operator') {
      const parts = [node];
      const operators = [];
      while (this.peek().type === 'operator') {
        operators.push(this.next().value);
        parts.push(this.parseChain());
      }
      return { kind: 'binary', parts, operators };
    }
    return node;
  }

  parseChain() {
    let node = this.parsePrimary();
    while (this.isPunct('.')) {
      this.next();
      const name = this.next();
      if (name.type !== 'ident') throw new Error(`Expected a member name, found "${name.value}"`);
      if (this.isPunct('(')) {
        node = { kind: 'call', target: node, name: name.value, args: this.parseArgs() };
      } else {
        node = { kind: 'member', target: node, name: name.value };
      }
    }
    return node;
  }

  parseArgs() {
    this.expectPunct('(');
    const args = [];
    if (!this.isPunct(')')) {
      do { args.push(this.parseExpression()); } while (this.eatPunct(','));
    }
    this.expectPunct(')');
    return args;
  }

  parsePrimary() {
    const token = this.peek();
    if (token.type === 'punct' && token.value === '(') {
      this.next();
      const inner = this.parseExpression();
      this.expectPunct(')');
      return inner;
    }
    if (token.type === 'string') { this.next(); return { kind: 'string', value: token.value }; }
    if (token.type === 'number') { this.next(); return { kind: 'number', value: token.value }; }
    if (token.type === 'ident' && token.value === 'new') {
      this.next();
      let type = this.next().value;
      if (this.eatPunct('<')) {
        const generics = [];
        do { generics.push(this.next().value); } while (this.eatPunct(','));
        this.expectPunct('>');
        type += `<${generics.join(',')}>`;
      }
      const elements = [];
      if (this.eatPunct('{')) {
        if (!this.isPunct('}')) {
          do { elements.push(this.parseExpression()); } while (this.eatPunct(','));
        }
        this.expectPunct('}');
      } else if (this.isPunct('(')) {
        this.parseArgs();
      }
      return { kind: 'newCollection', type, elements };
    }
    if (token.type === 'ident') {
      this.next();
      if (this.isPunct('(')) return { kind: 'call', target: null, name: token.value, args: this.parseArgs() };
      return { kind: 'ident', value: token.value };
    }
    throw new Error(`Unexpected apex token "${token.value}"`);
  }
}

export function parseApexChain(code) {
  const cleaned = code.trim().replace(/;\s*$/, '');
  const parser = new ApexParser(tokenizeApex(cleaned));
  const expression = parser.parseExpression();
  if (parser.peek().type !== 'eof') throw new Error(`Trailing apex input near "${parser.peek().value}"`);
  return expression;
}

export function renderApex(node) {
  if (node.kind === 'string') return `'${node.value}'`;
  if (node.kind === 'number') return node.value;
  if (node.kind === 'ident') return node.value;
  if (node.kind === 'member') return `${renderApex(node.target)}.${node.name}`;
  if (node.kind === 'call') {
    const prefix = node.target ? `${renderApex(node.target)}.` : '';
    return `${prefix}${node.name}(${node.args.map(renderApex).join(', ')})`;
  }
  if (node.kind === 'newCollection') return `new ${node.type}{ ${node.elements.map(renderApex).join(', ')} }`;
  if (node.kind === 'binary') {
    return node.parts.map(renderApex).reduce((acc, part, index) => index === 0 ? part : `${acc} ${node.operators[index - 1]} ${part}`, '');
  }
  return '';
}

/* ----- SOQL literal rendering (stands in for the bind map) ----- */

function soqlLiteral(value) {
  if (value === null) return 'null';
  if (typeof value === 'boolean') return String(value);
  if (typeof value === 'number') return String(value);
  if (typeof value === 'string') return `'${value.replace(/\\/g, '\\\\').replace(/'/g, "\\'")}'`;
  if (value && value.__kind === 'raw') return value.text;
  if (value && value.__kind === 'bind') return `:${value.name}`;
  if (value && value.__kind === 'list') return `(${value.values.map(soqlLiteral).join(', ')})`;
  if (Array.isArray(value)) return `(${value.map(soqlLiteral).join(', ')})`;
  if (value && typeof value.toString === 'function') return value.toString();
  return String(value);
}

/* ----- SOQL.cls emulation ----- */

const FUNCTION_FIELDS = new Set(['CONVERTCURRENCY', 'CONVERTTIMEZONE', 'FORMAT', 'GROUPING', 'TOLABEL']);
const AGGREGATE_FIELDS = new Set(['COUNT', 'AVG', 'COUNT_DISTINCT', 'MIN', 'MAX', 'SUM']);
const DATE_FIELDS = new Set(['CALENDAR_MONTH', 'CALENDAR_QUARTER', 'CALENDAR_YEAR', 'DAY_IN_MONTH',
  'DAY_IN_WEEK', 'DAY_IN_YEAR', 'DAY_ONLY', 'FISCAL_MONTH', 'FISCAL_QUARTER', 'FISCAL_YEAR',
  'HOUR_IN_DAY', 'WEEK_IN_MONTH', 'WEEK_IN_YEAR']);

function concatParts(parts) {
  if (!parts.some((part) => part && part.__kind === 'bind')) return parts.join('');
  const pieces = parts
    .filter((part) => part !== '')
    .map((part) => (part && part.__kind === 'bind' ? part.name : `'${part}'`));
  return { __kind: 'bind', name: pieces.join(' + ') };
}

class FieldSet {
  constructor() { this.values = []; }
  add(field) { if (!this.values.includes(field)) this.values.push(field); }
  get isEmpty() { return this.values.length === 0; }
  clear() { this.values = []; }
  retainAll(keep) { this.values = this.values.filter((value) => keep.includes(value)); }
}

class Fields {
  constructor() {
    this.plain = new FieldSet();
    this.relationship = new FieldSet();
    this.functions = new FieldSet();
    this.aggregates = new FieldSet();
    this.grouped = [];
  }

  count() { this.clearAll(); this.aggregates.add('COUNT()'); }

  clearAll() { this.plain.clear(); this.relationship.clear(); this.functions.clear(); this.aggregates.clear(); }

  withString(commaSeparated) {
    for (const part of String(commaSeparated).split(',')) this.classify(part.trim());
  }

  classify(field) {
    const head = field.split('(')[0].toUpperCase();
    if (FUNCTION_FIELDS.has(head)) { this.functions.add(field); return; }
    const isAliasing = !field.includes('(') && !field.includes(')') && field.includes(' ');
    if (AGGREGATE_FIELDS.has(head) || DATE_FIELDS.has(head) || isAliasing) { this.aggregates.add(field); return; }
    if (!field.includes('(') && !field.includes(')') && field.includes('.')) { this.relationship.add(field); return; }
    this.plain.add(field);
  }

  addAggregate(text, alias) { this.aggregates.add(alias ? `${text} ${alias}` : text); }
  addFunction(text, alias) { this.functions.add(alias ? `${text} ${alias}` : text); }

  toString() {
    if (this.plain.isEmpty && this.relationship.isEmpty && this.aggregates.isEmpty && this.functions.isEmpty) {
      this.plain.add('Id');
    }
    if (this.grouped.length || !this.aggregates.isEmpty) {
      this.plain.retainAll(this.grouped);
      this.relationship.retainAll(this.grouped);
      this.functions.retainAll(this.grouped);
    }
    const selected = [...this.plain.values, ...this.relationship.values, ...this.functions.values, ...this.aggregates.values];
    return `SELECT ${selected.join(', ')}`;
  }
}

class FilterBuilder {
  constructor(connector = 'AND') { this.conditions = []; this.customOrder = null; this.connector = connector; }
  addCondition(condition) { this.conditions.push(condition); }
  buildNested() {
    const order = this.customOrder || this.conditions.map((_, index) => index + 1).join(` ${this.connector} `);
    return order.replace(/\b(\d+)\b/g, (match, index) => {
      const condition = this.conditions[Number(index) - 1];
      return condition === undefined ? match : condition.toString();
    });
  }
}

class FilterGroup extends FilterBuilder {
  add(condition) { this.addCondition(condition); return this; }
  anyConditionMatching() { this.connector = 'OR'; return this; }
  conditionLogic(order) { this.customOrder = order; return this; }
  ignoreWhen(flag) { if (flag) this.conditions = []; return this; }
  toString() { return `(${this.buildNested()})`; }
}

class MainFilterGroup extends FilterGroup {
  toString() { return this.conditions.length ? `WHERE ${this.buildNested()}` : ''; }
}

class Filter {
  constructor() { this.field = null; this.comparator = null; this.value = undefined; this.wrapper = null; this.skipBinding = false; }
  id() { this.field = 'Id'; return this; }
  name() { this.field = 'Name'; return this; }
  recordType() { this.field = 'RecordType.DeveloperName'; return this; }
  with(...args) {
    if (args.length === 1) this.field = String(args[0]);
    else this.field = `${args[0]}.${args[1]}`;
    return this;
  }
  set(comparator, value) { this.comparator = comparator; this.value = value; return this; }
  isNull() { return this.set('=', null); }
  isNotNull() { return this.set('!=', null); }
  isTrue() { return this.set('=', true); }
  isFalse() { return this.set('=', false); }
  equal(value) { return this.set('=', value); }
  notEqual(value) { return this.set('!=', value); }
  lessThan(value) { return this.set('<', value); }
  lessOrEqual(value) { return this.set('<=', value); }
  greaterThan(value) { return this.set('>', value); }
  greaterOrEqual(value) { return this.set('>=', value); }
  contains(...args) {
    if (args.length === 1) return this.set('LIKE', concatParts(['%', args[0], '%']));
    return this.set('LIKE', concatParts(args));
  }
  startsWith(value) { return this.contains('', value, '%'); }
  endsWith(value) { return this.contains('%', value, ''); }
  notLike() { this.wrapper = 'NOT'; return this; }
  notContains(...args) { return this.notLike().contains(...args); }
  notStartsWith(value) { return this.notLike().startsWith(value); }
  notEndsWith(value) { return this.notLike().endsWith(value); }
  containsSome(values) { return this.set('LIKE', values); }
  isIn(value) { if (value instanceof InnerJoin) this.skipBinding = true; return this.set('IN', value); }
  notIn(value) { if (value instanceof InnerJoin) this.skipBinding = true; return this.set('NOT IN', value); }
  multipicklist(operator, values, separator) {
    this.skipBinding = true;
    return this.set(operator, { __kind: 'raw', text: `('${values.join(separator)}')` });
  }
  includesAll(values) { return this.multipicklist('INCLUDES', values, ';'); }
  includesSome(values) { return this.multipicklist('INCLUDES', values, "', '"); }
  excludesAll(values) { return this.multipicklist('EXCLUDES', values, "', '"); }
  excludesSome(values) { return this.multipicklist('EXCLUDES', values, ';'); }
  asDateLiteral() { this.skipBinding = true; return this; }
  ignoreWhen(flag) { if (flag) this.field = ''; return this; }
  toString() {
    const value = this.skipBinding && typeof this.value === 'string' ? this.value : soqlLiteral(this.value);
    const body = `${this.field} ${this.comparator} ${value}`;
    return this.wrapper === 'NOT' ? `(NOT ${body})` : body;
  }
}

class HavingFilter extends Filter {
  aggregate(fn, field) { this.field = `${fn}(${field})`; return this; }
  count(field) { return this.aggregate('COUNT', field); }
  avg(field) { return this.aggregate('AVG', field); }
  countDistinct(field) { return this.aggregate('COUNT_DISTINCT', field); }
  min(field) { return this.aggregate('MIN', field); }
  max(field) { return this.aggregate('MAX', field); }
  sum(field) { return this.aggregate('SUM', field); }
  isIn(values) { return this.set('IN', { __kind: 'raw', text: `('${values.join("', '")}')` }); }
  notIn(values) { return this.set('NOT IN', { __kind: 'raw', text: `('${values.join("', '")}')` }); }
  toString() {
    const body = `${this.field} ${this.comparator} ${soqlLiteral(this.value)}`;
    return this.wrapper === 'NOT' ? `(NOT ${body})` : body;
  }
}

class HavingFilterGroup extends FilterGroup {}
class MainHavingGroup extends FilterGroup {
  toString() { return this.conditions.length ? `HAVING ${this.buildNested()}` : ''; }
}

class DataCategoryFilter {
  with(field) { this.field = field; return this; }
  set(comparator, value) {
    this.comparator = comparator;
    this.value = Array.isArray(value) ? `(${value.join(', ')})` : value;
    return this;
  }
  at(v) { return this.set('AT', v); }
  above(v) { return this.set('ABOVE', v); }
  below(v) { return this.set('BELOW', v); }
  aboveOrBelow(v) { return this.set('ABOVE_OR_BELOW', v); }
  toString() { return `${this.field} ${this.comparator} ${this.value}`; }
}

class MainDataCategoryGroup extends FilterGroup {
  toString() { return this.conditions.length ? `WITH DATA CATEGORY ${this.buildNested()}` : ''; }
}

class Distance {
  constructor() { this.unitValue = 'km'; }
  of(...args) { this.field = args.length === 1 ? String(args[0]) : `${args[0]}.${args[1]}`; return this; }
  between(latitude, longitude) { this.location = `GEOLOCATION(${latitude},${longitude})`; return this; }
  mi() { this.unitValue = 'mi'; return this; }
  km() { this.unitValue = 'km'; return this; }
  toString() { return `DISTANCE(${this.field}, ${this.location},' ${this.unitValue}')`; }
}

class OrderBy {
  constructor() { this.field = null; this.direction = 'ASC'; this.nulls = 'FIRST'; }
  toString() { return `${this.field} ${this.direction} NULLS ${this.nulls}`; }
}

class QueryBuilder {
  constructor(objectName) {
    this.objectName = objectName;
    this.fields = new Fields();
    this.subQueries = [];
    this.scope = null;
    this.conditions = new MainFilterGroup();
    this.dataCategory = new MainDataCategoryGroup();
    this.groupByFields = [];
    this.groupByFunction = '';
    this.having = new MainHavingGroup();
    this.orderBys = [];
    this.limitValue = null;
    this.offsetValue = null;
    this.forValue = null;
  }

  toString() {
    const parts = [this.fields.toString()];
    if (this.subQueries.length) parts.push(`, ${this.subQueries.map((sub) => `(${sub})`).join(', ')}`);
    parts.push(`FROM ${this.objectName}`);
    if (this.scope) parts.push(`USING SCOPE ${this.scope}`);
    const where = this.conditions.toString();
    if (where) parts.push(where);
    const dataCategory = this.dataCategory.toString();
    if (dataCategory) parts.push(dataCategory);
    if (this.groupByFields.length) {
      const joined = this.groupByFields.join(', ');
      parts.push(`GROUP BY ${this.groupByFunction ? `${this.groupByFunction}(${joined})` : joined}`);
    }
    const having = this.having.toString();
    if (having) parts.push(having);
    if (this.orderBys.length) parts.push(`ORDER BY ${this.orderBys.map(String).join(', ')}`);
    if (this.limitValue !== null) parts.push(`LIMIT ${this.limitValue}`);
    if (this.offsetValue !== null) parts.push(`OFFSET ${this.offsetValue}`);
    if (this.forValue) parts.push(this.forValue);
    return parts.join(' ').trim();
  }
}

class InnerJoin {
  constructor() { this.builder = null; }
  of(objectName) { this.builder = new QueryBuilder(objectName); return this; }
  with(field) { this.builder.fields.plain.add(String(field)); return this; }
  whereAre(condition) { this.builder.conditions.add(condition); return this; }
  toString() { return `(${this.builder})`; }
}

class SubQuery {
  constructor() { this.builder = null; }
  of(relationship) { this.builder = new QueryBuilder(relationship); return this; }
  toString() { return this.builder.toString(); }
}

/* ----- fluent query surface ----- */

const SCOPES = {
  delegatedScope: 'DELEGATED', mineScope: 'MINE', mineAndMyGroupsScope: 'MINE_AND_MY_GROUPS',
  myTerritoryScope: 'MY_TERRITORY', myTeamTerritoryScope: 'MY_TEAM_TERRITORY', teamScope: 'TEAM',
};

const TERMINALS = new Set(['toList', 'toObject', 'toInteger', 'toAggregated', 'toAggregatedProxy',
  'toQueryLocator', 'toCursor', 'toPaginationCursor', 'doExist', 'toId', 'toIds', 'toMap', 'toString']);

const NO_OPS = new Set(['userMode', 'systemMode', 'withSharing', 'withoutSharing', 'stripInaccessible',
  'preview', 'mockId', 'byId', 'byIds', 'byRecordType']);

function fieldName(value) {
  if (value.t === 'field' || value.t === 'path') return value.name;
  if (value.t === 'string') return value.value;
  if (value.t === 'object') return String(value.value);
  return String(value.value);
}

class FluentQuery {
  constructor(objectName, isSubQuery = false) {
    this.builder = new QueryBuilder(objectName);
    this.isSubQuery = isSubQuery;
    this.accessMode = 'USER_MODE';
    this.sharingMode = null;
  }

  invoke(name, args) {
    const builder = this.builder;

    if (TERMINALS.has(name)) { this.terminal = name; return this; }
    if (NO_OPS.has(name)) {
      if (name === 'systemMode') this.accessMode = 'SYSTEM_MODE';
      if (name === 'userMode') this.accessMode = 'USER_MODE';
      if (name === 'withSharing') this.sharingMode = 'with';
      if (name === 'withoutSharing') this.sharingMode = 'without';
      return this;
    }
    if (SCOPES[name]) { builder.scope = SCOPES[name]; return this; }

    switch (name) {
      case 'with': return this.applyWith(args);
      case 'withFieldSet': return this;
      case 'count':
        if (!args.length) { builder.fields.count(); return this; }
        return this.aggregate('COUNT', args);
      case 'avg': return this.aggregate('AVG', args);
      case 'min': return this.aggregate('MIN', args);
      case 'max': return this.aggregate('MAX', args);
      case 'sum': return this.aggregate('SUM', args);
      case 'countDistinct': return this.aggregate('COUNT_DISTINCT', args);
      case 'grouping': return this.aggregate('GROUPING', args);
      case 'toLabel': {
        const [field, alias] = args;
        builder.fields.addFunction(`toLabel(${fieldName(field)})`, alias ? alias.value : '');
        return this;
      }
      case 'format': {
        const [field, alias] = args;
        builder.fields.addFunction(`FORMAT(${fieldName(field)})`, alias ? alias.value : '');
        return this;
      }
      case 'whereAre': {
        const value = args[0];
        builder.conditions.add(value.t === 'string' ? { toString: () => value.value } : value.value);
        return this;
      }
      case 'conditionLogic': builder.conditions.conditionLogic(args[0].value); return this;
      case 'anyConditionMatching': builder.conditions.anyConditionMatching(); return this;
      case 'groupBy': return this.groupBy(args, '');
      case 'groupByRollup': return this.groupBy(args, 'ROLLUP');
      case 'groupByCube': return this.groupBy(args, 'CUBE');
      case 'have': {
        const value = args[0];
        builder.having.add(value.t === 'string' ? { toString: () => value.value } : value.value);
        return this;
      }
      case 'havingConditionLogic': builder.having.conditionLogic(args[0].value); return this;
      case 'anyHavingConditionMatching': builder.having.anyConditionMatching(); return this;
      case 'withDataCategory': builder.dataCategory.add(args[0].value); return this;
      case 'orderBy': {
        const orderBy = new OrderBy();
        if (args.length === 2 && args[0].t === 'string' && (args[1].t === 'field' || args[1].t === 'path')) {
          orderBy.field = `${args[0].value}.${args[1].name}`;
        } else if (args.length === 2) {
          orderBy.field = fieldName(args[0]);
          orderBy.direction = args[1].value;
        } else {
          orderBy.field = fieldName(args[0]);
        }
        builder.orderBys.push(orderBy);
        return this;
      }
      case 'orderByCount': {
        const orderBy = new OrderBy();
        orderBy.field = `COUNT(${fieldName(args[0])})`;
        builder.orderBys.push(orderBy);
        return this;
      }
      case 'sortDesc': builder.orderBys.at(-1).direction = 'DESC'; return this;
      case 'sort': builder.orderBys.at(-1).direction = args[0].value; return this;
      case 'nullsLast': builder.orderBys.at(-1).nulls = 'LAST'; return this;
      case 'nullsOrder': builder.orderBys.at(-1).nulls = args[0].value; return this;
      case 'setLimit': builder.limitValue = args[0].value; return this;
      case 'offset': builder.offsetValue = args[0].value; return this;
      case 'forReference': builder.forValue = 'FOR REFERENCE'; return this;
      case 'forView': builder.forValue = 'FOR VIEW'; return this;
      case 'forUpdate': builder.forValue = 'FOR UPDATE'; return this;
      case 'allRows': builder.forValue = 'ALL ROWS'; return this;
      default:
        throw new Error(`Unknown SOQL Lib method ".${name}()"`);
    }
  }

  applyWith(args) {
    const builder = this.builder;
    const first = args[0];

    if (first.t === 'object' && first.value instanceof SubQuery) {
      builder.subQueries.push(first.value.toString());
      return this;
    }
    if (first.t === 'string' && args.length === 1) { builder.fields.withString(first.value); return this; }
    if (first.t === 'string') {
      const relationship = first.value;
      const rest = args.slice(1);
      const fields = rest[0].t === 'list' ? rest[0].values : rest;
      for (const field of fields) builder.fields.relationship.add(`${relationship}.${fieldName(field)}`);
      return this;
    }
    if (first.t === 'list') {
      for (const field of first.values) builder.fields.plain.add(fieldName(field));
      return this;
    }
    if (args.length === 2 && args[1].t === 'string') {
      builder.fields.addAggregate(fieldName(first), args[1].value);
      return this;
    }
    for (const field of args) builder.fields.plain.add(fieldName(field));
    return this;
  }

  aggregate(fn, args) {
    let relationship = null;
    let index = 0;
    if (args[0].t === 'string') { relationship = args[0].value; index = 1; }
    const field = fieldName(args[index]);
    const alias = args[index + 1] ? args[index + 1].value : '';
    const path = relationship ? `${relationship}.${field}` : field;
    this.builder.fields.addAggregate(`${fn}(${path})`, alias);
    return this;
  }

  groupBy(args, fn) {
    let path;
    if (args.length === 2 && args[0].t === 'string') path = `${args[0].value}.${fieldName(args[1])}`;
    else path = fieldName(args[0]);
    this.builder.fields.grouped.push(path);
    this.builder.groupByFields.push(path);
    if (this.builder.groupByFunction && this.builder.groupByFunction !== fn) {
      throw new Error("You can't use GROUP BY, GROUP BY ROLLUP and GROUP BY CUBE in the same query.");
    }
    this.builder.groupByFunction = fn;
    return this;
  }

  toString() { return this.builder.toString(); }
}

/* ----- evaluation ----- */

function isSoqlRoot(node) { return node && node.kind === 'ident' && node.value === 'SOQL'; }

const SOQL_FACTORIES = {
  Filter: () => new Filter(),
  FilterGroup: () => new FilterGroup(),
  HavingFilter: () => new HavingFilter(),
  HavingFilterGroup: () => new HavingFilterGroup(),
  InnerJoin: () => new InnerJoin(),
  DataCategoryFilter: () => new DataCategoryFilter(),
  Distance: () => new Distance(),
  SubQuery: () => new SubQuery(),
};

function evaluate(node) {
  if (node.kind === 'string') return { t: 'string', value: node.value };
  if (node.kind === 'number') return { t: 'number', value: Number(node.value) };
  if (node.kind === 'newCollection') {
    return { t: 'list', elementType: node.type, values: node.elements.map(evaluate) };
  }
  if (node.kind === 'ident') {
    if (node.value === 'true') return { t: 'boolean', value: true };
    if (node.value === 'false') return { t: 'boolean', value: false };
    if (node.value === 'null') return { t: 'null', value: null };
    return { t: 'bind', value: { __kind: 'bind', name: node.value } };
  }
  if (node.kind === 'binary') {
    return { t: 'bind', value: { __kind: 'bind', name: renderApex(node) } };
  }
  if (node.kind === 'member') {
    if (isSoqlRoot(node.target)) {
      const factory = SOQL_FACTORIES[node.name];
      if (!factory) throw new Error(`Unknown SOQL member "SOQL.${node.name}"`);
      return { t: 'object', value: factory() };
    }
    if (node.name === 'SObjectType') return { t: 'sobjectType', value: node.target.value };
    return { t: 'path', name: node.name, text: renderApex(node) };
  }
  if (node.kind === 'call') {
    if (node.target && node.target.kind === 'ident' && node.target.value === 'Date' && node.name === 'newInstance') {
      const [y, m, d] = node.args.map((a) => Number(a.value));
      return { t: 'date', value: { __kind: 'raw', text: `${y}-${String(m).padStart(2, '0')}-${String(d).padStart(2, '0')}` } };
    }
    if (node.target && node.target.kind === 'ident' && /^Date[tT]ime$/.test(node.target.value)) {
      const [y, m, d, h, mi, s] = node.args.map((a) => Number(a.value));
      const pad = (n) => String(n).padStart(2, '0');
      return { t: 'datetime', value: { __kind: 'raw', text: `${y}-${pad(m)}-${pad(d)}T${pad(h)}:${pad(mi)}:${pad(s)}Z` } };
    }
    if (isSoqlRoot(node.target) && node.name === 'of') {
      const argument = evaluate(node.args[0]);
      return { t: 'object', value: new FluentQuery(argument.value) };
    }

    const target = evaluate(node.target);
    const args = node.args.map(evaluate);

    // A method call on a local variable (`accountIds.keySet()`) stays opaque.
    if (target.t === 'bind') return { t: 'bind', value: { __kind: 'bind', name: renderApex(node) } };
    if (target.t !== 'object') throw new Error(`Cannot call .${node.name}() on ${target.t}`);
    const receiver = target.value;

    if (receiver instanceof FluentQuery) return { t: 'object', value: receiver.invoke(node.name, args) };

    if (receiver instanceof SubQuery) {
      if (node.name === 'of') { receiver.of(args[0].value); receiver.fluent = new FluentQuery(args[0].value, true); receiver.fluent.builder = receiver.builder; return target; }
      receiver.fluent.invoke(node.name, args);
      return target;
    }
    if (receiver instanceof InnerJoin) {
      if (node.name === 'of') return { t: 'object', value: receiver.of(args[0].value) };
      if (node.name === 'with') return { t: 'object', value: receiver.with(fieldName(args[0])) };
      if (node.name === 'whereAre') return { t: 'object', value: receiver.whereAre(args[0].t === 'string' ? { toString: () => args[0].value } : args[0].value) };
      throw new Error(`Unknown InnerJoin method ".${node.name}()"`);
    }
    if (receiver instanceof FilterGroup) {
      if (node.name === 'add') {
        receiver.add(args[0].t === 'string' ? { toString: () => args[0].value } : args[0].value);
        return target;
      }
      if (node.name === 'anyConditionMatching') { receiver.anyConditionMatching(); return target; }
      if (node.name === 'conditionLogic') { receiver.conditionLogic(args[0].value); return target; }
      if (node.name === 'ignoreWhen') { receiver.ignoreWhen(args[0].value); return target; }
      throw new Error(`Unknown FilterGroup method ".${node.name}()"`);
    }
    if (receiver instanceof Filter || receiver instanceof DataCategoryFilter || receiver instanceof Distance) {
      const method = receiver[node.name];
      if (typeof method !== 'function') throw new Error(`Unknown ${receiver.constructor.name} method ".${node.name}()"`);
      const takesFields = FIELD_METHODS.has(node.name);
      const values = args.map((argument) => {
        if (argument.t === 'list') return argument.values.map((entry) => unwrap(entry));
        if (takesFields && (argument.t === 'field' || argument.t === 'path')) return argument.name;
        return unwrap(argument);
      });
      return { t: 'object', value: method.apply(receiver, values) };
    }
    throw new Error(`Cannot call .${node.name}() on ${receiver.constructor.name}`);
  }
  throw new Error(`Cannot evaluate node kind "${node.kind}"`);
}

/** Methods whose arguments are SObjectField tokens rather than values. */
const FIELD_METHODS = new Set(['with', 'of', 'count', 'avg', 'min', 'max', 'sum', 'countDistinct']);

function unwrap(value) {
  if (value.t === 'path') return { __kind: 'bind', name: value.text };
  if (value.t === 'field') return value.name;
  if (value.t === 'object') return value.value;
  return value.value;
}

export function emulate(apexCode) {
  const result = evaluate(parseApexChain(apexCode));
  if (result.t !== 'object' || !(result.value instanceof FluentQuery)) {
    throw new Error('The apex chain did not evaluate to a SOQL query');
  }
  return {
    soql: result.value.builder.toString(),
    accessMode: result.value.accessMode,
    sharingMode: result.value.sharingMode,
    terminal: result.value.terminal,
  };
}
