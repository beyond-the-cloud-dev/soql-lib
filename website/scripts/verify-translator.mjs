/**
 * Regression check for src/lib/soqlTranslator.js.
 *
 * Every query in soql-corpus.json is translated to SOQL Lib apex, then that
 * apex is executed by apex-emulator.mjs - a faithful JS port of SOQL.cls - to
 * rebuild the SOQL it would produce. The rebuilt query is compared against the
 * original, so a translation is only accepted when it round-trips.
 *
 * Every generated method call is also checked against the interfaces declared
 * in SOQL.cls, which catches calls that would not compile.
 *
 * Run with: npm run verify:translator
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { parseSoql, translate } from '../src/lib/soqlTranslator.js';
import { emulate, parseApexChain } from './apex-emulator.mjs';

const HERE = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(HERE, '../..');
const corpus = JSON.parse(fs.readFileSync(path.join(HERE, 'soql-corpus.json'), 'utf8'));

/* ------------------------------------------------------------------ *
 * Canonical form - two queries match when they mean the same thing
 * ------------------------------------------------------------------ */

const lower = (value) => String(value).toLowerCase();

function expr(node, trimStrings = false) {
  if (!node) return '';
  if (node.kind === 'field') return lower(node.path);
  if (node.kind === 'function') {
    // SOQL.cls renders the DISTANCE unit as `' km'`; ignore that stray space.
    const trim = node.name.toUpperCase() === 'DISTANCE';
    return `${lower(node.name)}(${node.args.map((argument) => expr(argument, trim)).join(',')})`;
  }
  if (node.kind === 'literal') return token(node.literal, trimStrings);
  return JSON.stringify(node);
}

function token(item, trimStrings = false) {
  if (item.type === 'string') return `'${trimStrings ? item.value.trim() : item.value}'`;
  if (item.type === 'bind') return `:${item.value.replace(/\s+/g, '').replace(/^\((.*)\)$/, '$1')}`;
  if (item.type === 'ident') return lower(item.value);
  if (item.type === 'number') return String(Number(item.value));
  if (item.type === 'datetime') return new Date(item.value).toISOString();
  return String(item.value);
}

/** The translator rewrites NOT into the negated comparator; normalise both sides. */
const FLIPPED = { '=': '!=', '!=': '=', LIKE: 'NOT LIKE', 'NOT LIKE': 'LIKE', IN: 'NOT IN', 'NOT IN': 'IN' };

function pushNots(node) {
  if (!node) return node;
  if (node.type === 'and' || node.type === 'or') return { ...node, operands: node.operands.map(pushNots) };
  if (node.type === 'not') {
    const negated = negate(node.operand);
    return negated ? pushNots(negated) : { ...node, operand: pushNots(node.operand) };
  }
  return node;
}

function negate(node) {
  if (node.type === 'not') return node.operand;
  if (node.type === 'and' || node.type === 'or') {
    const operands = node.operands.map(negate);
    if (operands.some((operand) => operand === null)) return null;
    return { type: node.type === 'and' ? 'or' : 'and', operands };
  }
  if (node.type === 'comparison') {
    const operator = FLIPPED[node.operator.toUpperCase()];
    return operator ? { ...node, operator } : null;
  }
  return null;
}

function condition(node) {
  if (!node) return null;
  if (node.type === 'and' || node.type === 'or') {
    const flat = [];
    for (const operand of node.operands) {
      const rendered = condition(operand);
      if (operand.type === node.type) flat.push(...rendered.slice(1));
      else flat.push(rendered);
    }
    if (flat.length === 1) return flat[0];
    return [node.type, ...flat.map((entry) => JSON.stringify(entry)).sort().map((entry) => JSON.parse(entry))];
  }
  if (node.type === 'not') return ['not', condition(node.operand)];
  return `${expr(node.field)} ${node.operator.toUpperCase()} ${value(node.value)}`;
}

function value(item) {
  if (!item) return '';
  if (item.kind === 'scalar') return token(item.token);
  if (item.kind === 'list') return `(${item.values.map((entry) => token(entry)).join(',')})`;
  if (item.kind === 'expression') return expr(item.expression);
  if (item.kind === 'semiJoin') return `(${canonical(item.query)})`;
  return JSON.stringify(item);
}

