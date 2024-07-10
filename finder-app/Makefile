# This function was partially generated using ChatGPT at https://chat.openai.com/ with prompts including 
# "How to make Makefile".

CC = gcc

ifdef CROSS_COMPILE
CC = $(CROSS_COMPILE)gcc
endif

CFLAGS = -Wall -Werror -g

TARGET = writer

SRCS = writer.c 
OBJS = $(SRCS:.c=.o)

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) $(TARGET)
	
.PHONY: all clean
