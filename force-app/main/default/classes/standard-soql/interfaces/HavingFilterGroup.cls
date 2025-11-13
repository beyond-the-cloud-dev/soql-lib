global interface HavingFilterGroup {
    // ADD CONDITION
    HavingFilterGroup add(HavingFilterGroup havingFilterGroup);
    HavingFilterGroup add(HavingFilter havingFilter);
    HavingFilterGroup add(String dynamicHaving);
    // ORDER
    HavingFilterGroup anyConditionMatching();
    HavingFilterGroup conditionLogic(String order);

    Boolean hasValues();
}