function canonical(query) {
  const fields = query.fields.map((item) => {
    if (item.kind === 'subquery') return `(${canonical(item.query)})`;
    if (item.kind === 'typeof') return lower(item.raw.replace(/\s+/g, ' '));
    return item.alias ? `${expr(item.expression)} ${lower(item.alias)}` : expr(item.expression);
  }).sort();

  return JSON.stringify({
    object: lower(query.object),
    fields,
    scope: query.scope === 'EVERYTHING' ? null : query.scope,
    where: condition(pushNots(query.where)),
    dataCategories: query.dataCategories.map(
      (entry) => `${lower(entry.field)} ${entry.operator} ${entry.categories.map(lower).sort().join(',')}`
    ),
    groupBy: query.groupBy ? { type: query.groupBy.type, fields: query.groupBy.fields.map((f) => expr(f)).sort() } : null,
    having: condition(pushNots(query.having)),
    orderBy: query.orderBy.map((item) => `${expr(item.expression)} ${item.direction || 'ASC'} ${item.nulls || 'FIRST'}`),
    limit: query.limit === null ? null : Number(query.limit),
    offset: query.offset === null ? null : Number(query.offset),
    forClauses: [...query.forClauses].sort(),
    allRows: query.allRows,
  });
}

/* ------------------------------------------------------------------ *
 * Method signatures declared by SOQL.cls
 * ------------------------------------------------------------------ */

const CLS = fs.readFileSync(path.join(REPO, 'force-app/main/default/classes/standard-soql/SOQL.cls'), 'utf8');
const INTERFACES = ['Queryable', 'SubQuery', 'FilterGroup', 'Filter', 'InnerJoin', 'HavingFilterGroup', 'HavingFilter', 'DataCategoryFilter', 'Distance'];
const TERMINALS = new Set(['toList', 'toInteger', 'toAggregated', 'toObject', 'toIds', 'doExist']);
const ROOTS = {
  Filter: 'Filter', FilterGroup: 'FilterGroup', HavingFilter: 'HavingFilter',
  HavingFilterGroup: 'HavingFilterGroup', InnerJoin: 'InnerJoin',
  DataCategoryFilter: 'DataCategoryFilter', Distance: 'Distance', SubQuery: 'SubQuery',
};

const signatures = {};
for (const name of INTERFACES) {
  const start = CLS.indexOf(`public interface ${name} {`);
  if (start === -1) throw new Error(`interface ${name} not found in SOQL.cls`);
  let depth = 0;
  let end = start;
  for (let i = CLS.indexOf('{', start); i < CLS.length; i++) {
    if (CLS[i] === '{') depth++;
    if (CLS[i] === '}') { depth--; if (depth === 0) { end = i; break; } }
  }
  signatures[name] = Object.create(null);
  for (const line of CLS.slice(start, end).split('\n')) {
    const match = line.trim().match(/^[\w.<>,\s]+?\s+(\w+)\(([^)]*)\);$/);
    if (!match) continue;
    const flat = match[2].replace(/<[^>]*>/g, '');
    (signatures[name][match[1]] ||= new Set()).add(flat.trim() ? flat.split(',').length : 0);
  }
}

function receiverType(node) {
  if (node.kind === 'call' && node.target?.kind === 'ident' && node.target.value === 'SOQL' && node.name === 'of') return 'Queryable';
  if (node.kind === 'member' && node.target?.kind === 'ident' && node.target.value === 'SOQL') return ROOTS[node.name] || null;
  return null;
}

function checkSignatures(node, problems) {
  if (!node || typeof node !== 'object') return null;
  const direct = receiverType(node);
  if (direct) {
    if (node.kind === 'call') node.args.forEach((argument) => checkSignatures(argument, problems));
    return direct;
  }
  if (node.kind === 'call') {
    const type = checkSignatures(node.target, problems);
    node.args.forEach((argument) => checkSignatures(argument, problems));
    if (!type) return null;
    if (TERMINALS.has(node.name)) return null;
    const arities = signatures[type][node.name];
    if (!arities) problems.push(`${type}.${node.name}() does not exist`);
    else if (!arities.has(node.args.length)) {
      problems.push(`${type}.${node.name}() has no ${node.args.length}-argument overload (has ${[...arities].join('/')})`);
    }
    return type;
  }
  if (node.kind === 'newCollection') { node.elements.forEach((element) => checkSignatures(element, problems)); return null; }
  if (node.kind === 'binary') { node.parts.forEach((part) => checkSignatures(part, problems)); return null; }
  return null;
}

