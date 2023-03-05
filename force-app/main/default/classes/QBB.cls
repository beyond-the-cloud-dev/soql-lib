public with sharing class QBB {
    private static Integer uniqueIndex = 0;
    private Map<String, Object> binding = new Map<String, Object>();

    public String bind(Object value) {
        uniqueIndex++;

        binding.put('v' + uniqueIndex, value);

        return 'v' + uniqueIndex;
    }

    public Map<String, Object> build() {
        return binding;
    }
}
