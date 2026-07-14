namespace game;

enum BulletType
{
    case Normal;
    case SineWave;
    case SineWaveDNA;
    case Fragmentation;
    case FragmentationSmall;
    case Explosion;
    case LaserTelegraph;
    case LaserActive;
    case VortexCenter;

    public bool IsCollidable
    {
        get
        {
            return this != .LaserTelegraph && this != .Explosion && this != .VortexCenter;
        }
    }

    public bool IsBounded
    {
        get
        {
            return this != .LaserTelegraph && this != .LaserActive && this != .VortexCenter && this != .Explosion;
        }
    }
}
