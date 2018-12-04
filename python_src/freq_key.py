import mmap
import os
import struct
import sys

def configure_fpga(frequency, tolerance, match_time_ms):
	with open("/dev/uio0", "w+") as f:
		mem = mmap.mmap(f.fileno(), 64)
		mem[0:4] = struct.pack("I", frequency)
		mem[4:8] = struct.pack("I", tolerance)
		mem[8:12] = struct.pack("I", match_time_ms)

def wait_for_match(callback):
	fd = os.open("/dev/uio0", os.O_RDONLY)
	while True:
		resp = os.read(fd, 4)
		callback()
	os.close(fd)

def found():
	print("Match! ")


def main():
	if len(sys.argv) < 4:
		print("Usage: python freq_key.py <frequency> <tolerance> <match_time>")
		exit(1)
	configure_fpga(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))

	while(True):
		wait_for_match(found)


if __name__ == '__main__':
	main()
