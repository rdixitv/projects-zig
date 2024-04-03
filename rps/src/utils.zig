const std = @import("std");

var bw = std.io.bufferedWriter(std.io.getStdOut().writer());
const stdout = bw.writer();

pub const Score = struct { player: u8, computer: u8 };
pub var score = Score{
    .player = 0,
    .computer = 0,
};

pub const Choice = enum { Rock, Paper, Scissors, None };

pub const Result = enum { Win, Draw, Lose };

pub fn getScore() *Score {
    return &score;
}

pub fn setChoice(choice: u8) Choice {
    return switch (choice) {
        'r' => Choice.Rock,
        'p' => Choice.Paper,
        's' => Choice.Scissors,
        else => Choice.None,
    };
}

pub fn iterLen(iter: *std.process.ArgIterator) usize {
    var count: usize = 0;
    while (iter.next()) |_| {
        count += 1;
    }
    return count;
}

pub fn game(player_choice: Choice, computer_choice: Choice) Result {
    if (player_choice == computer_choice) {
        return Result.Draw;
    } else if ((player_choice == Choice.Rock and computer_choice == Choice.Scissors) or
        (player_choice == Choice.Scissors and computer_choice == Choice.Paper) or
        (player_choice == Choice.Paper and computer_choice == Choice.Rock))
    {
        return Result.Win;
    } else {
        return Result.Lose;
    }
}

pub fn printScore() !void {
    try stdout.print("You: {d}\nComputer: {}\n\n", .{ score.player, score.computer });
    try bw.flush();
}