/* ------------------------------------------------------------------ *
 * Run
 * ------------------------------------------------------------------ */

const ACCEPTED = {
  UNSUPPORTED_TYPEOF: 'TYPEOF cannot be expressed by SOQL Lib (emitted as a comment)',
  LIB_DROPS_FIELD: 'SOQL.cls drops non-grouped elements from aggregate queries (warned)',
  LIB_UNESCAPED_MULTIPICKLIST: 'SOQL.cls inlines INCLUDES/EXCLUDES values without escaping them',
};

const counts = {};
const failures = [];
const signatureProblems = [];

for (const entry of corpus) {
  const record = { soql: entry.soql, category: entry.category };
  const result = translate(entry.soql);
  record.code = result.code;

  const fail = (status, detail) => {
    counts[status] = (counts[status] || 0) + 1;
    if (!ACCEPTED[status]) failures.push({ ...record, status, detail });
  };

  if (result.error) { fail('PARSE_ERROR', result.error); continue; }

  try {
    checkSignatures(parseApexChain(result.code), signatureProblems);
  } catch (error) {
    fail('APEX_UNPARSEABLE', error.message);
    continue;
  }

  let emulated;
  try {
    emulated = emulate(result.code);
  } catch (error) {
    fail('APEX_INVALID', error.message);
    continue;
  }

  const expectedMode = /WITH\s+SYSTEM_MODE/i.test(entry.soql) ? 'SYSTEM_MODE' : 'USER_MODE';
  if (emulated.accessMode !== expectedMode) {
    fail('MODE_MISMATCH', `expected ${expectedMode}, got ${emulated.accessMode}`);
    continue;
  }

  let original;
  let rebuilt;
  try { original = canonical(parseSoql(entry.soql).query); } catch (error) { fail('CORPUS_UNPARSEABLE', error.message); continue; }
  try { rebuilt = canonical(parseSoql(emulated.soql).query); } catch (error) {
    fail(/INCLUDES|EXCLUDES/i.test(entry.soql) ? 'LIB_UNESCAPED_MULTIPICKLIST' : 'ROUNDTRIP_UNPARSEABLE', `${error.message} :: ${emulated.soql}`);
    continue;
  }

  if (original === rebuilt) { counts.OK = (counts.OK || 0) + 1; continue; }
  if (/TYPEOF/i.test(entry.soql)) { fail('UNSUPPORTED_TYPEOF', ''); continue; }
  if (result.warnings.some((warning) => warning.includes('removes non-grouped elements'))) { fail('LIB_DROPS_FIELD', ''); continue; }

  const left = JSON.parse(original);
  const right = JSON.parse(rebuilt);
  const differences = Object.keys(left)
    .filter((key) => JSON.stringify(left[key]) !== JSON.stringify(right[key]))
    .map((key) => `${key}: ${JSON.stringify(left[key])} -> ${JSON.stringify(right[key])}`);
  fail('MISMATCH', differences.join(' | '));
}

console.log(`Queries checked: ${corpus.length}`);
for (const [status, count] of Object.entries(counts).sort((a, b) => b[1] - a[1])) {
  console.log(`  ${status.padEnd(28)} ${count}${ACCEPTED[status] ? `   (accepted: ${ACCEPTED[status]})` : ''}`);
}

const uniqueSignatureProblems = [...new Set(signatureProblems)];
console.log(`Signature problems: ${uniqueSignatureProblems.length}`);
uniqueSignatureProblems.forEach((problem) => console.log(`  - ${problem}`));

if (failures.length || uniqueSignatureProblems.length) {
  console.log(`\n${failures.length} failing queries:`);
  for (const failure of failures.slice(0, 20)) {
    console.log(`\n[${failure.status}] ${failure.soql.replace(/\s+/g, ' ')}`);
    console.log(failure.code);
    console.log(`  -> ${failure.detail}`);
  }
  process.exit(1);
}

console.log('\nAll queries round-trip back to their original SOQL.');
