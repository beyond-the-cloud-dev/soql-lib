public class QB_Binder {
    private static Integer bindIndex = 0;
    private Map<String, Object> binding = new Map<String, Object>();

    public String bind(Object value) {
        bindIndex++;

        binding.put('v' + bindIndex, value);

        return 'v' + bindIndex;
    }

    public Map<String, Object> build() {
        return binding;
    }
}
