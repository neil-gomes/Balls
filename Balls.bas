' Ball demo

$DEBUG
OPTION _EXPLICIT

CONST MAX_BALLS = 2
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
END TYPE

SCREEN _NEWIMAGE(800, 600, 32)

RANDOMIZE TIMER

DIM myBall(1 TO MAX_BALLS) AS Ball
DIM i AS LONG

'FOR i = 1 TO MAX_BALLS
'    InitBall myBall(i)
'NEXT

myBall(1).position.x = 30
myBall(1).position.y = 300
myBall(1).radius = 20
myBall(1).colour = _RGB32(RND * 255, RND * 255, RND * 255)
myBall(1).velocity.x = 2
myBall(1).velocity.y = 0

myBall(2).position.x = 500
myBall(2).position.y = 320
myBall(2).radius = 20
myBall(2).colour = _RGB32(RND * 255, RND * 255, RND * 255)
myBall(2).velocity.x = 2
myBall(2).velocity.y = 0


DO
    FOR i = 1 TO MAX_BALLS
        UpdateBall myBall(i)
    NEXT

    CheckBallCollision myBall(1), myBall(2)

    CLS

    FOR i = 1 TO MAX_BALLS
        DrawBall myBall(i)
    NEXT

    _DISPLAY
    _LIMIT 60
LOOP UNTIL _KEYHIT = 27

SYSTEM


SUB InitBall (b AS Ball)
    b.position.x = RND * _WIDTH
    b.position.y = RND * _HEIGHT
    b.radius = BALL_RADIUS_MIN + RND * (BALL_RADIUS_MAX - BALL_RADIUS_MIN)
    b.colour = _RGB32(RND * 255, RND * 255, RND * 255)

    DO
        b.velocity.x = RND * 2
        b.velocity.y = RND * 2
    LOOP WHILE b.velocity.x = 0 OR b.velocity.y = 0
END SUB


SUB UpdateBall (b AS Ball)
    IF b.position.x - b.radius < 0 OR b.position.x + b.radius >= _WIDTH THEN
        b.velocity.x = -b.velocity.x
    END IF

    IF b.position.y - b.radius < 0 OR b.position.y + b.radius >= _HEIGHT THEN
        b.velocity.y = -b.velocity.y
    END IF

    b.position.x = b.position.x + b.velocity.x
    b.position.y = b.position.y + b.velocity.y
END SUB


SUB DrawBall (b AS Ball)
    CIRCLE (b.position.x, b.position.y), b.radius, b.colour
    PAINT (b.position.x, b.position.y), b.colour, b.colour
END SUB


FUNCTION BallCollides%% (b1 AS Ball, b2 AS Ball)
    DIM AS SINGLE difx, dify
    difx = b1.position.x - b2.position.x
    dify = b1.position.y - b2.position.y
    BallCollides = (b1.radius + b2.radius >= SQR(difx * difx + dify * dify))
END FUNCTION


SUB CheckBallCollision (b1 AS Ball, b2 AS Ball)
    IF BallCollides(b1, b2) THEN
        DIM AS SINGLE difx, dify, angleLoI, b1Velocity, b2Velocity, b1VelocityAngle, b2VelocityAngle
        DIM AS SINGLE b1FinalVelLoI, b2FinalVelLoI
        DIM AS Vector2 b1LoIVel, b2LoIVel
        difx = b1.position.x - b2.position.x
        dify = b1.position.y - b2.position.y
        angleLoI = ATN(dify / difx)
        b1Velocity = SQR(b1.velocity.x * b1.velocity.x + b1.velocity.y * b1.velocity.y)
        b2Velocity = -SQR(b2.velocity.x * b2.velocity.x + b2.velocity.y * b2.velocity.y)
        b1VelocityAngle = ATN(b1.velocity.y / b1.velocity.x)
        b2VelocityAngle = ATN(b2.velocity.y / b2.velocity.x)
        b1LoIVel.x = COS(angleLoI + b1VelocityAngle) * b1Velocity
        b1LoIVel.y = SIN(angleLoI + b1VelocityAngle) * b1Velocity
        b2LoIVel.x = COS(angleLoI + b2VelocityAngle) * b2Velocity
        b2LoIVel.y = SIN(angleLoI + b2VelocityAngle) * b2Velocity
        b2FinalVelLoI = b1LoIVel.x
        b1FinalVelLoI = b2LoIVel.x
        b1.velocity.y = b1LoIVel.y * COS(angleLoI) + b1FinalVelLoI * SIN(angleLoI)
        b1.velocity.x = b1LoIVel.y * SIN(angleLoI) + b1FinalVelLoI * COS(angleLoI)
        b2.velocity.y = b2LoIVel.y * COS(angleLoI) + b2FinalVelLoI * SIN(angleLoI)
        b2.velocity.x = b2LoIVel.y * SIN(angleLoI) + b2FinalVelLoI * COS(angleLoI)
    END IF
END SUB
