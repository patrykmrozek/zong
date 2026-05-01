const std = @import("std");
const print = std.debug.print;
const math = std.math;
const rl = @import("raylib");
const v2 = rl.Vector2;

const WIDTH = 1080;
const HEIGHT = 720;

const PLAYER_SIZE: v2 = v2.init(20, 70);
const PLAYER_1_START_POS: v2 = v2.init(WIDTH / 5 - (PLAYER_SIZE.x / 2), HEIGHT / 2 - (PLAYER_SIZE.y / 2));
const PLAYER_2_START_POS: v2 = v2.init(4 * WIDTH / 5 - (PLAYER_SIZE.x / 2), HEIGHT / 2 - (PLAYER_SIZE.y / 2));

const BALL_START_POS: v2 = v2.init(WIDTH / 2, HEIGHT / 2);
const BALL_SIZE = 10;

const Player = struct {
    pos: v2,
    size: v2 = PLAYER_SIZE,
    vel: v2 = v2.zero(),
    color: rl.Color = rl.Color.black,

    fn draw(self: Player) void {
        rl.drawRectangleV(self.pos, self.size, self.color);
    }
};

const Ball = struct {
    pos: v2 = BALL_START_POS,
    size: f32 = BALL_SIZE,
    vel: v2 = v2.zero(),
    color: rl.Color = rl.Color.black,

    fn draw(self: Ball) void {
        rl.drawCircleV(self.pos, self.size, self.color);
    }
};

const Game = struct {
    players: [2]Player,
    ball: Ball,

    fn init() Game {
        print("Game Created!\n", .{});
        return Game{
            .players = .{
                .{ .pos = PLAYER_1_START_POS },
                .{ .pos = PLAYER_2_START_POS },
            },
            .ball = .{},
        };
    }

    fn update() void {
        undefined;
    }

    fn render(self: Game) void {
        for (self.players) |player| {
            player.draw();
        }
        self.ball.draw();
    }
};

pub fn main() anyerror!void {
    print("Hello world!\n", .{});
    rl.initWindow(WIDTH, HEIGHT, "pong");
    defer rl.closeWindow();

    rl.setTargetFPS(60);
    const game: Game = Game.init();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        //game.update();
        game.render();
    }
}
