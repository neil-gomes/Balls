' Ball demo

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
    mass AS SINGLE
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
myBall(1).mass = 1

myBall(2).position.x = 500
myBall(2).position.y = 280
myBall(2).radius = 20
myBall(2).colour = _RGB32(RND * 255, RND * 255, RND * 255)
myBall(2).velocity.x = 2
myBall(2).velocity.y = 0
myBall(2).mass = 1

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
        DIM AS SINGLE difx, dify, angleLoI, b1Speed, b2Speed
        DIM AS SINGLE b1SpeedAngle, b2SpeedAngle
        DIM AS SINGLE b1FinalLoIspeedx, b2FinalLoIspeedx
        DIM AS Vector2 b1LoISpeedInitial, b2LoISpeedInitial
        difx = b2.position.x - b1.position.x
        dify = b2.position.y - b1.position.y
        angleLoI = ATN(dify / difx)
        b1Speed = SQR(b1.velocity.x * b1.velocity.x + b1.velocity.y * b1.velocity.y)
        b2Speed = SQR(b2.velocity.x * b2.velocity.x + b2.velocity.y * b2.velocity.y)
        b1SpeedAngle = ATN(b1.velocity.y / b1.velocity.x)
        IF b1.velocity.y = 0 AND b1.velocity.x < 0 THEN
            b1SpeedAngle = _PI
        END IF

        b2SpeedAngle = ATN(b2.velocity.y / b2.velocity.x)
        IF b2.velocity.y = 0 AND b2.velocity.x < 0 THEN b2SpeedAngle = _PI

        IF b1.velocity.x < 0 AND b1.velocity.y > 0 THEN b1SpeedAngle = _PI - b1SpeedAngle
        IF b1.velocity.x < 0 AND b1.velocity.y < 0 THEN b1SpeedAngle = _PI + b1SpeedAngle
        IF b2.velocity.x < 0 AND b2.velocity.y > 0 THEN b2SpeedAngle = _PI - b2SpeedAngle
        IF b2.velocity.x < 0 AND b2.velocity.y < 0 THEN b2SpeedAngle = _PI + b2SpeedAngle

        b1LoISpeedInitial.x = COS(-angleLoI + b1SpeedAngle) * b1Speed 'treat as u1
        b1LoISpeedInitial.y = SIN(-angleLoI + b1SpeedAngle) * b1Speed
        b2LoISpeedInitial.x = COS(-angleLoI + b2SpeedAngle) * b2Speed 'treat as u2
        b2LoISpeedInitial.y = SIN(-angleLoI + b2SpeedAngle) * b2Speed

        IF b1LoISpeedInitial.x > b2LoISpeedInitial.x THEN
            b1FinalLoIspeedx = (b1LoISpeedInitial.x * (b1.mass - b2.mass) + (2 * b2.mass * b2LoISpeedInitial.x)) / (b1.mass + b2.mass)
            b2FinalLoIspeedx = b1FinalLoIspeedx + (b1LoISpeedInitial.x - b2LoISpeedInitial.x)
            'the formula v1=(u1(m1-m2)+2m2u2)/(m1+m2) was derived from the conservation of momentum as well as the
            'elastic collision equation.This formula was used to get the final velocity along line of impact
        ELSE
            b2FinalLoIspeedx = (b2LoISpeedInitial.x * (b2.mass - b1.mass) + (2 * b1.mass * b1LoISpeedInitial.x)) / (b1.mass + b2.mass)
            b1FinalLoIspeedx = (b2LoISpeedInitial.x - b1LoISpeedInitial.x) + b2FinalLoIspeedx

        END IF

        b1.velocity.x = b1FinalLoIspeedx * COS(angleLoI) + b1LoISpeedInitial.y * SIN(angleLoI)
        b1.velocity.y = b1FinalLoIspeedx * SIN(angleLoI) + b1LoISpeedInitial.y * COS(angleLoI)
        b2.velocity.x = b2FinalLoIspeedx * COS(angleLoI) + b2LoISpeedInitial.y * SIN(angleLoI)
        b2.velocity.y = b2FinalLoIspeedx * SIN(angleLoI) + b2LoISpeedInitial.y * COS(angleLoI)
    END IF
END SUB
