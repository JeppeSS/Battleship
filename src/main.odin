package main

import "core:fmt"
import win "core:sys/windows"


import local_win "windows"


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
        input_handle = input_handle,
    }
}


main :: proc() {
    terminal := create_terminal()
    is_running := true
    for is_running {
        num_events: win.DWORD = 0
        if( !local_win.GetNumberOfConsoleInputEvents(terminal.input_handle, &num_events)){
            // TODO[Jeppe]: Logging
            return 
        }
        events_read: u32 = 0
        input_records: [64]local_win.INPUT_RECORD
        if(!local_win.ReadConsoleInputW(terminal.input_handle, &input_records[0], num_events, &events_read)){
            // TODO[Jeppe]: Logging
            return
        }
    
        for input_record in input_records {
            switch(input_record.EventType){
                case local_win.KEY_EVENT: fmt.println("KEY EVENT")
            }
        }
    }
}