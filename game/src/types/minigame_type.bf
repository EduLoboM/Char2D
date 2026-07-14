using System;

namespace game;

enum MinigameType
{
    case Slider;
    case Tap;
    case Arrow;
    case Charge;
    case RideTheBus;

    public int TpCost
    {
        get
        {
            switch (this)
            {
                case .Slider: return 15;
                case .Tap: return 15;
                case .Charge: return 20;
                case .Arrow: return 25;
                case .RideTheBus: return 30;
            }
        }
    }

    public float Multiplier
    {
        get
        {
            switch (this)
            {
                case .Slider: return 1.0f;
                case .Tap: return 1.0f;
                case .Charge: return 1.25f;
                case .Arrow: return 1.5f;
                case .RideTheBus: return 1.75f;
            }
        }
    }

    public StringView Name
    {
        get
        {
            switch (this)
            {
                case .Slider: return "SLIDER";
                case .Tap: return "TAP";
                case .Arrow: return "ARROW";
                case .Charge: return "CHARGE";
                case .RideTheBus: return "RIDE THE BUS";
            }
        }
    }

    public StringView Difficulty
    {
        get
        {
            switch (this)
            {
                case .Slider: return "EASY";
                case .Tap: return "EASY";
                case .Charge: return "MEDIUM";
                case .Arrow: return "HARD";
                case .RideTheBus: return "HARD";
            }
        }
    }

    public StringView CostStr
    {
        get
        {
            switch (this)
            {
                case .Slider: return "15 TP";
                case .Tap: return "15 TP";
                case .Charge: return "20 TP";
                case .Arrow: return "25 TP";
                case .RideTheBus: return "30 TP";
            }
        }
    }

    public StringView MultHint
    {
        get
        {
            switch (this)
            {
                case .Slider: return "1-0 DMG";
                case .Tap: return "1-0 DMG";
                case .Charge: return "1-2 DMG";
                case .Arrow: return "1-5 DMG";
                case .RideTheBus: return "1-7 DMG";
            }
        }
    }

    public attack_minigame CreateInstance()
    {
        switch (this)
        {
            case .Slider: return new slider_minigame();
            case .Tap: return new tap_minigame();
            case .Arrow: return new arrow_minigame();
            case .Charge: return new charge_minigame();
            case .RideTheBus: return new ride_the_bus_minigame();
        }
    }
}
