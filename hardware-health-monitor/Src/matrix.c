/**
 * @file        : matrix.c
 * @brief       : source file for the matrix operations
 *
 * Course       : CPE 2610
 * Section      : 131
 * Assignment   : Lab 12 - I2C
 * Author       : Jesse Rost <rostj@msoe.edu>
 * Date         : 04/14/26
 */

#include "matrix.h"
#include "stdint.h"
#include "stdio.h"
#include "stdlib.h"
#include "ina219.h"
#include "bme280.h"

uint8_t shadowBuffer[16] = { 0 };

void displayInit(void) {

	// send the oscillator command
	uint8_t cmd = OSCILLATOR;
	i2c_write(ht16k33_addr, 1, &cmd);

	// send the display command
	cmd = DISPLAY;
	i2c_write(ht16k33_addr, 1, &cmd);

	// send the brightness command
	cmd = MAX_BRIGHTNESS;
	i2c_write(ht16k33_addr, 1, &cmd);

	// clear the display
	uint8_t clear[17];

	// tells it where to start writing
	clear[0] = REG_STARTADDR;

	// clears the remaining 16 bits
	for (int i = 1; i < 17; i++) {
		clear[i] = 0;
	}
	// sends start position ayesnd the 16 bytes to write
	// initialization starts with all zeros, meaning that all LEDs are OFF
	i2c_write(ht16k33_addr, 17, clear);

}

void displayRefresh(uint8_t *buf) {
	uint8_t packet[17];
	// where to begin writing
	packet[0] = REG_STARTADDR;
	// copt everything forward from the bufer
	for (int i = 0; i < 16; i++) {
		packet[i + 1] = buf[i];
	}
	i2c_write(ht16k33_addr, 17, packet);
}

static int8_t char_to_glyph(char c) {
	if (c >= '0' && c <= '9') {
		return c - '0';
	}
	if (c == 'A') {
		return 10;
	}
	if (c == 'C') {
		return 11;
	}
	if (c == 'V') {
		return 12;
	}
	if (c == '.') {
		return 13;
	}
	return -1; // unknown character, return -1 to signal blank
}

void matrix_display_value(uint8_t metric_index, uint16_t voltage, int16_t current, int32_t temp) {
    // clear buffer
    for (int i = 0; i < 16; i++){
    	shadowBuffer[i] = 0;
    }

    char num_str[4] = {0};
    uint8_t unit = 0;
    uint8_t color = COLOR_GREEN;

    if (metric_index == 0) {
        sprintf(num_str, "%d.%d", voltage/1000, (voltage%1000)/100);
        unit = UNIT_V;
        color = (voltage > VGREEN_THRESH) ? COLOR_GREEN :
                (voltage >= VYELLOW_THRESH) ? COLOR_YELLOW : COLOR_RED;
    } else if (metric_index == 1) {
        sprintf(num_str, "%d", current);
        unit = UNIT_A;
        color = (current > CRED_THRESH) ? COLOR_RED :
                (current >= CYELLOW_THRESH) ? COLOR_YELLOW : COLOR_GREEN;
    } else {
        sprintf(num_str, "%d", (int)(temp/100));
        unit = UNIT_C;
        color = (temp > TRED_THRESH) ? COLOR_RED :
                (temp >= TYELLOW_THRESH) ? COLOR_YELLOW : COLOR_GREEN;
    }
    int buf_col_offset = 0;  // track current column position

    for (int ci = 0; ci < strlen(num_str); ci++) {
        if (num_str[ci] == '.') {
            // draw single pixel dot at bottom of number area
            int buf_row = 1;  // bottom of top half
            if (color == COLOR_GREEN)
                shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col_offset));
            else if (color == COLOR_RED)
                shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col_offset));
            else {
                shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col_offset));
                shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col_offset));
            }
            buf_col_offset += 1;  // only 1 columns wide for dot
            continue;
        }

        // normal character
        int8_t glyph = char_to_glyph(num_str[ci]);
        if (glyph < 0) continue;
        for (int col = 0; col < 3; col++) {
            uint8_t font_byte = font3x5[glyph][col];
            for (int row = 0; row < 5; row++) {
                if (font_byte & (1 << row)) {
                    int buf_row = 4 - row;
                    int buf_col = buf_col_offset + col;
                    if (buf_col < 8) {
                        if (color == COLOR_GREEN)
                            shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col));
                        else if (color == COLOR_RED)
                            shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col));
                        else {
                            shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col));
                            shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col));
                        }
                    }
                }
            }
        }
        buf_col_offset += 4;  // 3 cols + 0 gap
    }

    // right corner offset
    int unit_col_start = 5;

    // draw unit in bottom half (rows 5-7) using font3x3
    for (int col = 0; col < 3; col++) {
        uint8_t font_byte = font3x3[unit][col];
        for (int row = 0; row < 3; row++) {
            if (font_byte & (1 << row)) {
                int buf_row = 7 - row;  // bottom rows 5-7
                int buf_col = unit_col_start + col;
                if (color == COLOR_GREEN)
                    shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col));
                else if (color == COLOR_RED)
                    shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col));
                else {
                    shadowBuffer[buf_row * 2] |= (1 << (7 - buf_col));
                    shadowBuffer[buf_row * 2 + 1] |= (1 << (7 - buf_col));
                }
            }
        }
    }

    displayRefresh(shadowBuffer);
}

