public with sharing class QB_Join implements QB_Part {
    private QB builder;
    private QB_Bind bind;

    public static QB_Join joinWithBinder(QB_Bind bind) {
        return new QB_Join(bind);
    }

    private QB_Join(QB_Bind bind) {
        this.bind = bind;
    }

    // From

    public QB_Join of(sObjectType ofObject) {
        builder = new QB(ofObject);
        return this;
    }

    // Fields

    public QB_Join field(sObjectField field) {
        builder.fields.retrive(field);
        return this;
    }

    // Where

    public QB_Join whereAre(QB_ConditionsGroup conditions) {
        builder.conditions = conditions;
        return this;
    }

    // Helper

    public String build() {
        return builder.build();
    }
}
