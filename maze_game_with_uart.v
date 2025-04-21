`timescale 1ns / 1ps

module maze_game_with_uart (
    input clk,                 // FPGA ana saat sinyali (50 MHz)
    input uart_rx,             // UART giriş (RX)
    input [5:0] switches,      // FPGA üzerindeki switchler
    input mode_select,         // 0: Switch ile oynama, 1: UART ile oynama
    output hsync,              // VGA yatay senkronizasyon sinyali
    output vsync,              // VGA dikey senkronizasyon sinyali
    output [3:0] r, g, b,      // VGA renk sinyalleri (RGB)
    output reg [7:0] led,      // FPGA üzerindeki LED çıkışları
    output [6:0] seg,          // Seven-segment display segment sinyalleri
    output [3:0] anode         // Seven-segment display anode kontrolü
);

    // 1. Labirent parametreleri
    parameter CELL_SIZE = 32;       // Her hücre 32x32 piksel
    parameter GRID_WIDTH = 20;      // 20 sütun
    parameter GRID_HEIGHT = 15;     // 15 satır

    // Labirent ve oyuncu konumları
    reg [5:0] maze[0:299];          // Tek boyutlu dizi (15 x 20 = 300 hücre)
    reg [4:0] player_x = 1;         // Oyuncunun başlangıç sütunu
    reg [4:0] player_y = 1;         // Oyuncunun başlangıç satırı
    parameter goal_x = 18;          // Oyunun hedef sütunu
    parameter goal_y = 13;          // Oyunun hedef satırı

    // 2. Süre hesaplama
    reg [31:0] timer_counter = 0;   // Sayaç (50 MHz için)
    reg [15:0] elapsed_seconds = 0; // Toplam süre (saniye)
    reg game_completed = 1;         // Oyun bitiş durumu
    
    


    

    // 3. VGA zamanlama sinyalleri
    reg [9:0] h_count = 0;          // Yatay piksel sayacı
    reg [9:0] v_count = 0;          // Dikey piksel sayacı
    reg clk_25mhz = 0;              // VGA i?in 25 MHz saat sinyali
    reg clk_50mhz = 0;

    always @(posedge clk) begin
        clk_50mhz <= ~clk_50mhz;
    end
    
    always @(posedge clk_50mhz)begin
        clk_25mhz <= ~clk_25mhz;
    end
    always @(posedge clk_25mhz) begin
        if (h_count < 799)
            h_count <= h_count + 1;
        else begin
            h_count <= 0;
            if (v_count < 524)
                v_count <= v_count + 1;
            else
                v_count <= 0;
        end
    end

    assign hsync = (h_count >= 656 && h_count < 752);  // VGA yatay senkronizasyon
    assign vsync = (v_count >= 490 && v_count < 492);  // VGA dikey senkronizasyon

    wire display_active = (h_count < 640 && v_count < 480);

    // VGA renk çıkışı

assign r = (display_active && maze[(v_count / CELL_SIZE) * GRID_WIDTH + (h_count / CELL_SIZE)] == 1) ? 4'b1111 : 
           (display_active && h_count/CELL_SIZE == goal_x && v_count/CELL_SIZE == goal_y) ? 4'b0000 :
           (display_active && player_x == h_count/CELL_SIZE && player_y == v_count/CELL_SIZE) ? 4'b1111 : 4'b0000;

assign g = (display_active && maze[(v_count / CELL_SIZE) * GRID_WIDTH + (h_count / CELL_SIZE)] == 1) ? 4'b1111 : 
           (display_active && h_count/CELL_SIZE == goal_x && v_count/CELL_SIZE == goal_y) ? 4'b1111 :
           (display_active && player_x == h_count/CELL_SIZE && player_y == v_count/CELL_SIZE) ? 4'b0000 : 4'b0000;

assign b = (display_active && maze[(v_count / CELL_SIZE) * GRID_WIDTH + (h_count / CELL_SIZE)] == 1) ? 4'b1111 : 
           (display_active && h_count/CELL_SIZE == goal_x && v_count/CELL_SIZE == goal_y) ? 4'b0000 :
           (display_active && player_x == h_count/CELL_SIZE && player_y == v_count/CELL_SIZE) ? 4'b0000 : 4'b0000;

    // 4. Oyuncu hareket sinyalleri
    reg move_up = 0, move_down = 0, move_left = 0, move_right = 0;

    // UART alıcı modülü
    wire [7:0] uart_data;        // UART'dan alınan veri
    wire uart_ready;             // UART'dan yeni veri geldi sinyali
    uart_receiver uart_rx_mod (
        .clk(clk),
        .rx(uart_rx),
        .data(uart_data),
        .data_ready(uart_ready)
    );

    // Giriş seçim mantığı
    always @(posedge clk) begin
        if (switches[5]) begin
            if (uart_ready) begin
                case (uart_data)
                    8'h57: move_up <= 1;    // "W" tuşu
                    8'h53: move_down <= 1;  // "S" tuşu
                    8'h41: move_left <= 1;  // "A" tuşu
                    8'h44: move_right <= 1; // "D" tuşu
                    default: begin
                        move_up <= 0;
                        move_down <= 0;
                        move_left <= 0;
                        move_right <= 0;
                    end
                endcase
            end
        end
         else begin
            move_up <= switches[3];
            move_down <= switches[2];
            move_left <= switches[1];
            move_right <= switches[0];
        end
    end

    // 5. Oyuncu hareketi ve çarpışma kontrolü

always @(posedge clk) begin
    if(switches[4] & game_completed) begin
        player_x <= 1;
        player_y <= 1;
        game_completed <= 0;
        timer_counter <= 0;
        elapsed_seconds <= 0;
    end
    else begin
        if (!game_completed) begin
            // Movement logic
            if (move_up && maze[(player_y - 1) * GRID_WIDTH + player_x] == 0)
                player_y <= player_y - 1;
            else if (move_down && maze[(player_y + 1) * GRID_WIDTH + player_x] == 0)
                player_y <= player_y + 1;
            else if (move_left && maze[player_y * GRID_WIDTH + (player_x - 1)] == 0)
                player_x <= player_x - 1;
            else if (move_right && maze[player_y * GRID_WIDTH + (player_x + 1)] == 0)
                player_x <= player_x + 1;
                
            // Timer logic
            if (!switches[4]) begin
                timer_counter <= timer_counter + 1;
                if (timer_counter == 100000000) begin
                    elapsed_seconds <= elapsed_seconds + 1;
                    timer_counter <= 0;
                end
            end
            
            // Check for goal
            if (player_x == goal_x && player_y == goal_y)
                game_completed <= 1;
        end
    end
end
// LED control in separate block
always @(posedge clk) begin
    led <= game_completed ? 8'b00001111 : 8'b11111111;
end
    
    

    // 6. Seven-Segment Display Kontrolü
    reg [15:0] display_value = 0;
    always @(posedge clk) begin
        if (game_completed)
            display_value <= elapsed_seconds;
        else
            display_value <= elapsed_seconds;
    end
    

    seven_segment_display_controller seg_ctrl (
        .clk(clk),
        .value(display_value),
        .seg(seg),
        .anode(anode)
    );

    // 7. Labirent başlangıç durumu
    integer i;
    initial begin
            // 1. Satır (tamamen duvar)
    maze[0]  = 1; maze[1]  = 1; maze[2]  = 1; maze[3]  = 1; maze[4]  = 1;
    maze[5]  = 1; maze[6]  = 1; maze[7]  = 1; maze[8]  = 1; maze[9]  = 1;
    maze[10] = 1; maze[11] = 1; maze[12] = 1; maze[13] = 1; maze[14] = 1;
    maze[15] = 1; maze[16] = 1; maze[17] = 1; maze[18] = 1; maze[19] = 1;

    // 2. Satır (oyuncu başlangıç yolu)
    maze[20] = 1; maze[21] = 0; maze[22] = 0; maze[23] = 0; maze[24] = 0;
    maze[25] = 0; maze[26] = 0; maze[27] = 0; maze[28] = 0; maze[29] = 1;
    maze[30] = 1; maze[31] = 1; maze[32] = 1; maze[33] = 1; maze[34] = 1;
    maze[35] = 1; maze[36] = 1; maze[37] = 1; maze[38] = 1; maze[39] = 1;

    // 3. Satır
    maze[40] = 1; maze[41] = 0; maze[42] = 1; maze[43] = 1; maze[44] = 1;
    maze[45] = 0; maze[46] = 1; maze[47] = 1; maze[48] = 0; maze[49] = 0;
    maze[50] = 0; maze[51] = 0; maze[52] = 0; maze[53] = 0; maze[54] = 0;
    maze[55] = 0; maze[56] = 0; maze[57] = 0; maze[58] = 1; maze[59] = 1;

    // 4. Satır
    maze[60] = 1; maze[61] = 0; maze[62] = 1; maze[63] = 0; maze[64] = 1;
    maze[65] = 0; maze[66] = 0; maze[67] = 0; maze[68] = 0; maze[69] = 1;
    maze[70] = 1; maze[71] = 1; maze[72] = 1; maze[73] = 1; maze[74] = 1;
    maze[75] = 1; maze[76] = 1; maze[77] = 0; maze[78] = 1; maze[79] = 1;

    // 5. Satır
    maze[80] = 1; maze[81] = 0; maze[82] = 1; maze[83] = 0; maze[84] = 1;
    maze[85] = 1; maze[86] = 1; maze[87] = 1; maze[88] = 0; maze[89] = 1;
    maze[90] = 1; maze[91] = 0; maze[92] = 0; maze[93] = 0; maze[94] = 0;
    maze[95] = 0; maze[96] = 0; maze[97] = 0; maze[98] = 1; maze[99] = 1;

    // 6. Satır
    maze[100] = 1; maze[101] = 0; maze[102] = 0; maze[103] = 0; maze[104] = 1;
    maze[105] = 0; maze[106] = 1; maze[107] = 1; maze[108] = 0; maze[109] = 1;
    maze[110] = 1; maze[111] = 0; maze[112] = 1; maze[113] = 1; maze[114] = 1;
    maze[115] = 1; maze[116] = 1; maze[117] = 0; maze[118] = 1; maze[119] = 1;

    // 7. Satır
    maze[120] = 1; maze[121] = 1; maze[122] = 1; maze[123] = 0; maze[124] = 1;
    maze[125] = 0; maze[126] = 1; maze[127] = 1; maze[128] = 0; maze[129] = 1;
    maze[130] = 1; maze[131] = 0; maze[132] = 1; maze[133] = 0; maze[134] = 0;
    maze[135] = 0; maze[136] = 0; maze[137] = 0; maze[138] = 0; maze[139] = 1;

    // 8. Satır
    maze[140] = 1; maze[141] = 1; maze[142] = 1; maze[143] = 0; maze[144] = 0;
    maze[145] = 0; maze[146] = 0; maze[147] = 0; maze[148] = 0; maze[149] = 0;
    maze[150] = 0; maze[151] = 0; maze[152] = 1; maze[153] = 1; maze[154] = 1;
    maze[155] = 1; maze[156] = 1; maze[157] = 0; maze[158] = 1; maze[159] = 1;

    // 9. Satır (tamamen duvar)
    maze[160] = 1; maze[161] = 1; maze[162] = 1; maze[163] = 0; maze[164] = 1;
    maze[165] = 1; maze[166] = 1; maze[167] = 1; maze[168] = 1; maze[169] = 1;
    maze[170] = 1; maze[171] = 1; maze[172] = 1; maze[173] = 1; maze[174] = 1;
    maze[175] = 1; maze[176] = 1; maze[177] = 0; maze[178] = 1; maze[179] = 1;

    // 10. - 15. Satır (örnek yollar ve hedef alan)
    maze[180] = 1; maze[181] = 1; maze[182] = 1; maze[183] = 0; maze[184] = 1;
    maze[185] = 1; maze[186] = 1; maze[187] = 1; maze[188] = 1; maze[189] = 0;
    maze[190] = 1; maze[191] = 1; maze[192] = 0; maze[193] = 0; maze[194] = 1;
    maze[195] = 1; maze[196] = 1; maze[197] = 0; maze[198] = 1; maze[199] = 1;
    maze[200] = 1; maze[201] = 1; maze[202] = 1; maze[203] = 0; maze[204] = 1;
    maze[205] = 1; maze[206] = 1; maze[207] = 0; maze[208] = 0; maze[209] = 0;
    maze[210] = 0; maze[211] = 0; maze[212] = 0; maze[213] = 1; maze[214] = 1;
    maze[215] = 1; maze[216] = 0; maze[217] = 0; maze[218] = 1; maze[219] = 1;
    maze[220] = 1; maze[221] = 1; maze[222] = 1; maze[223] = 0; maze[224] = 0;
    maze[225] = 0; maze[226] = 0; maze[227] = 0; maze[228] = 1; maze[229] = 1;
    maze[230] = 1; maze[231] = 1; maze[232] = 1; maze[233] = 1; maze[234] = 1;
    maze[235] = 0; maze[236] = 0; maze[237] = 1; maze[238] = 1; maze[239] = 1;
    maze[240] = 1; maze[241] = 1; maze[242] = 1; maze[243] = 1; maze[244] = 1;
    maze[245] = 1; maze[246] = 1; maze[247] = 0; maze[248] = 0; maze[249] = 0;
    maze[250] = 0; maze[251] = 0; maze[252] = 0; maze[253] = 0; maze[254] = 0;
    maze[255] = 0; maze[256] = 1; maze[257] = 1; maze[258] = 1; maze[259] = 1;
    maze[260] = 1; maze[261] = 1; maze[262] = 1; maze[263] = 1; maze[264] = 1;
    maze[265] = 1; maze[266] = 1; maze[267] = 1; maze[268] = 1; maze[269] = 1;
    maze[270] = 1; maze[271] = 1; maze[272] = 1; maze[273] = 1; maze[274] = 1;
    maze[275] = 0; maze[276] = 0; maze[277] = 0; maze[278] = 0; maze[279] = 1; 

    // Son satır (tamamen duvar)
    maze[280] = 1; maze[281] = 1; maze[282] = 1; maze[283] = 1; maze[284] = 1;
    maze[285] = 1; maze[286] = 1; maze[287] = 1; maze[288] = 1; maze[289] = 1;
    maze[290] = 1; maze[291] = 1; maze[292] = 1; maze[293] = 1; maze[294] = 1;
    maze[295] = 1; maze[296] = 1; maze[297] = 1; maze[298] = 1; maze[299] = 1;
    end

endmodule

// UART Alıcı Modülü
module uart_receiver (
    input clk,
    input rx,
    output reg [7:0] data,
    output reg data_ready
);
    parameter CLK_FREQ = 100000000;
    parameter BAUD_RATE = 9600;
    localparam BIT_PERIOD = CLK_FREQ / BAUD_RATE;

    reg [15:0] bit_counter = 0;
    reg [3:0] bit_index = 0;
    reg [9:0] rx_shift_reg = 10'b0;
    reg rx_sync = 1;
    reg rx_start = 0;

    always @(posedge clk) begin
        rx_sync <= rx;
        if (!rx_start && !rx_sync) begin
            rx_start <= 1;
            bit_counter <= BIT_PERIOD / 2;
            bit_index <= 0;
        end

        if (rx_start) begin
            if (bit_counter == BIT_PERIOD - 1) begin
                bit_counter <= 0;
                rx_shift_reg <= {rx_sync, rx_shift_reg[9:1]};
                bit_index <= bit_index + 1;

                if (bit_index == 9) begin
                    data <= rx_shift_reg[8:1];
                    data_ready <= 1;
                    rx_start <= 0;
                end
            end else begin
                bit_counter <= bit_counter + 1;
            end
        end else begin
            data_ready <= 0;
        end
    end
endmodule

// Seven-Segment Display Controller Modülü
module seven_segment_display_controller (
    input clk,
    input [15:0] value,
    output reg [6:0] seg,
    output reg [3:0] anode
);
    reg [3:0] digit;
    reg [19:0] refresh_counter = 0;
    reg [1:0] active_digit = 0;
    reg [7:0] minutes;
    reg [7:0] seconds;

    always @(*) begin
        minutes = value / 60;
        seconds = value % 60;
    end

    always @(posedge clk) begin
        refresh_counter <= refresh_counter + 1;
        if (refresh_counter == 50000) begin
            active_digit <= active_digit + 1;
            refresh_counter <= 0;
        end
    end

     always @(*) begin
        case (active_digit)
            2'b00: begin
                anode = 4'b1110;
                digit = seconds % 10;      // Seconds ones
            end
            2'b01: begin
                anode = 4'b1101;
                digit = seconds / 10;      // Seconds tens
            end
            2'b10: begin
                anode = 4'b1011;
                digit = minutes % 10;      // Minutes ones
            end
            2'b11: begin
                anode = 4'b0111;
                digit = minutes / 10;      // Minutes tens
            end
        endcase
    end

    always @(*) begin
        case (digit)
            4'b0000: seg = 7'b1000000;
            4'b0001: seg = 7'b1111001;
            4'b0010: seg = 7'b0100100;
            4'b0011: seg = 7'b0110000;
            4'b0100: seg = 7'b0011001;
            4'b0101: seg = 7'b0010010;
            4'b0110: seg = 7'b0000010;
            4'b0111: seg = 7'b1111000;
            4'b1000: seg = 7'b0000000;
            4'b1001: seg = 7'b0010000;
            default: seg = 7'b1111111;
        endcase
    end
endmodule
