#ifndef __DUO_DL645_H__
#define __DUO_DL645_H__
/*      
 *  Copyright (C) 2014
 *      "Mu Lei" known as "NalaGinrut" <NalaGinrut@gmail.com>
 
 *  Duo is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 
 *  Duo is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdint.h>
#include <malloc.h>

#define DL645_PREFIX     0x68
#define DL645_END        0x16
#define DL645_TR_PREFIX  0xFE
#define DL645_DATA_MAX   200
#define DL645_ADDR_MAX   6

#define DL645_IS_START(x) (DL645_PREFIX == (x))
#define DL645_IS_END(x) (DL645_END == (x))

typedef struct DL645_Frame
{
  uint8_t addr[DL645_ADDR_MAX];
  uint8_t data[DL645_DATA_MAX];
  uint8_t data_length;
  uint8_t ctrl;
  uint8_t cs;
} dl645_frame_t;

// Functional code
#define DL645_RESERVE   0x00
#define DL645_MC_ADJT   0x08  // b01000
#define DL645_READ      0x11  // b10001
#define DL645_READ_SUC  0x12  // b10010
#define DL645_READ_ADR  0x13  // b10011
#define DL645_WRITE     0x14  // b10100
#define DL645_WRITE_ADR 0x15  // b10101
#define DL645_FREEZE    0x16  // b10110
#define DL645_SET_BRATE 0x17  // b10111
#define DL645_SET_PASS  0x18  // b11000
#define DL645_MREQ_CLR  0x19  // b11001
#define DL645_EMTR_CLR  0x1A  // b11010
#define DL645_EVENT_CLR 0x1B  // b11011

// Succeed pred
#define DL645_NO_SUCC  0x0
#define DL645_HAS_SUCC 0x1

// Slave ACK
#define DL645_SLV_ACK 0x0
#define DL645_SLV_SUC 0x1

// Direction
#define DL645_FROM_MAS 0x0
#define DL645_FROM_SLV 0x1

static void DL645_get_addr(dl645_port_t, dl645_frame_t*) always_inline;
static void DL645_get_length(dl645_port_t, dl645_frame_t*) always_inline;
static void DL645_get_ctrl(dl645_port_t, dl645_frame_t*) always_inline;
static void DL645_read_data(dl645_port_t, dl645_frame_t*) always_inline;
static void DL645_write_data(dl645_port_t, dl645_frame_t*) always_inline;          static void DL645_get_cs(dl645_port_t, dl645_frame_t*) always_inline;            
static void DL645_prepare_trans(dl645_port_t) always_inline;
static void DL645_is_valid_frame(dl645_frame_t*) always_inline;
static void DL645_drop_frame(dl645_frame_t*) always_inline;
                                              
static void DL645_get_addr(dl645_port_t port, dl645_frame_t* frame)
{
  __read_bytes(frame->addr, port, 6);
  assert(DL645_IS_START(__read_byte(port)));
}

/*
 * Get length of data field.
 * When reading: length <= 200
 * When writing: length <= 50
 * Null data: length == 0
 */
static void DL645_get_length(dl645_port_t port, dl645_frame_t* frame)
{
  frame->data_length = (uint8_t)__read_byte(port);
}

static void DL645_get_ctrl(dl645_port_t port, dl645_frame_t* frame)
{
  frame->ctrl = __read_byte(port);
}

static void DL645_read_data(dl645_port_t port, dl645_frame_t* frame)
{
  assert(frame->data_length <= 200);
  __read_bytes(frame->data, port, frame->data_length);
}

static void DL645_write_data(dl645_port_t port, dl645_frame_t* frame)
{
  assert(frame->data_length <= 50);
  __write_bytes(port, frame->data, frame->data_length);
}

static void DL645_get_cs(dl645_port_t port, dl645_frame_t* frame)
{
  frame->cs = __read_byte(port);
}

static void DL645_prepare_trans(dl645_port_t port)
{
  int i = 4;
  while(i-- > 0)
    __write_byte(port, DL645_TR_PREFIX);
}

static void DL645_is_valid_frame(dl645_frame_t* frame)
{
  // TODO: check the cs
}

static void DL645_drop_frame(dl645_frame_t* frame)
{
  printf("Invalid frame, drop it!\n");
  free(frame);
}

static dl645_frame_t DL645_read_frame(dl645_port_t port)
{
  dl645_frame_t* frame = (dl645_frame_t*)malloc(sizeof(dl645_frame_t));

  while(!DL645_IS_START(__read_byte(port)))
    ;

  // NOTE: Keep this order!
  DL645_get_addr(port, frame);
  DL645_get_ctrl(port, frame);
  DL645_get_length(port, frame);
  DL645_read_data(port, frame);
  DL645_get_cs(port, frame);
  assert(DL645_IS_END(__read_byte(port)));

  if(DL645_is_valid_frame(frame))
    return frame;

  // CS check failed, drop this frame and return NULL
  DL645_drop_frame(frame);
  return NULL;
}

#endif // End of __DUO_DL645_H__
