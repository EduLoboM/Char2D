using System;
using engine.core;

namespace game;

class character {
    public String name ~ delete _;
    public String texture_path ~ delete _;

    private int m_health;
    public int health => m_health;
    public int max_health;

    public int attack_power;
    public int max_stagger;

    private int m_stagger;
    public int stagger => m_stagger;

    private int m_mercy_bar;
    public int mercy_bar => m_mercy_bar;
    public int max_mercy_bar;

    private int m_tp;
    public int tp => m_tp;
    public int max_tp;

    public float x;
    public float y;
    public float width = 32;
    public float height = 32;
    public SpriteAnimation sprite = null ~ delete _;

    public float shake_timer = 0.0f;
    public float shake_phase = 0.0f;
    public float shake_offset_x = 0.0f;
    public float shake_offset_y = 0.0f;
    private const float SHAKE_DURATION = 0.4f;
    private const float SHAKE_INTENSITY = 3.0f;

    public status_effect[(int)status_type.Count] statuses;

    public this(String name, int max_health, int attack_power, int max_stagger, int max_mercy_bar, float start_x, float start_y, StringView texture_path, int frame_width = 32, int frame_height = 32) {
        this.name = new String()..Append(name);
        this.texture_path = new String()..Append(texture_path);
        this.m_health = max_health;
        this.max_health = max_health;
        this.attack_power = attack_power;
        this.max_stagger = max_stagger;
        this.m_stagger = 0;
        this.max_mercy_bar = max_mercy_bar;
        this.m_mercy_bar = 0;
        this.max_tp = 100;
        this.m_tp = 0;
        this.x = start_x;
        this.y = start_y;
        this.width = frame_width;
        this.height = frame_height;
        this.sprite = new SpriteAnimation(null, frame_width, frame_height);
        clear_statuses();
    }

    public void take_damage(int damage) {
        this.m_health -= damage;
        if (damage > 0)
        {
            this.shake_timer = SHAKE_DURATION;
            this.shake_phase = 0.0f;
        }
    }

    public void update_shake(float delta_time) {
        if (this.shake_timer > 0.0f)
        {
            this.shake_phase += delta_time * 40.0f;
            float intensity = SHAKE_INTENSITY * (this.shake_timer / SHAKE_DURATION);
            this.shake_offset_x = (float)Math.Sin(this.shake_phase) * intensity;
            this.shake_offset_y = (float)Math.Cos(this.shake_phase * 1.3f) * intensity * 0.5f;
            this.shake_timer -= delta_time;
            if (this.shake_timer <= 0.0f)
            {
                this.shake_timer = 0.0f;
                this.shake_offset_x = 0.0f;
                this.shake_offset_y = 0.0f;
            }
        }
    }

    public void heal(int heal_amount) {
        this.m_health = Math.Clamp(this.m_health + heal_amount, 0, this.max_health);
    }

    public void add_tp(int amount) {
        this.m_tp = Math.Clamp(this.m_tp + amount, 0, this.max_tp);
    }

    public void add_mercy(int amount) {
        this.m_mercy_bar = Math.Clamp(this.m_mercy_bar + amount, 0, this.max_mercy_bar);
    }

    public void add_stagger(int amount) {
        this.m_stagger = Math.Clamp(this.m_stagger + amount, 0, this.max_stagger);
    }

    public void stun() {
        this.m_stagger = this.max_stagger;
    }

    public void recover_from_stun() {
        this.m_stagger = 0;
    }

    public void use_mercy_ability(character target) {
        target.heal(this.max_mercy_bar);
    }

    public void fill_mercy_bar() {
        add_mercy(10);
    }

    public bool is_staggered() {
        return this.m_stagger == this.max_stagger;
    }

    public bool is_mercy_ready() {
        return this.m_mercy_bar == this.max_mercy_bar;
    }

    public void reset_character(float start_x, float start_y) {
        this.m_health = this.max_health;
        this.m_stagger = 0;
        this.m_mercy_bar = 0;
        this.m_tp = 0;
        this.x = start_x;
        this.y = start_y;
        clear_statuses();
    }

    public bool is_dead() {
        return this.m_health <= 0;
    }

    public void apply_status(status_type type, int potency, int count) {
        statuses[(int)type].potency += potency;
        statuses[(int)type].count += count;
    }

    public void clear_statuses() {
        for (int i = 0; i < (int)status_type.Count; i++) {
            statuses[i].potency = 0;
            statuses[i].count = 0;
        }
    }

    private void consume_status(status_type type) {
        statuses[(int)type].count--;
        if (statuses[(int)type].count == 0)
            statuses[(int)type].potency = 0;
    }

    public void on_action() {
        if (statuses[(int)status_type.bleed].count > 0) {
            take_damage(statuses[(int)status_type.bleed].potency);
            consume_status(.bleed);
        }
    }

    public void on_turn_end() {
        if (statuses[(int)status_type.burn].count > 0) {
            take_damage(statuses[(int)status_type.burn].potency);
            consume_status(.burn);
        }
    }

    public int calculate_damage(character target, int base_damage, bool is_skill) {
        int damage = base_damage;

        if (is_skill && statuses[(int)status_type.charge].count > 0) {
            damage = (int)(damage * (1.0f + 0.1f * statuses[(int)status_type.charge].potency));
            statuses[(int)status_type.charge].count = 0;
            statuses[(int)status_type.charge].potency = 0;
        }

        if (statuses[(int)status_type.poise].count > 0) {
            float crit_chance = statuses[(int)status_type.poise].potency * 0.05f;
            if (game_rand.next_float() < crit_chance) {
                damage = (int)(damage * 1.20f);
                consume_status(.poise);
            }
        }

        return damage;
    }

    public void on_hit(int base_damage) {
        int final_damage = base_damage;

        if (statuses[(int)status_type.rupture].count > 0) {
            final_damage += statuses[(int)status_type.rupture].potency;
            consume_status(.rupture);
        }

        if (statuses[(int)status_type.sinking].count > 0) {
            add_mercy(statuses[(int)status_type.sinking].potency);
            consume_status(.sinking);
        }

        if (statuses[(int)status_type.tremor].count > 0) {
            add_stagger(statuses[(int)status_type.tremor].potency);
            consume_status(.tremor);
        }

        take_damage(final_damage);
    }
}
