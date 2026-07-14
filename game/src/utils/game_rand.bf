namespace game;

class game_rand {
    private static uint32 s_seed = 12345;

    public static uint32 next() {
        s_seed = s_seed * 1664525 + 1013904223;
        return s_seed;
    }

    public static float next_float() {
        next();
        return (float)(s_seed & 0xFFFFFF) / 16777216.0f;
    }

    public static float next_range(float min, float max) {
        return min + next_float() * (max - min);
    }
}
