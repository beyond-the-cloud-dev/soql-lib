public interface IOpportunitiesSelector extends fflib_ISObjectSelector {
    List<Opportunity> selectById(Set<Id> idSet);
    List<Opportunity> selectByIdWithProducts(Set<Id> idSet);
}
