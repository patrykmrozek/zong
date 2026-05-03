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
const PLAYER_2_START_POS: v2 = v2.init(
    5 * SCREEN_WIDTH / 6 - (PLAYER_SIZE.x / 2),
    SCREEN_HEIGHT / 2 - (PLAYER_SIZE.y / 2),
);
const PLAYER_VEL: f32 = 7.5;

//ball
const BALL_START_POS: v2 = v2.init(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
const BALL_SIZE = 10;
const BALL_VEL: f32 = 6.5;

const Player = struct {
    pos: v2,
    size: v2 = PLAYER_SIZE,
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
            print("[UP] player pos: {any}\n", .{self.pos});
            //print("key up pressed: {any}\n", .{self.keys.key_up});
            if (self.pos.y <= 0) {
                self.pos.y = 0;
            } else {
                self.pos = v2.add(self.pos, Player.UP);
            }
        } else if (rl.isKeyDown(self.keys.key_down)) {
            print("[DOWN] player pos: {any}\n", .{self.pos});
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
    size: f32 = BALL_SIZE,
    vel: v2 = v2.init(BALL_VEL, 0),
    color: rl.Color = .black,

    fn draw(self: Ball) void {
        rl.drawCircleV(
            self.pos,
            self.size,
            self.color,
        );
    }

    fn update(self: *Ball) void {
        self.pos = v2.add(self.pos, self.vel);
    }
};

const Game = struct {
    players: [2]Player,
    ball: Ball,

    fn init() Game {
        print("Game Created!\n", .{});
        return Game{
            .players = .{
                .{
                    .pos = PLAYER_1_START_POS,
                    .keys = .{
                        .key_up = Key.w,
                        .key_down = Key.s,
                    },
                },
                .{
                    .pos = PLAYER_2_START_POS,
                    .keys = .{
                        .key_up = Key.up,
                        .key_down = Key.down,
                    },
                },
            },
            .ball = .{},
        };
    }

    //need to have self: *_ to be able to mutate
    fn update(self: *Game) void {
        for (&self.players) |*player| {
            player.update();
        }
        self.ball.update();
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
