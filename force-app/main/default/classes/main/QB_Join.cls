public with sharing class QB_Join implements QB_Part {
    private QB builder;
    private QB_Binder binder;

    public static QB_Join joinWithBinder(QB_Binder binder) {
        return new QB_Join(binder);
    }

    private QB_Join(QB_Binder binder) {
        this.binder = binder;
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
        builder.conditions.add(conditions);
        return this;
    }

    // Helper

    public String build() {
        return builder.build();
    }
}
