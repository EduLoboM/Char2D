namespace game;

enum BulletPatternType
{
    case Waves;
    case Spiral;
    case Rain;
    case Homing;
    case SineWave;
    case Fragmentation;
    case LaserWeb;
    case BoneZone;
    case DiamondOrbit;
    case ZigzagCorridor;
    case Starburst;

    public bullet_pattern CreateInstance()
    {
        switch (this)
        {
            case .Waves: return new waves_pattern();
            case .Spiral: return new spiral_pattern();
            case .Rain: return new rain_pattern();
            case .Homing: return new homing_pattern();
            case .SineWave: return new sine_wave_pattern();
            case .Fragmentation: return new fragmentation_pattern();
            case .LaserWeb: return new laser_web_pattern();
            case .BoneZone: return new bone_zone_pattern();
            case .DiamondOrbit: return new diamond_orbit_pattern();
            case .ZigzagCorridor: return new zigzag_corridor_pattern();
            case .Starburst: return new starburst_pattern();
        }
    }
}
