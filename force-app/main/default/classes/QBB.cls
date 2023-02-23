public with sharing class QBB {
    private Map<String, Object> binding = new Map<String, Object>();

    public String bind(Object value) {
        String binder = 'binding' + String.valueof(binding.size() - 1);

        binding.put(binder, value);

        return binder;
    }

    public Map<String, Object> build() {
        return binding;
    }
}
