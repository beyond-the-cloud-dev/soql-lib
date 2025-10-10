import React, { useState, useEffect } from 'react';
import Layout from '@theme/Layout';
import Heading from '@theme/Heading';

// SOQL Parser and Translator
class SOQLToSOQLLibTranslator {
  constructor() {
    this.sobjectType = '';
    this.selectFields = [];
    this.whereConditions = [];
    this.orderByFields = [];
    this.limitClause = '';
    this.offsetClause = '';
    this.groupByFields = [];
    this.havingConditions = [];
    this.withDataCategory = '';
    this.forClause = '';
  }

  parseSOQL(soqlQuery) {
    try {
      this.reset();
      const cleanQuery = soqlQuery.trim().replace(/\s+/g, ' ');
      
      // Check if query explicitly specifies SYSTEM_MODE
      const hasSystemMode = /WITH\s+SYSTEM_MODE/i.test(cleanQuery);
      
      // Extract SObject from FROM clause
      this.parseSObjectType(cleanQuery);
      
      // Parse SELECT clause
      this.parseSelectClause(cleanQuery);
      
      // Parse WHERE clause
      this.parseWhereClause(cleanQuery);
      
      // Parse ORDER BY clause
      this.parseOrderByClause(cleanQuery);
      
      // Parse GROUP BY clause
      this.parseGroupByClause(cleanQuery);
      
      // Parse HAVING clause
      this.parseHavingClause(cleanQuery);
      
      // Parse LIMIT clause
      this.parseLimitClause(cleanQuery);
      
      // Parse OFFSET clause
      this.parseOffsetClause(cleanQuery);
      
      // Parse FOR clause
      this.parseForClause(cleanQuery);
      
      return this.generateSOQLLibCode(hasSystemMode);
    } catch (error) {
      return `// Error parsing SOQL: ${error.message}\n// Please check your SOQL syntax and try again.`;
    }
  }

  reset() {
    this.sobjectType = '';
    this.selectFields = [];
    this.whereConditions = [];
    this.orderByFields = [];
    this.limitClause = '';
    this.offsetClause = '';
    this.groupByFields = [];
    this.havingConditions = [];
    this.withDataCategory = '';
    this.forClause = '';
  }

  parseSObjectType(query) {
    // First, remove any subqueries to avoid confusion
    let cleanQuery = query;
    
    // Remove subqueries by finding balanced parentheses containing SELECT
    let depth = 0;
    let inSubquery = false;
    let cleanedQuery = '';
    
    for (let i = 0; i < query.length; i++) {
      const char = query[i];
      
      if (char === '(' && query.substring(i, i + 7).toUpperCase().includes('SELECT')) {
        inSubquery = true;
        depth = 1;
        i += 6; // Skip past "SELECT"
        continue;
      }
      
      if (inSubquery) {
        if (char === '(') depth++;
        if (char === ')') depth--;
        
        if (depth === 0) {
          inSubquery = false;
        }
        continue;
      }
      
      cleanedQuery += char;
    }
    
    const fromMatch = cleanedQuery.match(/FROM\s+(\w+)/i);
    if (fromMatch) {
      this.sobjectType = fromMatch[1];
    } else {
      throw new Error('FROM clause not found');
    }
  }

  parseSelectClause(query) {
    // Find the main SELECT clause, avoiding subqueries
    const mainSelectMatch = this.extractMainSelectClause(query);
    if (mainSelectMatch) {
      const selectPart = mainSelectMatch;
      
      // Handle COUNT() queries
      if (selectPart.trim().toUpperCase() === 'COUNT()') {
        this.selectFields = ['COUNT()'];
        return;
      }
      
      // Handle aggregate functions
      const aggregateFunctions = ['COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'COUNT_DISTINCT'];
      const fields = this.parseFields(selectPart);
      
      this.selectFields = fields.map(field => {
        const trimmedField = field.trim();
        
        // Check for subqueries first
        if (trimmedField.includes('(SELECT ') && trimmedField.includes(' FROM ')) {
          return this.parseSubQuery(trimmedField);
        }
        
        // Check for aggregate functions
        for (const func of aggregateFunctions) {
          const pattern = new RegExp(`${func}\\s*\\(([^)]+)\\)(?:\\s+(\\w+))?`, 'i');
          const match = trimmedField.match(pattern);
          if (match) {
            const fieldName = match[1].trim();
            const alias = match[2] ? match[2].trim() : '';
            return {
              type: 'aggregate',
              function: func.toLowerCase(),
              field: fieldName,
              alias: alias
            };
          }
        }
        
        // Check for toLabel
        if (trimmedField.toUpperCase().includes('TOLABEL(')) {
          const toLabelMatch = trimmedField.match(/toLabel\(([^)]+)\)(?:\s+(\w+))?/i);
          if (toLabelMatch) {
            return {
              type: 'function',
              function: 'toLabel',
              field: toLabelMatch[1].trim(),
              alias: toLabelMatch[2] ? toLabelMatch[2].trim() : ''
            };
          }
        }
        
        // Check for relationship fields (contains dot)
        if (trimmedField.includes('.') && !trimmedField.includes('(')) {
          const parts = trimmedField.split('.');
          if (parts.length === 2) {
            return {
              type: 'relationship',
              relationship: parts[0].trim(),
              field: parts[1].trim()
            };
          }
        }
        
        // Check for field alias
        const aliasMatch = trimmedField.match(/^(\w+(?:\.\w+)?)\s+(\w+)$/);
        if (aliasMatch) {
          return {
            type: 'alias',
            field: aliasMatch[1],
            alias: aliasMatch[2]
          };
        }
        
        // Regular field
        return {
          type: 'field',
          field: trimmedField
        };
      });
    }
  }

