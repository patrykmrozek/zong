//TODO:
//  random ball init dir
//  pause between score
//  render score

const std = @import("std");
const print = std.debug.print;
const math = std.math;
const rl = @import("raylib");
const v2 = rl.Vector2;
const Key = rl.KeyboardKey;

//screen
const SCREEN_WIDTH = 1080;
const SCREEN_HEIGHT = 720;

//player
const PLAYER_SIZE: v2 = v2.init(20, 70);
const PLAYER_1_START_POS: v2 = v2.init(
    SCREEN_WIDTH / 6 - (PLAYER_SIZE.x / 2),
    SCREEN_HEIGHT / 2 - (PLAYER_SIZE.y / 2),
);
const PLAYER_1_NORMAL: v2 = v2.init(1, 0);
const PLAYER_2_START_POS: v2 = v2.init(
    5 * SCREEN_WIDTH / 6 - (PLAYER_SIZE.x / 2),
    SCREEN_HEIGHT / 2 - (PLAYER_SIZE.y / 2),
);
const PLAYER_2_NORMAL: v2 = v2.init(-1, 0);
const PLAYER_VEL: f32 = 7.5;

//ball
const BALL_START_POS: v2 = v2.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
const BALL_RAD = 10;
const BALL_VEL: f32 = 6.5;

//collision
const COLLISION_TIMER_MAX: u32 = 100;

const Player = struct {
    pos: v2,
    size: v2 = PLAYER_SIZE,
    normal: v2,
    score: u32 = 0,
    color: rl.Color = .black,
    keys: Keys,

    const Keys = struct {
        key_up: Key,
        key_down: Key,
    };

    const UP: v2 = v2.init(0, -PLAYER_VEL);
    const DOWN: v2 = v2.init(0, PLAYER_VEL);

    fn draw(self: Player) void {
        rl.drawRectangleV(
            self.pos,
            self.size,
            self.color,
        );
    }

    fn update(self: *Player) void {
        if (rl.isKeyDown(self.keys.key_up)) {
            //print("[UP] player pos: {any}\n", .{self.pos});
            //print("key up pressed: {any}\n", .{self.keys.key_up});
            if (self.pos.y <= 0) {
                self.pos.y = 0;
            } else {
                self.pos = v2.add(self.pos, Player.UP);
            }
        } else if (rl.isKeyDown(self.keys.key_down)) {
            //print("[DOWN] player pos: {any}\n", .{self.pos});
            //print("key down pressed: {any}\n", .{self.keys.key_down});
            if (self.pos.y >= SCREEN_HEIGHT - self.size.y) {
                self.pos.y = SCREEN_HEIGHT - self.size.y;
            } else {
                self.pos = v2.add(self.pos, Player.DOWN);
            }
        } else return;
    }
};

const Ball = struct {
    pos: v2 = BALL_START_POS,
    rad: f32 = BALL_RAD,
    //need to rand
    vel: v2 = v2.init(BALL_VEL, 1),
    color: rl.Color = .black,

    fn draw(self: Ball) void {
        rl.drawCircleV(
            self.pos,
            self.rad,
            self.color,
        );
    }

    //stole from acoustic tracer
    fn bounce(self: *Ball, normal: v2) void {
        const u = v2.scale(
            normal,
            (v2.dotProduct(self.vel, normal) / v2.dotProduct(normal, normal)),
        );
        const w = v2.subtract(self.vel, u);
        self.vel = v2.subtract(w, u);
    }

    fn update(self: *Ball) Game.Scored {
        if (self.pos.y < self.rad) {
            self.bounce(v2.init(0, 1));
        } else if (self.pos.y > SCREEN_HEIGHT - self.rad) {
            self.bounce(v2.init(0, -1));
        } else if (self.pos.x > SCREEN_WIDTH - self.rad) {
            return .PLAYER_1_SCORED;
        } else if (self.pos.x < self.rad) {
            return .PLAYER_2_SCORED;
        }
        self.pos = v2.add(self.pos, self.vel);
        return .NO_SCORED;
    }
};

const Game = struct {
    players: [2]Player,
    ball: Ball,
    can_resolve_collisions: bool = true,

    const Scored = enum {
        NO_SCORED,
        PLAYER_1_SCORED,
        PLAYER_2_SCORED,
    };

    fn resolveCollision(self: *Game, p: Player) void {
        //https://ziglang.org/documentation/master/#Locally-Scoped-Global-Variables
        //pretty much static var
        const CollisionTrack = struct {
            var timer: u32 = 0;
        };

        if (!self.can_resolve_collisions) {
            if (CollisionTrack.timer >= COLLISION_TIMER_MAX) {
                CollisionTrack.timer = 0;
                self.can_resolve_collisions = true;
            } else {
                CollisionTrack.timer += 1;
                return;
            }
        }

        var b: *Ball = &self.ball;
        var closest: v2 = b.pos;

        if (b.pos.x < p.pos.x) {
            closest.x = p.pos.x;
        } else if (b.pos.x > p.pos.x + p.size.x) {
            closest.x = p.pos.x + p.size.x;
        }
        if (b.pos.y < p.pos.y) {
            closest.y = p.pos.y;
        } else if (b.pos.y > p.pos.y + p.size.y) {
            closest.y = p.pos.y + p.size.y;
        }

        //print("\nclosest: ({}, {})\n", .{ closest.x, closest.y });
        //print("b.pos: ({}, {})\n", .{ b.pos.x, b.pos.y });
        //print("dist: {}\n", .{v2.distance(closest, b.pos)});

        if (v2.distance(closest, b.pos) <= b.rad) {
            b.bounce(p.normal);
            self.can_resolve_collisions = false;
        }
    }

    fn init() Game {
        //print("Game Created!\n", .{});
        return Game{
            .players = .{ .{
                .pos = PLAYER_1_START_POS,
                .normal = PLAYER_1_NORMAL,
                .keys = .{ .key_up = Key.w, .key_down = Key.s },
            }, .{
                .pos = PLAYER_2_START_POS,
                .normal = PLAYER_2_NORMAL,
                .keys = .{ .key_up = Key.up, .key_down = Key.down },
            } },
            .ball = .{},
        };
    }

    fn reset(self: *Game) void {
        self.players[0].pos = PLAYER_1_START_POS;
        self.players[1].pos = PLAYER_2_START_POS;
        self.ball.pos = BALL_START_POS;
        //need to sleep for a bit
    }

    //need to have self: *_ to be able to mutate
    fn update(self: *Game) void {
        //self.resolveCollision(self.players[1]);
        for (&self.players) |*player| {
            self.resolveCollision(player.*); //deref player
            player.update();
        }

        _ = switch (self.ball.update()) {
            Game.Scored.PLAYER_1_SCORED => {
                self.players[0].score += 1;
                self.reset();
            },
            Game.Scored.PLAYER_2_SCORED => {
                self.players[1].score += 1;
                self.reset();
            },
            Game.Scored.NO_SCORED => undefined,
        };
    }

    fn render(self: Game) void {
        for (self.players) |player| {
            player.draw();
        }
        self.ball.draw();
    }
};

pub fn main() anyerror!void {
    print("pong time baby\n", .{});

    rl.initWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "pong");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var game: Game = Game.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        game.update();
        game.render();
    }
}
