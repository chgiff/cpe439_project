import face_rec
import freq_key
import sys
import thread
import time

from threading import Thread

#global vars
face_match_time = 0
freq_match_time = 0

def face_matched():
	global face_match_time
	global freq_match_time
	print("Face match!")
	t = time.time()
	face_match_time = t
	if(t - freq_match_time < 10):
		print("Matched all!")
	

def freq_matched():
	global face_match_time
	global freq_match_time
	print("Frequency match!")
	t = time.time()
	freq_match_time = t
	if(t - face_match_time < 10):
		print("Match all!")

def main():
	if(len(sys.argv) < 5):
		print("Usage: <reference image> <frequency (Hz)> <frequency tolerance (Hz)> <frequency match time (ms)>")
		exit(1)
	ref_image = sys.argv[1]
	frequency = sys.argv[2]
	tolerance = sys.argv[3]
	match_time = sys.argv[4]

	freq_key.configure_fpga(int(frequency), int(tolerance), int(match_time))

	freq_thread = Thread(target=freq_key.wait_for_match, args=(freq_matched,))
	face_thread = Thread(target=face_rec.wait_for_face, args=(ref_image,face_matched,))
	freq_thread.daemon = True
	face_thread.daemon = True
	freq_thread.start()
	face_thread.start()


	print("Ready")	
	while True:
		pass	

	

if __name__=='__main__':
	main()
