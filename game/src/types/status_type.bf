namespace game;

enum status_type : int
{
    bleed = 0,
    burn = 1,
    charge = 2,
    sinking = 3,
    poise = 4,
    rupture = 5,
    tremor = 6,

    Count = 7
}

struct status_effect
{
    public int potency;
    public int count;

    public this(int potency, int count)
    {
        this.potency = potency;
        this.count = count;
    }
}
