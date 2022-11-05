public abstract class QB_QueryClause implements Comparable {

    public abstract String build();

    // Allows to keep QB_QueryClause as unique element of Set
    // Allows to sort List<QB_QueryClause> in proper way
    protected virtual Integer getPosition() {
        return null;
    }

    public virtual String validate() {
        return '';
    }

    // Comparable interface

    public Integer compareTo(Object compareTo) {
        QB_QueryClause queryUnit = (QB_QueryClause) compareTo;

        if (this.getPosition() < queryUnit.getPosition()) {
            return -1;
        }

        if (this.getPosition() > queryUnit.getPosition()) {
            return 1;
        }

        return 0;
    }

    // add QB_QueryClause to the Set

    public Boolean equals(Object queryUnit) {
        if (queryUnit.hashCode() == null) {
            return false;
        }
        return this.hashCode() == queryUnit.hashCode();
    }


    public Integer hashCode() {
        return this.getPosition();
    }
}
