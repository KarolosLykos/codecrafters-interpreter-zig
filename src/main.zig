const std = @import("std");

const print = std.debug.print;
const MyErrors = error{TokenNotFound};
const TokenType = enum {
    LEFT_PAREN,
    RIGHT_PAREN,
    EOF,
};

const Token = struct {
    tokenType: TokenType,
    lexeme: []const u8,
    literal: ?[]u8,
};

const EOFToken = Token{
    .tokenType = .EOF,
    .lexeme = "",
    .literal = null,
};
const LPARENToken = Token{
    .tokenType = .LEFT_PAREN,
    .lexeme = "(",
    .literal = null,
};
const RPARENToken = Token{
    .tokenType = .RIGHT_PAREN,
    .lexeme = ")",
    .literal = null,
};

pub fn main() !void {
    // You can use print statements as follows for debugging, they'll be visible when running tests.
    std.debug.print("Logs from your program will appear here!\n", .{});

    const args = try std.process.argsAlloc(std.heap.page_allocator);
    defer std.process.argsFree(std.heap.page_allocator, args);

    if (args.len < 3) {
        std.debug.print("Usage: ./your_program.sh tokenize <filename>\n", .{});
        std.process.exit(1);
    }

    const command = args[1];
    const filename = args[2];

    if (!std.mem.eql(u8, command, "tokenize")) {
        std.debug.print("Unknown command: {s}\n", .{command});
        std.process.exit(1);
    }

    const file_contents = try std.fs.cwd().readFileAlloc(std.heap.page_allocator, filename, std.math.maxInt(usize));
    defer std.heap.page_allocator.free(file_contents);

    // Uncomment this block to pass the first stage
    if (file_contents.len > 0) {
        for (file_contents) |i| {
            try scanner(i);
        }
    } else {
        try std.io.getStdOut().writer().print("EOF  null\n", .{}); // Placeholder, remove this line when implementing the scanner
    }
}

fn scanner(token: u8) !void {
    if (token == '\n') {
        return;
    }
    const t = try match(token);
    try std.io.getStdOut().writer().print("{s} {s} {any}\n", .{ @tagName(t.tokenType), t.lexeme, t.literal });
}

fn match(token: u8) MyErrors!Token {
    switch (token) {
        '(' => {
            return LPARENToken;
        },
        ')' => {
            return RPARENToken;
        },
        0 => {
            return EOFToken;
        },
        else => {
            return MyErrors.TokenNotFound;
        },
    }
}
