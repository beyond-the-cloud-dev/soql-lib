public with sharing class QB_Config {
    public List<String> soqlFields = new List<String>{ 'Id' };
    public List<SubQuery> subQueries;
    public String soqlObject;
    public String soqlScope;
    public ConditionGroups conditions;
    public String security;
    public String sharing;
    public List<String> groupBy;
    public OrderBy orderBy;
    public Integer soqlLimit;
    public Integer soqlOffset;
    public String soqlFor;

    public class SubQuery {
        public List<String> soqlFields = new List<String>{ 'Id' };
        public String soqlObject;
        public ConditionGroups conditions;
        public List<String> groupBy;
        public OrderBy orderBy;
        public Integer soqlLimit;
        public Integer soqlOffset;
        public String soqlFor;
    }

    public class ConditionGroups {
        public List<ConditionGroup> conditionGroups;
        public String order;
    }

    public class ConditionGroup {
        public List<Condition> conditions;
        public String order;
    }

    public class Condition {
        public String field;
        public String expression;
        public Object value;
    }

    public class OrderBy {
        public String field;
        public String order;
        public String nullsOrder;
    }
}