void matrix_bargraph(uint16_t voltage, int16_t current, int32_t temp) {
	// clear buffer at start
	for (int i = 0; i < 16; i++) {
		shadowBuffer[i] = 0;
	}

	// values converted to bar height
	uint8_t v_height = (voltage * 8) / 3600;
	uint8_t c_height = (current * 8) / 20;   // lowered max range
	uint8_t t_height = (temp * 8) / 8000;
	if (t_height > 8){
		t_height = 8;           // cap at 8
	}

	// values for columns
	uint8_t t_col_mask = 0xC0;
	uint8_t c_col_mask = 0x18;
	uint8_t v_col_mask = 0x03;

	// determine the column color based on the voltage
	uint8_t v_color;
	if (voltage > VGREEN_THRESH) {
		v_color = COLOR_GREEN;
	} else if (voltage >= VYELLOW_THRESH) {
		v_color = COLOR_YELLOW;
	} else {
		v_color = COLOR_RED;
	}

	// fill rows from bottom up into shadowbuffer for the voltage
	for (int row = 0; row < v_height; row++) {
		// bottom of display is row 7, so invert
		int buf_row = row;
		if (v_color == COLOR_GREEN) {
			shadowBuffer[buf_row * 2] |= (v_col_mask);
		} else if (v_color == COLOR_YELLOW) {
			shadowBuffer[buf_row * 2] |= (v_col_mask);
			shadowBuffer[buf_row * 2 + 1] |= (v_col_mask);
		} else if (v_color == COLOR_RED) {
			shadowBuffer[buf_row * 2 + 1] |= (v_col_mask);
		}
	}

	// determine the column color based on the current
	uint8_t c_color;
	if (current > CRED_THRESH) {
		c_color = COLOR_RED;
	} else if (current >= CYELLOW_THRESH) {
		c_color = COLOR_YELLOW;
	} else {
		c_color = COLOR_GREEN;
	}

	// fill rows from bottom up into shadowbuffer for the current
	for (int row = 0; row < c_height; row++) {
		// bottom of display is row 7, so invert
		int buf_row = row;
		if (c_color == COLOR_GREEN) {
			shadowBuffer[buf_row * 2] |= (c_col_mask);
		} else if (c_color == COLOR_YELLOW) {
			shadowBuffer[buf_row * 2] |= (c_col_mask);
			shadowBuffer[buf_row * 2 + 1] |= (c_col_mask);
		} else if (c_color == COLOR_RED) {
			shadowBuffer[buf_row * 2 + 1] |= (c_col_mask);
		}
	}

	// determine the column color based on the temp
	uint8_t t_color;
	if (temp > TRED_THRESH) {
		t_color = COLOR_RED;
	} else if (temp >= TYELLOW_THRESH) {
		t_color = COLOR_YELLOW;
	} else {
		t_color = COLOR_GREEN;
	}

	// fill rows from bottom up into shadowbuffer for the temp
	for (int row = 0; row < t_height; row++) {
		// bottom of display is row 7, so invert
		int buf_row = row;
		if (t_color == COLOR_GREEN) {
			shadowBuffer[buf_row * 2] |= (t_col_mask);
		} else if (t_color == COLOR_YELLOW) {
			shadowBuffer[buf_row * 2] |= (t_col_mask);
			shadowBuffer[buf_row * 2 + 1] |= (t_col_mask);
		} else if (t_color == COLOR_RED) {
			shadowBuffer[buf_row * 2 + 1] |= (t_col_mask);
		}
	}

    displayRefresh(shadowBuffer);
}

