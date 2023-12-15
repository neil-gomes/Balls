OPTION _EXPLICIT

CONST MAX_BALLS = 10
CONST BALL_RADIUS_MIN = 4
CONST BALL_RADIUS_MAX = 30

TYPE Vector2
    x AS SINGLE
    y AS SINGLE
END TYPE

TYPE Ball
    position AS Vector2
    radius AS LONG
    colour AS _UNSIGNED LONG
    velocity AS Vector2
    mass AS SINGLE
END TYPE

DIM SHARED myBall(MAX_BALLS) AS Ball

SCREEN _NEWIMAGE(800, 600, 32)

RANDOMIZE TIMER

DIM AS LONG i, j

FOR i = 1 TO MAX_BALLS
    InitBall myBall(i)
NEXT

DO
    FOR i = 1 TO MAX_BALLS
        UpdateBall myBall(i)
    NEXT

    FOR i = 1 TO MAX_BALLS - 1
        FOR j = i + 1 TO MAX_BALLS
            CheckBallCollision myBall(i), myBall(j)
        NEXT
    NEXT

    CLS

    FOR i = 1 TO MAX_BALLS
        DrawBall myBall(i)
    NEXT

    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

SYSTEM

FUNCTION RandomFloat! (min AS SINGLE, max AS SINGLE)
    RandomFloat = RND * (max - min) + min
END FUNCTION

SUB InitBall (b AS Ball)
    b.position.x = RandomFloat(0, _WIDTH)
    b.position.y = RandomFloat(0, _HEIGHT)
    b.radius = RandomFloat(BALL_RADIUS_MIN, BALL_RADIUS_MAX)
    b.colour = _RGB32(RND * 255, RND * 255, RND * 255)
    b.velocity.x = RandomFloat(-2, 2)
    b.velocity.y = RandomFloat(-2, 2)
    b.mass = b.radius
END SUB

SUB UpdateBall (b AS Ball)
    b.position.x = b.position.x + b.velocity.x
    b.position.y = b.position.y + b.velocity.y

    ' Reflect the balls at the screen edges
    IF b.position.x - b.radius < 0 OR b.position.x + b.radius >= _WIDTH THEN
        b.velocity.x = -b.velocity.x
    END IF

    IF b.position.y - b.radius < 0 OR b.position.y + b.radius >= _HEIGHT THEN
        b.velocity.y = -b.velocity.y
    END IF
END SUB

SUB DrawBall (b AS Ball)
    CIRCLE (b.position.x, b.position.y), b.radius, b.colour
    PAINT (b.position.x, b.position.y), b.colour, b.colour
END SUB

SUB CheckBallCollision (b1 AS Ball, b2 AS Ball)
    IF BallCollides(b1, b2) THEN
        DIM AS SINGLE angleLoI
        DIM AS SINGLE m1, m2
        DIM AS SINGLE b1Speed, b2Speed
        DIM AS SINGLE b1FinalSpeed, b2FinalSpeed


        angleLoI = _ATAN2(b2.position.y - b1.position.y, b2.position.x - b1.position.x)

        ' Calculate relative velocities
        b1Speed = (b1.velocity.x * COS(angleLoI) + b1.velocity.y * SIN(angleLoI))
        b2Speed = (b2.velocity.x * COS(angleLoI) + b2.velocity.y * SIN(angleLoI))

        ' Calculate new velocities using the elastic collision formula
        m1 = b1.mass
        m2 = b2.mass
        b1FinalSpeed = ((m1 - m2) * b1Speed + 2 * m2 * b2Speed) / (m1 + m2)
        b2FinalSpeed = ((m2 - m1) * b2Speed + 2 * m1 * b1Speed) / (m1 + m2)

        ' Update velocities for both balls
        b1.velocity.x = b1FinalSpeed * COS(angleLoI)
        b1.velocity.y = b1FinalSpeed * SIN(angleLoI)
        b2.velocity.x = b2FinalSpeed * COS(angleLoI)
        b2.velocity.y = b2FinalSpeed * SIN(angleLoI)
    END IF
END SUB

FUNCTION BallCollides% (b1 AS Ball, b2 AS Ball)
    DIM AS SINGLE dx, dy, distanceSquared
    dx = b2.position.x - b1.position.x
    dy = b2.position.y - b1.position.y
    distanceSquared = dx * dx + dy * dy
    BallCollides = (distanceSquared <= (b1.radius + b2.radius) * (b1.radius + b2.radius))
END FUNCTION
