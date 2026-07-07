using System;
using Engine.Core;

namespace Game;

class character {
    public String name ~ delete _;
    public int health;
    public int max_health;
    public int attack_power;
    public int max_stagger;
    public int stagger;
    public int mercy_bar;
    public int max_mercy_bar;

    public float x;
    public float y;
    public float width = 32;
    public float height = 32;

    public this(String name, int max_health, int attack_power, int max_stagger, int max_mercy_bar, float start_x, float start_y) {
        this.name = new String(name);
        this.health = max_health;
        this.max_health = max_health;
        this.attack_power = attack_power;
        this.max_stagger = max_stagger;
        this.stagger = 0;
        this.max_mercy_bar = max_mercy_bar;
        this.mercy_bar = 0;
        
        this.x = start_x;
        this.y = start_y;
    }

    public void take_damage(int damage) {
        this.health -= damage;
    }

    public void heal(int heal_amount) {
        this.health += heal_amount;
        if (this.health > this.max_health) {
            this.health = this.max_health;
        }
    }

    public void deal_damage(character target) {
        target.take_damage(this.attack_power);
    }

    public void perform_special_ability(character target) {
        target.take_damage(this.attack_power * 2);
    }

    public void stun() {
        this.stagger = this.max_stagger;
    }

    public void recover_from_stun() {
        this.stagger = 0;
    }

    public void use_mercy_ability(character target) {
        target.heal(this.max_mercy_bar);
    }

    public void fill_mercy_bar() {
        this.mercy_bar += 10;
        if (this.mercy_bar > this.max_mercy_bar) {
            this.mercy_bar = this.max_mercy_bar;
        }
    }

    public bool is_alive() {
        return this.health > 0;
    }

    public bool is_staggered() {
        return this.stagger == this.max_stagger;
    }

    public bool is_mercy_ready() {
        return this.mercy_bar == this.max_mercy_bar;
    }

    public bool is_dead() {
        return this.health <= 0;
    }
}