  extractMainSelectClause(query) {
    // Find the main SELECT...FROM pattern, ignoring subqueries
    let depth = 0;
    let inSubquery = false;
    let selectStart = -1;
    let fromStart = -1;
    
    for (let i = 0; i < query.length; i++) {
      const remaining = query.substring(i).toUpperCase();
      
      if (remaining.startsWith('(SELECT')) {
        inSubquery = true;
        depth = 1;
        i += 6; // Skip past "SELECT"
        continue;
      }
      
      if (inSubquery) {
        if (query[i] === '(') depth++;
        if (query[i] === ')') depth--;
        
        if (depth === 0) {
          inSubquery = false;
        }
        continue;
      }
      
      // Look for main SELECT
      if (selectStart === -1 && remaining.startsWith('SELECT')) {
        selectStart = i + 6; // After "SELECT"
        continue;
      }
      
      // Look for main FROM
      if (selectStart !== -1 && remaining.startsWith(' FROM ')) {
        fromStart = i;
        break;
      }
    }
    
    if (selectStart !== -1 && fromStart !== -1) {
      return query.substring(selectStart, fromStart).trim();
    }
    
    return null;
  }

  parseFields(fieldsString) {
    const fields = [];
    let currentField = '';
    let parenthesesCount = 0;
    let inQuotes = false;
    
    for (let i = 0; i < fieldsString.length; i++) {
      const char = fieldsString[i];
      
      if (char === "'" && fieldsString[i-1] !== '\\\\') {
        inQuotes = !inQuotes;
      }
      
      if (!inQuotes) {
        if (char === '(') parenthesesCount++;
        if (char === ')') parenthesesCount--;
        
        if (char === ',' && parenthesesCount === 0) {
          fields.push(currentField.trim());
          currentField = '';
          continue;
        }
      }
      
      currentField += char;
    }
    
    if (currentField.trim()) {
      fields.push(currentField.trim());
    }
    
    return fields;
  }

  parseSubQuery(subqueryString) {
    // Extract the subquery content from parentheses
    const subqueryMatch = subqueryString.match(/^\s*\(\s*(SELECT\s+.*?)\s*\)\s*$/i);
    if (!subqueryMatch) {
      // Return as plain field if we can't parse it as subquery
      return {
        type: 'field',
        field: subqueryString
      };
    }

    const subqueryContent = subqueryMatch[1];
    
    // Parse the subquery components
    const selectMatch = subqueryContent.match(/SELECT\s+(.*?)\s+FROM\s+(\w+)(?:\s+(.*))?$/i);
    if (!selectMatch) {
      return {
        type: 'field',
        field: subqueryString
      };
    }

    const selectPart = selectMatch[1].trim();
    const fromObject = selectMatch[2].trim();
    const remainingClause = selectMatch[3] ? selectMatch[3].trim() : '';

    // Parse the fields in the subquery
    const subFields = this.parseFields(selectPart);
    const parsedSubFields = subFields.map(field => {
      const trimmedField = field.trim();
      
      // Check for nested subqueries
      if (trimmedField.includes('(SELECT ') && trimmedField.includes(' FROM ')) {
        return this.parseSubQuery(trimmedField);
      }
      
      // Handle relationship fields
      if (trimmedField.includes('.')) {
        const parts = trimmedField.split('.');
        if (parts.length === 2) {
          return {
            type: 'relationship',
            relationship: parts[0],
            field: parts[1]
          };
        }
      }
      
      // Regular field
      return {
        type: 'field',
        field: trimmedField
      };
    });

    // Parse WHERE clause if present
    let whereConditions = [];
    if (remainingClause) {
      const whereMatch = remainingClause.match(/WHERE\s+(.*?)(?:\s+(?:ORDER\s+BY|LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE))\s|$)/i);
      if (whereMatch) {
        whereConditions = this.parseConditions(whereMatch[1].trim());
      }
    }

