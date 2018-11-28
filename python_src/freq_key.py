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

def wait_for_match():
	fd = os.open("/dev/uio0", os.O_RDONLY)
	resp = os.read(fd, 4)
	print("Match! " + str(struct.unpack("I", resp)))
	os.close(fd)


def main():
	if len(sys.argv) < 4:
		print("Usage: python freq_key.py <frequency> <tolerance> <match_time>")
		exit(1)
	configure_fpga(int(sys.argv[1]), int(sys.argv[2]), int(sys.argv[3]))

	while(True):
		wait_for_match()


if __name__ == '__main__':
	main()
