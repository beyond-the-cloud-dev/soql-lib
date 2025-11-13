global interface DataCategoryFilter {
    // FIELDS
    DataCategoryFilter with(String field);
    // COMPARATORS
    DataCategoryFilter at(String category);
    DataCategoryFilter at(Iterable<String> categories);
    DataCategoryFilter above(String category);
    DataCategoryFilter above(Iterable<String> categories);
    DataCategoryFilter below(String category);
    DataCategoryFilter below(Iterable<String> categories);
    DataCategoryFilter aboveOrBelow(String category);
    DataCategoryFilter aboveOrBelow(Iterable<String> categories);

    Boolean hasValue();
}