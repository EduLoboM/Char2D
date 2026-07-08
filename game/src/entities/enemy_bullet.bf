namespace game;

struct enemy_bullet {
    public float x;
    public float y;
    public float size = 12.0f;
    public float speed_x = 0.0f;
    public float speed_y = 0.0f;
    public int damage = 10;
    public bool is_grazed = false;

    public this(float x, float y, float speed_x, float speed_y, float size = 12.0f, int damage = 10) {
        this.x = x;
        this.y = y;
        this.speed_x = speed_x;
        this.speed_y = speed_y;
        this.size = size;
        this.damage = damage;
        this.is_grazed = false;
    }
}