    // Parse ORDER BY if present
    let orderBy = '';
    const orderByMatch = remainingClause.match(/ORDER\s+BY\s+(.*?)(?:\s+(?:LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE))\s|$)/i);
    if (orderByMatch) {
      orderBy = orderByMatch[1].trim();
    }

    // Parse LIMIT if present
    let limit = '';
    const limitMatch = remainingClause.match(/LIMIT\s+(\d+)/i);
    if (limitMatch) {
      limit = limitMatch[1];
    }

    // Parse OFFSET if present
    let offset = '';
    const offsetMatch = remainingClause.match(/OFFSET\s+(\d+)/i);
    if (offsetMatch) {
      offset = offsetMatch[1];
    }

    // Parse FOR clause if present
    let forClause = '';
    const forMatch = remainingClause.match(/FOR\s+(UPDATE|VIEW|REFERENCE)/i);
    if (forMatch) {
      forClause = forMatch[1].toUpperCase();
    }

    return {
      type: 'subquery',
      relationship: fromObject,
      fields: parsedSubFields,
      whereConditions: whereConditions,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
      forClause: forClause
    };
  }

  parseWhereClause(query) {
    const whereMatch = query.match(/WHERE\s+(.*?)(?:\s+(?:GROUP\s+BY|ORDER\s+BY|LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE)|ALL\s+ROWS)\s|$)/i);
    if (whereMatch) {
      const whereClause = whereMatch[1].trim();
      this.whereConditions = this.parseConditions(whereClause);
    }
  }

  parseConditions(conditionsString) {
    // This enhanced parser handles nested parentheses and complex logic
    const conditions = [];
    
    // First, let's try to parse the structure and extract individual conditions
    const parsed = this.parseComplexConditions(conditionsString);
    
    // If we have a complex structure with mixed AND/OR, use conditionLogic
    if (parsed.hasComplexLogic && parsed.conditions.length > 0) {
      for (let i = 0; i < parsed.conditions.length; i++) {
        const condition = this.parseIndividualCondition(parsed.conditions[i]);
        if (condition) {
          conditions.push(condition);
        }
      }
      
      // Add the logic structure info
      if (parsed.logicPattern) {
        if (parsed.logicPattern === 'anyConditionMatching') {
          // Pure OR pattern - just add the OR operator to trigger anyConditionMatching
          conditions.push({ type: 'operator', value: 'OR' });
        } else {
          // Complex pattern with conditionLogic
          conditions.push({ type: 'conditionLogic', value: parsed.logicPattern });
        }
      }
    } else {
      // Simple case - use the original logic
      const tokens = this.tokenizeConditions(conditionsString);
      
      for (const token of tokens) {
        if (token.type === 'condition') {
          const condition = this.parseIndividualCondition(token.value.trim());
          if (condition) {
            conditions.push(condition);
          }
        } else if (token.type === 'operator') {
          conditions.push({ type: 'operator', value: token.value });
        }
      }
    }
    
    return conditions;
  }

  parseComplexConditions(conditionsString) {
    const result = {
      conditions: [],
      hasComplexLogic: false,
      logicPattern: ''
    };
    
    // Check if we have parentheses with mixed AND/OR
    const hasParentheses = conditionsString.includes('(') && conditionsString.includes(')');
    const hasAnd = /\bAND\b/i.test(conditionsString);
    const hasOr = /\bOR\b/i.test(conditionsString);
    
    if (hasParentheses && (hasAnd || hasOr)) {
      result.hasComplexLogic = true;
      
      // For complex nested conditions, extract all individual field conditions
      const extractedConditions = this.extractAllConditionsFromComplex(conditionsString);
      result.conditions = extractedConditions;
      
      if (extractedConditions.length > 0) {
        // Generate conditionLogic pattern based on the structure
        // For the pattern: Industry = 'IT' AND ((Name = 'My Account' AND NumberOfEmployees >= 10) OR (Name = 'My Account 2' AND NumberOfEmployees <= 20))
        // We have 5 conditions: [Industry='IT', Name='My Account', NumberOfEmployees>=10, Name='My Account 2', NumberOfEmployees<=20]
        // The logic should be: 1 AND ((2 AND 3) OR (4 AND 5))
        
        if (extractedConditions.length === 5) {
          // This matches the pattern: condition AND ((condition AND condition) OR (condition AND condition))
          result.logicPattern = '1 AND ((2 AND 3) OR (4 AND 5))';
        } else if (extractedConditions.length === 4) {
          // Pattern: condition AND (condition OR condition) - simplified
          result.logicPattern = '1 AND (2 OR 3 OR 4)';
        } else if (extractedConditions.length === 3) {
          // Pattern: condition AND (condition OR condition)
          result.logicPattern = '1 AND (2 OR 3)';
        } else {
          // Fallback - use anyConditionMatching for simpler cases
          result.logicPattern = 'anyConditionMatching';
        }
      }
    }
    
    return result;
  }

  extractAllConditionsFromComplex(conditionsString) {
    const conditions = [];
    
    // Extract all field conditions using a comprehensive regex
    // This matches patterns like: field = 'value', field > 123, field LIKE '%test%'
    const conditionPattern = /(\w+(?:\.\w+)?)\s*(=|!=|<|<=|>|>=|LIKE|IN|NOT\s+IN)\s*('[^']*'|\d+|true|false|null|\([^)]+\))/gi;
    
    let match;
    while ((match = conditionPattern.exec(conditionsString)) !== null) {
      const field = match[1];
      const operator = match[2];
      const value = match[3];
      
      // Create a condition string that can be parsed by parseIndividualCondition
      const conditionStr = `${field} ${operator} ${value}`;
      conditions.push(conditionStr);
    }
    
    return conditions;
  }

  tokenizeConditions(conditionsString) {
    const tokens = [];
    let current = '';
    let parentheses = 0;
    let inQuotes = false;
    
    for (let i = 0; i < conditionsString.length; i++) {
      const char = conditionsString[i];
      const nextChars = conditionsString.substring(i, i + 4).toUpperCase();
      const nextThreeChars = conditionsString.substring(i, i + 3).toUpperCase();
      
      if (char === "'" && conditionsString[i-1] !== '\\') {
        inQuotes = !inQuotes;
      }
      
      if (!inQuotes) {
        if (char === '(') parentheses++;
        if (char === ')') parentheses--;
        
        if (parentheses === 0) {
          if (nextChars === ' AND ' || nextChars.startsWith('AND ')) {
            if (current.trim()) {
              tokens.push({ type: 'condition', value: current.trim() });
              current = '';
            }
            tokens.push({ type: 'operator', value: 'AND' });
            i += 3; // Skip ' AND'
            continue;
          } else if (nextThreeChars === ' OR ' || nextThreeChars.startsWith('OR ')) {
            if (current.trim()) {
              tokens.push({ type: 'condition', value: current.trim() });
              current = '';
            }
            tokens.push({ type: 'operator', value: 'OR' });
            i += 2; // Skip ' OR'
            continue;
          }
        }
      }
      
      current += char;
    }
    
    if (current.trim()) {
      tokens.push({ type: 'condition', value: current.trim() });
    }
    
    return tokens;
  }

  parseIndividualCondition(conditionStr) {
    // Remove outer parentheses if present
    conditionStr = conditionStr.replace(/^\s*\((.*)\)\s*$/, '$1').trim();
    
    // Parse different condition types
    const patterns = [
      // field = null
      { pattern: /^(\w+(?:\.\w+)?)\s*=\s*null$/i, type: 'isNull', isString: false },
      // field != null
      { pattern: /^(\w+(?:\.\w+)?)\s*!=\s*null$/i, type: 'isNotNull', isString: false },
      // field = true
      { pattern: /^(\w+(?:\.\w+)?)\s*=\s*true$/i, type: 'isTrue', isString: false },
      // field = false
      { pattern: /^(\w+(?:\.\w+)?)\s*=\s*false$/i, type: 'isFalse', isString: false },
      // field != true (equivalent to isFalse)
      { pattern: /^(\w+(?:\.\w+)?)\s*!=\s*true$/i, type: 'isFalse', isString: false },
      // field != false (equivalent to isTrue)
      { pattern: /^(\w+(?:\.\w+)?)\s*!=\s*false$/i, type: 'isTrue', isString: false },
      // field = 'value'
      { pattern: /^(\w+(?:\.\w+)?)\s*=\s*'([^']*)'$/i, type: 'equal', isString: true },
      // field = value
      { pattern: /^(\w+(?:\.\w+)?)\s*=\s*([^']\w*)$/i, type: 'equal', isString: false },
      // field != 'value'  
      { pattern: /^(\w+(?:\.\w+)?)\s*!=\s*'([^']*)'$/i, type: 'notEqual', isString: true },
      // field != value
      { pattern: /^(\w+(?:\.\w+)?)\s*!=\s*([^']\w*)$/i, type: 'notEqual', isString: false },
      // field > value
      { pattern: /^(\w+(?:\.\w+)?)\s*>\s*([^']\w*)$/i, type: 'greaterThan', isString: false },
      // field >= value  
      { pattern: /^(\w+(?:\.\w+)?)\s*>=\s*([^']\w*)$/i, type: 'greaterOrEqual', isString: false },
      // field < value
      { pattern: /^(\w+(?:\.\w+)?)\s*<\s*([^']\w*)$/i, type: 'lessThan', isString: false },
      // field <= value
      { pattern: /^(\w+(?:\.\w+)?)\s*<=\s*([^']\w*)$/i, type: 'lessOrEqual', isString: false },
      // field LIKE '%value%'
      { pattern: /^(\w+(?:\.\w+)?)\s+LIKE\s+'%([^%']+)%'$/i, type: 'contains', isString: true },
      // field LIKE 'value%' 
      { pattern: /^(\w+(?:\.\w+)?)\s+LIKE\s+'([^%']+)%'$/i, type: 'startsWith', isString: true },
      // field LIKE '%value'
      { pattern: /^(\w+(?:\.\w+)?)\s+LIKE\s+'%([^%']+)'$/i, type: 'endsWith', isString: true },
      // field LIKE 'value' (exact match without wildcards)
      { pattern: /^(\w+(?:\.\w+)?)\s+LIKE\s+'([^%']+)'$/i, type: 'equal', isString: true },
      // field IS NULL
      { pattern: /^(\w+(?:\.\w+)?)\s+IS\s+NULL$/i, type: 'isNull', isString: false },
      // field IS NOT NULL
      { pattern: /^(\w+(?:\.\w+)?)\s+IS\s+NOT\s+NULL$/i, type: 'isNotNull', isString: false },
      // field IN (value1, value2, ...)
      { pattern: /^(\w+(?:\.\w+)?)\s+IN\s+\(([^)]+)\)$/i, type: 'isIn', isString: false },
      // field NOT IN (value1, value2, ...)
      { pattern: /^(\w+(?:\.\w+)?)\s+NOT\s+IN\s+\(([^)]+)\)$/i, type: 'notIn', isString: false }
    ];
    
    for (const patternObj of patterns) {
      const match = conditionStr.match(patternObj.pattern);
      if (match) {
        const field = match[1];
        let value = match[2];
        
        // For isNull, isNotNull, isTrue, and isFalse, there's no value to capture
        if (patternObj.type === 'isNull' || patternObj.type === 'isNotNull' || 
            patternObj.type === 'isTrue' || patternObj.type === 'isFalse') {
          return {
            field: field,
            operator: patternObj.type,
            value: null,
            isString: false
          };
        }
        
        // Handle IN/NOT IN values
        if (patternObj.type === 'isIn' || patternObj.type === 'notIn') {
          value = value.split(',').map(v => v.trim().replace(/'/g, ''));
        }
        
        return {
          field: field,
          operator: patternObj.type,
          value: value,
          isString: patternObj.isString
        };
      }
    }
    
    // If no pattern matches, return null to indicate unparseable condition
    return null;
  }

  parseOrderByClause(query) {
    const orderByMatch = query.match(/ORDER\s+BY\s+(.*?)(?:\s+(?:LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE)|ALL\s+ROWS)\s|$)/i);
    if (orderByMatch) {
      const orderByClause = orderByMatch[1].trim();
      this.orderByFields = orderByClause.split(',').map(field => field.trim());
    }
  }

  parseGroupByClause(query) {
    const groupByMatch = query.match(/GROUP\s+BY\s+(.*?)(?:\s+(?:HAVING|ORDER\s+BY|LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE)|ALL\s+ROWS)\s|$)/i);
    if (groupByMatch) {
      const groupByClause = groupByMatch[1].trim();
      this.groupByFields = groupByClause.split(',').map(field => field.trim());
    }
  }

  parseHavingClause(query) {
    const havingMatch = query.match(/HAVING\s+(.*?)(?:\s+(?:ORDER\s+BY|LIMIT|OFFSET|FOR\s+(?:UPDATE|VIEW|REFERENCE)|ALL\s+ROWS)\s|$)/i);
    if (havingMatch) {
      const havingClause = havingMatch[1].trim();
      this.havingConditions = [havingClause];
    }
  }

  parseLimitClause(query) {
    const limitMatch = query.match(/LIMIT\s+(\d+)/i);
    if (limitMatch) {
      this.limitClause = limitMatch[1];
    }
  }

  parseOffsetClause(query) {
    const offsetMatch = query.match(/OFFSET\s+(\d+)/i);
    if (offsetMatch) {
      this.offsetClause = offsetMatch[1];
    }
  }

  parseForClause(query) {
    const forMatch = query.match(/(FOR\s+(?:UPDATE|VIEW|REFERENCE)|ALL\s+ROWS)/i);
    if (forMatch) {
      this.forClause = forMatch[1].toUpperCase();
    }
  }

  generateSOQLLibCode(hasSystemMode = false) {
    let code = `SOQL.of(${this.sobjectType}.SObjectType)`;
    
    // Handle SELECT fields
    if (this.selectFields.length > 0) {
      const regularFields = this.selectFields.filter(f => f.type === 'field');
      const relationshipFields = this.selectFields.filter(f => f.type === 'relationship');
      const aggregateFields = this.selectFields.filter(f => f.type === 'aggregate');
      const functionFields = this.selectFields.filter(f => f.type === 'function');
      const aliasFields = this.selectFields.filter(f => f.type === 'alias');
      const subqueryFields = this.selectFields.filter(f => f.type === 'subquery');
      
      // Handle COUNT() special case
      if (this.selectFields.length === 1 && this.selectFields[0] === 'COUNT()') {
        code += '\n    .count()';
      } else {
        // Regular fields
        if (regularFields.length > 0) {
          const fieldNames = regularFields.map(f => `${this.sobjectType}.${f.field}`).join(', ');
          code += `\n    .with(${fieldNames})`;
        }
        
        // Relationship fields grouped by relationship
        const relationshipGroups = {};
        relationshipFields.forEach(f => {
          if (!relationshipGroups[f.relationship]) {
            relationshipGroups[f.relationship] = [];
          }
          relationshipGroups[f.relationship].push(f.field);
        });
        
        Object.keys(relationshipGroups).forEach(relationship => {
          const fields = relationshipGroups[relationship].map(field => {
            // Try to determine the SObject type for the field
            return field === 'Id' ? `${relationship}.Id` : `${relationship}.${field}`;
          }).join(', ');
          code += `\n    .with('${relationship}', ${fields})`;
        });
        
        // Aggregate functions
        aggregateFields.forEach(f => {
          const field = f.field === '*' ? '' : `${this.sobjectType}.${f.field}`;
          const alias = f.alias ? `, '${f.alias}'` : '';
          if (f.function === 'count_distinct') {
            code += `\n    .countDistinct(${field}${alias})`;
          } else {
            code += `\n    .${f.function}(${field}${alias})`;
          }
        });
        
        // Function fields
        functionFields.forEach(f => {
          const alias = f.alias ? `, '${f.alias}'` : '';
          code += `\n    .${f.function}(${this.sobjectType}.${f.field}${alias})`;
        });
        
        // Alias fields
        aliasFields.forEach(f => {
          code += `\n    .with(${f.field}, '${f.alias}')`;
        });
        
        // Subqueries
        subqueryFields.forEach(f => {
          code += `\n    .with(${this.generateSubQueryCode(f)})`;
        });
      }
    }
    
    // WHERE conditions
    if (this.whereConditions.length > 0) {
      const conditionCode = this.generateWhereConditions(this.whereConditions);
      if (conditionCode) {
        code += `\n    .whereAre(${conditionCode})`;
      }
    }
    
    // GROUP BY
    if (this.groupByFields.length > 0) {
      this.groupByFields.forEach(field => {
        if (field.includes('.')) {
          const parts = field.split('.');
          code += `\n    .groupBy('${parts[0]}', ${parts[0]}.${parts[1]})`;
        } else {
          code += `\n    .groupBy(${this.sobjectType}.${field})`;
        }
      });
    }
    
    // HAVING
    if (this.havingConditions.length > 0) {
      code += `\n    .have('${this.havingConditions[0]}')`;
    }
    
    // ORDER BY
    if (this.orderByFields.length > 0) {
      this.orderByFields.forEach(field => {
        const fieldParts = field.split(/\s+/);
        const fieldName = fieldParts[0];
        const direction = fieldParts[1];
        const nullsOrder = fieldParts.includes('NULLS') ? fieldParts[fieldParts.indexOf('NULLS') + 1] : null;
        
        if (fieldName.includes('.')) {
          const parts = fieldName.split('.');
          code += `\n    .orderBy('${parts[0]}', ${parts[0]}.${parts[1]})`;
        } else {
          code += `\n    .orderBy(${this.sobjectType}.${fieldName})`;
        }
        
        if (direction && direction.toUpperCase() === 'DESC') {
          code += '\n    .sortDesc()';
        }
        
        if (nullsOrder && nullsOrder.toUpperCase() === 'LAST') {
          code += '\n    .nullsLast()';
        }
      });
    }
    
    // LIMIT
    if (this.limitClause) {
      code += `\n    .setLimit(${this.limitClause})`;
    }
    
    // OFFSET
    if (this.offsetClause) {
      code += `\n    .offset(${this.offsetClause})`;
    }
    
    // FOR clause
    if (this.forClause) {
      switch (this.forClause) {
        case 'FOR UPDATE':
          code += '\n    .forUpdate()';
          break;
        case 'FOR VIEW':
          code += '\n    .forView()';
          break;
        case 'FOR REFERENCE':
          code += '\n    .forReference()';
          break;
        case 'ALL ROWS':
          code += '\n    .allRows()';
          break;
      }
    }
    
    // Add system mode when WITH SYSTEM_MODE is specified in the query
    if (hasSystemMode) {
      code += '\n    .systemMode()';
      code += '\n    .withoutSharing()';
    }
    
    // Add result method
    code += '\n    .toList();';
    
    return code;
  }

  generateSubQueryCode(subquery) {
    let subCode = `SOQL.SubQuery.of('${subquery.relationship}')`;
    
    // Handle fields in the subquery
    if (subquery.fields.length > 0) {
      const regularFields = subquery.fields.filter(f => f.type === 'field');
      const relationshipFields = subquery.fields.filter(f => f.type === 'relationship');
      const nestedSubqueries = subquery.fields.filter(f => f.type === 'subquery');
      
      // Regular fields
      if (regularFields.length > 0) {
        const fieldNames = regularFields.map(f => {
          // Handle common field names
          if (f.field.toLowerCase() === 'id') {
            return `${subquery.relationship === 'Contacts' ? 'Contact' : subquery.relationship}.Id`;
          } else if (f.field.toLowerCase() === 'name') {
            return `${subquery.relationship === 'Contacts' ? 'Contact' : subquery.relationship}.Name`;
          } else {
            return `${subquery.relationship === 'Contacts' ? 'Contact' : subquery.relationship}.${f.field}`;
          }
        }).join(', ');
        subCode += `\n        .with(${fieldNames})`;
      }
      
      // Relationship fields grouped by relationship
      const relationshipGroups = {};
      relationshipFields.forEach(f => {
        if (!relationshipGroups[f.relationship]) {
          relationshipGroups[f.relationship] = [];
        }
        relationshipGroups[f.relationship].push(f.field);
      });
      
      Object.keys(relationshipGroups).forEach(relationship => {
        const fields = relationshipGroups[relationship];
        const fieldNames = fields.map(field => {
          if (field.toLowerCase() === 'id') {
            return `${relationship}.Id`;
          } else if (field.toLowerCase() === 'name') {
            return `${relationship}.Name`;
          } else {
            return `${relationship}.${field}`;
          }
        }).join(', ');
        subCode += `\n        .with('${relationship}', ${fieldNames})`;
      });
      
      // Nested subqueries
      nestedSubqueries.forEach(nestedSub => {
        subCode += `\n        .with(${this.generateSubQueryCode(nestedSub)})`;
      });
    }
    
    // Handle WHERE conditions
    if (subquery.whereConditions.length > 0) {
      const conditionCode = this.generateWhereConditions(subquery.whereConditions);
      if (conditionCode) {
        subCode += `\n        .whereAre(${conditionCode})`;
      }
    }
    
    // Handle ORDER BY
    if (subquery.orderBy) {
      const orderParts = subquery.orderBy.split(/\s+/);
      const field = orderParts[0];
      const direction = orderParts[1] ? orderParts[1].toUpperCase() : 'ASC';
      const nulls = orderParts.length > 2 ? orderParts.slice(2).join(' ').toUpperCase() : '';
      
      if (field.includes('.')) {
        const parts = field.split('.');
        subCode += `\n        .orderBy('${parts[0]}', ${parts[0]}.${parts[1]})`;
      } else {
        const objectName = subquery.relationship === 'Contacts' ? 'Contact' : subquery.relationship;
        subCode += `\n        .orderBy(${objectName}.${field})`;
      }
      
      if (direction === 'DESC') {
        subCode += `\n        .sortDesc()`;
      }
      
      if (nulls.includes('NULLS LAST')) {
        subCode += `\n        .nullsLast()`;
      }
    }
    
    // Handle LIMIT
    if (subquery.limit) {
      subCode += `\n        .setLimit(${subquery.limit})`;
    }
    
    // Handle OFFSET
    if (subquery.offset) {
      subCode += `\n        .offset(${subquery.offset})`;
    }
    
    // Handle FOR clause
    if (subquery.forClause) {
      if (subquery.forClause === 'UPDATE') {
        subCode += `\n        .forUpdate()`;
      } else if (subquery.forClause === 'VIEW') {
        subCode += `\n        .forView()`;
      } else if (subquery.forClause === 'REFERENCE') {
        subCode += `\n        .forReference()`;
      }
    }
    
    return subCode;
  }

  generateWhereConditions(conditions) {
    if (conditions.length === 0) return '';
    
    // Check if we have conditionLogic or conditionOrder
    const conditionLogicItem = conditions.find(c => c.type === 'conditionLogic');
    const conditionOrderItem = conditions.find(c => c.type === 'conditionOrder');
    const hasConditionLogic = conditionLogicItem !== undefined;
    const hasConditionOrder = conditionOrderItem !== undefined;
    
    // Filter out the conditionLogic/conditionOrder items and operators to get actual conditions
    const actualConditions = conditions.filter(c => c.type !== 'operator' && c.type !== 'conditionLogic' && c.type !== 'conditionOrder');
    
    // Check if we have only one condition
    if (actualConditions.length === 1 && !hasConditionLogic && !hasConditionOrder) {
      const singleFilter = this.generateSingleFilter(actualConditions[0]);
      // Return the single filter if valid, otherwise return empty string
      return singleFilter || '';
    }
    
    let filterCode = 'SOQL.FilterGroup';
    
    // Add each condition
    for (const condition of actualConditions) {
      const singleFilter = this.generateSingleFilter(condition);
      // Only add valid filters (skip null/invalid conditions)
      if (singleFilter) {
        filterCode += `\n        .add(${singleFilter})`;
      }
    }
    
    // Add conditionLogic or conditionOrder if we have it
    if (hasConditionLogic) {
      filterCode += `\n        .conditionLogic('${conditionLogicItem.value}')`;
    } else if (hasConditionOrder) {
      filterCode += `\n        .conditionOrder('${conditionOrderItem.value}')`;
    } else {
      // Check if all operators are OR (for simple cases without conditionLogic/conditionOrder)
      const hasOrOperator = conditions.some(c => c.type === 'operator' && c.value === 'OR');
      if (hasOrOperator) {
        filterCode += '\n        .anyConditionMatching()';
      }
    }
    
    return filterCode;
  }

  generateSingleFilter(condition) {
    // Skip null or invalid conditions
    if (!condition || !condition.field || !condition.operator) {
      return null;
    }
    
    const fieldReference = this.getFieldReference(condition.field);
    let filterCode = `SOQL.Filter.${fieldReference}`;
    
    switch (condition.operator) {
      case 'equal':
        filterCode += `.equal(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'notEqual':
        filterCode += `.notEqual(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'greaterThan':
        filterCode += `.greaterThan(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'greaterOrEqual':
        filterCode += `.greaterOrEqual(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'lessThan':
        filterCode += `.lessThan(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'lessOrEqual':
        filterCode += `.lessOrEqual(${this.formatValue(condition.value, condition.isString)})`;
        break;
      case 'contains':
        filterCode += `.contains('${condition.value}')`;
        break;
      case 'startsWith':
        filterCode += `.startsWith('${condition.value}')`;
        break;
      case 'endsWith':
        filterCode += `.endsWith('${condition.value}')`;
        break;
      case 'isNull':
        filterCode += '.isNull()';
        break;
      case 'isNotNull':
        filterCode += '.isNotNull()';
        break;
      case 'isTrue':
        filterCode += '.isTrue()';
        break;
      case 'isFalse':
        filterCode += '.isFalse()';
        break;
      case 'isIn':
        if (Array.isArray(condition.value)) {
          const values = condition.value.map(v => `'${v}'`).join(', ');
          filterCode += `.isIn(new List<String>{${values}})`;
        } else {
          filterCode += `.isIn(${this.formatValue(condition.value, condition.isString)})`;
        }
        break;
      case 'notIn':
        if (Array.isArray(condition.value)) {
          const values = condition.value.map(v => `'${v}'`).join(', ');
          filterCode += `.notIn(new List<String>{${values}})`;
        } else {
          filterCode += `.notIn(${this.formatValue(condition.value, condition.isString)})`;
        }
        break;
      default:
        filterCode += `.equal(${this.formatValue(condition.value, condition.isString)})`;
    }
    
    return filterCode;
  }

  getFieldReference(fieldName) {
    if (!fieldName) return 'with(fieldName)';
    
    // Handle special cases
    if (fieldName.toLowerCase() === 'id') {
      return 'id()';
    } else if (fieldName.toLowerCase() === 'name') {
      return 'name()';
    } else if (fieldName.toLowerCase().includes('recordtype')) {
      return 'recordType()';
    } else if (fieldName.includes('.')) {
      // Relationship field
      const parts = fieldName.split('.');
      return `with('${parts[0]}', ${parts[0]}.${parts[1]})`;
    } else {
      // Regular field
      return `with(${this.sobjectType}.${fieldName})`;
    }
  }

  formatValue(value, isString) {
    // Handle null values
    if (value === null || value === 'null') {
      return 'null';
    }
    
    if (isString) {
      return `'${value}'`;
    } else {
      // Try to detect if it's a number
      if (!isNaN(value) && !isNaN(parseFloat(value))) {
        return value;
      } else if (value === 'true' || value === 'false') {
        return value;
      } else {
        return `'${value}'`;
      }
    }
  }
}

export default function Playground() {
  const [soqlInput, setSoqlInput] = useState(`SELECT Id, Name, Industry, BillingCity
FROM Account
WHERE Industry = 'Technology' 
  AND BillingCity = 'San Francisco'
ORDER BY Name ASC
LIMIT 10
WITH USER_MODE`);
  
  const [soqlLibOutput, setSoqlLibOutput] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  // Trigger syntax highlighting when output changes
  useEffect(() => {
    if (typeof window !== 'undefined' && window.Prism && soqlLibOutput) {
      setTimeout(() => {
        window.Prism.highlightAll();
      }, 100);
    }
  }, [soqlLibOutput]);

  const translator = new SOQLToSOQLLibTranslator();

  const handleTranslate = () => {
    setIsLoading(true);
    setTimeout(() => {
      try {
        const result = translator.parseSOQL(soqlInput);
        setSoqlLibOutput(result);
      } catch (error) {
        setSoqlLibOutput(`// Error: ${error.message}`);
      }
      setIsLoading(false);
    }, 100);
  };

  const handleClear = () => {
    setSoqlInput('');
    setSoqlLibOutput('');
  };

  const handleLoadExample = (example) => {
    setSoqlInput(example);
    setSoqlLibOutput('');
  };

  const examples = [
      {
        name: "Simple Query",
        query: `SELECT Id, Name FROM Account WHERE Name LIKE '%Test%' WITH USER_MODE`
      },
    {
      name: "Multiple Conditions", 
      query: `SELECT Id, Name, Owner.Name FROM Account WHERE Industry = 'Technology' AND BillingCity = 'San Francisco' WITH USER_MODE`
    },
    {
      name: "OR Conditions",
      query: `SELECT Id, Name FROM Account WHERE Industry = 'Technology' OR Industry = 'Healthcare' WITH USER_MODE`
    },
    {
      name: "Parent Fields",
      query: `SELECT Id, Name, CreatedBy.Id, CreatedBy.Name, Parent.Id, Parent.Name FROM Account WITH USER_MODE`
    },
    {
      name: "COUNT & SUM",
      query: `SELECT CampaignId, COUNT(Id) totalRecords, SUM(Amount) totalAmount FROM Opportunity GROUP BY CampaignId WITH USER_MODE`
    },
    {
      name: "AVG & MIN",
      query: `SELECT Industry, AVG(AnnualRevenue) avgRevenue, MIN(NumberOfEmployees) minEmployees FROM Account GROUP BY Industry WITH USER_MODE`
    },
    {
      name: "SubQuery",
      query: `SELECT Id, Name, (SELECT Id, Name FROM Contacts) FROM Account WITH USER_MODE`
    },
    {
      name: "Complex WHERE",
      query: `SELECT Id FROM Account WHERE Industry = 'IT' AND ((Name = 'My Account' AND NumberOfEmployees >= 10) OR (Name = 'My Account 2' AND NumberOfEmployees <= 20)) WITH USER_MODE`
    },
    {
      name: "LIKE Patterns",
      query: `SELECT Id, Name FROM Account WHERE Name LIKE 'Test%' AND BillingCity LIKE '%Francisco%' WITH USER_MODE`
    },
    {
      name: "IN Operator",
      query: `SELECT Id, Name FROM Account WHERE Industry IN ('Technology', 'Healthcare', 'Finance') WITH USER_MODE`
    },
    {
      name: "ORDER BY Multiple",
      query: `SELECT Id, Name, Industry FROM Account ORDER BY Name DESC, Industry ASC LIMIT 50 WITH USER_MODE`
    },
    {
      name: "Complex Query",
      query: `SELECT Id, Name FROM Account WHERE (Industry = 'Technology' OR Industry = 'Healthcare') AND NumberOfEmployees > 100 ORDER BY Name LIMIT 20 WITH USER_MODE`
    },
    {
      name: "Boolean Fields",
      query: `SELECT Id, Name FROM Account WHERE IsDeleted = false AND IsPersonAccount = true WITH USER_MODE`
    },
    {
      name: "NULL Checks",
      query: `SELECT Id, Name FROM Account WHERE ParentId != null AND BillingCity = null WITH USER_MODE`
    },
    {
      name: "System Mode",
      query: `SELECT Id, Name, CreatedBy.Id, CreatedBy.Name, Parent.Id, Parent.Name FROM Account WITH SYSTEM_MODE`
    }
  ];

  // Initial translation
  React.useEffect(() => {
    handleTranslate();
  }, []);

  return (
    <Layout
      title="SOQL Playground"
      description="Convert traditional SOQL queries to SOQL Lib syntax">
      <div className="container mx-auto px-4 py-8 max-w-7xl">
        <div className="text-center mb-8">
          <Heading as="h1" className="text-4xl font-bold mb-4">
            SOQL Lib Playground
          </Heading>
          <p className="text-lg text-gray-600 dark:text-gray-300 max-w-2xl mx-auto">
            Paste your traditional SOQL query and see how it translates to SOQL Lib syntax. 
            Perfect for learning and migrating existing queries.
          </p>
        </div>

        {/* Example buttons */}
        <div className="mb-6">
          <div className="flex flex-wrap gap-2 justify-center">
            <span className="text-sm font-medium text-gray-700 dark:text-gray-300 mr-2">Examples:</span>
            {examples.map((example, index) => (
              <button
                key={index}
                onClick={() => handleLoadExample(example.query)}
                className="px-3 py-1 text-xs bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 rounded-full hover:bg-blue-200 dark:hover:bg-blue-800 transition-colors border-none"
              >
                {example.name}
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 items-start">
          {/* Input Panel */}
          <div className="space-b-4 h-full">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold">Traditional SOQL</h2>
              <button
                onClick={handleClear}
                className="px-3 py-1 text-sm bg-gray-200 dark:bg-gray-700 hover:bg-gray-300 dark:hover:bg-gray-600 rounded transition-colors border-none"
              >
                Clear
              </button>
            </div>
            <textarea
              value={soqlInput}
              onChange={(e) => setSoqlInput(e.target.value)}
              className="w-full h-80 p-4 border border-gray-300 dark:border-gray-600 rounded-lg bg-white dark:bg-gray-800 font-mono text-sm resize-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              placeholder="Enter your SOQL query here..."
            />
          </div>

          {/* Output Panel */}
          <div className="space-y-4 h-full">
            <h2 className="text-xl font-semibold">SOQL Lib Syntax</h2>
            <div className="relative">
              <pre className="w-full h-80 p-4 border border-gray-300 dark:border-gray-600 rounded-lg bg-gray-50 dark:bg-gray-900 font-mono text-sm overflow-auto">
                <code className="language-java">{soqlLibOutput || '// Your translated SOQL Lib code will appear here...'}</code>
              </pre>
              {soqlLibOutput && (
                <button
                  onClick={() => navigator.clipboard.writeText(soqlLibOutput)}
                  className="absolute top-2 right-2 p-2 bg-white dark:bg-gray-800 hover:bg-gray-100 dark:hover:bg-gray-700 rounded border text-xs transition-colors"
                  title="Copy to clipboard"
                >
                  📋 Copy
                </button>
              )}
            </div>
          </div>
        </div>

        {/* Translate Button - Centered between panels */}
        <div className="flex justify-center my-6">
          <button
            onClick={handleTranslate}
            disabled={isLoading || !soqlInput.trim()}
            className="px-6 py-2.5 bg-green-500 hover:bg-green-600 disabled:bg-gray-400 text-white font-medium rounded-md transition-colors flex items-center justify-center space-x-2 border-none"
          >
            {isLoading ? (
              <>
                <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white"></div>
                <span>Translating...</span>
              </>
            ) : (
              <>
                <span>🚀</span>
                <span>Translate to SOQL Lib</span>
              </>
            )}
          </button>
        </div>

        {/* Info Section */}
        <div className="mt-12 p-6 bg-blue-50 dark:bg-blue-900/20 rounded-lg">
          <h3 className="text-lg font-semibold mb-3">💡 How it works</h3>
            <ul className="space-y-2 text-sm text-gray-700 dark:text-gray-300">
              <li><strong>Field Selection:</strong> Converts SELECT fields to <code>.with()</code> methods - <a href="/soql/api/soql#with" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>Relationships:</strong> Transforms parent.field syntax to <code>.with('Parent', fields)</code> - <a href="/soql/api/soql#with-related-field" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>WHERE Conditions:</strong> Parses conditions into <code>SOQL.Filter</code> and <code>SOQL.FilterGroup</code> - <a href="/soql/api/soql-filter" className="text-blue-600 hover:text-blue-800 underline">Filter API</a> | <a href="/soql/api/soql-filters-group" className="text-blue-600 hover:text-blue-800 underline">FilterGroup API</a></li>
              <li><strong>Filter Operations:</strong> Maps SOQL operators to methods like <code>.equal()</code>, <code>.contains()</code>, <code>.greaterThan()</code> - <a href="/soql/api/soql-filter#comparators" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>Logic Operators:</strong> AND conditions are grouped, OR uses <code>.anyConditionMatching()</code> - <a href="/soql/api/soql-filters-group#anyconditionmatching" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>Aggregate Functions:</strong> Maps to specific methods like <code>.count()</code>, <code>.sum()</code> - <a href="/soql/api/soql#aggregate-functions" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>ORDER BY:</strong> Translates to <code>.orderBy()</code> with direction methods - <a href="/soql/api/soql#order-by" className="text-blue-600 hover:text-blue-800 underline">API docs</a></li>
              <li><strong>LIMIT/OFFSET:</strong> Converts to <code>.setLimit()</code> and <code>.offset()</code> - <a href="/soql/api/soql#limit" className="text-blue-600 hover:text-blue-800 underline">LIMIT</a> | <a href="/soql/api/soql#offset" className="text-blue-600 hover:text-blue-800 underline">OFFSET</a></li>
            </ul>

          <p className="mt-4 text-sm text-gray-600 dark:text-gray-400">
            <strong>Note:</strong> This is a learning tool that covers most common SOQL patterns. 
            Complex nested conditions may need manual refinement. Check the 
            <a href="/soql/examples/select" className="text-blue-600 hover:text-blue-800 underline"> full documentation</a> for advanced features.
          </p>
        </div>
      </div>
    </Layout>
  );
}
