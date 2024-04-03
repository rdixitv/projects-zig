const std = @import("std");
const utils = @import("utils.zig");
const Result = utils.Result;
const Choice = utils.Choice;
var score = utils.getScore();

const stdout_file = std.io.getStdOut().writer();
var bw = std.io.bufferedWriter(stdout_file);
const stdout = bw.writer();

const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    var best_of: u8 = 3;
    var player_choice_char: u8 = ' ';
    var player_choice: Choice = Choice.None;
    var computer_choice_char: u8 = ' ';
    var computer_choice: Choice = Choice.None;
    var n: u8 = 0;
    var result: Result = Result.Draw;
    var input: ?u8 = ' ';
    var seed: u64 = undefined;

    var args = std.process.args();
    defer args.deinit();

    _ = args.next();

    if (args.next()) |arg| {
        best_of = try std.fmt.parseInt(u8, arg, 10);
    }

    for (1..best_of + 1) |_| {
        try stdout.print("Rock, paper, or scissors [r/p/s]? ", .{});
        try bw.flush();
        input = try stdin.readByte();
        try stdin.streamUntilDelimiter(stdout, '\n', null);

        if (input) |choice| {
            player_choice_char = choice;
        }

        try std.os.getrandom(std.mem.asBytes(&seed));
        var prng = std.rand.DefaultPrng.init(seed);

        n = prng.random().int(u8) % 3;

        try stdout.print("Computer played: {s}\n", .{switch (n) {
            0 => "Rock",
            1 => "Paper",
            2 => "Scissors",
            else => "N/A",
        }});

        computer_choice_char = switch (n) {
            0 => 'r',
            1 => 'p',
            2 => 's',
            else => ' ',
        };

        player_choice = utils.setChoice(player_choice_char);
        computer_choice = utils.setChoice(computer_choice_char);

        result = utils.game(player_choice, computer_choice);

        try stdout.print("Round {s}!\n", .{switch (result) {
            Result.Win => "won",
            Result.Draw => "drawn",
            Result.Lose => "lost",
        }});
        try bw.flush();

        switch (result) {
            .Win => score.player += 1,
            .Lose => score.computer += 1,
            else => {},
        }

        try utils.printScore();

        if (score.player > best_of / 2 or score.computer > best_of / 2) {
            break;
        }
    }

    if (score.player > score.computer) {
        try stdout.print("Game won", .{});
    } else if (score.player < score.computer) {
        try stdout.print("Game lost", .{});
    } else {
        try stdout.print("Game drawn", .{});
    }

    try stdout.print(" {d} to {d}!\n", .{ score.player, score.computer });

    try bw.flush();
}
