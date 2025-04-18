const std = @import("std");

const print = std.debug.print;
const MyErrors = error{TokenNotFound};
const TokenType = enum { LEFT_PAREN, RIGHT_PAREN, LEFT_BRACE, RIGHT_BRACE, COMMA, DOT, MINUS, PLUS, STAR, SEMICOLON, EQUAL, EQUAL_EQUAL, EOF };

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

const LBRACEToken = Token{
    .tokenType = .LEFT_BRACE,
    .lexeme = "{",
    .literal = null,
};

const RBRACEToken = Token{
    .tokenType = .RIGHT_BRACE,
    .lexeme = "}",
    .literal = null,
};

const SEMICOLONToken = Token{
    .tokenType = .SEMICOLON,
    .lexeme = ";",
    .literal = null,
};

const COMMAToken = Token{
    .tokenType = .COMMA,
    .lexeme = ",",
    .literal = null,
};

const DOTToken = Token{
    .tokenType = .DOT,
    .lexeme = ".",
    .literal = null,
};

const MINUSToken = Token{
    .tokenType = .MINUS,
    .lexeme = "-",
    .literal = null,
};

const PLUSToken = Token{
    .tokenType = .PLUS,
    .lexeme = "+",
    .literal = null,
};

const STARToken = Token{
    .tokenType = .STAR,
    .lexeme = "*",
    .literal = null,
};

const EQUALToken = Token{
    .tokenType = .EQUAL,
    .lexeme = "=",
    .literal = null,
};

const EQUALEQUALToken = Token{
    .tokenType = .EQUAL_EQUAL,
    .lexeme = "==",
    .literal = null,
};

pub fn main() !void {
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

    var exit_code: u8 = 0;
    var line: u8 = 1;
    var next: bool = false;
    // Uncomment this block to pass the first stage
    if (file_contents.len > 0) {
        for (file_contents, 0..) |token, i| {
            if (next) {
                next = false;
                continue;
            }
            if (token == '\n') {
                line += 1;
                continue;
            }
            var t = scanner(token) catch {
                try std.io.getStdErr().writer().print("[line {d}] Error: Unexpected character: {c}\n", .{ line, token });

                exit_code = 65;
                continue;
            };

            if (t.tokenType == EQUALToken.tokenType and file_contents.len > i + 1) {
                const nextToken = scanner(file_contents[i + 1]) catch {
                    try std.io.getStdOut().writer().print("{s} {s} {any}\n", .{ @tagName(t.tokenType), t.lexeme, t.literal });
                    continue;
                };

                if (nextToken.tokenType == EQUALToken.tokenType) {
                    t.tokenType = EQUALEQUALToken.tokenType;
                    t.lexeme = EQUALEQUALToken.lexeme;
                    t.literal = EQUALEQUALToken.literal;
                    next = true;
                }
            }

            try std.io.getStdOut().writer().print("{s} {s} {any}\n", .{ @tagName(t.tokenType), t.lexeme, t.literal });
        }
    }
    try std.io.getStdOut().writer().print("EOF  null\n", .{});

    std.process.exit(exit_code);
}

fn scanner(token: u8) MyErrors!Token {
    const t = match(token) catch {
        return MyErrors.TokenNotFound;
    };

    return t;
}

fn match(token: u8) MyErrors!Token {
    switch (token) {
        '(' => {
            return LPARENToken;
        },
        ')' => {
            return RPARENToken;
        },
        '{' => {
            return LBRACEToken;
        },
        '}' => {
            return RBRACEToken;
        },
        ',' => {
            return COMMAToken;
        },
        '.' => {
            return DOTToken;
        },
        '-' => {
            return MINUSToken;
        },
        '+' => {
            return PLUSToken;
        },
        '*' => {
            return STARToken;
        },
        ';' => {
            return SEMICOLONToken;
        },
        '=' => {
            return EQUALToken;
        },
        0 => {
            return EOFToken;
        },
        else => {
            return MyErrors.TokenNotFound;
        },
    }
}
