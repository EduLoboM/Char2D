using System;
using System.Collections;

namespace game;

class arena
{
    public float center_x;
    public float center_y;
    public float rotation = 0.0f;
    public float w;
    public float h;

    public float x => center_x - w / 2.0f;
    public float y => center_y - h / 2.0f;

    public List<Vector2> local_vertices = new .() ~ delete _;

    public this(float x, float y, float w, float h)
    {
        this.center_x = x + w / 2.0f;
        this.center_y = y + h / 2.0f;
        this.w = w;
        this.h = h;
        set_as_rectangle(w, h);
    }

    public void set_as_rectangle(float width, float height)
    {
        this.w = width;
        this.h = height;
        local_vertices.Clear();
        float hw = width / 2.0f;
        float hh = height / 2.0f;
        local_vertices.Add(.( -hw, -hh ));
        local_vertices.Add(.( -hw,  hh ));
        local_vertices.Add(.(  hw,  hh ));
        local_vertices.Add(.(  hw, -hh ));
    }

    public void get_transformed_vertices(List<Vector2> out_vertices)
    {
        float cos = (float)Math.Cos(rotation);
        float sin = (float)Math.Sin(rotation);

        for (int i = 0; i < local_vertices.Count; i++)
        {
            float lx = local_vertices[i].x;
            float ly = local_vertices[i].y;
            float tx = lx * cos - ly * sin + center_x;
            float ty = lx * sin + ly * cos + center_y;
            out_vertices.Add(.(tx, ty));
        }
    }

    public void constrain_soul(player_soul soul)
    {
        if (local_vertices.Count < 3) return;

        List<Vector2> transformed = scope .();
        get_transformed_vertices(transformed);

        float scx = soul.x + soul.size / 2.0f;
        float scy = soul.y + soul.size / 2.0f;
        float r = soul.size / 2.0f;

        int count = transformed.Count;
        for (int i = 0; i < count; i++)
        {
            Vector2 p1 = transformed[i];
            Vector2 p2 = transformed[(i + 1) % count];

            float ex = p2.x - p1.x;
            float ey = p2.y - p1.y;
            float len = (float)Math.Sqrt(ex * ex + ey * ey);

            if (len > 0.0f)
            {
                float nx = -ey / len;
                float ny = ex / len;

                float dx = scx - p1.x;
                float dy = scy - p1.y;

                float projection = dx * nx + dy * ny;
                if (projection > -r)
                {
                    float overlap = projection + r;
                    scx -= overlap * nx;
                    scy -= overlap * ny;
                }
            }
        }

        soul.x = scx - r;
        soul.y = scy - r;
    }
}
