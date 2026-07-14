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
        }
    }
}
