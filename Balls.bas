OPTION _EXPLICIT

CONST BALL_RADIUS_MIN = 4
CONST BALL_RADIUS_MAX = 30

DIM SHARED MAX_BALLS AS LONG: MAX_BALLS = 20
DIM SHARED GRAVITY AS SINGLE: GRAVITY = 0.1
DIM SHARED FRICTION AS SINGLE: FRICTION = 0.99

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
    rotation AS SINGLE
    angularVelocity AS SINGLE
    spriteID AS LONG
    active AS _BYTE
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
    b.position.x = RandomFloat(b.radius, _WIDTH - b.radius)
    b.position.y = RandomFloat(b.radius, _HEIGHT - b.radius)
    b.radius = RandomFloat(BALL_RADIUS_MIN, BALL_RADIUS_MAX)
    b.colour = _RGB32(RND * 255, RND * 255, RND * 255)
    b.velocity.x = RandomFloat(-2, 2)
    b.velocity.y = RandomFloat(-2, 2)
    b.mass = b.radius * b.radius
    b.rotation = 0
    b.angularVelocity = 0
    b.spriteID = 0
    b.active = -1
END SUB


SUB UpdateBall (b AS Ball)
    b.velocity.y = b.velocity.y + GRAVITY

    b.position.x = b.position.x + b.velocity.x
    b.position.y = b.position.y + b.velocity.y

    b.velocity.x = b.velocity.x * FRICTION
    b.velocity.y = b.velocity.y * FRICTION

    IF b.radius > 0 THEN
        b.angularVelocity = b.velocity.x / b.radius * 0.1
    END IF
    b.rotation = b.rotation + b.angularVelocity
    IF b.rotation > 360 THEN b.rotation = b.rotation - 360
    IF b.rotation < 0 THEN b.rotation = b.rotation + 360

    IF b.position.x < b.radius THEN
        b.position.x = b.radius
        b.velocity.x = -b.velocity.x
        b.angularVelocity = -b.angularVelocity
    ELSEIF b.position.x > _WIDTH - b.radius THEN
        b.position.x = _WIDTH - b.radius
        b.velocity.x = -b.velocity.x
        b.angularVelocity = -b.angularVelocity
    END IF

    IF b.position.y < b.radius THEN
        b.position.y = b.radius
        b.velocity.y = -b.velocity.y
        b.angularVelocity = -b.angularVelocity
    ELSEIF b.position.y > _HEIGHT - b.radius THEN
        b.position.y = _HEIGHT - b.radius
        b.velocity.y = -b.velocity.y * FRICTION
        b.angularVelocity = b.angularVelocity * FRICTION
    END IF
END SUB


SUB DrawBall (b AS Ball)
    CIRCLE (b.position.x, b.position.y), b.radius, b.colour
    PAINT (b.position.x, b.position.y), b.colour, b.colour
    
    DIM AS SINGLE speedAngle
    IF b.velocity.x <> 0 OR b.velocity.y <> 0 THEN
        speedAngle = _ATAN2(b.velocity.y, b.velocity.x)
        DIM AS SINGLE indicatorLen
        indicatorLen = b.radius * 0.7
        LINE (b.position.x, b.position.y)-(b.position.x + COS(speedAngle) * indicatorLen, b.position.y + SIN(speedAngle) * indicatorLen), _RGB32(0, 0, 0)
    END IF
END SUB


FUNCTION GetBallSpeed! (b AS Ball)
    GetBallSpeed = SQR(b.velocity.x * b.velocity.x + b.velocity.y * b.velocity.y)
END FUNCTION


FUNCTION GetBallDirection! (b AS Ball)
    GetBallDirection = _ATAN2(b.velocity.y, b.velocity.x)
END FUNCTION


FUNCTION BallCollides% (ballA AS Ball, ballB AS Ball)
    DIM AS SINGLE dx, dy, distanceSquared, radiusSumSquared
    dx = ballB.position.x - ballA.position.x
    dy = ballB.position.y - ballA.position.y
    distanceSquared = dx * dx + dy * dy
    radiusSumSquared = (ballA.radius + ballB.radius) * (ballA.radius + ballB.radius)
    BallCollides = (distanceSquared <= radiusSumSquared)
END FUNCTION


SUB CheckBallCollision (ballA AS Ball, ballB AS Ball)
    IF BallCollides(ballA, ballB) THEN
        DIM AS SINGLE dx, dy, distance, nx, ny
        DIM AS SINGLE tx, ty, sepDist, massSum, massDiff
        DIM AS SINGLE vn_A, vn_B, vt_A, vt_B
        DIM AS SINGLE oldVn_A, oldVn_B

        dx = ballB.position.x - ballA.position.x
        dy = ballB.position.y - ballA.position.y
        distance = SQR(dx * dx + dy * dy)

        IF distance = 0 THEN distance = 0.001

        nx = dx / distance
        ny = dy / distance
        tx = -ny
        ty = nx

        vn_A = ballA.velocity.x * nx + ballA.velocity.y * ny
        vn_B = ballB.velocity.x * nx + ballB.velocity.y * ny
        IF vn_A <= vn_B THEN EXIT SUB

        sepDist = (ballA.radius + ballB.radius - distance) / 2 + 0.1
        ballA.position.x = ballA.position.x - nx * sepDist
        ballA.position.y = ballA.position.y - ny * sepDist
        ballB.position.x = ballB.position.x + nx * sepDist
        ballB.position.y = ballB.position.y + ny * sepDist

        vt_A = ballA.velocity.x * tx + ballA.velocity.y * ty
        vt_B = ballB.velocity.x * tx + ballB.velocity.y * ty

        oldVn_A = vn_A
        oldVn_B = vn_B

        massSum = ballA.mass + ballB.mass
        massDiff = ballA.mass - ballB.mass
        vn_A = (massDiff * oldVn_A + 2 * ballB.mass * oldVn_B) / massSum
        vn_B = (-massDiff * oldVn_B + 2 * ballA.mass * oldVn_A) / massSum

        ballA.velocity.x = vn_A * nx + vt_A * tx
        ballA.velocity.y = vn_A * ny + vt_A * ty
        ballB.velocity.x = vn_B * nx + vt_B * tx
        ballB.velocity.y = vn_B * ny + vt_B * ty
    END IF
END SUB
