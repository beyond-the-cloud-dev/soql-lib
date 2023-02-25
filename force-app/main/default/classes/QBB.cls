public with sharing class QBB {
    private static Integer index = 0;
    private Map<String, Object> binding = new Map<String, Object>();

    public String bind(Object value) {
        index++;

        binding.put('v' + index, value);

        return 'v' + index;
    }

    public Map<String, Object> build() {
        return binding;
    }
}
