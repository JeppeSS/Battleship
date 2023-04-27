package main

import "core:fmt"
import win "core:sys/windows"


import local_win "windows"

cursor_x := 11
cursor_y := 8



Terminal :: struct {
    output_handle: win.HANDLE,
    input_handle:  win.HANDLE,
}

create_terminal :: proc() -> Terminal {
    output_handle := win.GetStdHandle(win.STD_OUTPUT_HANDLE)
    input_handle  := win.GetStdHandle(win.STD_INPUT_HANDLE)

    // Enable virtual terminal sequences
    {
        buffer_mode: u32 = 0
        win.GetConsoleMode(output_handle, &buffer_mode);

        buffer_mode = buffer_mode | win.ENABLE_VIRTUAL_TERMINAL_PROCESSING
        win.SetConsoleMode(output_handle, buffer_mode)
    }

    // Enable input events
    {
        buffer_mode := win.ENABLE_WINDOW_INPUT | win.ENABLE_MOUSE_INPUT
        win.SetConsoleMode(input_handle, buffer_mode)
    }

    return Terminal { 
        output_handle = output_handle,
        input_handle  = input_handle,
    }
}


main :: proc() {
    terminal := create_terminal()

    // Hide cursor
    fmt.printf("\x1b[?25l")
    // Alternate buffer begin
    fmt.printf("\x1b[?1049h") 
    // Clear
    fmt.printf("\x1b[2J")


    is_running := true
    is_drawn := false
    for is_running {
        num_events: win.DWORD = 0
        local_win.GetNumberOfConsoleInputEvents(terminal.input_handle, &num_events)

        events_read: u32 = 0
        input_records: [32]local_win.INPUT_RECORD
        local_win.ReadConsoleInputW(terminal.input_handle, &input_records[0], num_events, &events_read)
    
        for input_record in input_records {
            switch(input_record.EventType){
                case local_win.KEY_EVENT:
                    key_event := input_record.Event.KeyEvent
                    if key_event.bKeyDown {
                        switch key_event.wVirtualKeyCode {
                            case 0x0D: // ENTER
                            case 0x25: // LEFT
                                if cursor_x > 11 {
                                    write_at(cursor_x, cursor_y, " ")
                                    cursor_x -= 4
                                }
                            case 0x26: // UP
                                if cursor_y > 8 {
                                    write_at(cursor_x, cursor_y, " ")
                                    cursor_y -= 2
                                }
                            case 0x27: // RIGHT
                                if cursor_x < 47 {
                                    write_at(cursor_x, cursor_y, " ")
                                    cursor_x += 4
                                }
                            case 0x28: // DOWN
                                if cursor_y < 26 {
                                    write_at(cursor_x, cursor_y, " ")
                                    cursor_y += 2
                                }
                        }
                    }
            }
        }

        if !is_drawn {
            // Player Board
            draw_board_outlines()
            is_drawn = true
        }

        write_at(cursor_x, cursor_y, "X")
    }

    // Alternate buffer end
    fmt.printf("\x1b[?1049l")
}



draw_board_outlines :: proc() {
    write_at(27, 4, "YOU")
    write_at(86, 4, "ENEMY")
    write_at(0, 6, "          1   2   3   4   5   6   7   8   9   10                      1   2   3   4   5   6   7   8   9   10\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      A |   |   |   |   |   |   |   |   |   |   |                 A |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" + 
                    "      B |   |   |   |   |   |   |   |   |   |   |                 B |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      C |   |   |   |   |   |   |   |   |   |   |                 C |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      D |   |   |   |   |   |   |   |   |   |   |                 D |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      E |   |   |   |   |   |   |   |   |   |   |                 E |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      F |   |   |   |   |   |   |   |   |   |   |                 F |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      G |   |   |   |   |   |   |   |   |   |   |                 G |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      H |   |   |   |   |   |   |   |   |   |   |                 H |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      I |   |   |   |   |   |   |   |   |   |   |                 I |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" +
                    "      J |   |   |   |   |   |   |   |   |   |   |                 J |   |   |   |   |   |   |   |   |   |   |\n" +
                    "        +---+---+---+---+---+---+---+---+---+---+                   +---+---+---+---+---+---+---+---+---+---+\n" )
}

write_at :: proc(x: int, y: int, text: string) {
    fmt.printf("\x1b[%d;%dH%s", y, x, text)
}